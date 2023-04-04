# Two stage build

# Stage 1: builder image
FROM registry.access.redhat.com/ubi9/nodejs-16 AS builder

## Add application sources
ADD . $HOME

## Install dependencies based on the preferred package manager
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Stage 2:  deployment image
## 1. Unversial Base Image (UBI)
FROM registry.access.redhat.com/ubi9/nodejs-16-minimal

## 2. Non-root, arbitrary user IDs
USER 1001

## 3. Image identification
LABEL name="jeremycaine/hello-word" \
      vendor="Acme, Inc." \
      version="1.2.3" \
      release="45" \
      summary="hello world web application" \
      description="This application says hello world."

USER root

## 4. Image license
## Red Hat requires that the image store the license file(s) in the /licenses directory. 
## Store the license in the image to self-document
COPY ./licenses /licenses

## 5. Latest security updates
## RUN dnf -y update-minimal --security --sec-severity=Important --sec-severity=Critical && \
##    dnf clean all

## on minimal UBI images use microdnf
RUN microdnf -y upgrade && \
    microdnf clean all

## 6. Group ownership and file permission
RUN chgrp -R 0 $HOME && \
    chmod -R g=u $HOME

USER 1001
RUN chown -R 1001:0 $HOME

## 7. Application source
## Copy the application source and build artifacts from the builder image to this one
COPY --from=builder $HOME $HOME

## Set environment environment variables and expose port
ENV NODE_ENV production
ENV PORT 3000
EXPOSE 3000

## Run script uses standard ways to run the application
CMD npm run -d start



