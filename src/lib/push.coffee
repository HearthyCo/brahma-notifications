_ = require 'underscore'
config = require '../config/global'
http = require 'http'

# Sends an event to the pushd server.
sendPush = (evt, payload) ->
  data = JSON.stringify payload
  console.log 'Data:', data
  post_options =
    host: config.pushd.host
    port: config.pushd.port
    path: '/event/' + evt
    method: 'POST'
    headers:
      'Content-Type': 'application/json'

  req = http.request post_options, (res) ->
    if res.statusCode >= 400
      console.log 'Error posting to postd:', res.statusCode, res.statusMessage
      res.setEncoding 'utf8'
      res.on 'data', (chunk) -> console.log chunk
  req.write data
  req.end()


exports = module.exports =

  sendUndelivered: (data) ->
    console.log 'Send:', data
    session = data.message.session
    for i in data.undelivered
      sendPush i,
        'title': 'New message'
        'msg': 'You have unread messages.'
        'data.type': 'message'
        'data.session': ''+session

