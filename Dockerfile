ARG FUNCTION_DIR="/var/task"

FROM node:16.14.2-bullseye as build-image
SHELL ["bash", "-c"]

RUN apt-get update && \
    apt-get install -y \
    g++ make cmake unzip libcurl4-openssl-dev \
    autoconf libtool python3-pip \
    git curl

ARG FUNCTION_DIR
WORKDIR ${FUNCTION_DIR}

COPY package.json package.json
RUN npm i aws-lambda-ric
RUN npm i --production

FROM node:16.14.2-bullseye-slim
SHELL ["bash", "-c"]

RUN apt-get update && \
    apt-get install -y \
    git curl

ARG FUNCTION_DIR
WORKDIR ${FUNCTION_DIR}

COPY --from=build-image ${FUNCTION_DIR} .
COPY index.js index.js

ENTRYPOINT ["npx", "aws-lambda-ric"]
CMD ["index.handler"]
