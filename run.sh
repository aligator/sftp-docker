#!/bin/sh

USERNAME=${USERNAME:sftp}
OWNER=${OWNER:-65534}
GROUP=${GROUP:-65534}

case $USERNAME in
  (*[![:alnum:]]*) echo "invalid username" && exit 1;;
  (*[[:alpha:]]*) true;;
  (*) echo "invalid username" && exit 1;;
esac

# create users matching ids passed if necessary
if [[ ${GROUP} -ne 65534 && ${GROUP} -ge 1000 ]]; then
  if getent group ${GROUP} ; then delgroup $(getent group 1000 | cut -d: -f1); fi
  addgroup -g $GROUP $USERNAME
fi

if [[ ${OWNER} -ne 65534 && ${OWNER} -ge 1000 ]]; then
  if getent passwd ${OWNER} ; then deluser $(getent passwd ${OWNER} | cut -d: -f1); fi
  adduser -D -u $OWNER -s /sbin/nologin -G $USERNAME -h /ssh-home $USERNAME
  
  # set a password to unlock the account (as sshd does not allow login to locked accounts)
  pw=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
  echo "$USERNAME:$pw" | chpasswd
  chown root:root /ssh-home
fi

# create the data directory if necessary
if [ ! -d /ssh-home/data ]; then
  mkdir /ssh-home/data
  chown $OWNER:$GROUP /ssh-home/data
fi

# copy overwrite files if they exist
if [ -f /overwrite/authorized_keys ]; then
  cp /overwrite/authorized_keys /etc/ssh/authorized_keys/$USERNAME
  chmod 600 /etc/ssh/authorized_keys/$USERNAME
  chown $OWNER:$GROUP /etc/ssh/authorized_keys/$USERNAME
fi
if [ -f /overwrite/sshd_config ]; then
  cp /overwrite/sshd_config /etc/ssh/sshd_config
fi
if [ -f /overwrite/ssh_host_ed25519_key ]; then
  cp /overwrite/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key
fi
if [ -f /overwrite/ssh_host_rsa_key ]; then
  cp /overwrite/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key
fi

# generate the host keys if they were not provided or still exist from the last time
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key < /dev/null
  rm /etc/ssh/ssh_host_ed25519_key.pub
fi
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key < /dev/null
  rm /etc/ssh/ssh_host_rsa_key.pub
fi

echo setup finished
exec /usr/sbin/sshd -D "$@"
