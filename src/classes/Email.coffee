_ = require 'underscore'
moment = require 'moment'
utils = require'../lib/utils'
mandrillapi = require 'mandrill-api'
config = require '../config/config'

defaultConfig =
  mandrill:
    track_opens: true
    track_clicks: true
    preserve_recipients: false
    inline_css: true
  templateMandrillName: null
  templateForceHtml: false


###*
# Converts javascript Objects into
# Mandrill's vars objects.
#
# @param  {Mixed}  _var Object to parse
# @return {Array}       An array of vars
###

objToMandrillVars = (_var) ->
  _new = []
  if 'object' == typeof _var
    _flat = utils.flattenObject(_var, '_')
    _.each _flat, (value, key) ->
      _new.push
        name: key
        content: value
      return
    return _new
  _var

###*
# Email Class
# ===========
#
# Helper class for sending emails with Mandrill.
#
# New instances take a `templatePath` string which must be a folder in the
# emails path, and must contain either `templateName/email.templateExt` or `templateName.templateExt`
# which is used as the template for the HTML part of the email.
#
# Once created, emails can sent.
#
# Requires the `mandrill api key` option to be set on config
#
# @api public
###

Email = (options) ->
  # Passing a string will use Email.defaults for everything but template name
  if 'string' == typeof options
    options = templateName: options
  else if !utils.isObject(options)
    throw new ErrorEmailOptionsRequired
  @templateMandrillName = options.templateMandrillName
  @templateName = options.templateName or @templateMandrillName
  @templateExt = options.templateExt or Email.defaults.templateExt
  @templateEngine = options.templateEngine or Email.defaults.templateEngine
  @templateBasePath = options.templateBasePath or Email.defaults.templateBasePath
  if !@templateName
    throw new ErrorNoEmailTemplateName
  this

###*
# Prepares the email, with or without render
#
# @param  {Object}   options  options to render the email
# @param  {Function} callback(err, message)
#
# @api private
###

Email::prepare = (options, callback) ->
  locals = options
  if arguments.length == 3 or !utils.isFunction(callback)
    callback = arguments[2]
    options = arguments[1] or arguments[0]
  callback = if 'function' == typeof callback then callback else (->
  )
  # Renders an email via Keystone (default behavior)
  if !@templateMandrillName or @templateForceHtml
    @render locals, ((err, email) ->
      _.extend options, email
      @buildOptions.call this, err, options, callback
      return
    ).bind(this)
  else
    @buildOptions.call this, null, options, callback
  return

###*
# Build an options object
#
# @param  {Object}   options  Input options
# @param  {Function} callback(err, callback)
#
# @api private
###

