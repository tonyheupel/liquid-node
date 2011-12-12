futures = require "futures"
testCase = require("nodeunit").testCase

module.exports =
  test_async_variable: renderTest (render, assert) ->
    asyncFunction = ->
      result = futures.future()
      setTimeout((-> result.deliver("worked")), 50)
      result

    render('worked', '{{ test }}', test: asyncFunction)
    #render('WORKED', '{{ test | capitalize }}', test: asyncFunction)