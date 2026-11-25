# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

"""Build offline VRCX-0 distfiles from the pinned upstream locks."""

import argparse
import base64
from concurrent.futures import ThreadPoolExecutor
import hashlib
import hmac
import json
from pathlib import Path
import shutil
import subprocess
import tarfile
from tempfile import TemporaryDirectory
import tomllib
from urllib.parse import urlsplit
from urllib.request import urlopen

CRATES_IO = "registry+https://github.com/rust-lang/crates.io-index"
NPM_TARGET = {"os": "linux", "cpu": "x64", "libc": "glibc"}


def download(url, destination, algorithm, expected):
    with urlopen(url, timeout=90) as response, destination.open("wb") as output:
        shutil.copyfileobj(response, output)
    with destination.open("rb") as stream:
        actual = hashlib.file_digest(stream, algorithm).digest()
    if not hmac.compare_digest(actual, expected):
        raise ValueError(f"{url}: {algorithm} does not match the pinned digest")


def cargo_packages(lock):
    packages = {}
    for package in lock["package"]:
        if "source" not in package:
            continue
        name, version = package["name"], package["version"]
        key = f"{name}-{version}"
        if package["source"] != CRATES_IO or key in packages:
            raise ValueError(f"Unexpected Cargo package: {package}")
        url = f"https://static.crates.io/crates/{name}/{key}.crate"
        packages[key] = (url, package["checksum"])
    return packages


def npm_packages(lock):
    if lock["lockfileVersion"] != 3:
        raise ValueError("Expected npm lockfile version 3")
    packages = {}
    for key, package in lock["packages"].items():
        if "resolved" not in package:
            if key and not package.get("inBundle"):
                raise ValueError(f"Missing npm resolved URL: {key}")
            continue
        if any(v.startswith("!") for k in NPM_TARGET for v in package.get(k, ())):
            raise ValueError(f"Unsupported negative npm platform selector: {key}")
        if any(package.get(k) and v not in package[k] for k, v in NPM_TARGET.items()):
            continue
        url, integrity = package["resolved"], package["integrity"]
        location = urlsplit(url)
        if (location.scheme, location.netloc) != ("https", "registry.npmjs.org") or not integrity.startswith("sha512-"):
            raise ValueError(f"Unpinned npm archive or unexpected registry: {key}")
        segments = location.path.lstrip("/").split("/")
        scope = segments[0][1:] + "-" if segments[0].startswith("@") else ""
        filename = f"npm-{scope}{segments[-1]}"
        entry = (url, integrity)
        if not filename.endswith(".tgz") or packages.setdefault(filename, entry) != entry:
            raise ValueError(f"Invalid or conflicting npm archive name: {url} -> {filename}")
    return packages


def make_bundles(source, output, package, commit, source_sha256):
    with source.open("rb") as stream:
        if hashlib.file_digest(stream, "sha256").hexdigest() != source_sha256:
            raise ValueError(f"{source}: upstream archive SHA-256 mismatch")
    with tarfile.open(source) as archive:
        root = f"VRCX-0-{commit}"
        crates = cargo_packages(tomllib.loads(archive.extractfile(f"{root}/Cargo.lock").read().decode()))
        npm = npm_packages(json.load(archive.extractfile(f"{root}/package-lock.json")))
    if (len(crates), len(npm)) != (1014, 531):
        raise ValueError(f"Unexpected lockfile counts: {len(crates)} Cargo, {len(npm)} npm")

    output.mkdir(parents=True, exist_ok=True)
    with TemporaryDirectory() as scratch:
        work = Path(scratch)
        (work / "vendor").mkdir()
        (work / "npm-distfiles").mkdir()

        def vendor_crate(entry):
            key, (url, checksum) = entry
            distfile = work / f"{key}.crate"
            download(url, distfile, "sha256", bytes.fromhex(checksum))
            with tarfile.open(distfile) as archive:
                archive.extractall(work / "vendor", filter="data")
            distfile.unlink()
            # Cargo checks this package digest against Cargo.lock, like cargo.eclass.
            (work / "vendor" / key / ".cargo-checksum.json").write_text(
                json.dumps({"package": checksum, "files": {}}) + "\n", encoding="utf-8"
            )

        def fetch_npm(entry):
            filename, (url, integrity) = entry
            expected = base64.b64decode(integrity.removeprefix("sha512-"), validate=True)
            download(url, work / "npm-distfiles" / filename, "sha512", expected)

        with ThreadPoolExecutor(max_workers=12) as executor:
            for _ in executor.map(vendor_crate, crates.items()):
                pass
            for _ in executor.map(fetch_npm, npm.items()):
                pass

        tar_options = ["tar", "--sort=name", "--mtime=@0", "--owner=0", "--group=0", "--numeric-owner"]
        subprocess.run(
            [*tar_options, "-I", "xz -T2 -3", "-cf", output / f"{package}-cargo.tar.xz", "vendor"],
            cwd=work, check=True,
        )
        # Keep the exact tgz bytes: npm ci looks up these blobs by SRI digest.
        subprocess.run(
            [*tar_options, "-cf", output / f"{package}-npm-linux-x64-gnu.tar", "npm-distfiles"],
            cwd=work, check=True,
        )
    print(f"Bundled {len(crates)} lock-verified Cargo crates and {len(npm)} lock-verified npm tarballs.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--package", required=True)
    parser.add_argument("--commit", required=True)
    parser.add_argument("--source-sha256", required=True)
    args = parser.parse_args()
    make_bundles(args.source, args.output.resolve(), args.package, args.commit, args.source_sha256)


if __name__ == "__main__":
    main()
