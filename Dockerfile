ARG UBUNTU_VERSION=22.04

FROM ubuntu:$UBUNTU_VERSION as cpu

ARG UBUNTU_VERSION

ARG USER=dev

ENV DEBIAN_FRONTEND noninteractive

# general setup
RUN apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade
RUN apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
RUN apt-get install -y sudo zsh git vim htop openssh-server less curl gnupg-agent software-properties-common 
RUN apt-get install -y \
        make \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        wget \
        curl \
        llvm \
        libncurses5-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libffi-dev \
        liblzma-dev \
        # python-openssl \
        git \
        tmux \
    && rm -rf /var/lib/apt/lists/*

# set up shared home directory users
ENV USERHOME=/home/$USER
RUN mkdir $USERHOME

RUN useradd -d $USERHOME -s /bin/zsh $USER
RUN usermod -aG sudo $USER
RUN echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# zsh setup
RUN curl -fsSL -o /opt/omz.sh https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
RUN ZSH=/opt/.zsh sh /opt/omz.sh --unattended
RUN chsh -s /bin/zsh root

# set up the home directory
RUN cp /root/.zshrc $USERHOME/.zshrc
RUN sed -i 's/robbyrussell/half-life/g' $USERHOME/.zshrc
RUN chown -R $USER $USERHOME
RUN chgrp users $USERHOME
RUN chmod g+w $USERHOME
RUN echo "umask 002" >> $USERHOME/.zshrc

# get google cloud utils
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-cli -y

USER $USER

WORKDIR $USERHOME

ARG PYTHON_VERSION=3.11

# pyenv setup
ENV PYENV_ROOT=$USERHOME/.pyenv
ENV PATH=$PYENV_ROOT/bin:$PATH
RUN curl https://pyenv.run | bash
RUN echo 'eval "$(pyenv init -)"' >> $USERHOME/.zshrc
RUN echo $PYTHON_VERSION
RUN pyenv install $PYTHON_VERSION
RUN pyenv global $PYTHON_VERSION
ENV PATH=$USERHOME/.pyenv/shims:$PATH
ENV PYENV_SHELL=zsh
ENV PATH=$PATH:$USERHOME/.local/bin

# pipx
RUN pip install pipx
RUN pipx install poetry
RUN pipx install maturin

# # get poetry
# ENV POETRY_HOME=$USERHOME/.poetry
# RUN curl -sSL https://install.python-poetry.org | python3 -
# ENV PATH=$PATH:$USERHOME/.poetry/bin

# get nvm and install nodejs
ENV NVM_DIR=$USERHOME/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" && nvm install 20 && nvm use 20

# install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y


ADD download-vs-code-server.sh $USERHOME
ADD .tmux.conf $USERHOME
RUN cd $USERHOME && sudo chmod a+x download-vs-code-server.sh && ./download-vs-code-server.sh && rm download-vs-code-server.sh
ENV PATH=$USERHOME/.vscode-server/bin/default_version/bin:$PATH
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-toolsai.jupyter
RUN code-server --install-extension svelte.svelte-vscode
RUN code-server --install-extension bradlc.vscode-tailwindcss
RUN code-server --install-extension rust-lang.rust-analyzer
RUN code-server --install-extension charliermarsh.ruff


CMD ["zsh"]
