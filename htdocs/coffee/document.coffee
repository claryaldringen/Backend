

CJSDocument = require './ComponentJS/document'
Content = require './content'
MenuContainer = require './menu_container'


class Document extends CJSDocument

	getMenuContainer: ->
		id = 'menuContainer'
		menuContainer = @getChildById(id)
		if not menuContainer?
			menuContainer = new MenuContainer(id, @)
			menuContainer.getEvent('openPage').subscribe(@, @openPage)
		menuContainer

	getContent: ->
		content = @getChildById('content')
		if not content?
			content = new Content('content', @)
			content.loadTypes()
			content.getEvent('change').subscribe(@, @contentChange)
			content.getEvent('languageChange').subscribe(@, @languageChange)
		content

	languageChange: (languageId) -> @sendRequest('useLanguage', {languageId: languageId}, @useLanguageResponse)

	ping: ->
		content = @getContent()
		if content.isChanged()
			@sendRequest('ping', {}, @pingResponse)
			content.setChanged(no)

	pingResponse: (response) ->
		location.reload() if response is no

	useLanguageResponse: ->
		@children = {}
		@load()

	openPage: (id, type) -> @getContent().setMenuId(id).setType(type).load()

	contentChange: -> @getMenuContainer().load()

	load: ->
		@getContent()
		@render()

	bindEvents: ->
		super()
		setInterval( => @ping()
		1000*60*5)

	getHtml: ->
		menuContainer = @getMenuContainer()
		html = '<div id="' + menuContainer.getId() + '">' + menuContainer.getHtml() + '</div>'

		content = @getContent()
		html += '<div id="' + content.getId() + '">' + content.getHtml() + '</div>'


window.Cms =
	Document: Document

