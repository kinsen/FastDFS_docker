# README

本项目基于 FastDFS 6.0 构建一个docker环境，建议用于开发环境或单一节点环境。因为docker内部分配的ip是内部ip，如果是分布式扩展，此ip无法访问。

## how to run

```
mkdir -p var/fdfs/tracker && mkdir -p /var/fdfs/storage0/data
docker-compose up --build
```

## 参考
[使用docker-compose一键部署分布式文件系统fastdfs](https://www.centos.bz/2017/12/%E4%BD%BF%E7%94%A8docker-compose%E4%B8%80%E9%94%AE%E9%83%A8%E7%BD%B2%E5%88%86%E5%B8%83%E5%BC%8F%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9Ffastdfs/)
[利用FastDFS搭建文件服务Docker一键启动集成版](https://juejin.im/post/5cee1de4f265da1bd04ec1df)

https://github.com/luhuiguo/fastdfs-docker

