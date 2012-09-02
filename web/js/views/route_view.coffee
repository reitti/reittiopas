define ['jquery', 'backbone', 'hbs!templates/route_view'], ($, Backbone, template) ->
  
  class RouteView extends Backbone.View
    
    tagName: 'li'
      
    events:
      "click": "select"
      
    initialize: (@route, @idx) ->
      Reitti.Event.on 'route:select', @onRouteSelected
      
    render: ->
      @$el.html(template(idx: @idx + 1))
      this
      
    select: ->
      Reitti.Event.trigger 'route:select', @idx
      
    onRouteSelected: (idx) =>
      @$el.toggleClass 'active', idx is @idx
