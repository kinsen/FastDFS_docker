
# FastDFS安装

基于 Centos6.5

## 安装libfastcommon

```bash
#安装依赖包：yum install -y libevent

wget https://github.com/happyfish100/libfastcommon/archive/V1.0.41.tar.gz
tar -zxvf V1.0.41
cd libfastcommon-1.0.41
./make.sh
./make.sh install
```

## 安装 fastdfs

```bash
wget https://github.com/happyfish100/fastdfs/archive/V6.00.tar.gz
tar -zxvf V6.00
cd fastdfs-6.00
./make.sh
./make.sh install

cp conf/tracker.conf conf/storage.conf conf/client.conf /etc/fdfs/
cp conf/http.conf conf/mime.types /etc/fdfs/
sed -i 's/base_path=\/home\/yuqing\/fastdfs/base_path=\/opt\/fastdfs\/tracker\/data-and-log/g' /etc/fdfs/tracker.conf
sed -i 's/base_path=\/home\/yuqing\/fastdfs/base_path=\/opt\/fastdfs\/storage\/data-and-log/g' /etc/fdfs/storage.conf
sed -i 's/store_path0=\/home\/yuqing\/fastdfs/store_path0=\/opt\/fastdfs\/storage\/images-data/g' /etc/fdfs/storage.conf
# update tracker_server config
sed -i 's/base_path=\/home\/yuqing\/fastdfs/base_path=\/opt\/fastdfs\/client\/data-and-log/g' /etc/fdfs/client.conf
# update tracker_server config

mkdir -p /opt/fastdfs/tracker/data-and-log
mkdir -p /opt/fastdfs/storage/data-and-log
mkdir -p /opt/fastdfs/storage/images-data
mkdir -p /opt/fastdfs/client/data-and-log

#start the tracker server:
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf restart
#in Linux, you can start fdfs_trackerd as a service:
/sbin/service fdfs_trackerd start


#start the storage server:
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf restart
#in Linux, you can start fdfs_storaged as a service:
/sbin/service fdfs_storaged start

#run the client test program:
/usr/bin/fdfs_test <client_conf_filename> <operation>
/usr/bin/fdfs_test1 <client_conf_filename> <operation>
#for example, upload a file:
/usr/bin/fdfs_test conf/client.conf upload /usr/include/stdlib.h

#run the monitor program:
/usr/bin/fdfs_monitor <client_conf_filename>

```

## 编译安装 nginx

```bash

wget https://github.com/happyfish100/fastdfs-nginx-module/archive/V1.21.tar.gz
tar -zxvf V1.21
cp fastdfs-nginx-module-1.21/src/mod_fastdfs.conf /etc/fdfs/
sed -i 's/store_path0=\/home\/yuqing\/fastdfs/store_path0=\/opt\/fastdfs\/storage\/images-data/g' /etc/fdfs/mod_fastdfs.conf
# modify url_have_group_name=true

wget http://nginx.org/download/nginx-1.15.1.tar.gz
tar -zxvf nginx-1.15.1.tar.gz
cd nginx-1.15.1

yum install -y gcc gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel

./configure  --add-module=../fastdfs-nginx-module-1.21/src

make; make install

```

## 修改nginx配置

```conf
# 拦截包含 /group1/M00 请求，使用 fastdfs 这个 Nginx 模块进行转发
location /group1/M00 {
    ngx_fastdfs_module;
}
```

----
参考

https://github.com/judasn/Linux-Tutorial/blob/master/markdown-file/FastDFS-Install-And-Settings.md

https://github.com/happyfish100/fastdfs/blob/master/INSTALL
https://github.com/happyfish100/fastdfs-nginx-module/blob/master/INSTALL
https://github.com/happyfish100/libfastcommon/blob/master/INSTALL
