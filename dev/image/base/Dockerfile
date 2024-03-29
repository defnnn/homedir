ARG IMAGE

FROM $IMAGE

USER root

ARG DEBIAN_FRONTEND=noninteractive

ENV HOME=/root
ENV container docker

RUN dpkg-divert --local --rename --add /sbin/udevadm && ln -s /bin/true /sbin/udevadm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        openssh-server ca-certificates tzdata locales git curl rsync unzip \
        gpg gpg-agent dirmngr scdaemon pass pass-extension-otp git-crypt oathtool \
        tmux vim-nox less \
        build-essential \
        python3-venv python3-pip \
        docker.io \
    && rm -f /usr/bin/gs

RUN ln -nfs /usr/bin/git-crypt /usr/local/bin/

RUN echo GatewayPorts clientspecified >> /etc/ssh/sshd_config
RUN echo StreamLocalBindUnlink yes >> /etc/ssh/sshd_config

RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && locale-gen en_US.UTF-8 \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN groupadd -g 1000 app
RUN useradd -u 1000 -d /home/app -s /bin/bash -g app -M app
RUN groupadd -g 121 ducker
RUN usermod -a -G ducker app
RUN usermod -a -G docker app
RUN mkdir -p /run/sshd && chown -hR app:app /run /etc/ssh
RUN install -d -m 0700 -o app -g app /home/app
RUN install -d -m 0700 -o app -g app /home/app/.ssh

RUN curl -sSL -o /usr/local/bin/hof https://github.com/hofstadter-io/hof/releases/download/v0.5.17/hof_0.5.17_Linux_x86_64 && chmod 755 /usr/local/bin/hof

RUN curl -sSL -o awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip && unzip awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip

RUN curl -sSL https://packagecloud.io/install/repositories/segment/aws-okta/script.deb.sh | bash && apt-get install -y aws-okta

USER app
WORKDIR /home/app
ENV HOME=/home/app

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LANGUAGE en_US:en
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

COPY VERSION /VERSION
RUN git clone https://github.com/amanibhavam/homedir homedir && mv homedir/.git . && rm -rf homedir && git reset --hard && make pod

RUN echo cue 0.4.1-beta.6 >> .tool-versions
RUN echo kubectl 1.21.8 >> .tool-versions
RUN echo kustomize 4.2.0 >> .tool-versions
RUN echo krew 0.4.2 >> .tool-versions
RUN echo helm 3.7.1 >> .tool-versions
RUN echo kubectx 0.9.4 >> .tool-versions
RUN echo tilt 0.23.4 >> .tool-versions
RUN echo k9s 0.25.16 >> .tool-versions
RUN echo jq 1.6 >> .tool-versions
RUN echo aws-vault 6.3.1 >> .tool-versions

RUN for a in cue kubectl kustomize krew helm kubectx tilt k9s jq aws-vault; do bin/env.sh asdf plugin-add $a; bin/env.sh asdf install $a; done

RUN bin/env.sh kubectl krew update && bin/env.sh kubectl krew install stern ctx ns get-all && bin/env.sh asdf reshim krew

RUN ln -nfs /mnt/work .

COPY default.json /mnt/.password-store/powerline/default.json

COPY --chown=app:app service /service
RUN chmod 755 /service

ENTRYPOINT [ "/service" ]
