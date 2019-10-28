#!/bin/bash

if [ -n "$PORT" ] ; then  
sed -i "s|^port=.*$|port=${PORT}|g" /etc/fdfs/"$FASTDFS_MODE".conf
fi

if [ -n "$TRACKER_SERVER" ] ; then  

sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/storage.conf
sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/client.conf
sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/mod_fastdfs.conf

fi

if [ -n "$GROUP_NAME" ] ; then  

sed -i "s|group_name=.*$|group_name=${GROUP_NAME}|g" /etc/fdfs/storage.conf

fi

echo "start trackerd"
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf restart

echo "start storage"
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf restart

echo "start nginx"
/usr/local/nginx/sbin/nginx 

tail -f  /dev/null