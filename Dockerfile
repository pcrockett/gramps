FROM docker.io/library/ruby:3.4-slim-bookworm AS base

RUN useradd --create-home ci_user && \
mkdir /repo && \
chown -R ci_user:ci_user /repo && \
apt-get update && \
apt-get install --yes --no-install-recommends \
    curl ca-certificates git libyaml-dev xz-utils zip make build-essential libffi-dev && \
apt-get clean && rm -rf /var/lib/apt/lists/*

USER ci_user
ENV HOME="/home/ci_user"
ENV ASDF_DATA_DIR="${HOME}/.local/state/asdf"
ENV ASDF_CONFIG_FILE="${HOME}/.config/asdf/asdfrc"
ENV PATH="${HOME}/.local/bin:${ASDF_DATA_DIR}/shims:${PATH}"

RUN \
mkdir -p "${ASDF_DATA_DIR}" && \
curl -SsfL https://philcrockett.com/yolo/v1.sh \
  | bash -s -- asdf && \
asdf plugin add age https://github.com/pcrockett/asdf-age.git && \
asdf plugin add shellcheck https://github.com/pcrockett/asdf-shellcheck.git && \
asdf plugin add bashly https://github.com/pcrockett/asdf-bashly.git && \
asdf plugin add bats https://github.com/pcrockett/asdf-bats.git

WORKDIR /repo

COPY .tool-versions .
RUN asdf install

FROM base AS builder

COPY --chown=ci_user:ci_user . .
