FROM ubuntu:20.04

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
RUN cp $HOME/.zshrc /opt/.zshrc
RUN chgrp users /opt
RUN chmod g+w /opt


COPY run.sh /opt/run.sh

WORKDIR /opt

RUN echo "umask 002" >> .zshrc

ENTRYPOINT ["/bin/bash", "/opt/run.sh"]

CMD ["root"]