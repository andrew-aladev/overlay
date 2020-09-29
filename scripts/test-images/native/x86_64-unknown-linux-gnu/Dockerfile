ARG FROM_IMAGE=test_x86_64-unknown-linux-gnu
FROM $FROM_IMAGE

COPY root /
COPY attached-common-root /
RUN build.sh -v \
  app-portage/eix dev-vcs/git dev-libs/gmp \
  dev-lang/ruby:2.5 dev-lang/ruby:2.6 dev-lang/ruby:2.7 \
  virtual/rubygems
