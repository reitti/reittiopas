define ['jquery', 'modernizr'], ($, Modernizr) ->
  class Position

    startWatching: ->
      if Modernizr.geolocation
        Reitti.Event.trigger 'position:lookup'
        @watchId = navigator.geolocation.watchPosition(
          (position) -> Reitti.Event.trigger 'position:change', position
          (error) -> Reitti.Event.trigger 'position:error', error
          {timeout: 5000, enableHighAccuracy: true, maximumAge: 15000})
      else
        Reitti.Event.trigger 'position:error'

    stopWatching: ->
      if Modernizr.geolocation and @watchId
        navigator.geolocation.clearWatch(@watchId)

    geocode: (longitude, latitude, callback) ->
      $.getJSON "/address?coords=#{longitude},#{latitude}", (location) =>
        callback(location)
