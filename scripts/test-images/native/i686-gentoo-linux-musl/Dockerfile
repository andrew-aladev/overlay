ARG FROM_IMAGE=test_i686-gentoo-linux-musl
FROM $FROM_IMAGE

COPY root /
COPY attached-common-root /
RUN build.sh -v \
  app-portage/eix dev-vcs/git \
  dev-lang/ruby:2.5 dev-lang/ruby:2.6 dev-lang/ruby:2.7 \
  virtual/rubygems
