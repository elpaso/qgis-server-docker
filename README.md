qgis-server-docker
============================

This is a simple container for testing QGIS Server, slightly inspired by:
https://github.com/kartoza/docker-qgis-server (many thanks to Tim and Richard)

**Note** this is not intended to be used in production

# Features

Both `CGI` and `FastCGI` endpoints are provided, `CGI` is particularly useful for testing
plugins because it reloads all plugins on each request while `FastCGI` requires
apache reloading.

**WFS-T** is enabled (no authentication required).

*QGIS Server Browser* plugin is installed by deafult for a quick preview of layers.


# Building

You can build the image with:

```
# Place your IP address here, if you want to use apt-catcher, or comment
# it out in the Dockerfile
$ export ADDR=192.168.1.1
$ docker build -t docker-qgis-server-boundless  --build-arg APT_CATCHER_IP=$ADDR .
```

# Running

To run a container, assuming that you want it available on host port 8081 do:

```
$ docker run -p 8081:80 -it --name docker-qgis-server-boundless  docker-qgis-server-boundless
```

You might want to mount the `/web` folder as a local volume that contains your
QGIS projects and makes logs easily accessible.


```
docker run -p 8081:80 -it --name docker-qgis-server-boundless \
    -v <path_to_local_web_folder>::/web\
    docker-qgis-server-boundless
```

Replace ``<path_to_local_web_folder>`` with an absolute path on your
filesystem.


# Example folder structure


The `/web` example folder contains:

* the *QGIS Server Browser* plugin, that provides a simple project browser (see: http://www.itopen.it/qgis-server-simple-browser-plugin/).
* the QGIS project **helloworld** with all its data


The provided example `/web` folder structure is:

```
web/
├── htdocs             # Your HTML docs
│   └── index.html
├── logs               # Server logs (apache and QGIS)
│   ├── access.log
│   ├── error.log
│   ├── qgis-cgi.log
│   └── qgis-fcgi.log
├── plugins            # Server plugins
│   └── qgis-server-simple-browser-master
└── projects           # QGIS projects
    ├── helloworld.qgs
    ├── world.dbf
    ├── world.prj
    ├── world.qix
    ├── world.shp
    └── world.shx
```


# Endpoints


## FastCGI, example project
http://localhost:8081/cgi-bin/qgis_mapserv.fcgi?MAP=/web/projects/helloworld.qgs&SERVICE=WMS&REQUEST=GetProjectsettings
## CGI, example project
http://localhost:8081/cgi-bin/qgis_mapserv.cgi?MAP=/web/projects/helloworld.qgs&SERVICE=WMS&REQUEST=GetProjectsettings


------------------
Alessandro Pasotti
