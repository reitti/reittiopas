define ['jquery', 'underscore', 'backbone', 'models/bookmark', 'backboneLocalStorage'], ($, _, Backbone, Bookmark) ->
  class Bookmarks extends Backbone.Collection

    model: Bookmark

    localStorage: new Backbone.LocalStorage('bookmarks'),

    nextId: ->
      if @isEmpty() then 1 else @last().get('id') + 1