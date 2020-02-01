FROM python:3.7.6
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -U pip --user
RUN while read line || [ -n "${line}" ]; \
 do \
 pip install $line; \
 done < requirements.txt
ADD . /code/