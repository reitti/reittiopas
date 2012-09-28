define ['jquery', 'hbs!template/map_location_marker', "async!http://maps.googleapis.com/maps/api/js?sensor=true#{window.gmapsKey}"], ($, template) ->

  WIDTH = 150
  HEIGHT = 20

  class MapLocationMarker extends google.maps.OverlayView

    constructor: (@location, @name, @map, @anchor = 'left') ->
      @setMap(@map)

    onAdd: ->
      @div = $(template(anchor: @anchor, content: @name))[0]
      @getPanes().floatPane.appendChild(@div)
      $(@div).on 'click', @onClicked
      $('.streetview-icon', @div).on 'click', @onStreetViewClicked
      @_checkStreetViewAvailability()

    draw: ->
      {x: x, y: y} = @getProjection().fromLatLngToDivPixel(@location)
      switch @anchor
        when 'top' 
          x -= WIDTH / 2
          y -= (HEIGHT + 10)
        when 'bottom'
          x -= WIDTH / 2
        when 'left'
          x -= (WIDTH + 10)
          y -= HEIGHT / 2
        when 'right'
          y -= HEIGHT / 2
      @div.style.left = "#{x}px"
      @div.style.top = "#{y}px"

    onClicked: =>
      @map.panTo @location
      @map.setZoom 18
      false

    onStreetViewClicked: =>
      @map.getStreetView().setPosition(@location)
      @map.getStreetView().setPov(heading: @heading, pitch: 0, zoom: 1)
      @map.getStreetView().setVisible(true)

    onRemove: ->
      @div.parentNode.removeChild(@div)
      @div = null

    @markerAnchor: (latLng, latLngs) ->
      if @_isNorthMost(latLng, latLngs)
        'top'
      else if @_isSouthMost(latLng, latLngs)
        'bottom'
      else if @_isEastMost(latLng, latLngs)
        'left'
      else
        'right'

    @_isNorthMost: (latLng, latLngs) ->
      for i in [0...latLngs.getLength()]
        return false if latLngs.getAt(i).lat() > latLng.lat()
      true

    @_isSouthMost: (latLng, latLngs) ->
      for i in [0...latLngs.getLength()]
        return false if latLngs.getAt(i).lat() < latLng.lat()
      true

    @_isEastMost: (latLng, latLngs) ->
      for i in [0...latLngs.getLength()]
        return false if latLngs.getAt(i).lng() < latLng.lng()
      true

    _checkStreetViewAvailability: () ->
      new google.maps.StreetViewService().getPanoramaByLocation @location, 30, (panoramaData, streetviewStatus) =>
        if streetviewStatus is 'OK'
          @heading = @_computeAngle(panoramaData.location.latLng)
          $('.streetview-icon', @div).show()
          
    # Approximate angle calculation courtesy of Jordan Clist
    # http://www.jaycodesign.co.nz/js/using-google-maps-to-show-a-streetview-of-a-house-based-on-an-address/

    _computeAngle: (availableLatLng) ->
      DEGREE_PER_RADIAN = 57.2957795
      RADIAN_PER_DEGREE = 0.017453
      dlat = @location.lat() - availableLatLng.lat()
      dlng = @location.lng() - availableLatLng.lng()
      yaw = Math.atan2(dlng * Math.cos(@location.lat() * RADIAN_PER_DEGREE), dlat) * DEGREE_PER_RADIAN
      @_wrapAngle(yaw)
   
    _wrapAngle: (angle) ->
      if angle >= 360
        angle -= 360
      else if angle < 0
        angle += 360
      angle
 
 