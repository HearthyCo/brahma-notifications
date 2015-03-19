_ = require 'underscore'
Email = require '../classes/Email'
utils = require './utils'
config = require '../config/config'
emailConfig = require '../config/email'
site = config.site or {}

defaults = ->
    userId: null
    user: null
    users: []
    to: null
    subject: null
    title: null
    body: null
    from:
      name: 'Do not reply'
      email: 'noreply@glue.gl'
    locals: emailConfig.locals or {}
    globalMergeVars:
      site: site
      private_profile: site.url
      current_year: 2014
      links:
        home: site.url + '/'
    content: {}
    mandrillTemplate: true

userToMandrill = (user) ->
  _user =
    name: user.name
    email: user.email
    vars:
      profile: user.url or site.url
      private_profile: site.url
      avatar: if user.thumb then user.thumb.avatar_small else ''
  # merge_vars via user object
  _user.vars = _.extend _user.vars, user.vars if user.vars
  _user

###*
# Parse options before the delivery
# @param  {Object} options
# @return {Object}
###

_parseOptions = (options) ->
  options = options or {}
  options = utils.deepDefaults options, defaults()
  options.to = options.to or []
  options.to = [ options.to ] if not utils.isArray options.to

  if options.user
    options.users.push options.user
    options.users = _.uniq options.users, false, (user) -> user.username
  if options.users and utils.isArray options.users
    options.users.forEach (_user) ->
      _user = userToMandrill _user
      # userVars via options
      _user.vars = _.extend _user.vars, options.userVars if options.userVars
      options.to.push _user
  options = _.omit _.extend(options, options.locals), [ 'locals' ]
  options

###*
# Sends an email
# @param  {String}   id       Email identifier
# @param  {Oject}    options  {to, subject, user, from, locals}
# @param  {Function} callback err
###

send = (id, options, callback) ->
  return callback 'No template' if not id
  options = _parseOptions options
  return callback 'No recipient' if not options.to

  init = templateName: id
  init.templateMandrillName = id if options.mandrillTemplate

  em = new (Email)(init)
  em.send options, (err, result) -> callback err, result, options

###
  Set exportable object
###
_object =
  send: send

exports = module.exports = _object