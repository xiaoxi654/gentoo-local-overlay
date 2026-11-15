# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 linux-mod-r1 udev

DESCRIPTION="Force-feedback driver for Thrustmaster racing wheels"
HOMEPAGE="https://github.com/Kimplul/hid-tmff2"
EGIT_REPO_URI="https://github.com/Kimplul/hid-tmff2.git"
EGIT_SUBMODULES=( deps/hid-tminit )

LICENSE="GPL-2 GPL-2+ GPL-3"
SLOT="0"
IUSE="steamdeck"

RDEPEND="virtual/udev"

CONFIG_CHECK="HID INPUT USB USB_HID ~INPUT_JOYDEV"
ERROR_INPUT_JOYDEV="CONFIG_INPUT_JOYDEV is needed by games using the legacy joystick interface."

src_compile() {
	# Build each Kbuild directly, without upstream's recursive install/depmod.
	emake "${MODULES_MAKEARGS[@]}" -C "${KV_OUT_DIR}" M="${S}" modules
	emake "${MODULES_MAKEARGS[@]}" -C "${KV_OUT_DIR}" M="${S}/deps/hid-tminit" modules
}

src_install() {
	# Match upstream's modules_install location, including existing manual installs.
	linux_moduleinto updates
	linux_domodule hid-tmff-new.ko deps/hid-tminit/{hid,usb}-tminit-new.ko
	modules_post_process

	insinto /usr/lib/modprobe.d
	doins "${FILESDIR}/${PN}.conf" modprobe/hid-tmff2-xpad.conf

	udev_dorules udev/99-t-lcm.rules
	if use steamdeck; then
		udev_dorules udev/71-thrustmaster-steamdeck.rules
	fi

	local DOCS=( README.md docs/DRIVER.md docs/INTEGRATION.md )
	einstalldocs
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst
	udev_reload

	elog "The modules are hid-tmff-new, hid-tminit-new and usb-tminit-new."
	elog "The in-tree hid_thrustmaster initializer is blacklisted in favour of"
	elog "the bundled hid-tminit-new. No modules are unloaded or reloaded here."
	elog "Unplug/replug the wheel or reboot to start using the installed driver."
	elog "When migrating from a manual or DKMS install, remove stale copies"
	elog "for the target kernel, including differently compressed .ko files."
	elog "Do not keep a DKMS registration that can overwrite these modules."
}

pkg_postrm() {
	udev_reload
}
