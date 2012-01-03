# LiquidNode - The Liquid template engine on Node.js

## Why this fork?

LiquidNode is a port of the Liquid template engine (originally written in Ruby) to *Node.js*. It uses Promises to support non-blocking, asynchronous variables/filters/blocks. Most code has been translated from Ruby to CoffeeScript, with a few adjustments (casing) to make it feel more *Coffee-/JavaScripty*.

## How [LiquidNode](https://github.com/sirlantis/liquid-node) differs from [Liquid](https://github.com/Shopify/liquid/)

The power of Node.js lies in its non-blocking nature. This presents a problem when using expressions like `{{ store.items | count }}` which may hide a blocking SQL-query.

LiquidNode tries to solve that problem by using [Futures and Promises](http://en.wikipedia.org/wiki/Futures_and_promises). The programmer must return Promises from asynchronous functions - designers don't have to care about it.

## Implementation of Promises

I started with the [**futures** package](https://github.com/coolaj86/futures) as an implementation of Promises but it didn't chain as nicely as I had hoped for.

So here is LiquidNode's custom Promise implementation. It's loosely based on [jQuery's Deferred](http://api.jquery.com/category/deferred-object/), [Promises/A](http://wiki.commonjs.org/wiki/Promises/A), and [Q](https://github.com/kriskowal/q).

```coffeescript
fs        = require "fs"
{async}   = require "liquid-node"

class Server
  name: ->
    "Falkor"

  # A deferred can either be resolved (no error) or rejected (error).
  think: ->
    async.promise (deferred) ->
      later = -> deferred.resolve(42)
      setTimeout(later, 1000)

  # This is an example of how to wait for a Promise:
  patientMethod: ->
    deepThought = @think()

    deepThought
      .done (answer) -> console.log "The answer is: %s.", answer
      .fail (e) -> console.log "Universe reset: %s.", e
      .always (e) -> console.log "Look on the bright side of life."

    # By the way: the left-hand side of async.promise returns a
    # read-only view (Promise) to the Deferred. This means an
    # Illuminati can't interfere with it on this side of the
    # Promise.
    #
    # deepThought.resolve(23) isn't available.

  # For node-ish callbacks you can use `deferred.node`. This
  # will automatically resolve/reject based on the first argument.
  accounts: ->
    async.promise (deferred) ->
      fs.readFile "/etc/passwd", "utf-8", deferred.node

```

## State of development

I'm developing this project alongside a different project. I translated a few basic tests from the original Liquid codebase - but there are hundreds of them. So if you find a bug-fix or have some time to translate further tests I'll be happy to pull them in.

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
promise = template.render 'name': 'tobi'        # => [Promise Object]
promise.done console.log                        # >> "hi tobi"
```