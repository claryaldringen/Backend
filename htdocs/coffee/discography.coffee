
class Cms.Discography extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		date = new Date()
		@albums = []
		@addText = []
		@saving = []

	setMenuId: (@menuId) -> @

	getWysiwyg:  ->
		id = @id + '_wysiwyg'
		child = @getChildById(id)
		child = new Cms.WysiwygEditor(id, @) if not child?
		content = if @song? then @albums[@album].songs[@song].text else @albums[@album].text
		child.setContent(content)

	load: -> @sendRequest('loadDiscography', {menuId: @menuId}, @loadResponse)

	loadResponse: (response) ->
		@albums = response
		album.songs = [{name: '', text: '', sortKey: 1}] for album in @albums when album.songs.length is 0
		date = new Date()
		@albums.unshift({id: 0, name: '', year: date.getFullYear(), text: '', link: '', price: 0, count: 0, songs: [{name: '', text: '', link: '', sortKey: 1}]})
		@render()

	save: (text) ->
		if @song?
			@albums[@album].songs[@song].text = text
		else
			@albums[@album].text = text
		@addText[@album] = no
		@render()

	upload: (files, album, song) ->
		for file in files
			fd = new FormData()
			fd.append('files[]', file, file.name)
			if song? then fd.append('action', 'saveAudio') else fd.append('action', 'saveAlbumImage')
			fd.append('data', JSON.stringify({album: album, song: song}))
			xhr = new XMLHttpRequest()
			xhr.open('POST', @getBaseUrl(), yes)
			xhr.onload = (response) => @uploadResponse(response)
			xhr.send(fd);

	uploadResponse: (response) ->
		fileInfo = JSON.parse(response.target.response)
		if fileInfo.song?
			@albums[fileInfo.album].songs[fileInfo.song].file = fileInfo.hash
			@albums[fileInfo.album].songs[fileInfo.song].fileId = fileInfo.fileId
		else
			@albums[fileInfo.album].image = fileInfo.hash
			@albums[fileInfo.album].imageId = fileInfo.fileId
		@render()

	focusIn: (element) ->
		if element.hasClass('addNext')
			@lastFocusedElementId = element.getAttribute('id')
			@albums[element.dataset.album].songs.push({name: '', text: '', link: '', sortKey: @albums[element.dataset.album].songs.length+1})
			@render()

	change: (element) ->
		if element.hasClass('changeSong')
			@albums[element.dataset.album].songs[element.dataset.song].name = element.value
		if element.hasClass('changeAlbum')
			@albums[element.dataset.album].name = element.value
		if element.hasClass('changeYear')
			@albums[element.dataset.album].year = element.value
		if element.hasClass('changeLink')
			@albums[element.dataset.album].link = element.value
		if element.hasClass('changePrice')
			@albums[element.dataset.album].price = element.value
		if element.hasClass('changeCount')
			@albums[element.dataset.album].count = element.value
		if element.hasClass('doUploadAudio')
			@upload(element.files, element.dataset.album, element.dataset.song)
		if element.hasClass('doUploadImage')
			@upload(element.files, element.dataset.album, null)
		if element.hasClass('doChangeNumber')
			@albums[element.dataset.album].songs[element.dataset.song].sortKey = element.value
		if element.hasClass('doAddLink')
			@albums[element.dataset.album].songs[element.dataset.song].link = element.value

	click: (element) ->
		if element.hasClass('doRemoveSong')
			delete(@albums[element.dataset.album].songs[element.dataset.song].file)
			delete(@albums[element.dataset.album].songs[element.dataset.song].fileId)
			@render()
		if element.hasClass('doAddText')
			@addText[element.dataset.album] = yes
			@album = element.dataset.album
			@song = element.dataset.song
			@render()
		if element.hasClass('doSetText')
			@addText[element.dataset.album] = yes
			@album = element.dataset.album
			@song = null
			@render()
		if element.hasClass('doSave')
			@saving[element.dataset.album] = yes
			@render()
			@sendRequest('saveAlbum', {album: @albums[element.dataset.album], menuId: @menuId, albumIndex: element.dataset.album}, @saveResponse)
		if element.hasClass('doRemove') and confirm('Opravdu chcete odstranit album?')
			@sendRequest('removeAlbum', {albumId: @albums[element.dataset.album].id, menuId: @menuId, albumIndex: element.dataset.album}, @removeResponse)

	saveResponse: (response) ->
		@albums[response.index] = response.album
		@albums[response.index].songs = [{name: '', text: '', sortKey: 1}] if @albums[response.index].songs.length is 0
		@saving[response.index] = null
		if @albums[0].id isnt 0
			date = new Date()
			@albums.unshift({id: 0, name: '', year: date.getFullYear(), text: '', link: '', price: 0, count: 0, songs: [{name: '', text: '', link: '', sortKey: 1}]})
		@render()

	removeResponse: (response) ->
		@albums.splice(response.index, 1)
		@render()

	beforeRender: ->
		@scroll = document.querySelector('.discography').scrollTop;

	renderFinish: ->
		document.querySelector('.discography').scrollTop = @scroll
		document.getElementById(@lastFocusedElementId)?.focus()
		id = @id + '_wysiwyg'
		@getChildById(id)?.renderFinish()


	getHtml: ->
		html = '<div class="discography" style="height:' + (@getHeight() - 42) + 'px">'
		for album,ai in @albums
			html += '<div class="album">'
			html += '<div class="left"><table>'
			html += '<tr><td>Název alba:&nbsp;</td><td><input data-album="' + ai + '" class="form-control input-sm changeAlbum" type="text" value="' + album.name + '"></td></tr>'
			html += '<tr><td>Rok vydání:&nbsp;</td><td><input data-album="' + ai + '" class="form-control input-sm changeYear" type="text" value="' + album.year + '"></td></tr>'
			html += '<tr><td>Odkaz na nákup:&nbsp;</td><td><input data-album="' + ai + '" class="form-control input-sm changeLink" type="url" value="' + album.link + '"></td></tr>'
			html += '<tr><td>Cena:&nbsp;</td><td><input data-album="' + ai + '" class="form-control input-sm changePrice" type="number" value="' + album.price + '"></td></tr>'
			html += '<tr><td>Počet kusů:&nbsp;</td><td><input data-album="' + ai + '" class="form-control input-sm changeCount" type="number" value="' + album.count + '"></td></tr>'
			html += '</table>'
			html += '<div class="album-image" style="' + (if album.image? then 'background-image: url(\'./images/userimages/large/' + album.image + '.jpg\')' else 'background: #FFF') + '">'
			html += '<input type="file" accept="image/jpeg" data-album="' + ai + '" class="doUploadImage"></div>'
			html += '<button class="btn btn-danger btn-sm doRemove" data-album="' + ai + '">Odstranit</button>&nbsp;&nbsp;' if album.id? and album.id > 0
			html += '<button class="btn btn-default btn-sm doSetText" data-album="' + ai + '">Vložit popisek</button>&nbsp;&nbsp;'
			if @saving[ai]?
				html += '<span>Ukládám...</span>';
			else
				html += '<button class="btn btn-primary btn-sm doSave" data-album="' + ai + '">Uložit</button>'
			html += '</div>'
			html += '<div class="right">'
			if @addText[ai]
				editor = @getWysiwyg()
				html += '<div id="' + editor.getId() + '">' + editor.getHtml() + '</div>'
			else
				html += '<table>'
				html += '<tr><th>Č.</th><th>Název skladby</th><th colspan="2">Poslechová ukázka</th><th>Odkaz na nákup</th><th>Text</th></tr>'
				for song,i in album.songs
					html += '<tr>'
					html += '<td class="number"><input class="form-control input-sm doChangeNumber" type="number" value="' + song.sortKey + '" data-album="' + ai + '" data-song="' + i + '"></td>'
					inputId = @id + '-' + ai + '-' + i
					html += '<td><input id="' + inputId + '" data-album="' + ai + '" data-song="' + i + '" class="form-control input-sm ' + (if i == album.songs.length-1 then 'addNext' else '') + ' changeSong" type="text" value="' + song.name + '"></td>'

					if song.file?
						html += '<td>'
						html += '<audio src="/userfiles/' + song.file + '" controls preload></audio></td><td>'
						html += '<button class="btn btn-danger btn-sm doRemoveSong" data-album="' + ai + '" data-song="' + i + '">Odstranit</button>'
					else
						html += '<td colspan="2">'
						html += '<input class="form-control input-sm file doUploadAudio" type="file" accept="audio/mpeg" data-album="' + ai + '" data-song="' + i + '">'
					html += '</td>'
					html += '<td><input type="text" class="form-control input-sm file doAddLink" data-album="' + ai + '" data-song="' + i + '" value="' + song.link + '"></td>'
					html += '<td><button class="btn btn-default btn-sm doAddText" data-album="' + ai + '" data-song="' + i + '">Vložit text</button>'
					html += '</td>'
					html += '</tr>'
				html += '</table>'
			html += '</div>'
			html += '<div style="clear: both;"></div>'
			html += '</div>'
		html += '</div>'
