define ['jquery', 'underscore', 'backbone', 'models/bookmark', 'backboneLocalStorage'], ($, _, Backbone, Bookmark) ->
  class Bookmarks extends Backbone.Collection

    model: Bookmark

    localStorage: new Backbone.LocalStorage('bookmarks'),

    comparator: (bookmark) ->
      bookmark.get('id') * -1