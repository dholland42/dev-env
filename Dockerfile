FROM debian:stable-slim AS devbase

ARG USER=dev

ENV DEBIAN_FRONTEND=noninteractive

# general setup
RUN apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade && apt-get install -y sudo zsh git vim htop less curl tmux && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local" sh

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

USER $USER

WORKDIR $USERHOME

COPY --chmod=755 scripts/install-rust /usr/local/bin/

# get nvm and install nodejs
ENV NVM_DIR=$USERHOME/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# RUN . "$NVM_DIR/nvm.sh" && nvm install 20 && nvm use 20

# install rust
ENV PATH="$PATH:$USERHOME/.cargo/bin"
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y

ADD .tmux.conf $USERHOME

CMD [ "zsh" ]

FROM devbase AS dev

ENV DEBIAN_FRONTEND=noninteractive
ARG USER
ARG CACHE_BUST

ENV USERHOME=/home/$USER
WORKDIR $USERHOME

COPY --chmod=755  --chown=$USER:$USER download-vs-code-server.sh .
RUN ./download-vs-code-server.sh && rm download-vs-code-server.sh
ENV PATH=$USERHOME/.vscode-server/bin/default_version/bin:$PATH
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-toolsai.jupyter
RUN code-server --install-extension svelte.svelte-vscode
RUN code-server --install-extension bradlc.vscode-tailwindcss
RUN code-server --install-extension rust-lang.rust-analyzer
RUN code-server --install-extension charliermarsh.ruff

CMD ["zsh"]
