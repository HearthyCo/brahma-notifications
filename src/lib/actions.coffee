async = require 'async'
conf = require '../config/email'

sendEmail = (opts) -> (data) ->
  opts = opts || {}

  to = utils.cleanObject data, email: 'user.email', name: 'user.email'
  globalMergeVars = utils.cleanObject data, opts.requiredFields

  email.send opts.template,
    to: to
    globalMergeVars: globalMergeVars
  , (err, result, options) ->
    console.err 'Error sent email:', err if err
    console.log 'Success sent email:', result if not err

actions =
  user:
    register: [ sendEmail conf.actions.register ]
    recover: [ sendEmail conf.actions.recover ]

module.exports = exports = actions