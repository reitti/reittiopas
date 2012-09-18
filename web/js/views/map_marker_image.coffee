define ['leaflet'], (L) ->

  class MapMarkerImage

    constructor: (map, latLng, legType) ->
      @marker = new L.Marker latLng, {
        icon: @_markerImage(legType)
      }

    on: (evt, listener) ->
      @marker.on evt, listener

    _markerImage: (legType) ->
      if legType is 'walk'
        new L.DivIcon
          className: 'icon-walk'
          iconSize: @_imageSize()
          iconAnchor: [0, 0]
      else
        new L.DivIcon
          className: @_iconClass(legType)
          iconSize: @_imageSize()
          iconAnchor: @_imageAnchor()

    _iconClass: (legType) ->
      switch legType
        when '2' then 'icon-tram'
        when '6' then 'icon-metro'
        when '7' then 'icon-ferry'
        when '12' then 'icon-train'
        else 'icon-bus'

    _imageSize: ->
      @imageSize ?= [32, 32]

    _imageAnchor: ->
      @imageAnchor ?= [16, 16]
