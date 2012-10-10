define ['jquery', 'backbone'], ($, Backbone) ->

  class NavbarView extends Backbone.View

    el: $('.navbar')

    events: 
      'click': 'onClicked'

    initialize: ->
      Reitti.Event.on 'routes:change', @onRoutesChanged

    onRoutesChanged: (routes, @routeParams) =>
      if routeParams.routeIndex?
        $('#route-displays').addClass 'expanded'
        @$el.find('.back').show()
      else
        $('#route-displays').removeClass 'expanded'
        @$el.find('.back').hide()

    onClicked: =>
      if @routeParams?.routeIndex?
        Reitti.Router.navigateToRoutes _.extend(@routeParams, routeIndex: undefined, legIndex: undefined, departureOrArrival: undefined)
      else
        Reitti.Router.navigate '/', trigger: true
      false
