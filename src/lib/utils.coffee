_ = require 'underscore'

utils =
  deepDefaults = (target) ->
    return target if !_.isObject(target)

    i = 1
    length = arguments.length
    while i < length
      defaults = arguments[i]
      for prop of defaults
        if target[prop]?
          target[prop] = defaults[prop]
        else if 'object' is typeof target[prop]
          if 'object' is typeof defaults[prop]
            deepDefaults target[prop], defaults[prop]
      i++
    target

  flattenObject = (obj, delim) ->
    delim = delim or '_'
    _ret = {}
    for key of obj
      if !obj.hasOwnProperty(key)
        continue
      if typeof obj[key] == 'object' and obj[key] != null
        _flat = flattenObject(obj[key], delim)
        for next of _flat
          if !_flat.hasOwnProperty(next)
            continue
          _ret[key + delim + next] = _flat[next]
      else
        _ret[key] = obj[key]
    _ret

  isFunction = (arg) -> 'function' is typeof arg

  isObject = (arg) -> '[object Object]' is Object.prototype.toString.call arg

  isArray = (arg) -> Array.isArray(arg);

module.exports = exports = utils
