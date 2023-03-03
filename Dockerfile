#FROM nodejs:16-ubi8-minimal
# First stage builds the application
FROM ubi8/nodejs-16 as builder

# Add application sources to a directory that the assemble script expects them
# and set permissions so that the container runs without root access
USER 0
ADD . /tmp/src
RUN chown -R 1001:0 /tmp/src
USER 1001

# Install the dependencies
RUN /usr/libexec/s2i/assemble

# Second stage copies the application to the minimal image
FROM ubi8/nodejs-16-minimal

# Copy the application source and build artifacts from the builder image to this one
COPY --from=builder $HOME $HOME

ENV NODE_ENV production
ENV PORT 3000

EXPOSE 3000

# Execute NodeJS (not NPM script) to handle SIGTERM and SIGINT signals.
#CMD ["node", "./server.js"]

# Set the default command for the resulting image
CMD /usr/libexec/s2i/run

#COPY . .

