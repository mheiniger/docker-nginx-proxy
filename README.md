# docker-nginx-proxy

Proxies requests using Nginx


```
docker run -it -p 8000:80 -e "UPSTREAM=somehost.com" -e "UPSTREAM_PORT=80" mheiniger/nginx-proxy
```

Set the variables:
- UPSTREAM: a hostname
- UPSTREAM_PORT: a port
- PROTOCOL: HTTP or TCP (defaults to HTTP)
- FORWARD_HOST_HEADER: 
  - TRUE (default): Forward the host header from the request/browser
  - FALSE: Set the host header to the same as UPSTREAM


Credits:
The initial code was found on https://github.com/getcarina/examples/tree/master/nginx-proxy
