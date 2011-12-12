Liquid = require "../../liquid"

class Liquid.Assign extends Liquid.Tag
  SyntaxHelp = "Syntax Error in 'assign' - Valid syntax: assign [var] = [source]"
  Syntax = ///
      ((?:#{Liquid.VariableSignature.source})+)
      \s*=\s*
      ((?:#{Liquid.QuotedFragment.source}))
    ///

  constructor: (tagName, markup, tokens) ->
    if match = Syntax.exec(markup)
      @to = match[1]
      @from = match[2]
    else
      throw new Liquid.SyntaxError(SyntaxHelp)

    super

  render: (context) ->
    context.lastScope()[@to] = context.get(@from)
    ''

Liquid.Template.registerTag('assign', Liquid.Assign)
module.exports = Liquid.Assign