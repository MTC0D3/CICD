FROM node:13-alpine

WORKDIR /wayshub-backend

COPY . .

RUN npm install && \
    npm install -g pm2@4.4.0 sequelize-cli

EXPOSE 5000

