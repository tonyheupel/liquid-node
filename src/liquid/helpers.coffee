futures = require "futures"

module.exports =
  unfuture: (future, options = {}) ->
    if options instanceof Function
      options =
        callback: options

    callback = options.callback

    if not future?.isFuture?
      if callback
        callbackResult = callback(null, future)
        module.exports.unfuture(callbackResult)
      else
        future

    else
      singleFuture = futures.future()

      _unfuture = (future) ->
        future.when (err, args...) ->
          try
            if err
              callback(arguments...)
              singleFuture.deliver(arguments...)
            else if args[0] and args[0].isFuture?
              _unfuture(args[0])
            else if callback
              result = callback(arguments...)

              if result?.isFuture?
                callback = null
                _unfuture(result)
              else
                singleFuture.deliver(err, result)
            else
              singleFuture.deliver(arguments...)
          catch e
            console.log "Couldn't unfuture: %s\n%s", e, e.stack

      _unfuture(future)
      singleFuture

  scan: (string, regexp, globalMatch = false) ->
    result = []

    _scan = (s) ->
      match = regexp.exec(s)

      if match
        if match.length == 1
          result.push match[0]
        else
          result.push match[1..]

        l = match[0].length
        l = 1 if globalMatch

        if match.index + l < s.length
          _scan(s.substring(match.index + l))

    _scan(string)
    result

  functionName: (f) ->
    return f.__name__ if f.__name__
    return f.name if f.name
    f.toString().match(/\W*function\s+([\w\$]+)\(/)?[1]