FROM node:13-alpine

WORKDIR /wayshub-backend

COPY . .

RUN npm install && 

EXPOSE 5000

