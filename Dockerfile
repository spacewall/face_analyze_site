ARG PYTHON_VERSION=3.11
FROM registry.s.rosatom.education/sirius/docker/python:${PYTHON_VERSION}-alpine

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

ARG USER=app
ARG ID=2000

RUN addgroup --gid ${ID} ${USER} && \
    adduser \
    --ingroup ${USER} \
    --uid ${ID} \
    --disabled-password \
    --home /app \
    --shell /sbin/nologin ${USER}

RUN apk update && \
    apk add ffmpeg libsm libxext wget musl-dev linux-headers g++ lapack-dev \
    gfortran 

RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

RUN mkdir /app/.deepface && mkdir /app/.deepface/weights && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/age_model_weights.h5 -P /app/.deepface/weights && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/facial_expression_model_weights.h5 -P /app/.deepface/weights && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/gender_model_weights.h5 -P /app/.deepface/weights && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/race_model_single_batch.h5 -P /app/.deepface/weights

# Leverage a cache mount to /root/.cache/pip to speed up subsequent builds.
# Leverage a bind mount to requirements.txt to avoid having to copy them into
# into this layer.
ADD requirements.txt /tmp/requirements.txt
RUN wget https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-2.0.0-cp27-cp27mu-manylinux2010_x86_64.whl && python3 -m pip install tensorflow-2.0.0-cp27-cp27mu-manylinux2010_x86_64.whl && python3 -m pip install -r /tmp/requirements.txt

WORKDIR /app

USER ${USER}

COPY . .

EXPOSE 8501

ENTRYPOINT [ "streamlit", "run", "face_analyze.py" ]
