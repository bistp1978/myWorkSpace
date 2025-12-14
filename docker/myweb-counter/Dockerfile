FROM node:25-alpine3.21

WORKDIR /usr/counter-app

COPY   package.json .

RUN npm install

RUN npm install express redis

COPY   ./ ./

CMD ["npm", "start" ]