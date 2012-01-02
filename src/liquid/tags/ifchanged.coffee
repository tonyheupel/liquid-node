Liquid = require "../../liquid"

module.exports = class Ifchanged extends Liquid.Block
  render: (context) ->
    context.stack =>
      rendered = @renderAll(@nodelist, context)

      Liquid.async.when(rendered)
        .when (output) ->
          if output != context.registers["ifchanged"]
            context.registers["ifchanged"] = output
            output
          else
            ""

Liquid.Template.registerTag "ifchanged", Ifchanged
