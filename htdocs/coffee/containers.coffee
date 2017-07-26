
Component = require './ComponentJS/component'
Container = require './container'

class Containers extends Component

	constructor: (id, parent) ->
		super(id, parent)
		@containers = []

	setMenuId: (@menuId) -> @

	setTypes: (@types) -> @

	load: -> @sendRequest('loadContainers', {menuId: @menuId}, @loadContainersResponse)

	loadContainersResponse: (response) ->
		@containers = response.containers
		@render()

	addContainer: -> @sendRequest('addContainer', {menuId: @menuId}, @addContainerResponse)

	removeContainer: (id) -> @sendRequest('removeContainer', {containerId: id, menuId: @menuId}, @loadContainersResponse)

	addContainerResponse: (response) ->
		@containers.push(response.id)
		@render()

	getContainer: (id, type) ->
		childId = @id + '_container' + id
		component = @getChildById(childId)
		if not component?
			component = new Container(childId, @)
			component.setMenuId(id).setTypes(@types).setType(type).setHeight(598).load()
		component

	click: (element) ->
		if element.hasClass('doAddContainer')
			@addContainer()
			@render()

	getHtml: ->
		html = '<div class="containers">'
		html += '<div class="toolbar controls form-inline">'
		html += '<button class="btn btn-sm btn-default doAddContainer">Přidat kontejner</button>'
		html += '</div><div style="height: ' + (@getHeight() - 82) + 'px;overflow: auto;">'
		for con in @containers
			container = @getContainer(con.id, con.type_id)
			html += '<div id="' + container.getId() + '" class="cms-container">' + container.getHtml() + '</div>'
		html += '</div></div>'

module.exports = Containers
