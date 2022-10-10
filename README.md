# fluentd-mongodb
Fluentd docker image with MongoDB output plugin

## Nginx example usage

Create docker container with access to the NGINX logs

```
docker run -d \
  --name=fluentd \
  -p 24224:24224 \
  -p 24224:24224/udp \
  -v $HOME/fluentd/etc:/fluentd/etc \
  -v $HOME/nginx/logs:/fluentd/nginx_logs \
  --restart unless-stopped \
  gregology/fluentd-mongodb:v1.15
```

Format the NGINX access logs as JSON by adding a log_format to the `http { }` section of `nginx.conf`.

```
    log_format main '{'
        '"timestamp":"$time_iso8601",'
        '"clientip": "$remote_addr",'
        '"size": $body_bytes_sent,'
        '"responsetime": $request_time,'
        '"upstreamtime": "$upstream_response_time",'
        '"upstreamhost": "$upstream_addr",'
        '"http_host": "$host",'
        '"request_method": "$request_method",'
        '"url": "$uri",'
        '"args": "$args",'
        '"xff": "$http_x_forwarded_for",'
        '"referer": "$http_referer",'
        '"agent": "$http_user_agent",'
        '"status": "$status"'
    '}';

    access_log /var/log/nginx/access.log main;
```

Create `fluentd/etc/fluent.conf` using the tail source type, json parse type, and mongo output type.

```
<source>
  @type tail
  path /fluentd/nginx_logs/access.log
  pos_file /fluentd/nginx_logs/access.log.pos # Update this if you do not want to give write access to the NGINX log directory
  tag nginx.access
  <parse>
    @type json
    time_format %Y-%m-%dT%H:%M:%S.%NZ
  </parse>
</source>

<match **>
  @type mongo
  connection_string "mongodb://username:password@mongodbhost:27017/fluentd?authSource=admin"

  collection nginx

  capped
  capped_size 1024m

  <inject>
    time_key time
  </inject>

  <buffer>
    flush_interval 10s
  </buffer>
</match>
```

## Build

```
docker build -t gregology/fluentd-mongodb:v1.15 .
docker push gregology/fluentd-mongodb:v1.15
docker tag gregology/fluentd-mongodb:v1.15 gregology/fluentd-mongodb:latest
docker push gregology/pavlov-server:latest
```