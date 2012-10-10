define ['jquery', 'backbone'], ($, Backbone) ->

  class NavbarView extends Backbone.View

    el: $('.navbar')

    events: 
      'click a': 'onBackClicked'

    initialize: ->
      Reitti.Event.on 'routes:change', @onRoutesChanged

    onRoutesChanged: (routes, @routeParams) =>
      if routeParams.routeIndex?
        $('#route-displays').addClass 'expanded'
        @$el.find('.nav').show()
        @$el.find('.brand').hide()
      else
        $('#route-displays').removeClass 'expanded'
        @$el.find('.nav').hide()
        @$el.find('.brand').show()

    onBackClicked: =>
      Reitti.Router.navigateToRoutes _.extend(@routeParams, routeIndex: undefined, legIndex: undefined, departureOrArrival: undefined)
      false