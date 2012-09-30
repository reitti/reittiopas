define ['jquery', 'backbone', 'hbs!template/blank_slate', 'i18n!nls/strings'], ($, Backbone, template, strings) ->

  class BlankSlateView extends Backbone.View

    el: $('#blank-slate')

    events:
      'click .example-route': 'goToExampleRoute'
      'click .close': 'dismiss'

    initialize: ->
      Reitti.Event.on 'home', @onGoneHome
      Reitti.Event.on 'routes:change', @onRoutesChanged

    goToExampleRoute: =>
      Reitti.Router.navigateToRoutes
        from: 'Mannerheimintie 15, Helsinki'
        to: 'Roihuvuoren kirjasto, Helsinki'
        arrivalOrDeparture: 'departure'
        date: 'now'
        transportTypes: ['all']
        routeIndex: 0
      false

    onGoneHome: =>
      return if @isDismissed()
      @$el.show()
      @$el.html(template(strings: strings.blankSlate))

    onRoutesChanged: =>
      @$el.hide()
      @$el.empty()

    dismiss: =>
      @$el.remove()
      expiresAt = new Date(new Date().getTime() + 20 * 365 * 24 * 60 * 60 * 1000)
      document.cookie = "blankSlateDismissed=true; expires=#{expiresAt.toUTCString()}; path: /"

    isDismissed: =>
      /blankSlateDismissed/.test(document.cookie)
