define ['jquery', 'underscore', 'backbone', 'bootstrap', 'plugins/select_range'], ($, _, Backbone) ->
  class SearchInputView extends Backbone.View

    initialize: () ->
      @$el.typeahead
        source: @getTypeaheadAddresses
        updater: (item) =>
          _.defer @afterTypeahead
          item
        minLength: 3
          
    getTypeaheadAddresses: (query, callback) =>
      params = $.param { query: query }
      $.getJSON "/autocomplete?#{params}", (addresses) ->
        callback(addresses)
      
    afterTypeahead: () =>
      idx = @$el.val().lastIndexOf(',')
      @$el.selectRange(idx) if idx? and idx > 0

    indicateError: () ->
      @$el.closest('.control-group').addClass('error')
      this

    clearError: () ->
      @$el.closest('.control-group').removeClass('error')
      this

    validate: () ->
      if $.trim(@val()) is ''
        @indicateError()
        false
      else
        true

    focus: () =>
      @$el.focus()

    blur: ->
      @$el.blur()

    val: (v) =>
      if arguments.length > 0
        @$el.val.apply(@$el, arguments)
      else
        @$el.val()

    placeholder: (v) =>
      @originalPlaceholder ?= @$el.prop('placeholder')
      @$el.prop('placeholder', v)

    resetPlaceholder: () =>
      @$el.prop('placeholder', @originalPlaceholder)

