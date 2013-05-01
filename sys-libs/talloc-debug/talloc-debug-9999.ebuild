# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: talloc Exp $

EAPI=4
inherit waf-utils python multilib git-2

DESCRIPTION="Samba talloc library with debug callback"
HOMEPAGE="http://talloc.samba.org/"

EGIT_REPO_URI="git://github.com/andrew-aladev/samba-talloc-debug.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="compat debug-callback"

RDEPEND="dev-libs/libxslt"
DEPEND="${RDEPEND}"

WAF_BINARY="${S}/buildtools/bin/waf"

src_configure() {
    cd lib/talloc/
    
    local extra_opts=""

    use compat && extra_opts+=" --enable-talloc-compat1"
    use debug-callback && extra_opts+=" --enable-debug-callback"
    waf-utils_src_configure \
        ${extra_opts}
}

src_install() {
    waf-utils_src_install
}
