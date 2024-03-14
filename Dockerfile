ARG FUNCTION_DIR="/var/task"

FROM node:20-bookworm as build-image
SHELL ["bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
    g++ make cmake unzip libcurl4-openssl-dev

ARG FUNCTION_DIR
WORKDIR ${FUNCTION_DIR}

COPY package.json package.json
RUN npm i aws-lambda-ric && npm i --omit=dev

FROM node:20-bookworm-slim
SHELL ["bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
    git curl \
 && apt-get autoremove -y && apt-get clean && rm -fr /var/lib/apt/lists/*

ARG FUNCTION_DIR
WORKDIR ${FUNCTION_DIR}

COPY --from=build-image ${FUNCTION_DIR} .
RUN chmod -R go+rX .
COPY index.js index.js
RUN chmod go+rX index.js

ENV NPM_CONFIG_CACHE=/tmp/.npm
ENTRYPOINT ["npx", "aws-lambda-ric"]
CMD ["index.handler"]
