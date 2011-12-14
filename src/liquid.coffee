util = require "util"

module.exports = class Liquid
  @FilterSeparator             = /\|/
  @ArgumentSeparator           = /,/
  @FilterArgumentSeparator     = /\:/
  @VariableAttributeSeparator  = /\./
  @TagStart                    = /\{\%/
  @TagEnd                      = /\%\}/
  @VariableSignature           = /\(?[\w\-\.\[\]]\)?/
  @VariableSegment             = /[\w\-]/
  @VariableStart               = /\{\{/
  @VariableEnd                 = /\}\}/
  @VariableIncompleteEnd       = /\}\}?/
  @QuotedString                = /"[^"]*"|'[^']*'/
  @QuotedFragment              = ///#{@QuotedString.source}|(?:[^\s,\|'"]|#{@QuotedString.source})+///
  @StrictQuotedFragment        = /"[^"]+"|'[^']+'|[^\s|:,]+/
  @FirstFilterArgument         = ///#{@FilterArgumentSeparator.source}(?:#{@StrictQuotedFragment.source})///
  @OtherFilterArgument         = ///#{@ArgumentSeparator.source}(?:#{@StrictQuotedFragment.source})///
  @SpacelessFilter             = ///^(?:'[^']+'|"[^"]+"|[^'"])*#{@FilterSeparator.source}(?:#{@StrictQuotedFragment.source})(?:#{@FirstFilterArgument.source}(?:#{@OtherFilterArgument.source})*)?///
  @Expression                  = ///(?:#{@QuotedFragment.source}(?:#{@SpacelessFilter.source})*)///
  @TagAttributes               = ///(\w+)\s*\:\s*(#{@QuotedFragment.source})///
  @AnyStartingTag              = /\{\{|\{\%/
  @PartialTemplateParser       = ///#{@TagStart.source}.*?#{@TagEnd.source}|#{@VariableStart.source}.*?#{@VariableIncompleteEnd.source}///
  @TemplateParser              = ///(#{@PartialTemplateParser.source}|#{@AnyStartingTag.source})///
  @VariableParser              = ///\[[^\]]+\]|#{@VariableSegment.source}+\??///

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
].forEach (className) =>

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

# TODO
# HtmlTags, FileSystem

# Load Tags

tagDir = "#{__dirname}/liquid/tags"
require("fs").readdirSync(tagDir).forEach (file) ->
  if /\.(coffee|js|node)$/.test(file)
    fullFile = tagDir + "/" + file
    require(fullFile)