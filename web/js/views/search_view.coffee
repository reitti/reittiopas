define ['jquery', 'underscore', 'backbone', 'views/search_input_view', 'utils'], ($, _, Backbone, SearchInputView, Utils) ->
  class SearchView extends Backbone.View

    el: $('#search')

    events:
      'submit form': 'searchRoute'

    initialize: ->
      @to = new SearchInputView(el: @$el.find('#to'))

      @from = new SearchInputView(el: @$el.find('#from'))
      Reitti.Event.on 'position:change', _.once (position) =>
        @populateFromBox position, =>
          @to.focus()

      if Utils.isLocalStorageEnabled()
        @from.val localStorage.from unless localStorage.from?
        @to.val localStorage.to
 
    render: ->
      @from.focus()

    searchRoute: (event) ->
      event.preventDefault()
      params = $.param { from: @from.val(), to: @to.val() }

      if Utils.isLocalStorageEnabled()
        localStorage.from = @from.val()
        localStorage.to = @to.val()

      # TODO: Move this logic somewhere else
      $.getJSON "/routes?#{params}", (data) ->
        Reitti.Event.trigger 'routes:change', data

    populateFromBox: (position, callback) ->
      # TODO: Move this logic somewhere else
      $.getJSON "/address?coords=#{position.coords.longitude},#{position.coords.latitude}", (location) =>
        @from.val location.name
        callback()
      
