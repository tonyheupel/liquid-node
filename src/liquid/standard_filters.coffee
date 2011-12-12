Liquid = require "liquid"
_ = require("underscore")._

toNumber = (input) ->
  Number(input)

module.exports = class Liquid.StandardFilters

  size: (input) ->
    input.length

  downcase: (input) ->
    String(input).toLowerCase()

  upcase: (input) ->
    String(input).toUpperCase()

  ## TODO!!!

  truncate: (input, length = 50, truncateString = '...') ->
    return unless input?
    return unless input.slice

    length = toNumber(length)
    l = length - truncateString.length
    l = 0 if l < 0

    if input.length > length then input[..l] + truncateString else input

  truncatewords: (input, words = 15, truncateString = '...') ->
    return unless input?
    return unless input.slice

    wordlist = input.split(" ")
    words = toNumber(words)
    l = words - 1
    l = 0 if l < 0

    if wordlist.length > l
      wordlist[..l].join(" ") + truncateString
    else
      input

  split: (input, pattern) ->
    input.split(pattern)

  ## TODO!!!

  join: (input, glue = ' ') ->
    _(input).flatten().join(glue)

  ## TODO!!!


  # Get the first element of the passed in array
  #
  # Example:
  #    {{ product.images | first | to_img }}
  #
  first: (array) ->
    if array.length > 0
      array[0]
    else
      null

  # Get the last element of the passed in array
  #
  # Example:
  #    {{ product.images | last | to_img }}
  #
  last: (array) ->
    if array.length > 0
      array[array.length-1]
    else
      null

  plus: (input, operand) ->
    toNumber(input) + toNumber(operand)

  minus: (input, operand) ->
    toNumber(input) - toNumber(operand)

  times: (input, operand) ->
    toNumber(input) * toNumber(operand)

  dividedBy: (input, operand) ->
    toNumber(input) / toNumber(operand)

  modulo: (input, operand) ->
    toNumber(input) % toNumber(operand)