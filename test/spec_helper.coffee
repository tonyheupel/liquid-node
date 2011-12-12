vows = require('vows')
assert = require('assert')
Liquid = require("../src/liquid")

assertTemplateResult = (expected, template, assigns, message) ->
  assigns or= {}
  actual = Liquid.Template.parse(template).renderOrRaise(assigns)
  assert.equal actual, expected, message

assert_template_result = assertTemplateResult

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

  IfElseTagTest:
    test_if: ->
      assertTemplateResult('  ',' {% if false %} this text should not go into the output {% endif %} ')
      assertTemplateResult('  this text should go into the output  ',
                             ' {% if true %} this text should go into the output {% endif %} ')
      assertTemplateResult('  you rock ?','{% if false %} you suck {% endif %} {% if true %} you rock {% endif %}?')

    test_if_else: ->
      assert_template_result(' YES ','{% if false %} NO {% else %} YES {% endif %}')
      assert_template_result(' YES ','{% if true %} YES {% else %} NO {% endif %}')
      assert_template_result(' YES ','{% if "foo" %} YES {% else %} NO {% endif %}')

    test_if_boolean: ->
      assert_template_result(' YES ','{% if var %} YES {% endif %}', 'var': true)

    test_if_or: ->
      assert_template_result(' YES ','{% if a or b %} YES {% endif %}', 'a': true, 'b': true)
      assert_template_result(' YES ','{% if a or b %} YES {% endif %}', 'a': true, 'b': false)
      assert_template_result(' YES ','{% if a or b %} YES {% endif %}', 'a': false, 'b': true)
      assert_template_result('',     '{% if a or b %} YES {% endif %}', 'a': false, 'b': false)

      assert_template_result(' YES ','{% if a or b or c %} YES {% endif %}', 'a': false, 'b': false, 'c': true)
      assert_template_result('',     '{% if a or b or c %} YES {% endif %}', 'a': false, 'b': false, 'c': false)

    test_if_or_with_operators: ->
      assert_template_result(' YES ','{% if a == true or b == true %} YES {% endif %}', 'a': true, 'b': true)
      assert_template_result(' YES ','{% if a == true or b == false %} YES {% endif %}', 'a': true, 'b': true)
      assert_template_result('','{% if a == false or b == false %} YES {% endif %}', 'a': true, 'b': true)

    test_comparison_of_strings_containing_and_or_or: ->
      awful_markup = "a == 'and' and b == 'or' and c == 'foo and bar' and d == 'bar or baz' and e == 'foo' and foo and bar"
      assigns = {'a': 'and', 'b': 'or', 'c': 'foo and bar', 'd': 'bar or baz', 'e': 'foo', 'foo': true, 'bar': true}
      assert_template_result(' YES ',"{% if #{awful_markup} %} YES {% endif %}", assigns)

    test_if_from_variable: ->
      assert_template_result('','{% if var %} NO {% endif %}', 'var': false)
      assert_template_result('','{% if var %} NO {% endif %}', 'var': null)
      assert_template_result('','{% if foo.bar %} NO {% endif %}', 'foo': {'bar': false})
      assert_template_result('','{% if foo.bar %} NO {% endif %}', 'foo': {})
      assert_template_result('','{% if foo.bar %} NO {% endif %}', 'foo': null)
      assert_template_result('','{% if foo.bar %} NO {% endif %}', 'foo': true)

      assert_template_result(' YES ','{% if var %} YES {% endif %}', 'var': "text")
      assert_template_result(' YES ','{% if var %} YES {% endif %}', 'var': true)
      assert_template_result(' YES ','{% if var %} YES {% endif %}', 'var': 1)
      assert_template_result(' YES ','{% if var %} YES {% endif %}', 'var': {})
      assert_template_result(' YES ','{% if var %} YES {% endif %}', 'var': [])
      assert_template_result(' YES ','{% if "foo" %} YES {% endif %}')
      assert_template_result(' YES ','{% if foo.bar %} YES {% endif %}', 'foo': {'bar': true})
      assert_template_result(' YES ','{% if foo.bar %} YES {% endif %}', 'foo': {'bar': "text"})
      assert_template_result(' YES ','{% if foo.bar %} YES {% endif %}', 'foo': {'bar': 1 })
      assert_template_result(' YES ','{% if foo.bar %} YES {% endif %}', 'foo': {'bar': {} })
      assert_template_result(' YES ','{% if foo.bar %} YES {% endif %}', 'foo': {'bar': [] })

      assert_template_result(' YES ','{% if var %} NO {% else %} YES {% endif %}', 'var': false)
      assert_template_result(' YES ','{% if var %} NO {% else %} YES {% endif %}', 'var': null)
      assert_template_result(' YES ','{% if var %} YES {% else %} NO {% endif %}', 'var': true)
      assert_template_result(' YES ','{% if "foo" %} YES {% else %} NO {% endif %}', 'var': "text")

      assert_template_result(' YES ','{% if foo.bar %} NO {% else %} YES {% endif %}', 'foo': {'bar': false})
      assert_template_result(' YES ','{% if foo.bar %} YES {% else %} NO {% endif %}', 'foo': {'bar': true})
      assert_template_result(' YES ','{% if foo.bar %} YES {% else %} NO {% endif %}', 'foo': {'bar': "text"})
      assert_template_result(' YES ','{% if foo.bar %} NO {% else %} YES {% endif %}', 'foo': {'notbar': true})
      assert_template_result(' YES ','{% if foo.bar %} NO {% else %} YES {% endif %}', 'foo': {})
      assert_template_result(' YES ','{% if foo.bar %} NO {% else %} YES {% endif %}', 'notfoo': {'bar': true})
}).run()