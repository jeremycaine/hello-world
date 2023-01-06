FROM node:16

# Install dependencies first, add code later: docker is caching by layers
COPY package.json ./

# Docker base image is already NODE_ENV=production
RUN npm install

# Add your source files
COPY . .

ENV NODE_ENV production
ENV PORT 3000

EXPOSE 3000

CMD [ "npm", "run", "start" ]
