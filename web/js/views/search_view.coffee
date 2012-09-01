define ['jquery', 'underscore', 'backbone', 'views/search_input_view'], ($, _, Backbone, SearchInputView) ->
  class SearchView extends Backbone.View

    el: $('#search')

    events:
      'submit form': 'searchRoute'

    initialize: ->
      @to = new SearchInputView(el: @$el.find('#to'))
      @to.val localStorage.to if @localStorageEnabled 

      @from = new SearchInputView(el: @$el.find('#from'))
      Reitti.Event.on 'position:change', _.once (position) =>
        @populateFromBox position, =>
          @to.focus()
       
    render: ->
      @from.focus()

    searchRoute: (event) ->
      event.preventDefault()
      params = $.param { from: @from.val(), to: @to.val() }

      localStorage.to = @to.val() if @localStorageEnabled 

      # TODO: Move this logic somewhere else
      $.getJSON "/routes?#{params}", (data) ->
        Reitti.Event.trigger 'route:change', data[0]

    populateFromBox: (position, callback) ->
      # TODO: Move this logic somewhere else
      $.getJSON "/address?coords=#{position.coords.longitude},#{position.coords.latitude}", (location) =>
        @from.val location.name
        callback()
        
    localStorageEnabled: ->
      typeof(Storage) != "undefined"
      
