email = require '../lib/email'
emailConf = require '../config/email'
emailEvents = emailConf.events.properties
push = require '../lib/push'

# Define an array with all notifications for each action
# ie: [ sendEmail opts, sendPush opts, sendCarrierPigeon opts ]
events =
  user:
    register: [ email.send emailEvents.register ]
    confirm: [ email.send emailEvents.confirm ]
    recoverPassword: [ email.send emailEvents.recoverPassword ]
    confirmPassword: [ email.send emailEvents.confirmPassword ]
  chat:
    activity: [ push.sendUndelivered ]
    unread: [ push.sendUnread ]
  session:
    finish: [ push.sendFinished ]
  push:
    update: [ push.update ]


module.exports = exports = events