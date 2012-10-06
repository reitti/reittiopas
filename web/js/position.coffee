define ['jquery'], ($) ->
  class Position

    startWatching: ->
      if navigator.geolocation
        Reitti.Event.trigger 'position:lookup'
        @watchId = navigator.geolocation.watchPosition(
          (position) -> Reitti.Event.trigger 'position:change', position
          () -> Reitti.Event.trigger 'position:error',
          {enableHighAccuracy: true, maximumAge: 30000, timeout: 5000})
      else
        Reitti.Event.trigger 'position:error'

    stopWatching: ->
      if navigator.geolocation and @watchId
        navigator.geolocation.clearWatch(@watchId)

    geocode: (longitude, latitude, callback) ->
      $.getJSON "/address?coords=#{longitude},#{latitude}", (location) =>
        callback(location)
