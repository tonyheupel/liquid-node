Liquid = require "../../liquid"
futures = require "futures"

class Liquid.Ifchanged extends require("../block")
  render: (context) ->
    context.stack =>
      rendered = @renderAll(@nodelist, context)

      Liquid.Helpers.unfuture rendered, (err, output) ->
        if output != context.registers["ifchanged"]
          context.registers["ifchanged"] = output
          output
        else
          ""

Liquid.Template.registerTag "ifchanged", Liquid.Ifchanged
module.exports = Liquid.Ifchanged