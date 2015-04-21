_ = require 'underscore'
config = require '../config/global'
http = require 'http'

# Sends an event to the pushd server.
sendPush = (evt, payload) ->
  data = JSON.stringify payload
  post_options =
    host: config.pushd.host
    port: config.pushd.port
    path: '/event/' + evt
    method: 'POST'

  req = http.request post_options, (res) ->
    if res.statusCode >= 400
      console.log 'Error posting to postd:', res.statusCode, res.statusMessage
      res.setEncoding 'utf8'
      res.on 'data', (chunk) -> console.log chunk
  req.write data
  req.end()


exports = module.exports =

  send: (data) ->
    sendPush 'test', msg: 'Hola mundo!'

