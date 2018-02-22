autossh -M 11166 -o “PubkeyAuthentication=yes” -o “PasswordAuthentication=no” -i /root/.ssh/id_rsa -R 6667:localhost:22 root@10.10.37.14


scp /root/.ssh/id_rsa.pub root@10.10.37.14:/root/autossh
