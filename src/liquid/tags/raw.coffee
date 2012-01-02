Liquid = require "../../liquid"

module.exports = class Raw extends Liquid.Block
  parse: (tokens) ->
    @nodelist or= []
    @nodelist.pop() while nodelist.length() > 0

    while tokens.length > 0
      token = token.shift()
      match = Liquid.FullToken.exec(token)

      if match and @blockDelimiter() == match[1]
        @endTag()
        return

    @nodelist.push(token) unless token.length == 0

Liquid.Template.registerTag "raw", Raw