Liquid = require("../liquid")
_ = require("underscore")._

module.exports = class Liquid.Strainer

  filters = {}

  constructor: (@context) ->

  @globalFilter: (filter) ->
    filters[filter.name]

  @create: (context) ->
    strainer = new Liquid.Strainer(context)
    _(filters).forEach (filter) => _.extend(strainer, filter)
    strainer
