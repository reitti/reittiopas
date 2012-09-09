define [
  'jquery'
  'underscore'
  'backbone'
  'models/route'
  'views/search_input_view'
  'utils'
  'timepicker'
], ($, _, Backbone, Route, SearchInputView, Utils) ->
  class SearchView extends Backbone.View

    el: $('#search')

    events:
      'submit form': 'searchRoute'

    initialize: ->
      @to = new SearchInputView(el: @$el.find('#to'))
      @from = new SearchInputView(el: @$el.find('#from'))

      now = new Date()
      $('#time').timePicker(
        startTime: Utils.nextQuarterOfHour(now)
        step: 15
      ).val(Utils.formatTime(now))

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
      @$el.find('.btn-primary').button('loading')

      Route.find @from.val(), @to.val(), @transportTypes(), (routes) =>
        @$el.find('.btn-primary').button('reset')
        Reitti.Event.trigger 'routes:change', routes

    transportTypes: () ->
      _.filter ['bus', 'tram', 'metro', 'train', 'ferry'], (vehicle) =>
        @$el.find('#' + vehicle).hasClass('active')

    populateFromBox: (position, callback) ->
      # TODO: Move this logic somewhere else
      if Utils.isWithinBounds(position)
        $.getJSON "/address?coords=#{position.coords.longitude},#{position.coords.latitude}", (location) =>
          @from.val location.name
          callback()
      
