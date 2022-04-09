#!/bin/sh
set -eu

echo 'SERVER_URL = "'${ROBOCOOK_SERVER_URL}'"' > /var/www/html/env.js

exec caddy file-server