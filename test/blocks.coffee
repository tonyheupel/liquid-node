Liquid = require("../src/index")

module.exports =
  test_assigned_variable: renderTest (render, assert) ->
    render  '.foo.',
            '{% assign foo = values %}.{{ foo[0] }}.',
            'values': ["foo", "bar", "baz"]

    render  '.bar.',
            '{% assign foo = values %}.{{ foo[1] }}.',
            'values': ["foo", "bar", "baz"]

  test_for_with_variable: renderTest (render, assert) ->
    render(' 1  2  3 ','{%for item in array%} {{item}} {%endfor%}','array': [1,2,3])
    render('123','{%for item in array%}{{item}}{%endfor%}','array': [1,2,3])
    render('123','{% for item in array %}{{item}}{% endfor %}','array': [1,2,3])
    render('abcd','{%for item in array%}{{item}}{%endfor%}','array': ['a','b','c','d'])
    render('a b c','{%for item in array%}{{item}}{%endfor%}','array': ['a',' ','b',' ','c'])
    render('abc','{%for item in array%}{{item}}{%endfor%}','array': ['a','','b','','c'])

  test_ifchanged: renderTest (render, assert) ->
    assigns = {'array': [ 1, 1, 2, 2, 3, 3] }
    render('123','{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}',assigns)

    assigns = {'array': [ 1, 1, 1, 1] }
    render('1','{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}',assigns)
