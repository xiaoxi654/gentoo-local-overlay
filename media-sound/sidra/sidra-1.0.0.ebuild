# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature unpacker xdg

DESCRIPTION="An elegant Apple Music desktop client for Linux, macOS and Windows"
HOMEPAGE="https://github.com/wimpysworld/sidra"
SRC_URI="https://github.com/wimpysworld/sidra/releases/download/${PV}/Sidra-${PV}-linux-amd64.deb"
S="${WORKDIR}"

LICENSE="BlueOak-1.0.0"
SLOT="0"
KEYWORDS="-* ~amd64"

# strip: keep the prebuilt CastLabs Electron binary intact for Widevine DRM.
RESTRICT="strip"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/libpulse
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	virtual/libudev:=
	x11-libs/cairo
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libnotify
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="
	/opt/Sidra/sidra
	/opt/Sidra/chrome-sandbox
	/opt/Sidra/chrome_crashpad_handler
	/opt/Sidra/libEGL.so
	/opt/Sidra/libGLESv2.so
	/opt/Sidra/libffmpeg.so
	/opt/Sidra/libvulkan.so.1
	/opt/Sidra/libvk_swiftshader.so
"

src_unpack() {
	unpack_deb "${DISTDIR}/${A}"
}

src_prepare() {
	default
	# Updates are managed by Portage.
	rm opt/Sidra/resources/app-update.yml || die
	sed -i 's/^Categories=Audio;$/Categories=AudioVideo;Audio;/' \
		usr/share/applications/sidra.desktop || die
}

src_install() {
	domenu usr/share/applications/sidra.desktop

	local size
	for size in 16 24 32 48 64 128 256 512; do
		doicon -s "${size}" "usr/share/icons/hicolor/${size}x${size}/apps/sidra.png"
	done

	insinto /opt
	doins -r opt/Sidra

	dosym ../../opt/Sidra/sidra /usr/bin/sidra

	fperms 4755 /opt/Sidra/chrome-sandbox
	fperms +x /opt/Sidra/sidra /opt/Sidra/chrome_crashpad_handler
	fperms +x /opt/Sidra/libffmpeg.so
	fperms +x /opt/Sidra/libvulkan.so.1 /opt/Sidra/libvk_swiftshader.so

	dodoc opt/Sidra/LICENSE.electron.txt opt/Sidra/LICENSES.chromium.html
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "keyring service" virtual/secret-service
}
