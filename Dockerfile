FROM python:3-slim

ENV CHROME_RELEASE_SHA256=ab00e9412f5f20e30c7db5dc987473248f4adf9ebf2c3f928ef62e1ffb104fe6 \
    CHROME_RELEASE=google-chrome-stable_current_amd64 \
    CHROME_DOWNLOAD_URL=https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb


RUN apt-get clean && \
    apt-get update && \
    apt-get -y install curl gnupg2 apt-utils locales libtemplate-plugin-digest-md5-perl libparallel-forkmanager-perl \
    software-properties-common

RUN add-apt-repository ppa:ubuntu-mozilla-daily/ppa && \
    apt-get update && apt-get install firefox-trunk

# Install Chrome
WORKDIR /
RUN curl -fsSL -o ${CHROME_RELEASE}.deb "$CHROME_DOWNLOAD_URL" && \
    echo "$CHROME_RELEASE_SHA256 ${CHROME_RELEASE}.deb" | sha256sum -c - && \
    apt install -y /${CHROME_RELEASE}.deb

# Install RobotFramework
RUN pip3 install --upgrade pip && \
    pip3 install robotframework webdrivermanager robotframework-seleniumlibrary webdrivermanager

RUN webdrivermanager firefox chrome --linkpath /usr/local/bin

COPY robot.robot /
ENTRYPOINT robot robot.robot

