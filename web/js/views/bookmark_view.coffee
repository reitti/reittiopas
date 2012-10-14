define [
  'jquery'
  'backbone'
  'models/bookmark'
  'views/search_input_view'
  'modernizr'
  'hbs!template/bookmark'
  'i18n!nls/strings'
], ($, Backbone, Bookmark, SearchInputView, Modernizr, template, strings) ->
  class BookmarkView extends Backbone.View

    events:
      'click .bookmark': 'onSelectBookmark'
      'click .remove-button': 'onRemoveBookmark'
      'submit form': 'onUpdateBookmark'

    initialize: ->
      @model.on 'remove', =>
        @destroyTooltips()
        @remove()

    render: ->
      @$el.html template
        name: @model.get('name')
        strings: strings
      @initTooltips()
      this

    editMode: ->
      @isBeingEdited = true
      @$el.find('.remove-button').removeClass('hidden')

    stopEditMode: ->
      delete @isBeingEdited
      @render()

    onRemoveBookmark: (event) ->
      event.stopPropagation()
      if confirm(strings.areYouSure)
        @model.destroy()

    onSelectBookmark: ->
      if !@isBeingEdited
        $('#to').val(@model.get('name')) # TODO: Don't modify the template of an another view directly
        Reitti.Event.trigger 'bookmark:selected'
      else
        @$el.find('.edit-bookmark').toggleClass('hidden')
        @$el.find('.remove-button').toggleClass('hidden')
        @$el.find('.bookmark').toggleClass('hidden')

    onUpdateBookmark: (event) ->
      event.preventDefault() if event?
      name = @$el.find('input[type="text"]').val()
      console.log name
      @model.save {name: name},
        success: =>
          @render()
          @editMode()
        error: =>
          console.log 'error'

    initTooltips: ->
      unless Modernizr.touch
        @$el.find('a[rel="tooltip"], button[rel="tooltip"]').tooltip()

    destroyTooltips: ->
      @$el.find('a[rel="tooltip"], button[rel="tooltip"]').tooltip('destroy')

