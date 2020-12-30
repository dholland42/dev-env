ARG UBUNTU_VERSION=latest

FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND noninteractive

# general setup
RUN apt-get update
RUN apt-get install -y sudo zsh git vim htop openssh-server less curl gnupg-agent software-properties-common 

# python setup
RUN apt-get install -y python3 python3-pip
RUN ln -s $(which python3) /usr/local/bin/python
RUN ln -s $(which pip3) /usr/local/bin/pip
RUN curl -fsSL -o /opt/omz.sh https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
RUN ZSH=/opt/.zsh sh /opt/omz.sh --unattended
RUN chsh -s /bin/zsh root
RUN mkdir /home/users
RUN cp $HOME/.zshrc /home/users/.zshrc
ENV HOME="/home/users"
RUN chgrp users /home/users
RUN chmod g+w /home/users

COPY run.sh /opt/run.sh

WORKDIR /home/users

RUN echo "umask 002" >> .zshrc

ENTRYPOINT ["/bin/bash", "/opt/run.sh"]

CMD ["root"]