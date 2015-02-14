FROM      ubuntu:14.04
MAINTAINER Rodrigo

RUN apt-get update && apt-get install -y nodejs npm nodejs-legacy

RUN mkdir -p /opt/poker
COPY package.json /opt/poker/
COPY examples /opt/poker/examples
COPY src /opt/poker/src
WORKDIR /opt/poker/
RUN npm install
EXPOSE 8080

CMD npm run server
