#!/bin/bash
docker-compose down
rm -rf ../database/
docker-compose up -d