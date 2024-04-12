VERSION 0.8
FROM docker.io/library/ruby:3.3-slim-bookworm

RUN useradd --create-home ci_user && \
mkdir /repo && \
chown -R ci_user:ci_user /repo && \
apt-get update && \
apt-get install --yes --no-install-recommends curl ca-certificates git libyaml-dev xz-utils zip make && \
apt-get clean && rm -rf /var/lib/apt/lists/*

USER ci_user
ENV ASDF_DIR="/home/ci_user/.asdf"
ENV PATH="/home/ci_user/.asdf/bin:/home/ci_user/.asdf/shims:${PATH}"

RUN git config --global advice.detachedHead false && \
git clone https://github.com/asdf-vm/asdf.git "${ASDF_DIR}" --branch v0.14.0 --depth 1 && \
. "${ASDF_DIR}/asdf.sh" && \
echo '. "${ASDF_DIR}/asdf.sh"' >> /home/ci_user/.profile && \
echo '. "${ASDF_DIR}/asdf.sh"' >> /home/ci_user/.bashrc && \
asdf plugin add age && \
asdf plugin add shellcheck && \
asdf plugin add bashly https://github.com/pcrockett/asdf-bashly.git && \
asdf plugin add bats https://github.com/pcrockett/asdf-bats.git

WORKDIR /repo

COPY .tool-versions .
RUN asdf install

COPY . .

SAVE IMAGE gramps-ci:latest

all:
    BUILD +build
    BUILD +lint
    BUILD +test

build:
    RUN make build
    SAVE ARTIFACT gramps AS LOCAL gramps

lint:
    COPY +build/gramps .
    RUN make lint

test:
    COPY +build/gramps .
    RUN make test
