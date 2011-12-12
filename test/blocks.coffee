vows
  .describe('Liquid blocks')
  .addBatch({
    AssignTest:
      test_assigned_variable: ->
        assertTemplateResult  '.foo.',
                              '{% assign foo = values %}.{{ foo[0] }}.',
                              'values': ["foo", "bar", "baz"]

        assertTemplateResult  '.bar.',
                              '{% assign foo = values %}.{{ foo[1] }}.',
                              'values': ["foo", "bar", "baz"]

    StandardTagTest:
      test_for_with_variable: ->
        assert_template_result(' 1  2  3 ','{%for item in array%} {{item}} {%endfor%}','array': [1,2,3])
        assert_template_result('123','{%for item in array%}{{item}}{%endfor%}','array': [1,2,3])
        assert_template_result('123','{% for item in array %}{{item}}{% endfor %}','array': [1,2,3])
        assert_template_result('abcd','{%for item in array%}{{item}}{%endfor%}','array': ['a','b','c','d'])
        assert_template_result('a b c','{%for item in array%}{{item}}{%endfor%}','array': ['a',' ','b',' ','c'])
        assert_template_result('abc','{%for item in array%}{{item}}{%endfor%}','array': ['a','','b','','c'])

      test_ifchanged: ->
        assigns = {'array': [ 1, 1, 2, 2, 3, 3] }
        assert_template_result('123','{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}',assigns)

        assigns = {'array': [ 1, 1, 1, 1] }
        assert_template_result('1','{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}',assigns)
  }).export(module)