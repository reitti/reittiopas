define ['jquery', 'underscore', 'backbone', 'bootstrap'], ($, _, Backbone) ->
  class SearchView extends Backbone.View

    el: $('#search')

    events:
      'submit form': 'searchRoute'

    typeaheadOptions:
      source: (query, process) ->
        params = $.param { query: query }
        $.getJSON "/autocomplete?#{params}", (addresses) ->
          process(addresses)
      minLength: 3

    initialize: ->
      @$to = @$el.find('#to');
      @$from = @$el.find('#from')
      Reitti.Event.on 'position:change', _.once (position) =>
        @populateFromBox position, =>
          @$to.focus()
      @$from.typeahead(@typeaheadOptions)
      @$to.typeahead(@typeaheadOptions)

    render: ->
      @$from.focus()

    searchRoute: (event) ->
      event.preventDefault()
      params = $.param { from: @$from.val(), to: @$to.val() }

      # TODO: Move this logic somewhere else
      $.getJSON "/routes?#{params}", (data) ->
        Reitti.Event.trigger 'route:change', data[0]

    populateFromBox: (position, callback) ->
      # TODO: Move this logic somewhere else
      $.getJSON "/address?coords=#{position.coords.longitude},#{position.coords.latitude}", (location) =>
        @$from.val location.name
        callback()
