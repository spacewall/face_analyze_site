# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/engine/reference/builder/

ARG PYTHON_VERSION=3.11.4
FROM python:${PYTHON_VERSION}-slim as base

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
ARG USER=app
ARG ID=2000

RUN addgroup --gid ${ID} ${USER} && \
    adduser \
    --ingroup ${USER} \
    --uid ${ID} \
    --disabled-password \
    --home /app \
    --shell /sbin/nologin ${USER}

# Download dependencies as a separate step to take advantage of Docker's caching.
RUN apt-get update && apt-get install \
    ffmpeg libsm6 libxext6  -y

# Leverage a cache mount to /root/.cache/pip to speed up subsequent builds.
# Leverage a bind mount to requirements.txt to avoid having to copy them into
# into this layer.
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    python -m pip install -r requirements.txt

WORKDIR /app

# Switch to the non-privileged user to run the application.
USER ${USER}

# Copy the source code into the container.
COPY . .

# Expose the port that the application listens on.
EXPOSE 8501

# Run the application.
ENTRYPOINT ["streamlit", "run", "face_analyze.py"]