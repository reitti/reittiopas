define ['jquery', 'backbone'], ($, Backbone) ->
  
  class RouteView extends Backbone.View
    
    tagName: 'li'
    
    events:
      "click": "select"
      
    initialize: (@route, @idx) ->
      
    render: ->
      @$el.html("Show #{@idx+1}.")
      this
      
    select: ->
      Reitti.Event.trigger 'route:select', @idx
      
