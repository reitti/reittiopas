define ['backbone'], (Backbone) ->
  class Bookmark extends Backbone.Model
    initialize: ->
      @on 'remove', =>
        @destroy()

    validate: (attrs) ->
      if !attrs.name
        'error'