# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
USE_RUBY="ruby25 ruby26 ruby27 ruby30"

RUBY_FAKEGEM_EXTRADOC="README.md"
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"
RUBY_FAKEGEM_RECIPE_DOC="none"
RUBY_FAKEGEM_RECIPE_TEST="rake"
RUBY_FAKEGEM_TASK_TEST="test"

inherit ruby-fakegem

DESCRIPTION="Ruby bindings for zstd library."
HOMEPAGE="https://github.com/andrew-aladev/ruby-zstds"
SRC_URI="https://github.com/andrew-aladev/ruby-zstds/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~mips ~x64-cygwin ~x64-macos ~x64-winnt x86 ~x86-winnt"

IUSE="test"

PATCHES=(
  "${FILESDIR}/${PV}/gemspec.patch"
  "${FILESDIR}/${PV}/port-autoset.patch"
  "${FILESDIR}/${PV}/remove-extension-task.patch"
)

RDEPEND=">=app-arch/zstd-1.4 <app-arch/zstd-1.5"
DEPEND="${RDEPEND}"

ruby_add_bdepend "
  test? (
    dev-ruby/minitest:5
    dev-ruby/minitar
    dev-ruby/ocg
  )
"

each_ruby_configure() {
  "$RUBY" -Cext extconf.rb || die
}

each_ruby_compile() {
  emake V=1 -Cext
  mv ext/zstds_ext.so lib/ || die
}
