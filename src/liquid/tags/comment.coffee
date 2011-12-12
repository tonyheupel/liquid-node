Liquid = require "../../liquid"

class Liquid.Comment extends require("../block")
  render: ->
    ""

Liquid.Template.registerTag("comment", Liquid.Comment)