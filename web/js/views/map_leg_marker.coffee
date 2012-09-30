define [], ->

  class MapLegMarker

    constructor: (map, latLng, legType) ->
      @marker = new google.maps.Marker(map: map, position: latLng, icon: @_markerImage(legType))

    setMap: (map) ->
      @marker.setMap map

    _markerImage: (legType) ->
      new google.maps.MarkerImage '/img/vehicles_small.png', @_imageSize(), @_imageOrigin(legType), @_imageAnchor()


    _imageOrigin: (legType) ->
      switch legType
        when '2' then new google.maps.Point(32, 32)
        when '6' then new google.maps.Point(0, 32)
        when '7' then new google.maps.Point(0, 64)
        when '12' then new google.maps.Point(32, 0)
        when 'walk' then new google.maps.Point(32, 64)
        else new google.maps.Point(0, 0)

    _imageSize: ->
      @imageSize ?= new google.maps.Size 32, 32, 'px', 'px'

    _imageAnchor: ->
      @imageAnchor ?= new google.maps.Point 16, 16
