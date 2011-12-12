# This is kind of ugly but I'm not really in the mood to put this in every test module.

global.Liquid = require("../src/liquid")

global.renderTest = (f) ->
  cnt = 0

  assertTemplateResult = (assert) ->
    (expected, template, assigns, message) ->
      actual = Liquid.Template.parse(template).renderOrRaise(assigns)

      if actual.isFuture?
        cnt += 1

        actual.when (rendered) ->
          assert.eql rendered, expected, message
          cnt -= 1
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