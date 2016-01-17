
class Cms.FloatPages extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@isWritable = no
		@items = []

	getElNameId: (index) -> @id + '-inputName-' + index
	getElUrlId: (index) -> @id + '-inputUrl-' + index

	setIsWritable: (@isWritable) ->
		@addItem() if not @items.length and @isWritable
		@

	addItem: ->
		@items.push({text: '', url: '', visibility: 'invisible'})
		@

	setSelectedItemId: (@selectedItemId) -> @

	load: -> @sendRequest('loadMenu', {type: 'invisible'}, @loadResponse)

	loadResponse: (response) ->
		if not response.error?
			@items = response.items
			if not @items.length
				@addItem()
				@setIsWritable(yes)
			else
				@setIsWritable(no)
			@render()
		else
			throw 'SERVER ERROR: ' + response.error.replace(/&gt;/g, '>')

	isLast: (index) -> index*1 is @items.length-1

	focusIn: (element) ->
		if @isWritable
			if @isLast(element.dataset.index)
				@idToFocus = element.id
				@addItem().render()
		@

	click: (element) ->
		if element.hasClass('doSave')
			@sendRequest('saveFloat', @items, @loadResponse)
		if element.hasClass('doWrite')
			@setIsWritable(yes).render()
		if element.hasClass('doOpenPage')
			@getEvent('openPage').fire(element.dataset.id, element.dataset.type, 'float')
			@setSelectedItemId(element.dataset.id*1)
			@render()
		@

	change: (element) -> @items[element.dataset.index].text = element.value

	renderItem: (item, index) ->
		html = '<li>'
		if @isWritable
			html += '<input type="text" class="form-control input-sm name" id="' + @getElNameId(index) + '" value="' + item.text + '" data-index="' + index + '">'
			html += '<input type="text" class="form-control input-sm url" id="' + @getElUrlId(index) + '" value="' + item.url + '" readonly="true">'
		else
			if item.id is @selectedItemId
				html += '<span class="selected">' + item.text + '</span>'
			else
				html += '<a href="#" data-id="' + item.id + '" data-type="' + item.type + '" class="doOpenPage">' + item.text + '</a>'
		html += '</li>'

	renderFinish: ->
		document.getElementById(@idToFocus).focus() if @idToFocus
		@idToFocus = null

	getHtml: ->
		html = '<div class="toolbar">'
		if @isWritable
			html += '<button class="btn btn-primary btn-sm doWrite doSave">Uložit</button>'
		else
			html += '<button class="btn btn-primary btn-sm doWrite">Editovat</button>'
		html += '</div>'
		html += '<ul>'
		html += @renderItem(item, index) for item, index in @items
		html += '</ul>'


