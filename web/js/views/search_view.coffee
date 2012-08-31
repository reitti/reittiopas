define ['jquery', 'underscore', 'backbone'], ($, _, Backbone) ->
  class SearchView extends Backbone.View

    el: $('#search')

    events:
      'submit form': 'searchRoute'

    initialize: ->
      Reitti.Event.on 'position:change', _.once (position) =>
        @populateFromBox position, =>
          @$el.find('#to').focus()

    render: ->
      @$el.find('#from').focus()

    searchRoute: (event) ->
      event.preventDefault()
      params = $.serialize @el.find('form')

      # TODO: Move this logic somewhere else
      $.getJSON "/routes?#{params}", (data) ->
        Reitti.Event.trigger 'route:change', data[0]

    populateFromBox: (position, callback) ->
      # TODO: Move this logic somewhere else
      $.getJSON "/address?coords=#{position.coords.longitude},#{position.coords.latitude}", (location) =>
        @$el.find('#from').val location.name
        callback()
