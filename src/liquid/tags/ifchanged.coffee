Liquid = require "../../liquid"

class Liquid.Ifchanged extends Liquid.Block
  render: (context) ->
    context.stack =>
      output = @renderAll(@nodelist, context)

      if output != context.registers["ifchanged"]
        context.registers["ifchanged"] = output
        output
      else
        ""

Liquid.Template.registerTag "ifchanged", Liquid.Ifchanged
module.exports = Liquid.Ifchanged