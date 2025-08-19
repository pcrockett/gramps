FROM docker.io/library/ruby:3.4-slim-bookworm AS base
SHELL ["/bin/bash", "-Eeuo", "pipefail", "-c"]
ARG GITHUB_TOKEN

RUN useradd --create-home ci_user && \
mkdir /repo && \
chown -R ci_user:ci_user /repo && \
apt-get update && \
apt-get install --yes --no-install-recommends \
    curl ca-certificates git libyaml-dev xz-utils zip make build-essential libffi-dev && \
apt-get clean && rm -rf /var/lib/apt/lists/*

USER ci_user
ENV HOME="/home/ci_user"
ENV ASDF_DATA_DIR="${HOME}/.asdf"
ENV PATH="${ASDF_DATA_DIR}/shims:${HOME}/.local/bin:${PATH}"

RUN \
git config --global advice.detachedHead false && \
mkdir -p "${ASDF_DATA_DIR}" "${HOME}/.local/bin" && \
curl -SsfL https://philcrockett.com/yolo/v1.sh \
    | bash -s -- asdf

RUN \
asdf plugin add age https://github.com/pcrockett/asdf-age.git && \
asdf plugin add shellcheck https://github.com/pcrockett/asdf-shellcheck.git && \
asdf plugin add bashly https://github.com/pcrockett/asdf-bashly.git && \
asdf plugin add bats https://github.com/pcrockett/asdf-bats.git

WORKDIR /repo

COPY .tool-versions .
RUN asdf install

ENTRYPOINT ["/bin/bash", "-c"]

FROM base AS ci
COPY . .
