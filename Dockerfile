# Define custom function directory
ARG FUNCTION_DIR="/task"

FROM node:lts-buster-slim as build-image

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Install aws-lambda-cpp build dependencies
RUN apt-get update && \
    apt-get install -y \
    g++ make cmake autoconf libtool python3-pip unzip libcurl4-openssl-dev

RUN npm i -g npm@latest

RUN mkdir -p ${FUNCTION_DIR} && chown node:staff ${FUNCTION_DIR}
WORKDIR ${FUNCTION_DIR}
USER node

# If the dependency is not in package.json uncomment the following line
# RUN npm install aws-lambda-ric

COPY --chown=node:staff package.json package.json
RUN npm i aws-lambda-ric
RUN npm ci

# Grab a fresh slim copy of the image to reduce the final size
FROM node:lts-buster-slim

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

# Copy in the built dependencies
COPY --from=build-image --chown=node:staff ${FUNCTION_DIR} .

ENTRYPOINT ["/usr/local/bin/npx", "aws-lambda-ric"]
CMD ["index.handler"]
