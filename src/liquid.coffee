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

  # Errors
  class @Error extends Error
  class @ArgumentError extends @Error
  class @ContextError extends @Error
  class @FilterNotFound extends @Error
  class @FileSystemError extends @Error
  class @StandardError extends @Error
  class @SyntaxError extends @Error
  class @StackLevelError extends @Error

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

# TODO
# HtmlTags, FileSystem