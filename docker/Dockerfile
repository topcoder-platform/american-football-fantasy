# Use the base image with Node.js
FROM node:8.12.0

# Copy the current directory into the Docker image
COPY . /platform
# Set working directory for future use
WORKDIR /platform

RUN apt-get update && apt-get install -y vim
RUN npm install -g truffle  --unsafe-perm
RUN npm install -g solc --unsafe-perm
RUN npm install -g ganache-cli --unsafe-perm
