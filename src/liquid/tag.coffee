Liquid = require "liquid"

module.exports = class Liquid.Tag
  constructor: (@tagName, @markup, tokens) ->
    @parse(tokens)

  parse: (tokens) ->

  name: ->
    tagName = /^function (\w+)\(/.exec(@constructor.toString())?[1]
    tagName or= 'UnknownTag'
    tagName.toLowerCase()

  render: ->
    ""