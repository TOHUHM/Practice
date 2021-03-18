FROM ubuntu

WORKDIR /app

ENV key1=test1  key2=test2

LABEL maintainer="jason.xu.partner@decathlon"

EXPOSE 22

RUN echo $key1 >> key1.log

ADD ./id_rsa.pub  .

ENTRYPOINT  ["sleep"]

CMD ["5"]
