FROM node:25-alpine3.21
COPY package.json /app/package.json
COPY src /app/src
WORKDIR /app
RUN npm install
CMD ["node", "src/server.js"]
EXPOSE 3000

