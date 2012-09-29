# Sets string values from i18n to placeholders on the host page HTML.
#
# To define a string, add the attribute data-string to the corresponding element.
# Its value should be the key to the string. Nested object properties are supported.
#
# If the element also has attribute data-string-attr, the string will be set as the value
# of the attribute of that name. If data-string-attr is absent, the string is appended
# to the element's contents.
define ['jquery', 'i18n!nls/strings'], ($, strings) ->

  lookupString = ([key, keys...], strs) ->
    if keys.length is 0
      strs[key]
    else
      lookupString keys, strs[key]

  ->
    for el in $('[data-string]')
      $el = $(el)
      stringKeys = $el.data('string').split('.')
      string = lookupString(stringKeys, strings)
      
      if attr = $el.data('string-attr')
        $el.attr attr, string
      else
        $el.append string
