#!/bin/bash

docker compose -p rbmdkrfinalefk -f efk.compose.yml up -d --no-deps --build
sleep 10
docker compose -p rbmdkrfinalapp -f app.compose.yml up -d --no-deps --force-recreate --build
