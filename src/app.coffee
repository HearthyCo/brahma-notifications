#!/usr/bin/env node

amqp = require 'amqplib'
all = (require 'when').all
actionsList = require './lib/actions'
utils = require './lib/utils'
config = require './config/global'
email = require './lib/email'

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

  try data = JSON.parse msg.content.toString()
  catch e then console.error e

  console.log 'AMQP Received:', key

  actions = utils.resolve key, actionsList

  action data for action in actions if actions?
  console.warn key, 'does not exists in actions' if not actions?