Liquid = require "../liquid"

# Container for liquid nodes which conveniently wraps decision making logic
#
# Example:
#
#   c = Condition.new('1', '==', '1')
#   c.evaluate #=> true
#
module.exports = class Liquid.Condition
  @operators =
    '==': (cond, left, right) ->  cond.equalVariables(left, right)
    '!=': (cond, left, right) -> !cond.equalVariables(left, right)
    '<>': (cond, left, right) -> !cond.equalVariables(left, right)
    'contains': (cond, left, right) ->
      if left and right
        left.indexOf(right) >= 0
      else
        false

  operators: ->
    Liquid.Condition.operators

  constructor: (@left, @operator, @right) ->
    @childRelation = null
    @childCondition = null

  evaluate: (context) ->
    context or= new Liquid.Context
    result = @interpretCondition(@left, @right, @operator, context)

    switch @childRelation
      when "or"
        result or @childCondition.evaluate(context)
      when "and"
        result and @childCondition.evaluate(context)
      else
        result

  or: (@childCondition) ->
    @childRelation = "or"

  and: (@childCondition) ->
    @childRelation = "and"

  attach: (@attachment) ->

  else: ->
    false

  inspect: ->
    "<Condition #{[@left, @operator, @right].join(' ')}>"

  # private API

  equalVariables: (left, right) ->
    # TODO: symbol stuff?
    left == right

  interpretCondition: (left, right, op, context) ->
    # If the operator is empty this means that the decision statement is just
    # a single variable. We can just poll this variable from the context and
    # return this as the result.
    context[left] unless op?

    left = context[left]
    right = context[right]

    operation = Liquid.Condition.operators[op]
    throw new Error("Unknown operator #{op}") unless operation?

    if operation
      operation(@, left, right)
    else
      null

class Liquid.ElseCondition extends Liquid.Condition
  else: ->
    true

  evaluate: ->
    true