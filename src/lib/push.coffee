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
    console.log 'Undelivered message; Session:',
      data.message.session, 'Users:', data.undelivered
    session = data.message.session
    for i in data.undelivered
      # TODO: Use translations instead of hardcoding everything.
      sendPush i,
        'title': 'New message'
        'title.es': 'Nuevo mensaje'
        'msg': 'You have unread messages.'
        'msg.es': 'Tienes mensajes sin leer.'
        'data.type': 'message'
        'data.session': ''+session

  sendFinished: (data) ->
    console.log 'Session finished; Session:',
      data.sessionId, 'Users:', data.clients
    session = data.sessionId
    for i in data.clients
      sendPush i,
        'title': 'Session finished'
        'title.es': 'Sesión finalizada'
        'msg': 'You have received your session report.'
        'msg.es': 'Has recibido el informe de tu sesión.'
        'data.type': 'finished'
        'data.session': ''+session
