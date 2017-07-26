
Component = require './ComponentJS/component'
ShareControl = require './share_control'

class Gallery extends Component

	constructor: (id, parent) ->
		super(id, parent)
		@uploaded = 0
		@fileCount = 0
		@actualFolderId = 0
		@mainFolder = {id: 0}
		@showType = 'all'

	getElUploadId: -> @id + '-upload'

	getElSortableId: -> @id + '-sortable'

	setMenuId: (@menuId) -> @

	setShowType: (@showType = 'all') -> @

	getShareControl: ->
		id = @id + '_sc'
		sc = @getChildById(id)
		sc = new ShareControl(id, @) if not sc?
		sc.setFolderId(@actualFolderId).setMenuId(@menuId)

	load: () -> @sendRequest('loadGallery', {menuId: @menuId, showType: @showType}, @loadResponse)

	loadResponse: (response) ->
		if not response.error?
			@mainFolder = response[0]
			@actualFolderId = response[0].id if not @actualFolderId
			@uploaded = 0
			@fileCount = 0
			@render()
		else
			throw 'SERVER ERROR: ' + response.error.replace(/&gt;/g, '>')

	uploadResponse: ->
		@uploaded++
		percentage = @uploaded/@fileCount*100
		$('#' + @getElUploadId()).css('background-size', percentage + '% 100%')
		@load() if @fileCount is @uploaded

	getActualFolder: (folder = @mainFolder) ->
		return folder if folder.id is @actualFolderId
		if folder.folders?
			for fold in folder.folders
				actualFolder =	@getActualFolder(fold)
				return actualFolder if actualFolder?

	getTextContent: -> @getActualFolder().text

	setTextContent: (text) ->
		@getActualFolder().text = text
		@

	upload: (files) ->
		@fileCount = files.length
		for file in files
			fd = new FormData()
			fd.append('files[]', file, file.name)
			fd.append('action', 'saveImage')
			fd.append('data', JSON.stringify({folderId: @actualFolderId, menuId: @menuId}))
			xhr = new XMLHttpRequest()
			xhr.open('POST', @getBaseUrl(), yes)
			xhr.onload = => @uploadResponse()
			xhr.send(fd);
		$('#' + @getElUploadId()).css('background-size', '1% 100%')

	select: (imageId) -> @

	click: (element) ->
		if element.hasClass('doOpenFolder')
			@actualFolderId = element.dataset.id*1
			@render()
		if element.hasClass('doCreateNewFolder')
			@sendRequest('createGalleryFolder', {parent: @actualFolderId, menuId: @menuId}, @loadResponse)
		if element.hasClass('doDelete')
			@sendRequest('deleteGalleryItem', {type: element.dataset.type, id: element.dataset.id, menuId: @menuId}, @loadResponse) if confirm('Opravdu chcete odstranit tuto položku?')
		if element.hasClass('doSelect')
			@select(element.dataset.url)

	change: (element) ->
		if element.hasClass('doRename')
			@sendRequest('renameGalleryItem', {id: element.dataset.id, type: element.dataset.type, name: element.value, menuId: @menuId}, @loadResponse)
		if element.hasClass('doUpload')
			@upload(element.files)

	focusIn: (element) -> $(element).addClass('focused')

	focusOut: (element) -> $(element).removeClass('focused')

	dragStart: (element) -> console.log element

	doSort: (event) ->
		@sendRequest('saveSort', {id: event.item.dataset.id, oldIndex: event.oldIndex, newIndex: event.newIndex, type: event.item.dataset.type, menuId: @menuId}, @loadResponse)

	renderFinish: ->
		el = document.getElementById(@getElSortableId())
		if el?
			params =
				animation: 150
				onSort: (event) => @doSort(event)
			Sortable.create(el, params)
		@

	getHtml: ->
		sc = @getShareControl()
		html = '<div class="toolbar controls form-inline">'
		html += '<button class="doCreateNewFolder btn btn-sm btn-default">Vytvořit novou složku</button>&nbsp;'
		html += '<input type="file" id="' + @getElUploadId() + '" class="form-control input-sm doUpload" accept="image/*" multiple>'
		html += '&nbsp;<div id="' + sc.getId() + '" class="form-control input-sm">' + sc.getHtml() + '</div>'
		html += '</div>'
		if @actualFolderId
			html += '<div id="' + @getElSortableId() + '">'
			actualFolder = @getActualFolder()
			html += '<div class="folder" data-id="' + actualFolder.parent + '"><img src="../images/gallery/folder_256.png" width="128" class="doOpenFolder" data-id="' + actualFolder.parent + '">Zpět</div>' if actualFolder.parent?
			if actualFolder.folders?
				for folder in actualFolder.folders
					html += '<div class="folder" draggable="true" data-id="' + folder.id + '" data-type="folder">'
					html += '<img class="doDelete" data-type="folder" data-id="' + folder.id + '" title="Odstranit" src="../images/cms/icons/cross.png" width="16" height="16">'
					html += '<img src="../images/gallery/folder_256.png" width="128" class="doOpenFolder" data-id="' + folder.id + '" draggable="false">'
					html += '<input class="doRename" type="text" data-type="folder" data-id="' + folder.id + '" value="' + folder.name + '">'
					html += '</div>'
			if  actualFolder.images?
				for image in actualFolder.images
					html += '<div class="folder" data-id="' + image.id + '" data-type="image">'
					html += '<img class="doDelete" data-type="image" data-id="' + image.id + '" title="Odstranit" src="../images/cms/icons/cross.png" width="16" height="16">'
					if image.type is 'general'
						html += '<div><img class="doSelect" data-url="' + image.file + '" src="http://' + window.location.hostname + '/images/gallery/128.png"></div>'
					else
						html += '<div><img class="doSelect" data-url="' + image.file + '" src="http://' + window.location.hostname + '/images/userimages/small/' + image.file + '"></div>'
					html += '<input class="doRename" type="text" data-type="image" data-id="' + image.id + '" value="' + image.name + '">'
					html += '</div>'
			html += '</div>'
		else
			html += 'Loading...'
		html

module.exports = Gallery