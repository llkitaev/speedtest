#!/bin/bash

docker compose -p rbmdkrfinalapp -f app.compose.yml down
docker compose -p rbmdkrfinalefk -f efk.compose.yml down
