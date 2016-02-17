
class CJS.Component

	constructor: (@id, @parent) ->
		@parent.setChild(@) if @parent?
		@children = {}
		@baseUrl = null
		@events = {}

	getId: -> @id

	setParent: (@parent) ->
		@parent.setChild(@)
		@

	getParent: -> @parent

	setChild: (child) ->
		@children[child.id] = child

	getChildById: (id) -> @children[id]

	findChildById: (id) ->
		ids = id.split('_')
		child = @
		for id in ids
			id = lastId + '_' + id if lastId?
			child = child?.getChildById(id)
			lastId = id
		if child? then child else new CJS.Component()

	setBaseUrl: (@baseUrl) -> @

	getEvent: (event) ->
		if not @events[event]
			@events[event] = new CJS.Event()
		@events[event]

	getBaseUrl: ->
		@baseUrl = @parent.getBaseUrl() if not @baseUrl?
		@baseUrl

	setHeight: (@height) -> @

	getHeight: ->
		if @height?
			@height
		else
			@getDocumentHeight()

	getDocumentHeight: -> Math.max(document.body.scrollHeight, document.documentElement.scrollHeight, document.body.offsetHeight, document.documentElement.offsetHeight, document.body.clientHeight, document.documentElement.clientHeight)

	sendRequest: (action, params, callback = ->) ->
		$.post(@getBaseUrl(), {action: action, data: JSON.stringify(params)}, (data) =>
			data = JSON.parse(data)
			if data? and data.errorCode? and data.errorCode*1 is 1
				alert('Při provádění operace došlo k chybě. Kontaktujte prosím administrátora webu.');
				console.log(data.error)
			else
				callback.call(@, data)
		)
		@

	click: ->

	focusIn: ->

	focusOut: ->

	change: ->

	keyUp: ->

	dragStart: ->

	resize: ->

	beforeRender: ->

	render: ->
		@beforeRender()
		element = document.getElementById(@id)
		if element?
			element.innerHTML = @getHtml()
			@renderFinish()
			@restoreView()
		@

	renderFinish: -> child.renderFinish() for childId,child of @children

	restoreView: -> child.restoreView() for childId,child of @children

	getHtml: -> ''

