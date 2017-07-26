
Component = require './ComponentJS/component'
Menu = require './menu'
FloatPages = require './float_pages'

class MenuContainer extends Component

	constructor: (id, parent) ->
		super(id, parent)
		@tab = 'menu'

	getElMenuId: -> @id + '_menu'
	getElFloatId: -> @id + '_float'

	getMenu: ->
		id = @getElMenuId()
		menu = @getChildById(id)
		if not menu?
			menu = new Menu(id, @)
			menu.getEvent('openPage').subscribe(@, @openPage)
			menu.load()
		menu

	getFloatPages: ->
		id = @getElFloatId()
		float = @getChildById(id)
		if not float?
			float = new FloatPages(id, @)
			float.getEvent('openPage').subscribe(@, @openPage)
			float.load()
		float

	openPage: (id, type, pageType) ->
		@getFloatPages().setSelectedItemId(0) if pageType is 'menu'
		@getMenu().setSelectedItemId(0) if pageType is 'menu'
		@getEvent('openPage').fire(id, type)

	load: -> @getComponent().load()

	getComponent: ->
		if @tab is 'menu'
			component = @getMenu()
		else
			component = @getFloatPages()
		component

	click: (element) ->
		if element.hasClass('doChangeTab')
			@tab = element.dataset.tab
			@render()

	getHtml: ->
		html = '<div class="toolbar">'
		html += '<div class="tab doChangeTab ' + (if @tab is 'menu' then 'active' else '') + '" data-tab="menu">Stránky v menu</div>'
		html += '<div class="tab doChangeTab ' + (if @tab is 'float' then 'active' else '') + '" data-tab="float">Ostatní stránky</div>'
		html += '</div>'
		component = @getComponent()
		html += '<div class="left_column" id="' + component.getId() + '">' + component.getHtml() + '</div>'

module.exports = MenuContainer