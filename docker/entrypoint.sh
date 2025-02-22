#!/bin/bash

set -e
set -x

# Cleanup
rm -rf /var/www/html/*

# Copy frontend files
cp /speedtest/*.js /var/www/html/
cp /speedtest/*.ico /var/www/html/

# Set up backend side for standlone modes
if [ "$MODE" == "standalone" ]; then
  cp -r /speedtest/backend/ /var/www/html/backend
  if [ ! -z "$IPINFO_APIKEY" ]; then
    sed -i s/\$IPINFO_APIKEY=\"\"/\$IPINFO_APIKEY=\"$IPINFO_APIKEY\"/g /var/www/html/backend/getIP_ipInfo_apikey.php
  fi
fi

if [ "$MODE" == "backend" ]; then
  cp -r /speedtest/backend/* /var/www/html
  if [ ! -z "$IPINFO_APIKEY" ]; then
    sed -i s/\$IPINFO_APIKEY=\"\"/\$IPINFO_APIKEY=\"$IPINFO_APIKEY\"/g /var/www/html/getIP_ipInfo_apikey.php
  fi
fi


# Set up index.php for frontend-only or standalone modes
if [ "$MODE" == "frontend" ]; then
  cp /speedtest/frontend.php /var/www/html/index.php
elif [ "$MODE" == "standalone" ]; then
  cp /speedtest/standalone.php /var/www/html/index.php
fi

# Apply Telemetry settings when running in standalone or frontend mode and telemetry is enabled
if [[ "$TELEMETRY" == "true" && ( "$MODE" == "frontend" || "$MODE" == "standalone" ) ]]; then
  cp -r /speedtest/results /var/www/html/results

  sed -i s/\$db_type=\".*\"/\$db_type=\"$DB_TYPE\"\/g /var/www/html/results/telemetry_settings.php
  sed -i s/\$stats_password=\".*\"/\$stats_password=\"$STATS_PASSWORD\"/g /var/www/html/results/telemetry_settings.php
  sed -i s/\$PostgreSql_username=\".*\"/\$PostgreSql_username=\"$POSTGRES_USER\"/g /var/www/html/results/telemetry_settings.php
  sed -i s/\$PostgreSql_password=\".*\"/\$PostgreSql_password=\"$POSTGRES_PASSWORD\"/g /var/www/html/results/telemetry_settings.php
  sed -i s/\$PostgreSql_hostname=\".*\"/\$PostgreSql_hostname=\"$POSTGRES_HOST\"/g /var/www/html/results/telemetry_settings.php
  sed -i s/\$PostgreSql_databasename=\".*\"/\$PostgreSql_databasename=\"$POSTGRES_DB\"/g /var/www/html/results/telemetry_settings.php

  if [ "$ENABLE_ID_OBFUSCATION" == "true" ]; then
    sed -i s/\$enable_id_obfuscation=.*\;/\$enable_id_obfuscation=true\;/g /var/www/html/results/telemetry_settings.php
  fi

  if [ "$REDACT_IP_ADDRESSES" == "true" ]; then
    sed -i s/\$redact_ip_addresses=.*\;/\$redact_ip_addresses=true\;/g /var/www/html/results/telemetry_settings.php
  fi

  mkdir -p /database/
  chown www-data /database/
fi

echo "Starting NGINX Unit..."
/usr/local/bin/docker-entrypoint.sh unitd --no-daemon --control unix:/var/run/control.unit.sock
