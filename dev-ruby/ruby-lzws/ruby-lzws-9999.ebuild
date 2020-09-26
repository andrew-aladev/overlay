# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
USE_RUBY="ruby25 ruby26 ruby27"

RUBY_FAKEGEM_EXTRADOC="README.md"
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"
RUBY_FAKEGEM_RECIPE_DOC="none"
RUBY_FAKEGEM_RECIPE_TEST="rake"
RUBY_FAKEGEM_TASK_TEST="test"

inherit ruby-fakegem git-r3

DESCRIPTION="Ruby bindings for lzws library."
HOMEPAGE="https://github.com/andrew-aladev/ruby-lzws"
EGIT_REPO_URI="https://github.com/andrew-aladev/ruby-lzws.git"
EGIT_CHECKOUT_DIR="${WORKDIR}/all/${P}"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

IUSE="test"

PATCHES=(
  "${FILESDIR}/${PV}/gemspec.patch"
  "${FILESDIR}/${PV}/live-version.patch"
  "${FILESDIR}/${PV}/remove-extension-task.patch"
)

RDEPEND="app-arch/lzws"
DEPEND="${RDEPEND}"

ruby_add_bdepend "
  test? (
    dev-ruby/minitest:5
    dev-ruby/ocg
  )
"

each_ruby_configure() {
  "$RUBY" -Cext extconf.rb || die
}

each_ruby_compile() {
  emake V=1 -Cext
  mv ext/lzws_ext.so lib/ || die
}
