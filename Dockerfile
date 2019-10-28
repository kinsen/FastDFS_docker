FROM alpine:3.6

LABEL maintainer "skinsen@gmail.com"

# 备份原始文件
RUN cp /etc/apk/repositories /etc/apk/repositories.bak
# 修改为国内镜像源
RUN echo "http://mirrors.aliyun.com/alpine/v3.6/main/" > /etc/apk/repositories


ENV FASTDFS_PATH=/opt/fdfs \
    FASTDFS_BASE_PATH=/var/fdfs \
    PORT= \
    GROUP_NAME= \
    TRACKER_SERVER=

#get all the dependences
RUN apk update \
        && apk add --no-cache --virtual .build-deps bash gcc libc-dev make openssl-dev pcre-dev zlib-dev linux-headers curl gnupg libxslt-dev gd-dev geoip-dev

#create the dirs to store the files downloaded from internet
RUN mkdir -p ${FASTDFS_PATH}/src \
&& mkdir -p ${FASTDFS_BASE_PATH}/data


# 下载fastdfs、libfastcommon、nginx插件的源码
RUN cd ${FASTDFS_PATH}/src \
	&& curl -fSL https://github.com/happyfish100/libfastcommon/archive/V1.0.41.tar.gz -o fastcommon.tar.gz \
	&& curl -fSL https://github.com/happyfish100/fastdfs/archive/V6.00.tar.gz -o fastfs.tar.gz \
	&& curl -fSL https://github.com/happyfish100/fastdfs-nginx-module/archive/V1.21.tar.gz -o fastdfs-nginx-module.tar.gz \
	&& tar zxf fastcommon.tar.gz \
    && tar zxf fastfs.tar.gz \
    && tar zxf fastdfs-nginx-module.tar.gz


# 安装libfastcommon
RUN cd ${FASTDFS_PATH}/src/libfastcommon-1.0.41 \
	&& ./make.sh \
	&& ./make.sh install


# 安装fastdfs
RUN cd ${FASTDFS_PATH}/src/fastdfs-6.00 \
	&& ./make.sh \
	&& ./make.sh install


# 配置fastdfs: base_dir
RUN cd ${FASTDFS_PATH}/src/fastdfs-6.00 \
	&& cp conf/* /etc/fdfs/


# 获取nginx源码，与fastdfs插件一起编译
RUN cd ${FASTDFS_PATH}/src \
	&& curl -fSL http://nginx.org/download/nginx-1.15.1.tar.gz -o nginx.tar.gz \
	&& tar zxf nginx.tar.gz \
	&& cd ${FASTDFS_PATH}/src/nginx-1.15.1 \
	&& ./configure  --add-module=${FASTDFS_PATH}/src/fastdfs-nginx-module-1.21/src \
	&& make \
	&& make install

# 设置nginx和fastdfs联合环境，并配置nginx
RUN cp ${FASTDFS_PATH}/src/fastdfs-nginx-module-1.21/src/mod_fastdfs.conf /etc/fdfs/ \
	&& sed -i "s|^store_path0.*$|store_path0=${FASTDFS_BASE_PATH}|g" /etc/fdfs/mod_fastdfs.conf \
    && sed -i "s|^url_have_group_name =.*$|url_have_group_name = true|g" /etc/fdfs/mod_fastdfs.conf \
    && echo -e "\
events {\n\
    worker_connections  1024;\n\
}\n\
http {\n\
    include       mime.types;\n\
    default_type  application/octet-stream;\n\
    server {\n\
        listen 80;\n\

        location ~/group([0-9])/M00 {\n\
            ngx_fastdfs_module;\n\
        }\n\
    }\n\
}">/usr/local/nginx/conf/nginx.conf


# 修改配置
RUN cd /etc/fdfs \
	&& sed -i "s|base_path=.*$|base_path=${FASTDFS_BASE_PATH}|g" /etc/fdfs/tracker.conf \
	&& sed -i "s|base_path=.*$|base_path=${FASTDFS_BASE_PATH}|g" /etc/fdfs/storage.conf \
	&& sed -i "s|store_path0=.*$|store_path0=${FASTDFS_BASE_PATH}|g" /etc/fdfs/storage.conf \
	&& sed -i "s|base_path=.*$|base_path=${FASTDFS_BASE_PATH}|g" /etc/fdfs/client.conf \
	&& sed -i "s|store_path0=.*$|store_path0=${FASTDFS_BASE_PATH}|g" /etc/fdfs/mod_fastdfs.conf

#
VOLUME ["$FASTDFS_BASE_PATH", "/etc/fdfs"]
# 默认nginx端口
ENV WEB_PORT 80
# 默认fastdfs端口
ENV FDFS_PORT 22122
# 默认fastdfs端口
EXPOSE 22122 23000 8080 80



COPY start.sh /usr/bin/
#make the start.sh executable 
RUN chmod 777 /usr/bin/start.sh

ENTRYPOINT ["/usr/bin/start.sh"]
CMD ["tracker"]