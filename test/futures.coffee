futures = require "futures"
testCase = require("nodeunit").testCase

module.exports =
  test_async_variable: renderTest (render, assert) ->
    asyncResult = (result) ->
      ->
        f = futures.future()
        setTimeout((-> f.deliver(result)), 5)
        f

    render 'worked', '{{ test }}',
      test: asyncResult("worked")

    render 'WORKED', '{{ test | upcase }}',
      test: asyncResult("worked")

    render '1-2-3', '{{ array | join:minus }}',
      minus: asyncResult("-")
      array: [1, 2, 3]

    render '1+2+3', '{{ array | join:minus | split:minus | join:plus }}',
      minus: asyncResult("-")
      plus: asyncResult("+")
      array: [1, 2, 3]