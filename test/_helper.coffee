# This is kind of ugly but I'm not really in the mood to put this in every test module.

global.vows = require('vows')
global.assert = require('assert')
global.Liquid = require("../src/liquid")

global.assertTemplateResult = (expected, template, assigns, message) ->
  assigns or= {}
  actual = Liquid.Template.parse(template).renderOrRaise(assigns)

  if actual.isFuture?
    actual.when (rendered) ->
      assert.equal rendered, expected, message
  else
    assert.equal actual, expected, message

global.assert_template_result = assertTemplateResult