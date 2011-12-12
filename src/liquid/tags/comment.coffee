Liquid = require "../../liquid"

class Liquid.Comment extends Liquid.Block
  render: ->
    ""

Liquid.Template.registerTag("comment", Liquid.Comment)