# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="${PN}.sh"
MY_PV="${PV/_p/-}"

DESCRIPTION="Tool to check TLS/SSL cipher support"
HOMEPAGE="https://testssl.sh/"
SRC_URI="https://github.com/drwetter/${MY_PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2 bundled-openssl? ( openssl )"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="bundled-openssl"

RDEPEND="
	app-shells/bash[net]
	dev-libs/openssl-bad
	net-dns/bind-tools
	sys-apps/util-linux
	sys-libs/ncurses:0
	sys-process/procps
"

S=${WORKDIR}/${MY_PN}-${MY_PV}

QA_PREBUILT="opt/${PN}/*"

pkg_setup() {
	use amd64 && BUNDLED_OPENSSL="openssl.Linux.x86_64"
}

src_prepare() {
	default
	sed -i ${PN}.sh \
		-e 's|TESTSSL_INSTALL_DIR="${TESTSSL_INSTALL_DIR:-""}"|TESTSSL_INSTALL_DIR="/"|' \
		-e 's|$TESTSSL_INSTALL_DIR/etc/|&testssl/|g' || die

	sed -i ${PN}.sh \
		-e 's|OPENSSL="$1/openssl"|OPENSSL="$1/openssl-bad"|' || die
}

src_install() {
	dodoc CHANGELOG.stable-releases.txt CREDITS.md Readme.md
	dodoc openssl-rfc.mappping.html

	dobin ${PN}.sh

	insinto /etc/${PN}
	doins etc/*

	if use bundled-openssl; then
		exeinto /opt/${PN}
		use amd64 && doexe bin/${BUNDLED_OPENSSL}
	fi
}

pkg_postinst() {
	if use bundled-openssl; then
		einfo "A precompiled version of OpenSSL has been installed into /opt/${PN},"
		einfo "configured to enable a wider range of features to allow better testing."
		einfo ""
		einfo "To use it, call ${PN} appropriately:"
		einfo "${MY_PN} --openssl /opt/${PN}/${BUNDLED_OPENSSL} example.com"
	fi
}
