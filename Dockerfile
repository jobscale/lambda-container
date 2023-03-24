ARG FUNCTION_DIR="/task"

FROM debian:bullseye as build-image
SHELL ["bash", "-c"]

RUN apt-get update && \
    apt-get install -y \
    g++ make cmake unzip libcurl4-openssl-dev \
    autoconf libtool python3-pip \
    git curl

ARG FUNCTION_DIR
WORKDIR ${FUNCTION_DIR}

COPY setup.sh setup.sh
RUN ./setup.sh

COPY nvm.sh /etc/profile.d/nvm.sh
COPY package.json package.json
RUN . /etc/profile.d/nvm.sh && npm i aws-lambda-ric
RUN . /etc/profile.d/nvm.sh && npm i --production

FROM debian:bullseye-slim
SHELL ["bash", "-c"]

RUN apt-get update && \
    apt-get install -y \
    git curl

ARG FUNCTION_DIR
WORKDIR ${FUNCTION_DIR}

COPY --from=build-image /usr/local/nvm /usr/local/nvm
COPY --from=build-image ${FUNCTION_DIR} .
COPY nvm.sh /etc/profile.d/nvm.sh
COPY entrypoint.sh /bin/entrypoint.sh
COPY index.js index.js

ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["index.handler"]
