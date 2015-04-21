URL = require 'url'

# AMQP
amqp_env = process.env.AMQP_PORT or 'amqp://localhost:5672'
amqp = URL.parse amqp_env, true

# Protocol defaults to amqp:
amqp.protocol = 'amqp:'

config =
  env: process.env.NODE_ENV or 'development'
  amqp:
    url: URL.format amqp
    exchange: 'amq.topic'
    keys: ['#']
  mandrill:
    email: 'ignacio@glue.gl'
    apikey: 'A6dtZPAhlL2K_VDtyyhYVQ'
  site:
    name: process.env.SITE_NAME or 'hearthy'
    email: process.env.CONTACT_EMAIL or 'hola@glue.gl'
    url: process.env.PUBLIC_URL or 'http://hearthy-client-dev.dev01.glue.gl'
    brand: process.env.BRAND or 'Hearthy'
  pushd:
    host: 'localhost'
    port: 2407

module.exports = exports = config