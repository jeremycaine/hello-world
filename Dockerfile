# First stage builds the application
#FROM ubi8/nodejs-16 as builder

#USER 1001

# Add application sources
#ADD . $HOME

# Install the dependencies
#RUN npm install

# Second stage copies the application to the minimal image
#FROM ubi8/nodejs-16-minimal

# Copy the application source and build artifacts from the builder image to this one
#COPY --from=builder $HOME $HOME

# Run script uses standard ways to run the application
#EXPOSE 3000

#CMD [ "npm", "run", "start" ]
#CMD npm run -d start


FROM registry.access.redhat.com/ubi8/nodejs-18-minimal:1

CMD sudo chown -R 1001:0 "/opt/app-root/src"
WORKDIR /opt/app-root/src

COPY package.json /opt/app-root/src
RUN npm install --only=prod
COPY . /opt/app-root/src

ENV NODE_ENV production
ENV PORT 3000

EXPOSE 3000

CMD [ "npm", "run", "start" ]
