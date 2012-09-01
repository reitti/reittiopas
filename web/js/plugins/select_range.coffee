require ['jquery'], ($) ->
  # Select a certain range or position in a text input or textarea
  $.fn.selectRange = (start, end) ->
    end ?= start
    this.each ->
      if @setSelectionRange
        @focus()
        @setSelectionRange start, end
      else if @createTextRange
        range = @createTextRange()
        range.collapse true
        range.moveEnd 'character', end
        range.moveStart 'character', start
        range.select()
    this
