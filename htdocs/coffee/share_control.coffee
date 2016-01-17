
class Cms.ShareControl extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@opened = no

	setFolderId: (@folderId) -> @

	setMenuId: (@menuId) -> @

	click: (element) ->
		@sendRequest('loadShare', {folderId: @folderId}, @loadResponse) if element.hasClass('doOpen')
		if element.hasClass('doSave')
			@items = null
			shared = []
			checkboxes = document.querySelectorAll('.check')
			shared.push(checkbox.dataset.id) for checkbox in checkboxes when checkbox.checked
			@sendRequest('saveShare', {folderId: @folderId, menuIds: shared, menuId: @menuId}, @render())

	loadResponse: (response) ->
		if not response.error?
			@items = response.items
			@render()
		else
			throw 'SERVER ERROR: ' + response.error.replace(/&gt;/g, '>')

	getHtml: ->
		if @items?
			html = '<div class="share_control">'
			html += '<table>'
			html += '<tr><td><label><input class="check" type="checkbox" data-id="' + item.id + '">' + item.name + '</label></td><td><img src="/images/flags/' + item.flag + '.png"></td></tr>' for item in @items
			html += '<tr><td colspan="3" style="text-align: center;"><button class="doSave">OK</button></td></tr>'
			html += '</table>'
			html += '</div>'
		else
			html = '<div class="share_control doOpen">Sdílet tuto složku</div>'
		html