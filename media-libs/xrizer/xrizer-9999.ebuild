# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MULTILIB=1
RUST_MIN_VER="1.83.0"
inherit cargo git-r3 multilib-minimal

DESCRIPTION="OpenVR over OpenXR compatibility layer"
HOMEPAGE="https://github.com/Supreeeme/xrizer/"
EGIT_REPO_URI="https://github.com/Supreeeme/xrizer.git"

LICENSE="GPL-3+"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD Boost-1.0 ISC MIT OFL-1.1 UbuntuFontLicense-1.0
	Unicode-3.0 ZLIB
"
SLOT="0"

BDEPEND="media-libs/shaderc"

src_unpack() {
	git-r3_src_unpack
	cd "${S}" || die
	cargo_live_src_unpack
}

src_prepare() {
	default
	multilib_copy_sources
}

multilib_src_compile() {
	cargo_src_compile
}

multilib_src_install() {
	# OpenVR expects this particular directory structure.
	exeinto "/opt/${PN}/bin$(multilib_is_native_abi && echo /linux64)"
	newexe "$(cargo_target_dir)"/libxrizer.so vrclient.so
	touch "${ED}/opt/${PN}/version.txt"
}
