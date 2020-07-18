# Build
```shell
$ export ES_VERSION=6.0.0
$ docker build -t elasticsearch .
```

# Run
```shell
$ docker run -p 9200:9200 elasticsearch
```
Point browser to http://127.0.0.1:9200/_cluster/health

