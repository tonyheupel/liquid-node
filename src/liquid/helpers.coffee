futures = require "futures"

module.exports =
  unfuture: (future, callback) ->
    if not future?.isFuture?
      callback(null, future)
    else
      singleFuture = futures.future()

      _unfuture = (future) ->
        future.when (err, args...) ->
          if err
            callbackResult = callback(arguments...)
            singleFuture.deliver(arguments...)
          else if r?.isFuture?
            _unfuture(r)
          else
            callbackResult = callback(arguments...)

            if callbackResult?.isFuture?
              callbackResult.when ->
                singleFuture.deliver(arguments...)
            else
              singleFuture.deliver(arguments...)

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