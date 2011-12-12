Liquid = require("../liquid")
_ = require("underscore")._

module.exports = class Liquid.Document extends Liquid.Block
  # we don't need markup to open this block
  constructor: (tokens) ->
    @parse(tokens)

  # There isn't a real delimter
  blockDelimiter: ->
    []

  # Document blocks don't need to be terminated since they are
  # not actually opened
  assertMissingDelimitation: ->
