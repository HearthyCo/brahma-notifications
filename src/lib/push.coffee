_ = require 'underscore'
config = require '../config/global'
http = require 'http'

# Sends an event to the pushd server.
pushdPost = (path, payload, callback) ->
  data = JSON.stringify payload
  post_options =
    host: config.pushd.host
    port: config.pushd.port
    path: path
    method: 'POST'
    headers:
      'Content-Type': 'application/json'

  req = http.request post_options, (res) ->
    str = ''
    res.on 'data', (chunk) -> str += chunk
    res.on 'end', ->
      if res.statusCode >= 400
        console.warn 'Error posting to postd:', res.statusCode,
          res.statusMessage
        console.warn str
      else
        console.log 'Pushd:', path
      callback JSON.parse str if callback
  req.write data
  req.end()

exports = module.exports =

  sendUndelivered: (data) ->
    console.log 'Undelivered message; Session:',
      data.message.session, 'Users:', data.undelivered
    session = data.message.session
    for i in data.undelivered
      # TODO: Use translations instead of hardcoding everything.
      pushdPost '/event/' + i,
        'title': 'New message'
        'title.es': 'Nuevo mensaje'
        'msg': 'You have unread messages.'
        'msg.es': 'Tienes mensajes sin leer.'
        'data.type': 'message'
        'data.session': ''+session
        'badge': 1

  sendFinished: (data) ->
    console.log 'Session finished; Session:',
      data.sessionId, 'Users:', data.clients
    session = data.sessionId
    for i in data.clients
      pushdPost '/event/' + i,
        'title': 'Consultation finished'
        'title.es': 'Consulta finalizada'
        'msg': 'You have received your consultation report.'
        'msg.es': 'Has recibido el informe de tu consulta.'
        'data.type': 'finished'
        'data.session': ''+session

  update: (data) ->
    console.log 'Push subscriptions update:', data
    pushdPost '/subscribers/', _.omit(data, 'uid'), (ret) ->
      if data.uid
        url = '/subscriber/' + ret.id + '/subscriptions'
        payload = {}
        payload[data.uid] = {}
        pushdPost url, payload

