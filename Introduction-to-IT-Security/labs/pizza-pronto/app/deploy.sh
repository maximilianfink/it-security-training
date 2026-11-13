#!/bin/sh
# Luca's "deployment pipeline": always fetch the latest dependencies, then start the shop.
echo "[deploy] installing dependencies ..."
npm install --no-package-lock --no-audit --no-fund
echo "[deploy] starting shop ..."
exec node server.js
