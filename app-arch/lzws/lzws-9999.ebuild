# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cmake-multilib cmake-utils git-r3

DESCRIPTION="LZW streaming compressor/decompressor compatible with UNIX compress."
HOMEPAGE="https://github.com/andrew-aladev/lzws"
EGIT_REPO_URI="https://github.com/andrew-aladev/lzws.git"
EGIT_SUBMODULES=()
SRC_URI=""

LICENSE="BSD-3-Clause"
SLOT="0"
KEYWORDS=""

IUSE_COMPRESSOR_DICTIONARY="
  compressor_dictionary_linked-list
  +compressor_dictionary_sparse-array
"
IUSE_BIGNUM_LIBRARY="
  +bignum_library_gmp
  bignum_library_tommath
"
IUSE="
  ${IUSE_COMPRESSOR_DICTIONARY}
  ${IUSE_BIGNUM_LIBRARY}
  static
  test
  noman
"
IUSE_EXPAND="
  COMPRESSOR_DICTIONARY
  BIGNUM_LIBRARY
"
REQUIRED_USE="
  ^^ ( ${IUSE_COMPRESSOR_DICTIONARY/+/} )
  ^^ ( ${IUSE_BIGNUM_LIBRARY/+/} )
"

RDEPEND="
  virtual/libc
  bignum_library_gmp? ( dev-libs/gmp )
  bignum_library_tommath? ( dev-libs/libtommath )
  static? (
    bignum_library_gmp? ( dev-libs/gmp[static-libs] )
    bignum_library_tommath? ( dev-libs/libtommath[static-libs] )
  )
"
DEPEND="${RDEPEND}"
BDEPEND="!noman? ( app-text/asciidoc )"

src_configure() {
  local mycmakeargs=(
    -DLZWS_COMPRESSOR_DICTIONARY=$(usex compressor_dictionary_linked-list linked-list sparse-array)
    -DLZWS_BIGNUM_LIBRARY=$(usex bignum_library_gmp gmp tommath)
    -DLZWS_SHARED=ON
    -DLZWS_STATIC=$(usex static)
    -DLZWS_CLI=ON
    -DLZWS_TESTS=$(usex test)
    -DLZWS_EXAMPLES=OFF
    -DLZWS_MAN=$(usex noman OFF ON)
  )

  cmake-multilib_src_configure
}
