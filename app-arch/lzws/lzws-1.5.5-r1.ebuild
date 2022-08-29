# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cmake-multilib cmake

DESCRIPTION="LZW streaming compressor/decompressor compatible with UNIX compress."
HOMEPAGE="https://github.com/andrew-aladev/lzws"
ARGTABLE3_TAG="release-v3.2.1.7704006"
ARGTABLE3_P="${PN}-argtable3-${ARGTABLE3_TAG}"
SRC_URI="
  https://github.com/andrew-aladev/lzws/archive/v${PV}.tar.gz -> ${P}.tar.gz
  https://github.com/andrew-aladev/argtable3/archive/refs/tags/${ARGTABLE3_TAG}.tar.gz -> ${ARGTABLE3_P}.tar.gz
"

LICENSE="BSD-3-Clause"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~mips ~x64-cygwin ~x64-macos ~x64-winnt x86 ~x86-winnt"

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

src_unpack() {
  default

  rm -rf "${S}/argtable3" || die "failed to remove argtable3 directory"
  mv "${WORKDIR}/argtable3-${ARGTABLE3_TAG}" "${S}/argtable3" || die "failed to move argtable3 directory"
}

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
    -DLZWS_COVERAGE=OFF
  )

  cmake-multilib_src_configure
}
