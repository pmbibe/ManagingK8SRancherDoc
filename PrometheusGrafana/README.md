 Because Grafana container run as user who has UID is 472 and GID is 472. We have to change owner of path mounted.  
chown 472:472 /data
