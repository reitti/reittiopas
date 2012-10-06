define [
  'jquery'
  'underscore'
  'router'
  'hbs!template/map_menu'
  'i18n!nls/strings'
  "async!http://maps.googleapis.com/maps/api/js?sensor=true#{window.gmapsKey}"
], ($, _, Router, template, strings) ->

  class MapMenu extends google.maps.OverlayView

    constructor: ({@map}) ->
      @$el = $('<div id="map-menu">').css('position', 'absolute')
      @setMap(@map)
      @mapDiv = @map.getDiv()

    onAdd: ->
      @$el.html(template({strings})).hide()
      @$menu = @$el.find('.dropdown-menu').css('display', 'block') # It's hidden by bootstrap's base CSS

      google.maps.event.addListener @map, 'click', (event) =>
        @hide()
      google.maps.event.addListener @map, 'rightclick', (event)  =>
        @show(event.latLng)
      @$el.find('#map-routes-from').on 'click', (event) =>
        Reitti.Event.trigger 'routes:from', @position.lng(), @position.lat()
      @$el.find('#map-routes-to').on 'click', (event) =>
        Reitti.Event.trigger 'routes:to', @position.lng(), @position.lat()

      @getPanes().floatPane.appendChild(@$el[0])

    onRemove: ->
      @$el.remove()

    draw: ->
      return unless @position?
      {x, y} = @getProjection().fromLatLngToDivPixel(@position)
      mapWidth = @mapDiv.offsetWidth
      mapHeight = @mapDiv.offsetHeight
      menuWidth = @$menu.innerWidth()
      menuHeight = @$menu.outerHeight()
      left = if x + menuWidth < mapWidth then x else x - menuWidth
      top = if y + menuHeight < mapHeight then y else y - menuHeight
      @$el.css
        top: top
        left: left

    hide: ->
      @$el.hide()
      this

    show: (latLng) ->
      @position = latLng
      @$el.show()
      @draw()
      this
