Liquid = require("../src/index")

global.renderTest = (f) ->
  map = {}
  cnt = 0
  uniqueId = 0

  assertTemplateResult = (assert) ->
    (expected, template, assigns, message) ->
      actual = Liquid.Template.parse(template).renderOrRaise(assigns)

      if Liquid.async.isPromise(actual)
        myId = uniqueId++
        cnt += 1
        map[myId] = { expected, template, assigns }

        actual.always (err, actual) ->
          cnt -= 1
          delete map[myId]

          if err
            console.log "Unexpected error: %s, %s", err, err.stack
            assert.eql err, null

          assert.type actual, "string"

          assert.eql actual, expected, JSON.stringify({
            template,
            expected,
            actual,
            assigns
          }, null, 2)
      else
        assert.eql actual, expected, JSON.stringify({
          template,
          expected,
          actual,
          assigns
        }, null, 2)

  (exit, assert) ->
    f(assertTemplateResult(assert), assert)
    exit ->
      if cnt != 0
        for k, v of map
          console.log {
            template: v.template,
            expected: v.expected,
            rendered: null,
            assigns: Object.keys(v.assigns)
          }

      assert.eql(0, cnt, "Not all render-tasks have finished: #{cnt} left.")

module.exports =
  testsTruth: (e, assert) ->
    assert.eql(true, true)

  testsRender: renderTest (render, assert) ->
    true