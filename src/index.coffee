Liquid = require("./liquid")
util = require "util"

# based on node's lib/assert.js
customError = (name, inherit = global.Error) ->
  error = (message) ->
    @name = name
    @message = message

    if global.Error.captureStackTrace
      global.Error.captureStackTrace(@, arguments.callee)

  util.inherits(error, inherit)
  error:: = inherit::
  error

Liquid.Error = customError "Error"

# Errors
[ "ArgumentError", "ContextError", "FilterNotFound",
  "FilterNotFound", "FileSystemError", "StandardError",
  "StackLevelError", "SyntaxError"
].forEach (className) ->

  Liquid[className] = customError("Liquid.#{className}", Liquid.Error)


Liquid.Helpers          = require("./liquid/helpers")
Liquid.Drop             = require("./liquid/drop")
Liquid.Strainer         = require("./liquid/strainer")
Liquid.Context          = require("./liquid/context")
Liquid.Tag              = require("./liquid/tag")
Liquid.Block            = require("./liquid/block")
Liquid.Document         = require("./liquid/document")
Liquid.Variable         = require("./liquid/variable")
Liquid.Template         = require("./liquid/template")
Liquid.StandardFilters  = require("./liquid/standard_filters")
Liquid.Condition        = require("./liquid/condition")
class Liquid.ElseCondition extends Liquid.Condition
  else: -> true
  evaluate: -> true

Liquid.Template.registerFilter(Liquid.StandardFilters)

[ "assign", "capture", "comment", "decrement",
  "for", "if", "ifchanged", "increment",
  "raw", "unless"
].forEach (tag) ->
  require("./liquid/tags/#{tag}")

module.exports = Liquid