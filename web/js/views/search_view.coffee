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
      $('#date').val(Utils.formatDate(now, '-'))

      Reitti.Event.on 'position:change', _.once (position) =>
        @populateFromBox position, =>
          @to.focus()
      Reitti.Event.on 'routes:find', @onFindingRoutes
      Reitti.Event.on 'routes:change', @onRoutesReceived
      Reitti.Event.on 'routes:notfound', @onSearchFailed

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
      @setDate(params.date)
      @setArrivalOrDeparture(params.arrivalOrDeparture)
      @setTransportTypes(params.transportTypes)
      @$el.find('.btn-primary').button('loading')

    onRoutesReceived: (routes) =>
      @$el.find('.btn-primary').button('reset')
      @from.val(routes.from)
      @to.val(routes.to)

    onSearchFailed: (statuses) =>
      @$el.find('.btn-primary').button('reset')
      @from.indicateError() unless statuses.from
      @to.indicateError() unless statuses.to

    transportTypes: () ->
      transportType for transportType in Utils.transportTypes when @$el.find('#' + transportType).hasClass('active')

    setTransportTypes: (types) ->
      for transportType in Utils.transportTypes
        @$el.find("##{transportType}").toggleClass('active', _.include(types, transportType))

    date: () ->
      time = @$el.find('#time').val()
      date = new Date(Date.parse(@$el.find('#date').val()))
      Utils.parseTime(time, date = date)

    setDate: (d) ->
      @$el.find('#time').val(Utils.formatTime(d))
      @$el.find('#date').val(Utils.formatDate(d, '-'))

    arrivalOrDeparture: () ->
      timeType = @$el.find('#time-type').val()

    setArrivalOrDeparture: (v) ->
      @$el.find('#time-type').val(v)

    populateFromBox: (position, callback) ->
      # TODO: Move this logic somewhere else
      if Utils.isWithinBounds(position)
        $.getJSON "/address?coords=#{position.coords.longitude},#{position.coords.latitude}", (location) =>
          @from.val location.name
          callback()
      
