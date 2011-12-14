Liquid = require("../src/liquid")

global.renderTest = (f) ->
  cnt = 0

  assertTemplateResult = (assert) ->
    (expected, template, assigns, message) ->
      actual = Liquid.Template.parse(template).renderOrRaise(assigns)

      if actual?.isFuture?
        cnt += 1

        actual.when (err, rendered) ->
          cnt -= 1
          assert.eql rendered, expected, message
      else
        assert.eql actual, expected, message

  (exit, assert) ->
    f(assertTemplateResult(assert), assert)
    exit ->
      assert.eql(0, cnt, "Not all render-tasks have finished.")

module.exports =
  testsTruth: (e, assert) ->
    assert.eql(true, true)

  testsRender: renderTest (render, assert) ->
    true