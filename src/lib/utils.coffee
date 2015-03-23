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

  cleanObject: (obj, args) ->
    return false if not object? and not args?
    _ret = {}
    for key in args
      field = utils.resolve args[key], obj
      return null if not field?
      _ret[key] = field
    _ret

  resolve = (path, obj) ->
    path.split('.').reduce (prev, curr) ->
      prev[curr]
    , obj or @

  isFunction: (arg) -> 'function' is typeof arg
  isObject: (arg) -> '[object Object]' is Object.prototype.toString.call arg
  isArray: (arg) -> Array.isArray arg

module.exports = exports = utils
