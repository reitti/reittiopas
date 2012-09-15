define [
  'jquery'
  'underscore'
  'backbone'
  'models/routes'
  'views/search_input_view'
  'utils'
  'timepicker'
], ($, _, Backbone, Routes, SearchInputView, Utils) ->
  class SearchView extends Backbone.View

    el: $('#search')

    events:
      'submit form': 'searchRoutes'

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

    render: ->
      @from.focus()

    searchRoutes: (event) ->
      event.preventDefault()
      @$el.find('.btn-primary').button('loading')

      Routes.find @from.val(), @to.val(), @date(), @arrivalOrDeparture(), @transportTypes(), (routes) =>
        @$el.find('.btn-primary').button('reset')
        @from.val(routes.from)
        @to.val(routes.to)
        Reitti.Event.trigger 'routes:change', routes

    transportTypes: () ->
      transportTypes = ['bus', 'tram', 'metro', 'train', 'ferry']
      transportType for transportType in transportTypes when @$el.find('#' + transportType).hasClass('active')

    date: () ->
      time = @$el.find('#time').val()
      date = new Date()
      timeZone = Math.round(date.getTimezoneOffset() / 60)
      timeZoneZeroPad = if Math.abs(timeZone) < 10 then '0' else ''
      timeZoneSign = if timeZone >= 0 then '-' else '+'
      dateString = "#{Utils.formatDate(date, '-')}T#{time}#{timeZoneSign}#{timeZoneZeroPad}#{Math.abs(timeZone)}00"
      new Date(Date.parse(dateString))

    arrivalOrDeparture: () ->
      timeType = @$el.find('#time-type').val()

    populateFromBox: (position, callback) ->
      # TODO: Move this logic somewhere else
      if Utils.isWithinBounds(position)
        $.getJSON "/address?coords=#{position.coords.longitude},#{position.coords.latitude}", (location) =>
          @from.val location.name
          callback()
      
