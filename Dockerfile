FROM python:3-slim

ARG user=robot
ARG group=robot
ARG uid=1000
ARG gid=1000

ENV CHROME_RELEASE_SHA256=ab00e9412f5f20e30c7db5dc987473248f4adf9ebf2c3f928ef62e1ffb104fe6 \
    CHROME_RELEASE=google-chrome-stable_current_amd64 \
    CHROME_DOWNLOAD_URL=https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    ROBOT_HOME=/var/robot \
    LANG=C.UTF-8

RUN apt-get clean && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

# Create robot User
RUN mkdir -p $ROBOT_HOME && \
    chown ${uid}:${gid} $ROBOT_HOME && \
    groupadd -g ${gid} ${group} && \
    useradd -d "$ROBOT_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Install Firefox
RUN echo "deb [arch=amd64] http://ftp.de.debian.org/debian buster main" >> /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends gpgv apt curl firefox-esr gdebi

# Install Chrome & RobotFramework
WORKDIR $ROBOT_HOME
RUN curl -fsSL -o ${CHROME_RELEASE}.deb "$CHROME_DOWNLOAD_URL" && \
    echo "$CHROME_RELEASE_SHA256 ${CHROME_RELEASE}.deb" | sha256sum -c - && \
    apt install -y ${ROBOT_HOME}/${CHROME_RELEASE}.deb && \
    pip install --upgrade pip && \
    pip install robotframework webdrivermanager robotframework-seleniumlibrary webdrivermanager

# Configure RobotFramework
RUN webdrivermanager firefox chrome --linkpath /usr/local/bin && \
    chown -R ${user}:${user} ${ROBOT_HOME} && \
    rm -f ${CHROME_RELEASE}.deb && \
    export PATH=$PATH:${ROBOT_HOME}/.local/bin

COPY robot.robot $ROBOT_HOME

# Run as non-root user
USER ${user}
ENTRYPOINT robot robot.robot

