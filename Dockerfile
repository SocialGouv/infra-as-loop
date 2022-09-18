ARG NODE_ENV=production
ARG UBUNTU_VERSION=22.04
FROM ubuntu:$UBUNTU_VERSION as base

RUN apt-get update && \
  apt-get install -y \
    curl \
    wget \
    git \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 ubuntu

FROM base as node
ARG NODE_VERSION=18
ENV NODE_VERSION=$NODE_VERSION
RUN wget -qO- https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
  && apt-get install nodejs \
  && npm install -g yarn \
  && rm -rf /var/lib/apt/lists/*

FROM base as kubectl
ARG KUBECTL_VERSION=v1.25.0
ENV KUBECTL_VERSION=$KUBECTL_VERSION
RUN curl -sL https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl > /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl

FROM base as gomplate
ARG GOMPLATE_VERSION=v1.9.0
ENV GOMPLATE_VERSION=$GOMPLATE_VERSION
RUN curl -sL https://github.com/SocialGouv/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64 > /tmp/gomplate \
  && mv /tmp/gomplate /usr/local/bin/gomplate \
  && chmod +x /usr/local/bin/gomplate

FROM base as rollout-status
ARG ROLLOUT_STATUS_VERSION=v1.9.1
ENV ROLLOUT_STATUS_VERSION=$ROLLOUT_STATUS_VERSION
RUN curl -sL https://github.com/SocialGouv/rollout-status/releases/download/${ROLLOUT_STATUS_VERSION}/rollout-status-${ROLLOUT_STATUS_VERSION}-linux-amd64 > /tmp/rollout-status \
  && mv /tmp/rollout-status /usr/local/bin/rollout-status \
  && chmod +x /usr/local/bin/rollout-status

FROM base as snip
ARG SNIP_VERSION=v1.12.2
ENV SNIP_VERSION=$SNIP_VERSION
RUN curl -sL https://github.com/devthejo/snip/releases/download/${SNIP_VERSION}/snip-${SNIP_VERSION}-linux-amd64 > /tmp/snip \
  && mv /tmp/snip /usr/local/bin/snip \
  && chmod +x /usr/local/bin/snip

## PREPARE (package.json to avoid node_modules cache invalidation on version bumping)
FROM node as preparation
COPY package.json /app/
RUN node -e "fs.writeFileSync('/app/package.json', JSON.stringify({ ...JSON.parse(fs.readFileSync('/app/package.json')), version: '0.0.0' }));"

## FINAL IMAGE
FROM node as server

ARG NODE_ENV
ENV NODE_ENV=$NODE_ENV
ENV GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
RUN mkdir /app && chown 1000 /app
ENV PATH=$PATH:/app/bin:/app/node_modules/.bin
WORKDIR /app
USER 1000
CMD ["snip", "playbooks"]

COPY --from=kubectl /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=gomplate /usr/local/bin/gomplate /usr/local/bin/gomplate
COPY --from=rollout-status /usr/local/bin/rollout-status /usr/local/bin/rollout-status
COPY --from=snip /usr/local/bin/snip /usr/local/bin/snip

### INSTALL (node modules)
COPY --from=preparation --chown=1000 /app/package.json ./
COPY --chown=1000 yarn.lock .yarnrc.yml .env.default ./
COPY --chown=1000 .yarn .yarn

#### YARN INSTALL
RUN mkdir common
RUN yarn install --immutable \
  && yarn cache clean

### COPY (package sources)
COPY --chown=1000 . .
