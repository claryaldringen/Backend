
class Cms.Discussion extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@comments = []
		@comment = {comment_id: null, name: '', caption: '', text: ''}
		@scroll = 0

	setMenuId: (@menuId) -> @

	load: -> @sendRequest('loadComments', {menuId: @menuId}, @loadResponse)

	loadResponse: (response) ->
		@comments = response.comments
		@comment = {comment_id: null, name: '', caption: '', text: ''}
		@render()

	save: ->
		@comment.menu_id = @menuId
		@sendRequest('saveComment', @comment, @loadResponse)

	search: (id, comments = @comments) ->
		for comment in comments
			return comment if comment.id is id
			if comment.comments? and comment.comments.length
				comment = @search(id, comment.comments)
				return comment if comment?
		null

	change: (element) ->
		if element.hasClass('doChangeName')
			@comment.name = element.value
		if element.hasClass('doChangeCaption')
			@comment.caption = element.value
		if element.hasClass('doChangeText')
			@comment.text = element.value

	click: (element) ->
		if element.hasClass('doReply')
			@comment.comment_id = element.dataset.id
			@render()
		if element.hasClass('doEdit')
			@comment = @search(element.dataset.id*1)
			@render()
		if element.hasClass('doRemove') and confirm('Opravdu chcete odstranit komentář včetně reakcí?')
			@sendRequest('removeComment', {id: element.dataset.id, menuId: @menuId}, @loadResponse)
		if element.hasClass('doCancel')
			@comment = {comment_id: null, name: '', caption: '', text: ''}
			@render()
		if element.hasClass('doSubmit')
			if @comment.name is ''
				alert('Jméno nesmí být prázdné.')
			else if  @comment.caption is ''
				alert('Nadpis nesmí být prázdný.')
			else if  @comment.text is ''
				alert('Vložte prosím text zprávy.')
			else @save()

	beforeRender: ->
		@scroll = document.querySelector('.comments-container')?.scrollTop;

	renderFinish: ->
		document.querySelector('.comments-container').scrollTop = @scroll

	getFormHtml: ->
		html = '<div class="comment-form"><table>'
		html += '<tr><td>Jméno:&nbsp;</td><td><input type="text" class="form-control input-sm doChangeName" value="' + @comment.name + '"></td></tr>'
		html += '<tr><td>Titulek:&nbsp;</td><td><input type="text" class="form-control input-sm doChangeCaption" value="' + @comment.caption + '"></td></tr>'
		html += '<tr><td colspan="2">Text sdělení:<br><textarea class="form-control input-sm doChangeText">' + @comment.text + '</textarea></td></tr>'
		html += '<tr><td class="center"><button class="btn btn-default btn-sm doCancel">Zrušit</button></td>'
		html += '<td class="center"><button class="btn btn-primary btn-sm doSubmit">Odeslat komentář</button></td></tr>'
		html += '</table></div>'

	getCommentHtml: (comment) ->
		html = '<li><div class="comment">'
		html += '<span class="username">' + comment.name + '</span>'
		html += '<h4>' + comment.caption + '</h4>'
		html += comment.text
		if comment.id*1 is @comment.comment_id*1
			@comment.caption = 'Re: ' + comment.caption
			html += @getFormHtml()
		else
			html += '<table><tr>'
			html += '<td><button data-id="' + comment.id + '" class="btn btn-default btn-sm doReply">Odpovědět</button></td>'
			html += '<td><button data-id="' + comment.id + '" class="btn btn-primary btn-sm doEdit">Editovat</button></td>'
			html += '<td><button data-id="' + comment.id + '" class="btn btn-danger btn-sm doRemove">Odstranit</button></td>'
			html += '</tr></table>'
		html += '</div><ul>'
		html += @getCommentHtml(comm) for comm in comment.comments
		html += '</ul>'
		html += '</li>'

	getHtml: ->
		html = '<div style="height: ' + (@getHeight() - 42) + 'px;" class="comments-container"><ul>'
		for comment in @comments
			html += @getCommentHtml(comment)
		html += '</ul>'
		html += @getFormHtml() if not @comment.comment_id? or @comment.comment_id is 0
		html += '</div>'

