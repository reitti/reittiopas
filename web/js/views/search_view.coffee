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
      @initializationTime = new Date()
      @initDateTimePickers(@initializationTime)

      Reitti.Event.on 'position:change', _.once (position) =>
        @populateFromBox position, =>
          @to.focus()
      Reitti.Event.on 'routes:find', @onFindingRoutes
      Reitti.Event.on 'routes:change', @onRoutesReceived
      Reitti.Event.on 'routes:notfound', @onSearchFailed

    initDateTimePickers: (date) ->
      date = @initializationTime if date is 'now'
      $('#time').each(-> delete this.timePicker ).unbind().timePicker(
        startTime: Utils.nextQuarterOfHour(date)
        step: 15
      ).val(Utils.formatTimeForHumans(date))
      $('#date').val(Utils.formatDateForHTML5Input(date))

    render: ->
      @from.focus()

    searchRoutes: (event) ->
      event.preventDefault()
      if @from.validate() and @to.validate()
        @from.clearError()
        @to.clearError()
        Reitti.Router.navigateToRoutes
          from: @from.val()
          to: @to.val()
          arrivalOrDeparture: @arrivalOrDeparture()
          date: @date()
          transportTypes: @transportTypes()
          routeIndex: 0

    onFindingRoutes: (params) =>
      @from.val(params.from)
      @to.val(params.to)
      @initDateTimePickers(params.date)
      @setArrivalOrDeparture(params.arrivalOrDeparture)
      @setTransportTypes(params.transportTypes)
      @$el.find('button[type=submit]').button('loading')
      Routes.find params.from, params.to, params.date, params.arrivalOrDeparture, params.transportTypes, params

    onRoutesReceived: (routes) =>
      @$el.find('button[type=submit]').button('reset')
      @from.val(routes.fromName)
      @to.val(routes.toName)

    onSearchFailed: (statuses) =>
      @$el.find('button[type=submit]').button('reset')
      @from.indicateError() unless statuses.from
      @to.indicateError() unless statuses.to

    transportTypes: () ->
      types = (transportType for transportType in Utils.transportTypes when @$el.find('#' + transportType).hasClass('active'))
      if types.length is Utils.transportTypes.length or types.length is 0 then ['all'] else types

    setTransportTypes: (types) ->
      for transportType in Utils.transportTypes
        @$el.find("##{transportType}").toggleClass('active', _.include(types, transportType))

    date: () ->
      date = @$el.find('#date').val()
      time = @$el.find('#time').val()
      result = Utils.parseDateAndTimeFromHTML5Input(date, time)
      if Utils.isSameMinute(@initializationTime, result)
        'now'
      else
        result

    arrivalOrDeparture: () ->
      @$el.find('input:radio[name="time-type"]:checked').val()

    setArrivalOrDeparture: (v) ->
      @$el.find('#time-type').val(v)

    populateFromBox: (position, callback) ->
      # TODO: Move this logic somewhere else
      if Utils.isWithinBounds(position) and position.coords.accuracy < 200
        $.getJSON "/address?coords=#{position.coords.longitude},#{position.coords.latitude}", (location) =>
          @from.val location.name
          callback()


