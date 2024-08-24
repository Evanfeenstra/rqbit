# Rust as the base image
FROM rust:1.77-slim-bullseye as build

# Create a new empty shell project
# RUN USER=root cargo new --lib rqbit
WORKDIR /rqbit

# Copy our manifests
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# Build only the dependencies to cache them
# RUN cargo build --lib --release
# RUN rm src/*.rs

# Copy the source code
COPY ./crates ./crates

RUN apt-get update && \
    apt-get install -y \
    pkg-config make g++ libssl-dev

# Build for release.
# remove the lib
RUN cargo build --release

# The final base image
# FROM debian:buster-slim
# FROM debian:bullseye-slim
FROM debian:11-slim

# get root CA certs
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates 

# Copy from the previous build
COPY --from=build /rqbit/target/release/rqbit /usr/src/rqbit

# frontend assets
# COPY assets /usr/src/rqbit/assets

EXPOSE 8000

# Run the binary
CMD ["/usr/src/rqbit"]
