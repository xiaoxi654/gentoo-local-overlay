# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit qmake-utils xdg

DESCRIPTION="Control and monitor modern Icom, Kenwood and Yaesu transceivers"
HOMEPAGE="
	https://wfview.org/
	https://github.com/wf-group/wfview
"
SRC_URI="https://github.com/wf-group/wfview/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/wfview-${PV}"

# NOTE: the upstream tarball embeds resources/frequency.ttf, a proprietary
# AGFA/Linotype "Univers Condensed" font (Copyright 1992 Miles Inc., all
# rights reserved) that is compiled into the installed binary.  It is not
# covered by the licenses below; do not redistribute binaries built from this
# package until upstream clarifies the font licensing.
LICENSE="BSD GPL-2+ GPL-3+ LGPL-2.1+ MIT public-domain"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-libs/hidapi
	dev-libs/qcustomplot
	dev-qt/qtbase:6[gui,network,widgets,xml]
	dev-qt/qtmultimedia:6
	dev-qt/qtserialport:6
	dev-qt/qtwebsockets:6
	media-libs/libpulse
	media-libs/opus
	media-libs/portaudio[alsa]
	media-libs/rtaudio:=[alsa]
	virtual/libudev:=
"
DEPEND="
	${RDEPEND}
	dev-cpp/eigen:=
"
BDEPEND="dev-qt/qtbase:6"

PATCHES=(
	"${FILESDIR}/${P}-gitshort.patch"
	# Qt >= 6.11.1 compares through a const_iterator in QMultiMap::remove()
	"${FILESDIR}/${P}-cachingqueue-const-eq.patch"
)

src_configure() {
	# wfview.pro discovers qcustomplot through /sbin/ldconfig and only accepts
	# Qt6-suffixed library names, while dev-libs/qcustomplot installs plain
	# libqcustomplot.so.  Link it explicitly instead of patching the probe.
	eqmake6 wfview.pro \
		"PREFIX=${EPREFIX}/usr" \
		"VERSION=${PV}" \
		"LIBS+=-lqcustomplot"
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	dodoc CHANGELOG LICENSE README.md
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Serial-port access for non-root users requires membership in the"
	elog "'dialout' group, for example:"
	elog "    usermod -aG dialout <user>"
}
