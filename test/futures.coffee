Liquid = require("../src/liquid")
futures = require "futures"
testCase = require("nodeunit").testCase

asyncResult = (result) ->
  ->
    f = futures.future()
    setTimeout((-> f.deliver(null, result)), 10)
    f

module.exports =
  test_async_variable: renderTest (render, assert) ->

    render 'worked', '{{ test }}',
      test: asyncResult("worked")

    render 'WORKED', '{{ test | upcase }}',
      test: asyncResult("worked")

    render '1-2-3', '{{ array | join:minus }}',
      minus: asyncResult("-")
      array: [1, 2, 3]

    render '1+2+3', '{{ array | join:minus | split:minus | join:plus }}',
      minus: asyncResult("-")
      plus: asyncResult("+")
      array: [1, 2, 3]

    render 'YES', '{% if test %}YES{% else %}NO{% endif %}',
      test: asyncResult(true)

    render 'NO', '{% if test %}YES{% else %}NO{% endif %}',
      test: asyncResult(false)

    render 'NO', '{% unless test %}YES{% else %}NO{% endunless %}',
      test: asyncResult(true)

    render 'YES', '{% unless test %}YES{% else %}NO{% endunless %}',
      test: asyncResult(false)

    render 'Monkeys', '{% capture heading %}{{animal}}{% endcapture %}{{heading}}'
      animal: asyncResult("Monkeys")

    render 'YES', '{% assign test = var %}{% if test %}YES{% else %}NO{% endif %}',
      var: true

    render 'NO', '{% assign test = var %}{% if test %}YES{% else %}NO{% endif %}',
      var: false

  test_for_loop: renderTest (render, assert) ->
    products = ({ id: "item#{i}" } for i in [1, 2, 2])

    doc = "{% for product in products %}- {{ product.id }}\n{% endfor %}"
    render "- item1\n- item2\n- item2\n", doc,
      products: asyncResult(products)

    doc = "{% for product in products %}{% ifchanged %}- {{ product.id }}\n{% endifchanged %}{% endfor %}"
    render "- item1\n- item2\n", doc,
      products: asyncResult(products)

  test_for_loop_with_async_elements: renderTest (render, assert) ->
    doc = "{% for product in products %}- {{ product.id }}\n{% endfor %}"
    products = ({ id: asyncResult("item#{i}") } for i in [1..3])

    render "- item1\n- item2\n- item3\n", doc,
      products: products