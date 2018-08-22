#!/bin/bash

set -euo pipefail

# Validate environment variables
: "${UPSTREAM:?Set UPSTREAM using --env}"
: "${UPSTREAM_PORT?Set UPSTREAM_PORT using --env}"
PROTOCOL=${PROTOCOL:=HTTP}
FORWARD_HOST_HEADER=${FORWARD_HOST_HEADER:=TRUE}

cat <<EOF >/etc/nginx/nginx.conf
user nginx;
worker_processes 2;

events {
  worker_connections 1024;
}
EOF

SET_HOST_HEADER=""
if [ "$FORWARD_HOST_HEADER" = "TRUE" ]; then
    SET_HOST_HEADER="proxy_set_header Host \$host;"
fi

if [ "$PROTOCOL" = "HTTP" ]; then
cat <<EOF >>/etc/nginx/nginx.conf

http {
  log_format main '\$proxy_add_x_forwarded_for - \$remote_user [\$time_local] '
'"\$request" \$status \$body_bytes_sent "\$http_referer" '
'"\$http_user_agent"' ;

  access_log /var/log/nginx/access.log main;
  error_log /var/log/nginx/error.log;

  server {
    location / {
      proxy_pass http://${UPSTREAM}:${UPSTREAM_PORT};
      ${SET_HOST_HEADER}
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
  }
}
EOF
elif [ "$PROTOCOL" == "TCP" ]; then
cat <<EOF >>/etc/nginx/nginx.conf

stream {
  server {
    listen ${UPSTREAM_PORT};
    proxy_pass ${UPSTREAM}:${UPSTREAM_PORT};
  }
}
EOF
else
echo "Unknown PROTOCOL. Valid values are HTTP or TCP."
fi

echo "Forward the requests host header: ${FORWARD_HOST_HEADER}"
echo "Start ${PROTOCOL} Proxy for ${UPSTREAM}:${UPSTREAM_PORT}"

# Launch nginx in the foreground
/usr/sbin/nginx -g "daemon off;"
