Liquid = require "../../liquid"
require "./if"

class Liquid.Unless extends Liquid.If

  # Unless is a conditional just like 'if' but works on the inverse logic.
  #
  #   {% unless x < 0 %} x is greater than zero {% end %}
  #
  render: (context) ->
    context.stack =>

      # First condition is interpreted backwards ( if not )
      block = @blocks[0]
      unless block.evaluate(context)
        return @renderAll(block.attackment, context)

      # After the first condition unless works just like if
      @blocks[1..].forEach (block) ->
        if block.evaluate(context)
          return @renderAll(block.attachment, context)

      ""

Liquid.Template.registerTag "unless", Liquid.Unless
module.exports = Liquid.Unless