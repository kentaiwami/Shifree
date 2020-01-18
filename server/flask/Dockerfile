FROM python:3.7.2
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -U pip
RUN while read line; \
 do \
 pip install $line; \
 done < requirements.txt
ADD . /code/