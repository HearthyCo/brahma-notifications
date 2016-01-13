# Parse redis url
URL = require 'url'
redis_env = process.env.REDIS_URL or
  process.env.REDIS_PORT or
  process.env.REDIS_PORT_6379_TCP or
  'tcp://localhost:6379'
redis_url = URL.parse redis_env, true

console.log 'Trying redis at:', redis_url.hostname + ':' + redis_url.port

# Exports
exports.server =
  redis_port: redis_url.port
  redis_host: redis_url.hostname
  tcp_port: 2407
  udp_port: 2407
  listen_ip: '127.0.0.1'
  access_log: yes
  acl:
    publish: ['127.0.0.1', '10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16']

exports['event-source'] =
  enabled: yes

exports['apns'] =
  enabled: no
  #enabled: yes
  class: require('./lib/pushservices/apns').PushServiceAPNS
  #cert: '/mnt/pushd/cert.pem'
  #key: '/mnt/pushd/key.pem'
  cacheLength: 100
  payloadFilter: ['messageFrom', 'news_id']
  gateway: process.env['APN_PUSH_GATEWAY']
  address: process.env['APN_FEEDBACK_ADDRESS']

exports['gcm'] =
  enabled: yes
  class: require('./lib/pushservices/gcm').PushServiceGCM
  key: process.env['GCM_API_KEY']

exports['http'] =
  enabled: no

exports['mpns-toast'] =
  enabled: no

exports['mpns-tile'] =
  enabled: no

exports['mpns-raw'] =
  enabled: no

exports['loglevel'] = process.env['LOGLEVEL'] or 'info'
