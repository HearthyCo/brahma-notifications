#!/bin/bash

# Open pushd as a background thread
cd pushd
coffee pushd.coffee &
cd ..

# Start our server as the foreground thread
npm start
