define ['jquery', 'underscore', 'backbone', 'bootstrap', 'plugins/select_range'], ($, _, Backbone) ->
  class SearchInputView extends Backbone.View

    initialize: () ->
      @$el.typeahead
        source: (query, process) ->
          params = $.param { query: query }
          $.getJSON "/autocomplete?#{params}", (addresses) ->
            process(addresses)
        updater: (item) =>
          _.defer @afterTypeahead
          item
        minLength: 3
            
    afterTypeahead: () =>
      idx = @$el.val().lastIndexOf(',')
      @$el.selectRange(idx) if idx? and idx > 0
        
    focus: () => @$el.focus()
    val: (v) => @$el.val.apply(@$el, arguments)
