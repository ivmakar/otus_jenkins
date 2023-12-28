FROM ivmak/otus:1

RUN curl -O https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip \
&& unzip ./commandlinetools-linux-8512546_latest.zip -d /sdk \
&& rm ./commandlinetools-linux-8512546_latest.zip \
&& export ANDROID_SDK_ROOT=/sdk \
&& export ANDROID_HOME=/sdk \
&& export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/bin \
&& yes | sdkmanager --sdk_root=/sdk --licenses

COPY ./gradle-profiler-0.20.0 /gradle-profiler

RUN export PATH=$PATH:/gradle-profiler

USER jenkins
