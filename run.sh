if [ -n "$1" ] && ! id "$1" >/dev/null 2>&1; then
    useradd -g users -G sudo -d /opt -s /bin/zsh -g users -G sudo $1 && echo "ADDED $1"
    usermod -aG sudo "$1"
    echo "$1 ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

eval "su $1"