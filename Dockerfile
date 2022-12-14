FROM python:3.6-alpine
EXPOSE 8080

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY requirements.txt /usr/src/app/
RUN pip3 install --no-cache-dir -r requirements.txt

COPY main.py /usr/src/app/main.py

CMD [ "python", "main.py" ]
