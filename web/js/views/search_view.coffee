define [
  'jquery'
  'underscore'
  'backbone'
  'models/routes'
  'models/bookmarks'
  'views/search_input_view'
  'views/error_message_view'
  'views/bookmarks_view'
  'modernizr'
  'utils'
  'i18n!nls/strings'
  'timepicker'
  'datepicker'
  'datepickerfi'
], ($, _, Backbone, Routes, Bookmarks, SearchInputView, ErrorMessageView, BookmarksView, Modernizr, Utils, strings) ->
  class SearchView extends Backbone.View

    el: $('#search')

    events:
      'submit form': 'searchRoutes'
      'click #toggle-geolocation': 'onToggleGeolocation'
      'click #toggle-bookmarks': 'onToggleBookmarks'

    initialize: ->
      @to = new SearchInputView(el: @$el.find('#to'))
      @from = new SearchInputView(el: @$el.find('#from'))
      @initializationTime = Utils.now()
      @initDateTimePickers(@initializationTime)

      @$toggleGeolocationButton = @$el.find('#toggle-geolocation')
      @$toggleBookmarksButton = @$el.find('#toggle-bookmarks')
      @$positionLookupSpinner = @$el.find('#loading-indicator')
      @canWatchPosition = Reitti.Settings.get('canWatchPosition')
      if @canWatchPosition
        @$toggleGeolocationButton.addClass('on')

      Reitti.Event.on 'position:lookup', @onGeolocationStart
      Reitti.Event.on 'position:change', @onPositionChange
      Reitti.Event.on 'position:error', @onGeolocationError
      Reitti.Event.on 'routes:find', @onFindingRoutes
      Reitti.Event.on 'routes:change', @onRoutesReceived
      Reitti.Event.on 'routes:notfound', @onSearchFailed
      Reitti.Event.on 'routes:from', @onRoutingRequestFrom
      Reitti.Event.on 'routes:to', @onRoutingRequestTo

    initDateTimePickers: (date) ->
      date = @initializationTime if date is 'now'
      $('#time').val(Utils.formatTimeForHumans(date))
      unless Modernizr.inputtypes.time
        $('#time').timepicker(defaultTime: 'value', showMeridian: false)
      formattedDate = Utils.formatDateForHTML5Input(date)
      $('#date').val(formattedDate)
      unless Modernizr.inputtypes.date
        $('#date').datepicker(format: 'yyyy-mm-dd', weekStart: 1, language: Utils.language()).datepicker('setValue', formattedDate)

    searchRoutes: (event) ->
      event.preventDefault() if event
      if @from.validate() and @to.validate()
        @to.blur()
        @from.clearError()
        @to.clearError()
        @to.clearError()
        Reitti.Router.navigateToRoutes
          from: @from.val()
          to: @to.val()
          arrivalOrDeparture: @arrivalOrDeparture()
          date: @date()
          transportTypes: @transportTypes()
          routeIndex: 0

    onRoutingRequestFrom: (longitude, latitude) =>
      Reitti.Position.geocode longitude, latitude, (location) =>
        @from.val(location.name or Utils.formatCoordinate(location.coords))
        @searchRoutes()

    onRoutingRequestTo: (longitude, latitude) =>
      Reitti.Position.geocode longitude, latitude, (location) =>
        @to.val(location.name or Utils.formatCoordinate(location.coords))
        @searchRoutes()

    onFindingRoutes: (params) =>
      Reitti.Event.off 'position:change', @populateFromBox # We're no longer interested in the user's initial geolocation
      @$positionLookupSpinner.hide()
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

    onPositionChange: (position) =>
      @$positionLookupSpinner.hide()
      if Utils.isWithinBounds(position) and position.coords.accuracy < 200
        Reitti.Position.geocode position.coords.longitude, position.coords.latitude, (location) =>
          @from.val location.name or Utils.formatCoordinate(location.coords)
          @to.focus()
      Reitti.Event.off 'position:change', @onPositionChange

    onGeolocationStart: () =>
      @$positionLookupSpinner.show()
      @from.placeholder(strings.geolocating)

    onGeolocationError: () =>
      @$positionLookupSpinner.hide()
      @from.resetPlaceholder()
      message = new ErrorMessageView(message: strings.geolocationError).render()

    onToggleGeolocation: =>
      if !@canWatchPosition
        @canWatchPosition = Reitti.Settings.set('canWatchPosition', true)
        @$positionLookupSpinner.show()
        @$toggleGeolocationButton.addClass('on')
        Reitti.Event.on 'position:change', @onPositionChange
        Reitti.Position.startWatching()
      else
        @canWatchPosition = Reitti.Settings.set('canWatchPosition', false)
        @$toggleGeolocationButton.removeClass('on')
        @$positionLookupSpinner.hide()
        Reitti.Position.stopWatching()
        @from.resetPlaceholder()

    onToggleBookmarks: (event) ->
      event.stopPropagation()
      if @bookmarks? and @bookmarksView
        @bookmarksView.toggle()
      else
        size = if $(window).width() <= 480 then BookmarksView.FULL else BookmarksView.FIT_TO_ANCHOR
        @bookmarks = new Bookmarks()
        @bookmarksView = new BookmarksView(collection: @bookmarks, anchor: @to.$el, size: size)
          .show() # Need to make the element visible first, as it needs to calculate some widths
          .render()