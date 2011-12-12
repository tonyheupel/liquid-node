vows = require('vows')
assert = require('assert')
Liquid = require("../liquid")

Liquid.SyntaxError = Error

switchMatch = (src, m) ->
  unless m
    return "(?:#{src.source})"

  lastChar = src.source.charAt(src.source.length-1)
  if lastChar == "?" or lastChar == "+" or lastChar == "*"
    new RegExp(src.source.slice(0, src.source.length-1) + m).source
  else
    new RegExp(src.source + m).source

class Liquid.Assign extends Liquid.Tag
  @Syntax = ///(#{switchMatch(Liquid.VariableSignature)}+)\s*=\s*(#{switchMatch(Liquid.QuotedFragment)})///

  constructor: (tagName, markup, tokens) ->
    if match = Liquid.Assign.Syntax.exec(markup)
      @to = match[1]
      @from = match[2]
    else
      throw new Liquid.SyntaxError("Syntax Error in 'assign' - Valid syntax: assign [var] = [source]")

    super

  render: (context) ->
    context.lastScope()[@to] = context.get(@from)
    ''

Liquid.Template.registerTag('assign', Liquid.Assign)

assertTemplateResult = (expected, template, assigns, message) ->
  assigns or= {}
  assert.equal Liquid.Template.parse(template).renderOrRaise(assigns),
                expected, message

vows.
describe('Liquid assign blocks').
addBatch({
  'when we evaluate them':
    'the variables should be assigned': ->
      assertTemplateResult  '.foo.',
                            '{% assign foo = values %}.{{ foo[0] }}.',
                            'values': ["foo", "bar", "baz"]

      assertTemplateResult  '.bar.',
                            '{% assign foo = values %}.{{ foo[1] }}.',
                            'values': ["foo", "bar", "baz"]

}).
#describe('Liquid variables').
addBatch({
  VariableTest:
    test_variable: ->
      variable = new Liquid.Variable('hello')
      assert.equal variable.name, 'hello'

    test_filters: ->
      v = new Liquid.Variable('hello | textileze')
      assert.equal 'hello', v.name
      assert.deepEqual [["textileze",[]]], v.filters

      v = new Liquid.Variable('hello | textileze | paragraph')
      assert.equal 'hello', v.name
      assert.deepEqual [["textileze",[]], ["paragraph",[]]], v.filters

      v = new Liquid.Variable("""hello | strftime: '%Y'""")
      assert.equal 'hello', v.name
      assert.deepEqual [["strftime",["'%Y'"]]], v.filters

      v = new Liquid.Variable("""'typo' | link_to: 'Typo', true""")
      assert.equal """'typo'""", v.name
      assert.deepEqual [["link_to",["'Typo'", "true"]]], v.filters

      v = new Liquid.Variable("""'typo' | link_to: 'Typo', false""")
      assert.equal """'typo'""", v.name
      assert.deepEqual [["link_to",["'Typo'", "false"]]], v.filters

      v = new Liquid.Variable("""'foo' | repeat: 3""")
      assert.equal """'foo'""", v.name
      assert.deepEqual [["repeat",["3"]]], v.filters

      v = new Liquid.Variable("""'foo' | repeat: 3, 3""")
      assert.equal """'foo'""", v.name
      assert.deepEqual [["repeat",["3","3"]]], v.filters

      v = new Liquid.Variable("""'foo' | repeat: 3, 3, 3""")
      assert.equal """'foo'""", v.name
      assert.deepEqual [["repeat",["3","3","3"]]], v.filters

      v = new Liquid.Variable("""hello | strftime: '%Y, okay?'""")
      assert.equal 'hello', v.name
      assert.deepEqual [["strftime",["'%Y, okay?'"]]], v.filters

      v = new Liquid.Variable(""" hello | things: "%Y, okay?", 'the other one'""")
      assert.equal 'hello', v.name
      assert.deepEqual [["things",["\"%Y, okay?\"","'the other one'"]]], v.filters

    test_filter_with_date_parameter: ->
      v = new Liquid.Variable(""" '2006-06-06' | date: "%m/%d/%Y" """)
      assert.equal "'2006-06-06'", v.name
      assert.deepEqual [["date",["\"%m/%d/%Y\""]]], v.filters

    # TODO

  VariableResolutionTest:
    test_simple_variable: ->
      template = Liquid.Template.parse("""{{test}}""")
      assert.equal 'worked', template.render(test: 'worked')
      assert.equal 'worked wonderfully', template.render(test: 'worked wonderfully')

  FiltersTest:
    test_local_filter: ->
      MoneyFilter =
        money: (input) ->
          require('util').format(' %d$ ', input)

        money_with_underscore: (input) ->
          require('util').format(' %d$ ', input)

      context = new Liquid.Context()
      context.set 'var', 1000
      context.addFilters(MoneyFilter)

      assert.equal ' 1000$ ', new Liquid.Variable("var | money").render(context)
}).run()
