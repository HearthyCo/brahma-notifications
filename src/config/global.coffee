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
    email: process.env.MANDRILL_EMAIL or ''
    apikey: process.env.MANDRILL_APIKEY or ''
  site:
    name: process.env.SITE_NAME or ''
    email: process.env.CONTACT_EMAIL or ''
    url: process.env.PUBLIC_URL or ''
    brand: process.env.BRAND or ''
  pushd:
    host: 'localhost'
    port: 2407

module.exports = exports = config