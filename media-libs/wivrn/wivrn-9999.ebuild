# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit cmake-multilib flag-o-matic git-r3 python-any-r1 xdg

DESCRIPTION="WiVRn OpenXR streaming"
HOMEPAGE="https://github.com/WiVRn/WiVRn"
EGIT_REPO_URI="https://github.com/WiVRn/WiVRn.git"
EGIT_BRANCH="sapphire/solarxr-rewrite"
EGIT_MIN_CLONE_TYPE="single+tags"
MONADO_REPO_URI="https://gitlab.freedesktop.org/monado/monado.git"

LICENSE="GPL-3 Apache-2.0 Boost-1.0 MIT"
SLOT="0"
IUSE="debug gui nvenc +pipewire vaapi wireshark-plugins x264"

RDEPEND="
	app-arch/libarchive:=
	dev-libs/boost:=
	dev-libs/glib:2
	dev-libs/libbsd
	dev-libs/openssl:=
	gnome-base/librsvg:2
	media-libs/libglvnd[X,${MULTILIB_USEDEP}]
	media-libs/libpng:=
	media-libs/openxr-loader
	>=media-libs/vulkan-loader-1.4.304[${MULTILIB_USEDEP}]
	net-dns/avahi[dbus]
	virtual/libudev:=[${MULTILIB_USEDEP}]
	x11-libs/libnotify
	|| (
		sys-apps/systemd
		sys-auth/elogind
	)
	gui? (
		dev-libs/kirigami-addons
		dev-libs/qcoro:=[qml]
		dev-qt/qtbase:6[dbus,gui,network]
		dev-qt/qtdeclarative:6
		kde-frameworks/kcoreaddons:6
		kde-frameworks/ki18n:6
		kde-frameworks/kiconthemes:6
		kde-frameworks/kirigami:6
		kde-frameworks/qqc2-desktop-style:6
	)
	pipewire? ( media-video/pipewire:= )
	vaapi? (
		media-video/ffmpeg:=[drm(-),vaapi]
		x11-libs/libdrm
	)
	x264? ( media-libs/x264:= )
	wireshark-plugins? (
		>=media-libs/openxr-loader-1.1.53
		>=net-analyzer/wireshark-4.6.1:=
	)
"
DEPEND="
	${RDEPEND}
	dev-cpp/cli11
	dev-cpp/eigen
	dev-cpp/nlohmann_json
	>=dev-util/vulkan-headers-1.4.304
"
BDEPEND="
	${PYTHON_DEPS}
	dev-util/gdbus-codegen
	dev-util/glslang
	dev-util/spirv-tools
	sys-apps/util-linux
	virtual/pkgconfig
	gui? (
		kde-frameworks/extra-cmake-modules:0
		sys-devel/gettext
	)
"

src_unpack() {
	git-r3_src_unpack

	GIT_DESC=$(git -C "${EGIT_DIR}" describe --tags --always "${EGIT_VERSION}") || die
	GIT_COMMIT=${EGIT_VERSION}

	local monado_commit
	monado_commit=$(<"${S}/monado-rev") || die

	# Keep WiVRn's branch and checkout metadata separate from Monado's.
	local EGIT_BRANCH= EGIT_COMMIT= EGIT_COMMIT_DATE= EGIT_DIR EGIT_VERSION
	git-r3_fetch "${MONADO_REPO_URI}" "${monado_commit}"
	git-r3_checkout "${MONADO_REPO_URI}" "${WORKDIR}/monado-src"
}

src_prepare() {
	eapply --directory="${WORKDIR}/monado-src" "${S}"/patches/monado/*.patch
	cmake_src_prepare
}

multilib_src_configure() {
	use debug || append-cppflags -DNDEBUG
	local mycmakeargs=(
		-DGIT_DESC="${GIT_DESC}"
		-DGIT_COMMIT="${GIT_COMMIT}"
		-DPython3_EXECUTABLE="${PYTHON}"
		-DWIVRN_BUILD_CLIENT=OFF
		-DWIVRN_BUILD_SERVER=$(multilib_is_native_abi && echo ON || echo OFF)
		-DWIVRN_BUILD_SERVER_LIBRARY=ON
		-DWIVRN_OPENXR_MANIFEST_TYPE=relative
		-DWIVRN_OPENXR_MANIFEST_ABI=$(multilib_is_native_abi && echo OFF || echo ON)
		-DWIVRN_BUILD_DASHBOARD=$(multilib_native_usex gui)
		-DWIVRN_BUILD_DISSECTOR=$(multilib_native_usex wireshark-plugins)
		-DWIVRN_BUILD_WIVRNCTL=$(multilib_is_native_abi && echo ON || echo OFF)
		-DWIVRN_FEATURE_SOLARXR=ON
		-DWIVRN_FEATURE_STEAMVR_LIGHTHOUSE=ON
		-DWIVRN_USE_PIPEWIRE=$(multilib_native_usex pipewire)
		-DWIVRN_USE_NVENC=$(multilib_native_usex nvenc)
		-DWIVRN_USE_VAAPI=$(multilib_native_usex vaapi)
		-DWIVRN_USE_VULKAN_ENCODE=ON
		-DWIVRN_USE_X264=$(multilib_native_usex x264)
		-DWIVRN_USE_SYSTEM_OPENXR=ON
		-DWIVRN_USE_SYSTEM_BOOST=ON
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DFETCHCONTENT_SOURCE_DIR_MONADO="${WORKDIR}/monado-src"
		-DENABLE_COLOURED_OUTPUT=OFF
	)

	cmake_src_configure
}

multilib_src_install_all() {
	newenvd - "50${PN}" <<-EOF
		PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
	EOF
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "WiVRn requires a compatible client APK on your VR headset."
	elog "Look for a build of this branch under ${HOMEPAGE}/actions/workflows/Build.yml."
}
