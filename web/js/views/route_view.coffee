define ['jquery', 'backbone', 'handlebars', 'text!templates/route_view.handlebars'], ($, Backbone, Handlebars, template) ->
  
  class RouteView extends Backbone.View
    
    tagName: 'li'
    template: Handlebars.compile(template)
    
    events:
      "click": "select"
      
    initialize: (@route, @idx) ->
      
    render: ->
      @$el.html(@template(idx: @idx))
      this
      
    select: ->
      Reitti.Event.trigger 'route:select', @idx
