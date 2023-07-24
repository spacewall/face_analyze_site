ARG PYTHON_VERSION=3.11.4
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

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/v3.9  --update bash && rm -rf /var/cache/apk/*
RUN apk search -x npm | apk add
    # build-essential \
    # curl \
    # software-properties-common \
    # ffmpeg libsm6 libxext6 wget

RUN mkdir /app/.deepface && mkdir /app/.deepface/weights && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/age_model_weights.h5 -P /app/.deepface/weights && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/facial_expression_model_weights.h5 -P /app/.deepface/weights && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/gender_model_weights.h5 -P /app/.deepface/weights && \
    wget https://github.com/serengil/deepface_models/releases/download/v1.0/race_model_single_batch.h5 -P /app/.deepface/weights

# Leverage a cache mount to /root/.cache/pip to speed up subsequent builds.
# Leverage a bind mount to requirements.txt to avoid having to copy them into
# into this layer.
ADD requirements.txt /tmp/requirements.txt
RUN python3 -m pip install -r /tmp/requirements.txt

WORKDIR /app

USER ${USER}

COPY . .

EXPOSE 8501

ENTRYPOINT [ "streamlit", "run", "face_analyze.py" ]
