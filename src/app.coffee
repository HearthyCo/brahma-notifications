#!/usr/bin/env node

amqp = require 'amqplib'
all = (require 'when').all
utils = require './lib/utils'
config = require './lib/config'

###
  AMQP --------------------------------------------------------------
###
exchange = 'amq.topic'
keys = ['#']

amqp.connect(config.amqp.url).then (conn) ->
  conn.createChannel().then (ch) ->
    ok = ch.assertExchange exchange, 'topic', durable: true
    ok = ok.then -> ch.assertQueue '', exclusive: true
    ok = ok.then (qok) ->
      queue = qok.queue
      t = all keys.map (rk) -> ch.bindQueue queue, exchange, rk
      t.then -> queue
    ok = ok.then (queue) -> ch.consume queue, amqpHandler
    return ok.then -> console.info 'AMQP listening'
.then null, console.error

amqpHandler = (msg) ->
  key = msg.fields.routingKey
  try
    data = JSON.parse msg.content.toString()
  catch e
    console.error e
  console.log 'AMQP Received:', key, data

  switch key
    when 'user.register' console.log 'user.register', data
    when 'user.recover' console.log 'user.recover', data