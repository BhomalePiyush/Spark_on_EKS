ARG BASE_IMAGE=public.ecr.aws/emr-on-eks/spark/emr-7.8.0:latest

FROM ${BASE_IMAGE}

USER root

COPY requirements.txt .

RUN pip3 install -r requirements.txt &&\
    rm requirements.txt

USER hadoop:hadoop