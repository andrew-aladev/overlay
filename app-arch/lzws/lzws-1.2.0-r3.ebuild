# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cmake-multilib cmake

DESCRIPTION="LZW streaming compressor/decompressor compatible with UNIX compress."
HOMEPAGE="https://github.com/andrew-aladev/lzws"
SRC_URI="https://github.com/andrew-aladev/lzws/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-3-Clause"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~mips ~x64-cygwin ~x64-macos ~x64-winnt x86 ~x86-winnt"

IUSE_COMPRESSOR_DICTIONARY="
  compressor_dictionary_linked-list
  +compressor_dictionary_sparse-array
"
IUSE="${IUSE_COMPRESSOR_DICTIONARY} static test noman"
IUSE_EXPAND="COMPRESSOR_DICTIONARY"
REQUIRED_USE="^^ ( ${IUSE_COMPRESSOR_DICTIONARY/+/} )"

RDEPEND="
  virtual/libc
  dev-libs/gmp
  static? ( dev-libs/gmp[static-libs] )
"
DEPEND="${RDEPEND}"
BDEPEND="!noman? ( app-text/asciidoc )"

src_configure() {
  local mycmakeargs=(
    -DLZWS_COMPRESSOR_DICTIONARY=$(usex compressor_dictionary_linked-list linked-list sparse-array)
    -DLZWS_SHARED=ON
    -DLZWS_STATIC=$(usex static)
    -DLZWS_CLI=ON
    -DLZWS_TESTS=$(usex test)
    -DLZWS_EXAMPLES=OFF
    -DLZWS_MAN=$(usex noman OFF ON)
    -DLZWS_COVERAGE=OFF
  )

  cmake-multilib_src_configure
}
