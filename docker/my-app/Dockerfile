FROM node:25-alpine3.21
RUN mkdir -p /home/app
COPY ./src /home/app
WORKDIR /home/app
RUN npm install
CMD ["node", "myServer.js"]
EXPOSE 3000