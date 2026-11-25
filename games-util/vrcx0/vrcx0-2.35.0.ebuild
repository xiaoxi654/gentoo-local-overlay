# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( {20..23} )
RUST_MIN_VER="1.95.0"
inherit llvm-r2 cargo desktop xdg

DESCRIPTION="Desktop companion for VRChat"
HOMEPAGE="https://github.com/Map1en/VRCX-0"
DEPS_URI="https://github.com/xiaoxi654/gentoo-local-overlay/releases/download/${P}-deps-v2"
SRC_URI="
	https://github.com/Map1en/VRCX-0/archive/refs/tags/v${PV}.tar.gz -> ${P}-source.tar.gz
	${DEPS_URI}/${P}-cargo.tar.xz
	${DEPS_URI}/${P}-node-modules-linux-x64-gnu.tar.xz
"
S="${WORKDIR}/VRCX-0-${PV}"

LICENSE="
	GPL-3 MIT 0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2
	Boost-1.0 CC0-1.0 CDLA-Permissive-2.0 IJG ISC MPL-2.0 OFL-1.1
	UoI-NCSA Unicode-3.0 ZLIB public-domain
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="abi_x86_64 +lto +thinlto"
REQUIRED_USE="abi_x86_64 elibc_glibc thinlto? ( lto )"

BDEPEND="
	dev-build/cmake
	>=net-libs/nodejs-24.15.0[npm]
	virtual/pkgconfig
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
		llvm-core/llvm:${LLVM_SLOT}
	')
"
DEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/glib:2
	media-libs/fontconfig:1.0
	net-libs/libsoup:3.0[ssl]
	net-libs/webkit-gtk:4.1[X,wayland]
	sys-apps/dbus
	sys-devel/gcc:*
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X,wayland]
	x11-libs/libX11
	x11-libs/pango
"
RDEPEND="
	${DEPEND}
	app-misc/ca-certificates
	dev-libs/libayatana-appindicator
	x11-misc/xdg-utils
	x11-themes/hicolor-icon-theme
"

PATCHES=( "${FILESDIR}/${P}-portable-amd64.patch" )

ECARGO_VENDOR="${WORKDIR}/vendor"

pkg_setup() {
	llvm-r2_pkg_setup
	rust_pkg_setup
	if [[ ${MERGE_TYPE} != binary ]]; then
		LIBCLANG_PATH=$("$(get_llvm_prefix -b)/bin/llvm-config" --libdir) || die
		export LIBCLANG_PATH
	fi
}

src_prepare() {
	# cargo_src_unpack extracts the frontend dependency tree into WORKDIR.
	mv "${WORKDIR}/node_modules" "${S}/node_modules" || die
	default
}

src_configure() {
	# Apply the same packaging settings to compilation and tests.
	export VRCX_0_DISABLE_UPDATE_CHECK=1
	if use thinlto; then
		export CARGO_PROFILE_RELEASE_LTO=thin
	else
		export CARGO_PROFILE_RELEASE_LTO=$(usex lto fat off)
	fi
	export CARGO_PROFILE_RELEASE_STRIP=none
	export AWS_LC_SYS_USE_SYSTEM=0

	# Embed dist/ instead of using the development server from tauri.conf.json.
	cargo_src_configure --frozen --features tauri/custom-protocol
}

src_compile() {
	node --input-type=commonjs -e 'for (const name of process.argv.slice(1)) require(name)' \
		@rolldown/binding-linux-x64-gnu @tailwindcss/oxide-linux-x64-gnu lightningcss-linux-x64-gnu || die

	npm run build || die
	[[ -s dist/index.html && -s src-tauri/resources/licenses/THIRD_PARTY_NOTICES.txt ]] || die
	node --input-type=commonjs -e '
		const manifest = require("./dist/licenses/third-party-licenses.json");
		if (!manifest.entries.some(entry => entry.sourceType === "rust")) process.exit(1);
	' || die

	cargo_src_compile --package vrcx-0 --bin vrcx-0
}

src_test() {
	cargo_src_test --package vrcx-0 --test backend_architecture
}

src_install() {
	dobin "$(cargo_target_dir)/vrcx-0"

	# Tauri resolves resources relative to the executable via ../lib/VRCX-0.
	insinto /usr/lib/VRCX-0
	doins LICENSE
	insinto /usr/lib/VRCX-0/LICENSES
	doins LICENSES/MIT.txt
	insinto /usr/lib/VRCX-0/licenses
	doins src-tauri/resources/licenses/THIRD_PARTY_NOTICES.txt
	newdoc "${ECARGO_VENDOR}/openvr_sys-2.1.4/openvr/LICENSE" OPENVR-LICENSE
	dodoc README.md NOTICE

	domenu "${FILESDIR}/VRCX-0.desktop"
	newicon -s 32 src-tauri/icons/32x32.png vrcx-0.png
	newicon -s 128 src-tauri/icons/128x128.png vrcx-0.png
	newicon -s 256 src-tauri/icons/128x128@2x.png vrcx-0.png
}
