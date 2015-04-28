_ = require 'underscore'

utils =
  deepDefaults: (target) ->
    return target if not _.isObject target

    i = 1
    length = arguments.length
    while i < length
      defaults = arguments[i]
      for prop of defaults
        if target[prop] is undefined
          target[prop] = defaults[prop]
        else if 'object' is typeof target[prop]
          if 'object' is typeof defaults[prop]
            utils.deepDefaults target[prop], defaults[prop]
      i++
    target

  flattenObject: (obj, delim) ->
    delim = delim or '_'
    _ret = {}
    for key of obj
      continue if not obj.hasOwnProperty key
      if typeof obj[key] is 'object' and obj[key] isnt null
        _flat = utils.flattenObject(obj[key], delim)
        for next of _flat
          continue if not _flat.hasOwnProperty next
          _ret[key + delim + next] = _flat[next]
      else
        _ret[key] = obj[key]
    _ret

  ###
  # Constructs an object with the key args, solving path values in args in obj
  # @param  {Object}  obj: Data
  # @param  {Object}  args: required fields and paths where find them
  # @return {Object}  Return an object with all required fields
  ###
  mkObject: (obj, args) ->
    return null if not obj? or not args?
    _ret = {}
    for key of args
      field = utils.resolve args[key], obj
      return null if not field?
      _ret[key] = field
    _ret

  ###
  # Return value for the path in object
  # @param  {String, Array} path: Path for the value in obj
  # @param  {Object}        obj: object in which search path
  # @return {String}        Return a string with the value for the path param
  ###
  resolve: (path, obj) ->
    path = [path] if not utils.isArray path
    for p in path
      value = p.split('.').reduce (prev, curr) ->
        prev[curr] if prev
      , obj or @
      return value if value?

  isFunction: (arg) -> 'function' is typeof arg
  isObject: (arg) -> '[object Object]' is Object.prototype.toString.call arg
  isArray: (arg) -> Array.isArray arg

module.exports = exports = utils
