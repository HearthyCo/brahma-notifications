email = require './email'
emailConf = require '../config/email'
emailActions = emailConf.actions
# TODO: push = require './push'

# Define an array with all notifications for each action
# ie: [ sendEmail opts, sendPush opts, sendCarrierPigeon opts ]
actions =
  user:
    register: [ email.send emailActions.register ]
    recover: [ email.send emailActions.recover ]
    confim: [ email.send emailActions.confirm ]

module.exports = exports = actions