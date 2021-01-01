ARG VERSION=latest

FROM tensorflow/tensorflow:${VERSION}

ENV DEBIAN_FRONTEND noninteractive

# general setup
RUN apt-get update
RUN apt-get install -y sudo zsh git vim htop openssh-server less curl gnupg-agent software-properties-common 

# set up shared home directory users
ENV USERHOME=/home/users
RUN mkdir $USERHOME

# zsh setup
RUN curl -fsSL -o /opt/omz.sh https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
RUN ZSH=/opt/.zsh sh /opt/omz.sh --unattended
RUN chsh -s /bin/zsh root

# get poetry and ignore virtual envs because we're in a container
ENV POETRY_HOME=/opt/poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
RUN chmod a+x /opt/poetry/bin/poetry
RUN echo 'export PATH="$PATH:/opt/poetry/bin"' >> $HOME/.zshrc

# set up the shared home directory
RUN cp $HOME/.zshrc $USERHOME/.zshrc
RUN chgrp users $USERHOME
RUN chmod g+w $USERHOME

COPY run.sh /opt/run.sh

RUN echo "umask 002" >> $USERHOME/.zshrc

WORKDIR $USERHOME

ENTRYPOINT ["/bin/bash", "/opt/run.sh"]

CMD ["root"]
