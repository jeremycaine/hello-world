# First stage builds the application
FROM nodejs:16-ubi9 as builder
# registry.redhat.io/
# registry.access.redhat.com/

RUN chgrp -R 0 $HOME && \
    chmod -R g=u $HOME

USER 1001
RUN chown -R 1001:0 $HOME

# Add application sources
ADD . $HOME

# Install dependencies based on the preferred package manager
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Install the dependencies
# RUN npm install -g npm@9.6.0
##solid
##RUN npm ci --unsafe-perm && npm run build


# Second stage copies the application to the minimal image
FROM nodejs:16-ubi9
#FROM ubi8/nodejs-16-minimal

USER 1001

# Copy the application source and build artifacts from the builder image to this one
COPY --from=builder $HOME $HOME

ENV NODE_ENV production
ENV PORT 3000

EXPOSE 3000

# Run script uses standard ways to run the application
CMD npm run -d start



