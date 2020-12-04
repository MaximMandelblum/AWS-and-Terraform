FROM alpine:3.9

LABEL maintainer="maximum24@gmail.com"

COPY . /SRC

WORKDIR /SRC

RUN apk update && apk upgrade && apk add  py-pip python3

RUN pip install --upgrade pip

RUN pip install  -r requirements.txt

EXPOSE 5000

CMD python3 ./app.py


