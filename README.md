qgis3-server-docker
============================

Container for QGIS 3 Server

# Building

You can build the image with:

```bash
docker build -t qgis-server .
```

# Stable container

Due to issues on QT > 5.6, the recommended container is Dockerfile.xenial-nginx

```bash
docker build -t elpaso/qgis3-server:xenial-nginx -f Dockerfile.xenial-nginx  .
```
