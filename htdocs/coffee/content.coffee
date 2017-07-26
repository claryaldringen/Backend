
Component = require './ComponentJS/component'
Toolbar = require './toolbar'
Gallery = require './gallery'
Settings = require './settings'
HtmlEditor = require './html_editor'
WysiwygEditor = require './wysiwyg_editor'
Articles = require './articles'
Discography = require './discography'
Containers = require './containers'
Discussion = require './discussion'
Concerts = require './concerts'

class Content extends Component

	constructor: (id, parent) ->
		super(id, parent)
		@typeId = 1
		@types = []
		@tab = ''
		@content = ''
		@changed = no

	setMenuId: (@menuId) -> @

	setType: (typeId = 1) ->
		@typeId = typeId*1
		defaultTabs = {1: 'wysiwyg', 2: 'gallery', 3: '', 4: '',5: '', 6: '', 7: ''}
		@tab = defaultTabs[@typeId]
		@

	getToolbar: ->
		id = @id + '_toolbar'
		toolbar = @getChildById(id)
		if not toolbar?
			toolbar = new Toolbar(id, @)
			toolbar.getEvent('languageChange').subscribe(@, @languageChange)
			toolbar.load()
		toolbar

	languageChange: (languageId) -> @getEvent('languageChange').fire(languageId)

	getGallery: ->
		id = @id + '_gallerygallery'
		component = @getChildById(id)
		if not component?
			component = new Gallery(id, @)
			component.setMenuId(@menuId)
		component

	getContent: ->
		id = @id + '_' + @menuId + 'x' + @typeId + 'x' + @tab
		id = @id + '_' + @tab if @tab is 'settings'
		component = @getChildById(id)
		if not component?
			return new Settings(id, @) if @tab is 'settings'
			switch @typeId
				when 1
					switch @tab
						when 'html' then component = new HtmlEditor(id, @)
						when 'wysiwyg' then component = new WysiwygEditor(id, @)
					component?.getEvent('change').subscribe(@, @textChange)
				when 2
					switch @tab
						when 'gallery' then component = @getGallery()
						when 'html'
							component = new HtmlEditor(id, @)
							component?.getEvent('change').subscribe(@, @textChange)
						when 'wysiwyg'
							component = new WysiwygEditor(id, @)
							component?.getEvent('change').subscribe(@, @textChange)
				when 3
					component = new Articles(id, @)
					component.setMenuId(@menuId).load()
				when 4
					component = new Discography(id, @)
					component.setMenuId(@menuId).load()
				when 5
					component = new Containers(id, @)
					component.setMenuId(@menuId).setTypes(@types).load()
				when 6
					component = new Discussion(id, @)
					component.setMenuId(@menuId).load()
				when 7
					component = new Concerts(id, @)
					component.setMenuId(@menuId).load()
		component

	textChange: (text) ->
		@getGallery().setTextContent(text) if @typeId is 2
		@content = text
		@changed = yes
		@

	isChanged: -> @changed

	setChanged: (@changed) -> @

	getTabs: ->
		html = ''
		switch @typeId
			when 1
				html += '<div class="tab doChangeTab ' + (if @tab is 'wysiwyg' then 'active' else '') + '" data-tab="wysiwyg">WYSIWYG</div>'
				html += '<div class="tab doChangeTab ' + (if @tab is 'html' then 'active' else '') + '" data-tab="html">HTML</div>'
			when 2
				html += '<div class="tab doChangeTab ' + (if @tab is 'gallery' then 'active' else '') + '" data-tab="gallery">Galerie</div>'
				html += '<div class="tab doChangeTab ' + (if @tab is 'wysiwyg' then 'active' else '') + '" data-tab="wysiwyg">WYSIWYG</div>'
				html += '<div class="tab doChangeTab ' + (if @tab is 'html' then 'active' else '') + '" data-tab="html">HTML</div>'
			else
				html += '<div class="tab doChangeTab ' + (if @tab is '' then 'active' else '') + '" data-tab="">Obsah</div>'
		html += '<div class="tab doShowSettings ' + (if @tab is 'settings' then 'active' else '') + '" data-tab="settings">Nastavení</div>'
		html

	load: ->
		switch @typeId
			when 1 then @sendRequest('loadPage', {pageId: @menuId}, @loadResponse)
			when 2 then @getContent().load()
		@render()

	loadResponse: (response) ->
		@content = response.text
		@render()

	loadTypes: -> @sendRequest('loadTypes', {}, @loadTypesResponse)

	loadTypesResponse: (response) ->
		@types = response
		@render()

	save: (text) ->
		folderId = @getGallery().getActualFolder().id
		@sendRequest('savePage', {pageId: @menuId, folderId: folderId, typeId: @typeId, text: text}, @loadResponse)
		@

	click: (element) ->
		if element.hasClass('doChangeTab')
			@tab = element.dataset.tab
			@content = @getGallery().getTextContent() if @typeId is 2
			@render()
		if element.hasClass('doShowSettings')
			@tab = element.dataset.tab
			@render()

	change: (element) ->
		@sendRequest('saveContentType', {oldTypeId: @typeId, newTypeId: element.value, menuId: @menuId}, @saveResponse)
		hash = window.location.hash.split('&')
		hash[1] = element.value
		window.location.hash = hash[0] + '&' + hash[1]
		@setType(element.value*1)


	saveResponse: ->
		@getEvent('change').fire()
		@load()

	renderFinish: ->
		@width = document.getElementById(@id).clientWidth
		@height = document.getElementById(@id).clientHeight
		@getContent()?.renderFinish()

	getHtml: ->
		toolbar = @getToolbar()
		content = @getContent()
		content.setContent(@content) if @tab in ['html', 'wysiwyg']
		html = '<div class="toolbar controls form-inline"><label>'
		html += 'Typ obsahu: <select class="form-control input-sm">'
		html += '<option value="' + type.id + '" ' + ('selected' if @typeId is type.id) + '>' + type.name + '</option>' for type in @types
		html += '</select></label>'
		html += @getTabs()
		html += '<div class="main_toolbar" id="' + toolbar.getId() + '">' + toolbar.getHtml() + '</div>'
		html += '</div>'
		html += '<div id="' + content.getId() + '">' + content.getHtml() + '</div>' if content?
		html

module.exports = Content
