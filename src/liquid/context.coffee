Liquid = require "../liquid"
_ = require("underscore")._

module.exports = class Liquid.Context

  constructor: (environments = {}, outerScope = {}, registers = {}, rethrowErrors = false) ->
    @environments = _.flatten [environments]
    @scopes = [outerScope or {}]
    @registers = registers
    @errors = []
    @rethrowErrors = rethrowErrors
    @strainer = Liquid.Strainer.create(@)
    @squashInstanceAssignsWithEnvironments()


  # Adds filters to this context.
  #
  # Note that this does not register the filters with the main
  # Template object. see <tt>Template.register_filter</tt>
  # for that
  addFilters: (filters) ->
    filters = _([filters]).chain().flatten().compact().value()
    filters.forEach (filter) =>
      unless filter instanceof Object
        throw new Error("Expected Object but got: #{typeof(filter)}")

      _.extend @strainer, filter

  handleError: (e) ->
    @errors.push e
    throw e if @rethrowErrors

    if e instanceof Liquid.SyntaxError
      "Liquid syntax error: #{e.message}"
    else
      "Liquid error: #{e.message}"

  invoke: (method, args...) ->
    if @strainer[method]?
      f = @strainer[method]
      f.apply(@strainer, args)
    else
      args?[0]

  push: (newScope = {}) ->
    @scopes.unshift newScope
    throw new Error("Nesting too deep") if @scopes.length > 100

  merge: (newScope = {}) ->
    _(@scopes[0]).extend(newScope)

  pop: ->
    throw new Error("ContextError") if @scopes.length <= 1
    @scopes.shift()

  lastScope: ->
    @scopes[@scopes.length-1]

  # Pushes a new local scope on the stack, pops it at the end of the block
  #
  # Example:
  #   context.stack do
  #      context['var'] = 'hi'
  #   end
  #
  #   context['var]  #=> nil
  stack: (newScope = {}, f) ->
    try
      if arguments.length < 2
        f = newScope
        newScope = {}

      @push(newScope)
      f()
    finally
      @pop()

  clearInstanceAssigns: ->
    @scopes[0] = {}

  # Only allow String, Numeric, Hash, Array, Proc, Boolean
  # or <tt>Liquid::Drop</tt>
  set: (key, value) ->
    @scopes[0][key] = value

  get: (key) ->
    @resolve(key)

  hasKey: (key) ->
    !!@resolve(key)

  # PRIVATE API

  @Literals =
    'null': null
    'nil': null
    '': null
    'true': true
    'false': false
    'empty': (v) -> v.length == 0
    'blank': (v) -> !v or v.length == 0

  # Look up variable, either resolve directly after considering the name.
  # We can directly handle Strings, digits, floats and booleans (true,false).
  # If no match is made we lookup the variable in the current scope and
  # later move up to the parent blocks to see if we can resolve
  # the variable somewhere up the tree.
  # Some special keywords return symbols. Those symbols are to be called on the rhs object in expressions
  #
  # Example:
  #   products == empty #=> products.empty?
  resolve: (key) ->
    if _(Liquid.Context.Literals).keys().indexOf(key) >= 0
      Liquid.Context.Literals[key]
    else
      if match = /^'(.*)'$/.exec(key) # Single quoted strings
        match[1]
      else if match = /^"(.*)"$/.exec(key) # Double quoted strings
        match[1]
      else if match = /^(\d+)$/.exec(key) # Integer and floats
        Number(match[1])
      else if match = /^\((\S+)\.\.(\S+)\)$/.exec(key) # Ranges
        lo = Number(resolve(match[1]))
        hi = Number(resolve(match[2]))
        # TODO: generate Range
      else if match = /^(\d[\d\.]+)$/.exec(key) # Floats
        Number(match[1])
      else
        @variable(key)


  findVariable: (key) ->
    scope = _(@scopes).detect (s) ->
      s.hasOwnProperty?(key)

    scope or= _(@environments).detect (e) =>
      variable = @lookupAndEvaluate(e, key)
    scope or= @environments[@environments.length-1] or @scopes[@scopes.length-1]
    variable or= @lookupAndEvaluate(scope, key)

    variable = liquify(variable)
    variable.context = @ if variable instanceof Liquid.Drop

    variable

  variable: (markup) ->
    parts = Liquid.Helpers.scan(markup, Liquid.VariableParser)
    squareBracketed = /^\[(.*)\]$/

    firstPart = parts.shift()

    if match = squareBracketed.exec(firstPart)
      firstPart = match[1]

    object = @findVariable(firstPart)

    if object
      _(parts).detect (part) =>
        if partResolved = squareBracketed.exec(part)
          part = @resolve(partResolved[1])

        # If object is a hash- or array-like object we look for the
        # presence of the key and if its available we return it
        if (_.isArray(object) and _.isNumber(part)) or
           (object instanceof Object and _(object).keys().indexOf(part) >= 0)

          res = @lookupAndEvaluate(object, part)
          object = liquify(res)

          # Some special cases. If the part wasn't in square brackets and
          # no key with the same name was found we interpret following calls
          # as commands and call them on the current object
        else if !partResolved and object.length and ["size", "first", "last"].indexOf(part) >= 0
          object = switch part
            when "size"
              object.length
            when "first"
              object[0]
            when "last"
              object[object.length-1]
            else
              object
        else
          object = null
          true # break loop

        object.context = @ if object instanceof Liquid.Drop
        false

    object

  lookupAndEvaluate: (obj, key) ->
    value = obj[key]

    if _.isFunction(value)
      obj[key] = if value.length == 0
        value.call(obj)
      else
        value.call(obj, @)
    else
      value

  squashInstanceAssignsWithEnvironments: ->
    lastScope = @lastScope()

    _(lastScope).chain().keys().forEach (key) =>
      _(@environments).detect (env) =>
        if _(env).keys().indexOf(key) >= 0
          lastScope[key] = @lookupAndEvaluate(env, key)
          true

  liquify = (object) ->
    return object unless object?

    if object.toLiquid?
      object.toLiquid()
    else
      # TODO: implement toLiquid for native types
      object