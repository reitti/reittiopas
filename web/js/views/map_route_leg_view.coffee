define ['underscore', 'utils', 'views/map_leg_marker', 'views/map_location_marker'], (_, Utils, MapLegMarker, MapLocationMarker) ->

  class MapRouteLegView
    
    constructor: (routes: routes, routeIndex: routeIndex, index: index, map: map) ->
      @routes = routes
      @routeIndex = routeIndex
      @index = index
      @leg = @routes.at(@routeIndex).getLeg(@index)
      @map = map
      Reitti.Event.on 'routes:change', @onRoutesChanged

    dispose: ->
      Reitti.Event.off 'routes:change', @onRoutesChanged
      @line?.setMap null
      @marker?.setMap null
      @originMarker?.setMap null
      @destMarker?.setMap null
      this
      
    render: () ->
      path = (new google.maps.LatLng point.y, point.x for point in @leg.get('shape'))
      @line = new google.maps.Polyline _.extend({
          map: @map
          path: path
          strokeWeight: 3
          strokeColor: Utils.transportColors[@leg.get('type')]
          strokeOpacity: 1.0
        }, @_legStyle())
      @marker = new MapLegMarker(@map, path[Math.floor(path.length / 2)], @leg.get('type'))

      google.maps.event.addListener @line, 'click', @onClicked
      google.maps.event.addListener @marker.marker, 'click', @onClicked
      this
      
    onClicked: () =>
      Reitti.Event.trigger 'leg:change', @leg

    onRoutesChanged: (routes, routeParams) =>
      if @isSelectedIn(routes, routeParams) and @line.getPath()?
        originLatLng = @line.getPath().getAt(0)
        destLatLng = @line.getPath().getAt(@line.getPath().getLength() - 1)
        @originMarker ?= new MapLocationMarker(originLatLng, @leg.originName(), @map, @_markerAnchor(originLatLng))
        @destMarker ?= new MapLocationMarker(destLatLng, @leg.destinationName(), @map, @_markerAnchor(destLatLng))
      else
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

    _legStyle: () ->
      switch @leg.get('type')
        when 'walk'
          strokeOpacity: 0
          icons: [{
            icon:
              path: 'M 0,-0.2 0,0.2'
              strokeOpacity: 1
            repeat: '7px'
          }, {
            icon:
              path: google.maps.SymbolPath.FORWARD_OPEN_ARROW
              scale: 2.5
              strokeOpacity: 1
            repeat: '150px'
          }]
        else
          icons: [{
            icon:
              path: google.maps.SymbolPath.FORWARD_OPEN_ARROW
              scale: 2.5
              strokeOpacity: 1
            repeat: '150px'
          }]

    _markerAnchor: (latLng) ->
      if @_isNorthMost(latLng)
        'top'
      else if @_isSouthMost(latLng)
        'bottom'
      else if @_isEastMost(latLng)
        'left'
      else
        'right'

    _isNorthMost: (latLng) ->
      for i in [0...@line.getPath().getLength()]
        return false if @line.getPath().getAt(i).lat() > latLng.lat()
      true

    _isSouthMost: (latLng) ->
      for i in [0...@line.getPath().getLength()]
        return false if @line.getPath().getAt(i).lat() < latLng.lat()
      true

    _isEastMost: (latLng) ->
      for i in [0...@line.getPath().getLength()]
        return false if @line.getPath().getAt(i).lng() < latLng.lng()
      true
