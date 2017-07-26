
Component = require './ComponentJS/component'

class Menu extends Component

	constructor: (id, parent) ->
		super(id, parent)
		@isWritable = no
		@items = []

	getElInputId: (index) -> @id + '-input-' + index.join('-')

	getElPlusId: (index) -> @id + '-plus-' + index.join('-')

	getElUpId: (index) -> @id + '-up-' + index.join('-')

	getElDownId: (index) -> @id + '-down-' + index.join('-')

	setIsWritable: (@isWritable) ->
		@addItem() if not @items.length and @isWritable
		@

	addItem: (way = [0], items = @items) ->
		if way.length is 1
			items.push({text: '', visibility: 'visible'})
		else
			for item,index in items
				if way[0] is index
					item.items = [] if not item.items?
					way.shift()
					@addItem(way, item.items)
		@

	setSelectedItemId: (@selectedItemId) -> @

	load: -> @sendRequest('loadMenu', {type: 'visible'}, @loadResponse)

	loadResponse: (response) ->
		if not response.error?
			@items = response.items
			if not @items.length
				@setIsWritable(yes)
				@addItem()
			else
				@setIsWritable(no)
				ident = window.location.hash.replace('#','').split('&')
				@openPage(ident[0], ident[1]) if ident[0]? and ident[1]?
			@render()
		else
			throw 'SERVER ERROR: ' + response.error.replace(/&gt;/g, '>')

	isLast: (way, items) ->
		for item, index in items
			if way?
				return yes if way.length is 1 and way[0] is index and not items[index+1]?
				if way[0] is index and item.items?
					newWay = way.slice(0)
					newWay.shift()
					return @isLast(newWay, item.items)
		no

	findItemById: (elId, callback) ->
		for item,i in @items
			way = @findItem(elId, callback, item, [i], 1)
			return way if way?

	findItem: (elId, callback, item, index, level) ->
		if callback.call(@, index) is elId
			return index
		else if item.items?
			for childItem,itemIndex in item.items
				index[level] = itemIndex
				clone = index.slice(0);
				way = @findItem(elId, callback, childItem, clone, level+1)
				return way if way?
		null

	setItemName: (way, name, items) ->
		item = items[way.shift()]
		if item.items and way.length
			@setItemName(way, name, item.items)
		else
			item.text = name

	setPosition: (way, items, pos) ->
		index = way.shift()
		if way.length
			@setPosition(way, item.items, pos) for item,i in items when i is index
		else
			val = {up: -1, down: 1}[pos]
			item = items[index]
			items[index] = items[index + val]
			items[index + val] = item
		@

	focusIn: (element) ->
		if @isWritable
			way = @findItemById(element.id, @getElInputId)
			if @isLast(way, @items)
				@idToFocus = element.id
				@addItem(way).render()
		@

	click: (element) ->
		if element.hasClass('doSave')
			@sendRequest('saveMenu', @items, @loadResponse)
		if element.className is 'doUp'
			way = @findItemById(element.id, @getElUpId)
			@setPosition(way, @items, 'up').render()
		if element.className is 'doDown'
			way = @findItemById(element.id, @getElDownId)
			@setPosition(way, @items, 'down').render()
		if element.className is 'doSubmenu'
			way = @findItemById(element.id, @getElPlusId)
			if way?
				way.push(0)
				@addItem(way).render()
		if element.hasClass('doWrite')
			@setIsWritable(yes).render()
		if element.hasClass('doOpenPage')
			@openPage(element.dataset.id, element.dataset.type)
			return no
		@

	openPage: (id, type) ->
		@getEvent('openPage').fire(id, type, 'menu')
		@selectedItemId = id*1
		window.location.hash = '#' + id + '&' + type
		@render()

	change: (element) ->
		way = @findItemById(element.id, @getElInputId)
		@setItemName(way, element.value, @items)

	renderItem: (item, index, level) ->
		html = '<li>'
		if @isWritable
			html += '<input type="text" class="form-control input-sm" id="' + @getElInputId(index) + '" value="' + item.text + '">'
			html += '<img src="/images/cms/icons/arrow_up.png" title="Posunout nahoru" class="doUp" id="' + @getElUpId(index) + '">'
			html += '<img src="/images/cms/icons/arrow_down.png" title="Posunout dolu" class="doDown" id="' + @getElDownId(index) + '">'
		else
			if item.id is @selectedItemId
				html += '<span class="selected">' + item.text + '</span>'
			else
				html += '<a href="#" data-id="' + item.id + '" data-type="' + item.type + '" class="doOpenPage">' + item.text + '</a>'
		if item.items? and item.items.length
			html += '<ul>'
			for child, childIndex in item.items
				index[level] = childIndex
				clone = index.slice(0);
				html += @renderItem(child, clone, level+1)
			html += '</ul>'
		else if @isWritable
			html += '<img src="/images/cms/icons/add.png" title="Přidat podmenu" class="doSubmenu" id="' + @getElPlusId(index) + '">'
		html += '</li>'

	renderFinish: ->
		document.getElementById(@idToFocus).focus() if @idToFocus
		@idToFocus = null

	getHtml: ->
		html = '<div class="toolbar">'
		html += if @isWritable then '<button class="btn btn-primary btn-sm doWrite doSave">Uložit</button>' else '<button class="btn btn-primary btn-sm doWrite">Upravit menu</button>'
		html += '</div>'
		html += '<ul>'
		html += @renderItem(item, [index], 1) for item, index in @items
		html += '</ul>'

module.exports = Menu
