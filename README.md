# SFTP for docker

This is a small docker image which just provides a simple sftp server.
It starts sshd but disables normal ssh access. Instead you can mount any data at /ssh-home/data
which will be accessible using sftp.

Currently it does only provide access using private keys because for me there was no need for
username + password, but this would be very easy to implement if needed...

## Usage

Just see the example docker-compose.yml it basically shows everything you need:
* expose port 22
* mount data to /ssh-home/data
* mount override to /override
* set the environment variables for uid, gid and username

Then you just need to provide any public keys by creating a `overwrite/authorized_keys` file.
It will be copied (if it exists) into the container on each start. That way you can also edit it and with the next
restart it will be copied into the container.

Similar to that you can also provide a custom `overwrite/sshd_config` file which will also be treated the same way to 
inject a custom sshd config into the container.

The host keys get built automatically on the first start. But you can also run `cd overwrite && ./genHostKeys.sh` to 
even preserve the keys on container rebuilt.
