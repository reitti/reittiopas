define [
  'jquery'
  'backbone'
  'models/bookmark'
  'views/search_input_view'
  'hbs!template/bookmarks'
  'i18n!nls/strings'
], ($, Backbone, Bookmark, SearchInputView, template, strings) ->

  ARROW_WIDTH = 12

  class BookmarksView extends Backbone.View

    el: $('#bookmarks')

    events:
      'click .bookmark': 'select'
      'click #add-bookmark': 'add'
      'click #edit-bookmarks': 'edit'
      'submit form': 'create'

    initialize: ({@collection, @anchor, @width}) ->
      @collection.fetch()
      @collection.on('add', @render)
      @collection.on('remove', @render)

    render: =>
      @$el.html(template bookmarks: @collection.toJSON(), strings: strings, @width)
      @_placeWindow()
      @_placeArrow()
      @initTooltips()
      @initTypeAhead()
      this

    toggleVisibility: ->
      @$el.toggle()
      this

    hide: ->
      @$el.hide()
      this

    add: ->
      @$el.find('.placeholder').hide()
      @$el.find('#new-favorite').removeClass('hidden')

    edit: ->

    create: (event) ->
     event.preventDefault()
     name = @$el.find('#bookmark-name').val()
     id = if @collection.isEmpty() then 1 else @collection.first().get('id') + 1
     if @collection.create({name, id})
       @render()
       @searchInputView.clearError()
     else
       @searchInputView.indicateError()

    select: (event) ->
      id = $(event.target).data('id')
      bookmark = @collection.get(id)
      $('#to').val(bookmark.get('name'))
      @hide()

    _offset: ->
      {
        left: @anchor.offset().left + @anchor.innerWidth() + ARROW_WIDTH
        top: Math.max(20, @anchor.offset().top + @anchor.outerHeight() / 2 - @$el.outerHeight() / 2)
      }

    _placeWindow: ->
      @$el.offset(@_offset()).css({width: @width - 2 * ARROW_WIDTH})

    _placeArrow: ->
      @$el.find('.arrow').css('top', @anchor.offset().top - @$el.offset().top + @anchor.outerHeight() / 2)

    initTooltips: ->
      @$el.find('a[rel="tooltip"], button[rel="tooltip"]').tooltip()

    initTypeAhead: ->
      @searchInputView ?= new SearchInputView(el: @$el.find('#bookmark-name'))
