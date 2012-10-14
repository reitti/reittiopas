define [
  'jquery'
  'backbone'
  'hbs!template/error_message'
  'i18n!nls/strings'
], ($, Backbone, template, strings) ->
  class ErrorMessageView extends Backbone.View

    el: $('#error-message')
    initialize: ({@message}) ->

    render: ->
      @$el.html(template({@message, strings}))
      this