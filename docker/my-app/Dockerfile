FROM node:25-alpine3.21
RUN mkdir -p /home/app
COPY ./src /home/app
WORKDIR /home/app
RUN npm install
RUN npm install dotenv
ENV MONGO_URL="mongodb://admin:password@mongodb:27017/"
CMD ["node", "myServer.js"]
