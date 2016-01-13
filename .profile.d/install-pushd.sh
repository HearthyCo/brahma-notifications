#!/bin/bash

cd /app
git clone git://github.com/rs/pushd.git
cd pushd
PATH=$PATH:/app/.heroku/node/bin/
npm install
cp ../pushd-settings.coffee settings.coffee
