FROM node:16

# Copy files as a non-root user. The `node` user is built in the Node image.
ENV NODE_ENV production
ENV PORT 3000

# Just copy the package.json...
COPY package*.json ./

#WORKDIR /usr/src/app
#RUN chown node:node ./
#USER node


# Install dependencies first, as they change less often than code.
COPY package.json package-lock.json* ./
RUN npm ci && npm cache clean --force
COPY . .

EXPOSE 3000

# Execute NodeJS (not NPM script) to handle SIGTERM and SIGINT signals.
CMD ["node", "./server.js"]