Email::buildOptions = (err, options, callback) ->
  callback = if 'function' == typeof callback then callback else (->
  )
  if err
    return callback(err)
  if !utils.isObject(options)
    return callback(
      from: 'Email.send'
      key: 'invalid options'
      message: 'options object is required')
  if 'string' == typeof options.from
    options.fromName = options.from
    options.fromEmail = options.from
  else if utils.isObject(options.from)
    options.fromName = if utils.isObject(options.from.name) then options.from.name.full else options.from.name
    options.fromEmail = options.from.email
  if !options.fromName or !options.fromEmail
    return callback(
      from: 'Email.send'
      key: 'invalid options'
      message: 'options.fromName and options.fromEmail are required')
  if !options.mandrill
    if !config.mandrill.apikey
      return callback(
        from: 'Email.send'
        key: 'missing api key'
        message: 'You must either provide a Mandrill API Instance or set the mandrill api key before sending email.')
    options.mandrill = new (mandrillapi.Mandrill)(config.mandrill.apikey)
  options.tags = if utils.isArray(options.tags) then options.tags else []
  options.tags.push 'sent:' + moment().format('YYYY-MM-DD')
  options.tags.push @templateName
  if config.env is 'development'
    options.tags.push 'development'

  ###*
  # Convert and concat globalMergeVars
  ###

  if options.globalMergeVars
    options.global_merge_vars = (options.global_merge_vars or []).concat(objToMandrillVars(options.globalMergeVars))
  recipients = []
  mergeVars = []
  options.to = if Array.isArray(options.to) then options.to else [ options.to ]
  i = 0
  while i < options.to.length
    if 'string' == typeof options.to[i]
      options.to[i] = email: options.to[i]
    else if 'object' == typeof options.to[i] and options.to[i] != null
      if !options.to[i].email
        return callback(
          from: 'Email.send'
          key: 'invalid recipient'
          message: 'Recipient ' + i + 1 + ' does not have a valid email address.')
    else
      return callback(
        from: 'Email.send'
        key: 'invalid recipient'
        message: 'Recipient ' + i + 1 + ' is not a string or an object.')
    recipient = email: options.to[i].email
    vars = [ {
      name: 'email'
      content: recipient.email
    } ]
    if 'string' == typeof options.to[i].name
      recipient.name = options.to[i].name
      vars.push
        name: 'name'
        content: options.to[i].name
    else if 'object' == typeof options.to[i].name
      recipient.name = options.to[i].name.full or ''
      vars.push
        name: 'name'
        content: options.to[i].name.full or ''
      vars.push
        name: 'first_name'
        content: options.to[i].name.first or ''
      vars.push
        name: 'last_name'
        content: options.to[i].name.last or ''
    # Mandrill template
    if recipient.vars
      vars.concat objToMandrillVars(recipient.vars)
    recipients.push recipient
    mergeVars.push
      rcpt: recipient.email
      vars: vars
    i++
  message = 
    from_name: options.fromName
    from_email: options.fromEmail
    tags: options.tags
    attachments: options.attachments
    to: recipients
    global_merge_vars: options.global_merge_vars
    merge_vars: mergeVars
    async: true
  if options.subject
    message.subject = options.subject
  if options.html
    message.html = options.html
  _.defaults message, options.mandrillOptions
  _.defaults message, Email.defaults.mandrill
  toSend = message: message
  if @templateMandrillName
    toSend.template_name = @templateMandrillName
    toSend.template_content = []
  callback null, toSend
  return

###*
# Sends the email
#
# Options:
#
# - mandrill
#   Initialised Mandrill API instance
#
# - tags
#   Array of tags to send to Mandrill
#
# - to
#   Object / String or Array of Objects / Strings to send to, e.g.
#   ['jed@team9.com.au', { email: 'jed.watson@gmail.com' }]
#   { email: 'jed@team9.com.au' }
#   'jed@team9.com.au'
#
# - fromName
#   Name to send from
#
# - fromEmail
#   Email address to send from
#
# For compatibility with older implementations, send supports providing
# locals and options objects as the first and second arguments, and the
# callback as the third.
#
# @param {Function} callback(err, info)
#
# @api private
###

Email::send = (options, callback) ->
  locals = options
  prepareOptions = [ locals ]
  if arguments.length == 3
    # we expect locals, options, callback
    if _.isObject(arguments[1])
      prepareOptions.push arguments[1]
    callback = arguments[2]
  else if arguments.length == 2 and !utils.isFunction(callback)
    # no callback so we expect locals, options
    if _.isObject(arguments[1])
      prepareOptions.push arguments[1]

    callback = (err, info) ->
      if err
        console.log err
      return

  else if arguments.length == 1
    # we expect options here and it is pushed already

    callback = (err, info) ->
      if err
        console.log err
      return

  prepareOptions.push ((err, toSend) ->
    if err
      return callback(err, null)

    onSuccess = (info) ->
      callback null, info
      return

    onFail = (info) ->
      callback
        from: 'Email.send'
        key: 'send error'
        message: 'Mandrill encountered an error and did not send the emails.'
        info: info
      return

    if @templateMandrillName
      process.nextTick ->
        options.mandrill.messages.sendTemplate toSend, onSuccess, onFail
        return
    else
      process.nextTick ->
        options.mandrill.messages.send toSend, onSuccess, onFail
        return
  ).bind(this)
  @prepare.apply this, prepareOptions
  return

Email.getEmailsPath = getEmailsPath
Email.templateCache = templateCache
Email.templateCSSMethods = templateCSSMethods
Email.defaults = defaultConfig
exports = module.exports = Email

# ---
# generated by js2coffee 2.0.1