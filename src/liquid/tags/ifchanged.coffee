Liquid = require "../../liquid"
futures = require "futures"

class Liquid.Ifchanged extends Liquid.Block
  render: (context) ->
    context.stack =>
      output = @renderAll(@nodelist, context)

      if output?.isFuture?
        result = futures.future()
        output.when (output) =>
          if output != context.registers["ifchanged"]
            context.registers["ifchanged"] = output
            result.deliver(output)
          else
            result.deliver ""
        result
      else if output != context.registers["ifchanged"]
        context.registers["ifchanged"] = output
        output
      else
        ""

Liquid.Template.registerTag "ifchanged", Liquid.Ifchanged
module.exports = Liquid.Ifchanged