URL = require 'url'

# AMQP
amqp_env = process.env.AMQP_PORT || 'amqp://localhost:5672'
amqp = URL.parse amqp_env, true

# Protocol defaults to amqp:
amqp.protocol = 'amqp:'

config =
  env: process.env.NODE_ENV || 'development'
  amqp:
    url: URL.format amqp
  mandrill:
    email: 'ignacio@glue.gl'
    apikey: 'A6dtZPAhlL2K_VDtyyhYVQ'
  site:
    name: process.env.SITE_NAME || 'hearthy'
    email: process.env.CONTACT_EMAIL || 'hola@glue.gl'
    url: process.env.PUBLIC_URL || 'http://hearthy-client-dev.dev01.glue.gl'
    brand: process.env.BRAND || 'Hearthy'

module.exports = exports = config