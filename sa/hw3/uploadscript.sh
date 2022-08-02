#!/usr/local/bin/bash
if [[ $1 =~ .*\.exe ]]; then
        mv $1 /home/ftp/hidden/.exe/
        ip=$(cat /var/log/pureftpd/login.log | grep $UPLOAD_VUSER | awk -F'@' 'END{split($2,a,")"); print a[1]}')
        logger -t ftpuscr -p local0.notice "$1 violate file detected. Uploaded by $UPLOAD_VUSER. From $ip."
fi
