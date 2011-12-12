# LiquidNode - The Liquid template engine on Node.js

## Summary of this Fork

LiquidNode is a port of the Liquid template engine (written in Ruby) to *Node.js*. It uses Futures to support non-blocking, asynchronous variables/filters/blocks. Most code has been translated from Ruby to CoffeeScript, with a few adjustments to make it feel more *Coffee-/JavaScripty*.

## How `LiquidNode` differs from [Liquid](https://github.com/Shopify/liquid/)

The power of Node.js lies in its non-blocking nature. This presents a problem when using expressions like `{{ store.items | count }}` which hide a blocking SQL-query.

LiquidNode tries to solve that problem by using [Futures and Promises](http://en.wikipedia.org/wiki/Futures_and_promises). The programmer must return Future-objects from asynchronous functions - designs don't have to care about it.

## Implementation of Futures

I decided to use the [`futures` package](https://github.com/coolaj86/futures) as an implementation of Futures (for now).

```coffeescript
fs = require "fs"
futures = require "futures"

class Server
  name: ->
    "Falkor7"

  accounts: ->
    future = futures.future()
    fs.readFile "/etc/passwd", "utf-8", (err, data) ->
      future.deliver err, data
    future
```

# Liquid template engine

## Introduction

Liquid is a template engine which was written with very specific requirements:

* It has to have beautiful and simple markup. Template engines which don't produce good looking markup are no fun to use.
* It needs to be non evaling and secure. Liquid templates are made so that users can edit them. You don't want to run code on your server which your users wrote.
* It has to be stateless. Compile and render steps have to be seperate so that the expensive parsing and compiling can be done once and later on you can just render it passing in a hash with local variables and objects.

## Why you should use Liquid

* You want to allow your users to edit the appearance of your application but don't want them to run **insecure code on your server**.
* You want to render templates directly from the database
* You like smarty (PHP) style template engines
* You need a template engine which does HTML just as well as emails
* You don't like the markup of your current templating engine

## What does it look like?

```html
<ul id="products">
  {% for product in products %}
    <li>
      <h2>{{ product.name }}</h2>
      Only {{ product.price | price }}

      {{ product.description | prettyprint | paragraph }}
    </li>
  {% endfor %}
</ul>
```

## Howto use Liquid

Liquid supports a very simple API based around the Liquid.Template class.
For standard use you can just pass it the content of a file and call render with a parameters hash.

```coffeescript
Liquid = require "liquid-node"

template = Liquid.Template.parse("hi {{name}}") # Parses and compiles the template
template.render 'name': 'tobi'                  # => "hi tobi"
```