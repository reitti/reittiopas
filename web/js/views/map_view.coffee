define [
  'jquery'
  'underscore'
  'backbone'
  'async!http://maps.googleapis.com/maps/api/js?sensor=true' + if window.location.host is 'localhost' then '' else '&key=AIzaSyDZj9_A4WUDGph6cKf2A7VsFbDz6Pb7QBk'
], ($, _, Backbone) ->
  
  legColors =
    walk: '#1e74fc'
    1:    '#193695' # Helsinki internal bus lines
    2:    '#00ab66' # Trams
    3:    '#193695' # Espoo internal bus lines
    4:    '#193695' # Vantaa internal bus lines
    5:    '#193695' # Regional bus lines
    6:    '#fb6500' # Metro
    7:    '#00aee7' # Ferry
    8:    '#193695' # U-lines
    12:   '#ce1141' # Commuter trains
    21:   '#193695' # Helsinki service lines
    22:   '#193695' # Helsinki night buses
    23:   '#193695' # Espoo service lines
    24:   '#193695' # Vantaa service lines
    25:   '#193695' # Region night buses
    36:   '#193695' # Kirkkonummi internal bus lines
    39:   '#193695' # Kerava internal bus lines

  class MapView extends Backbone.View

    el: $('#map')

    initialize: ->
      # If we already have the user's current position, use it. If not, center
      # the map to it as soon as everything is initialized and we have the
      # location.
      if window.initialPosition
        @currentPosition = new google.maps.LatLng(window.initialPosition.coords.latitude,
          window.initialPosition.coords.longitude)
      else
        Reitti.Event.on 'position:change', (position) =>
          _.once @centerMap(position)

      Reitti.Event.on 'position:change', (position) =>
        @displayCurrentPosition position

      Reitti.Event.on 'route:change', @drawRoute, @


    render: ->
      @map = new google.maps.Map(@el,
        center: @currentPosition or new google.maps.LatLng(60.171, 24.941) # Rautatieasema
        zoom: 16
        mapTypeId: google.maps.MapTypeId.ROADMAP
        mapTypeControlOptions:
          position: google.maps.ControlPosition.TOP_CENTER
      )
      @

    clearRoute: ->
      if @route?
        leg.setMap(null) for leg in @route

    drawRoute: (route) ->
      @clearRoute()
      @route = for leg in route[0].legs
        latLngs = (new google.maps.LatLng point.y, point.x for point in leg.shape)
        new google.maps.Polyline
          map: @map
          path: latLngs
          strokeColor: legColors[leg.type] or '#0000ee'
          strokeWeight: 4

      @panToRouteBounds()

    panToRouteBounds: () ->
      bounds = new google.maps.LatLngBounds()
      for leg in @route
        bounds.extend(latLng) for latLng in leg.getPath().getArray()
      @map.fitBounds bounds

    centerMap: (position) ->
      latLng = new google.maps.LatLng position.coords.latitude, position.coords.longitude
      @map.setCenter latLng

    displayCurrentPosition: (position) ->
      latLng   = new google.maps.LatLng position.coords.latitude, position.coords.longitude
      accuracy = position.coords.accuracy

      @positionIndicator ?= new google.maps.Circle(
        strokeColor: '#0000FF'
        strokeOpacity: 0.50
        strokeWeight: 2
        fillColor: '#0000FF'
        fillOpacity: 0.10
        map: @map
        center: latLng
        radius: accuracy
      )
      @positionIndicator.setCenter latLng
      @positionIndicator.setRadius accuracy