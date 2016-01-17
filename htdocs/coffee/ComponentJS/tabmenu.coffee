
class CJS.TabMenu extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@tabs = []

	getChildId: (id) -> @id + '_' + id

	getSelectedTab: -> return tab for tab in @tabs when tab.selected

	addTab: (id, label, selected = no)->
		@tabs.push({id: id, label: label, selected: selected})
		@

	click: (element) ->
		if element.hasClass('doChangeTab')
			for tab in @tabs
				if tab.id is element.dataset.id then tab.selected = yes else tab.selected = no
			@getEvent('change').fire(@)
			@render()

	getHtml: ->
		html = '<div class="tabBar">'
		for tab in @tabs
			selected = ''
			if tab.selected
				selected = 'selected'
				childId = @getChildId(tab.id)
			html += '<div class="' + selected + ' doChangeTab" data-id="' + tab.id + '">' + tab.label + '</div>'
		html += '</div><div id="' + @id + '-content' + '">'
		content = @getChildById(childId)
		html += '<div id="' + content.id + '">' + content.getHtml() + '</div></div>'

