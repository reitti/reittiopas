define ['underscore', 'utils', 'views/map_leg_marker', 'views/map_location_marker'], (_, Utils, MapLegMarker, MapLocationMarker) ->
  class MapRouteLegView

    constructor: ({@routes, @routeParams, @routeIndex, @index, @map}) ->
      @leg = @routes.at(@routeIndex).getLeg(@index)
      Reitti.Event.on 'routes:change', @onRoutesChanged

    dispose: ->
      Reitti.Event.off 'routes:change', @onRoutesChanged
      @line?.setMap null
      @marker?.setMap null
      @hideMarkers()
      this

    render: () ->
      path = (new google.maps.LatLng point.y, point.x for point in @leg.get('shape'))
      @line = new google.maps.Polyline
          map: @map
          path: path
          strokeWeight: 5
          strokeColor: Utils.transportColors[@leg.get('type')]
      @marker = new MapLegMarker(@map, path[Math.floor(path.length / 2)], @leg.get('type'))

      google.maps.event.addListener @line, 'click', @onClicked
      google.maps.event.addListener @marker.marker, 'click', @onClicked
      this

    onClicked: () =>
      Reitti.Router.navigateToRoutes _.extend(@routeParams, legIndex: @index)

    onRoutesChanged: (routes, routeParams) =>
      if @isSelectedIn(routes, routeParams) and @line.getPath()?
        @showOriginMarker()
        @showDestinationMarker()
      else
        @hideMarkers()

    showOriginMarker: =>
      return unless @originLatLng()?
      anchor = MapLocationMarker.markerAnchor(@originLatLng(), @line.getPath())
      @originMarker ?= new MapLocationMarker(@originLatLng(), @leg.originName(), @map, anchor)

    showDestinationMarker: =>
      return unless @originLatLng()?
      anchor = MapLocationMarker.markerAnchor(@destinationLatLng(), @line.getPath())
      @destMarker ?= new MapLocationMarker(@destinationLatLng(), @leg.destinationName(), @map, anchor)

    originLatLng: ->
      @line?.getPath()?.getAt(0)

    destinationLatLng: ->
      @line?.getPath()?.getAt(@line.getPath().getLength() - 1)

    hideMarkers: =>
      @originMarker?.setMap null
      @destMarker?.setMap null
      @originMarker = null
      @destMarker = null

    isSelectedIn: (routes, routeParams) ->
      routes is @routes and routeParams.routeIndex is @routeIndex and routeParams.legIndex is @index

    getBounds: () ->
      bounds = new google.maps.LatLngBounds()
      if @line? and @line.getPath()?
        bounds.extend(latLng) for latLng in @line.getPath().getArray()
      bounds