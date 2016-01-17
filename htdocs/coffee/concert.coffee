
class Cms.Concert extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@saving = no

	setConcert: (@concert) ->
		@saving = no
		@

	getWysiwyg:  ->
		id = @id + '_wysiwyg'
		child = @getChildById(id)
		if not child?
			child = new Cms.WysiwygEditor(id, @)
			child.setType('mini').getEvent('change').subscribe(@, @changeText)
		child.setContent(@concert.text)

	upload: (files) ->
		for file in files
			fd = new FormData()
			fd.append('files[]', file, file.name)
			fd.append('action', 'saveConcertImage')
			fd.append('data', JSON.stringify({concertId: @concert.id}))
			xhr = new XMLHttpRequest()
			xhr.open('POST', @getBaseUrl(), yes)
			xhr.onload = (response) => @uploadResponse(response)
			xhr.send(fd);

	uploadResponse: (response) ->
		fileInfo = JSON.parse(response.target.response)
		@concert.image_id = fileInfo.fileId
		@concert.image = fileInfo.hash
		@render()

	save: ->
		@saving = yes
		@render()
		@sendRequest('saveConcert', @concert, @saveResponse)

	saveResponse: (response) ->
		if response.id?
			@concert.id = response.id*1
			@saving = no
			@render()
		else
			@getParent().loadResponse(response)
		@

	remove: -> @sendRequest('removeConcert', {id: @concert.id, menuId: @concert.menu_id}, @removeResponse)

	removeResponse: (response) -> @getParent().loadResponse(response)

	changeText: (text) -> @concert.text = text

	change: (element) ->
		@upload(element.files) if element.hasClass('doUploadImage')
		@concert.name = element.value if element.hasClass('doChangeName')
		@concert.start_time = element.value if element.hasClass('doChangeStartTime')
		@concert.place = element.value if element.hasClass('doChangePlace')
		@concert.ticket_uri = element.value if element.hasClass('doChangeTicketUri')

	click: (element) ->
		@save() if element.hasClass('doSave')
		@remove() if element.hasClass('doRemove') and confirm('Opravdu chcete odstranit tuto událost?')

	getHtml: ->
		html = '<div class="concert"><table>'
		html += '<tr>'
		html += '<td rowspan="4"><div class="concert-image" style="' + (if @concert.image? then 'background-image: url(\'./images/userimages/medium/' + @concert.image + '.jpg\')' else 'background: #FFF') + '">'
		html += '<input type="file" class="form-control input-sm doUploadImage"></div></td>'
		html += '<td>Název: </td><td><input type="text" class="form-control input-sm doChangeName" value="' + @concert.name + '"></td>'
		html += '</tr>'
		html += '<tr><td>Datum: </td><td><input type="datetime-local" class="form-control input-sm doChangeStartTime" value="' + @concert.start_time + '"></td></tr>'
		html += '<tr><td>Místo: </td><td><input type="text" class="form-control input-sm doChangePlace" value="' + @concert.place + '"></td></tr>'
		html += '<tr><td>URL vstupenek: </td><td><input type="url" class="form-control input-sm doChangeTicketUri" value="' + @concert.ticket_uri + '"></td></tr>'
		html += '<tr><td colspan="3">'
		editor = @getWysiwyg().setHeight(300)
		html += '<div id="' + editor.getId() + '">' + editor.getHtml() + '</div>'
		html += '</td></tr>'
		html += '<tr><td class="center">'
		html += '<button class="btn btn-danger btn-sm doRemove">Odstranit</button>' if @concert.id
		html += '</td><td></td><td class="center">'
		if @saving
			html += 'Ukládám...'
		else
			html += '<button class="btn btn-primary btn-sm doSave">Uložit</button>'
		html += '</td></tr>'
		html += '</table><div style="clear: both;"></div></div>'