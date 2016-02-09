
class Cms.Articles extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@scroll = 0
		@count = 0

	setMenuId: (@menuId) -> @

	load: -> @sendRequest('loadArticles', {menuId: @menuId}, @loadResponse)

	loadResponse: (response) ->
		if not response.error?
			@articles = response.articles
			@length = response.length
			@count = response.count
			@render()
		else
			alert(response.error)

	getWysiwyg: (index) ->
		id = @id + '_wysiwyg'
		child = @getChildById(id)
		child = new Cms.WysiwygEditor(id, @) if not child?
		child.setContent(@articles[index].html)

	save: (data) ->
		articleId = if @articles[@opened].id? then @articles[@opened].id else null
		@sendRequest('saveArticle', {menuId: @menuId, articleId: articleId, text: data}, @loadResponse)

	loadArticleResponse: (response) ->
		@articles[@opened] = response
		@render()

	click: (element) ->
		if element.hasClass('doCreateArticle')
			@articles.unshift({id: null, html: ''})
			@opened = 0
			@render()
		if element.hasClass('doCloseEditor')
			@opened = null
			@render()
		if element.hasClass('doEdit')
			@opened = element.dataset.index*1
			if @articles[@opened].id?
				@sendRequest('loadArticle', {articleId: @articles[@opened ].id}, @loadArticleResponse)
			else
				@render()
		if element.hasClass('doRemove') and confirm('Opravdu chcete odstranit tento článek?')
			index = element.dataset.index
			if @articles[index].id?
				@sendRequest('removeArticle', {articleId: @articles[index].id, menuId: @menuId}, @loadResponse)
			else
				@articles.splice(index, 1)
				@render()
		if element.hasClass('doMoveDown')
			index = element.dataset.index
			@sendRequest('moveArticle', {articleId: @articles[index].id, menuId: @menuId, order: 'down'}, @loadResponse)
		if element.hasClass('doMoveUp')
			index = element.dataset.index
			@sendRequest('moveArticle', {articleId: @articles[index].id, menuId: @menuId, order: 'up'}, @loadResponse)

	change: (element) ->
		if element.hasClass('doChangeShowType')
			if element.selectedIndex then @length = 1024 else @length = null
			@render()
		if element.hasClass('doChangeLength')
			@length = element.value
		if element.hasClass('doChangeCount')
			@count = element.value
		@sendRequest('saveArticleSetting', {menuId: @menuId, length: @length, count: @count})

	beforeRender: ->
		@scroll = document.querySelector('.article_container').scrollTop;

	renderFinish: ->
		super()
		document.querySelector('.article_container').scrollTop = @scroll

	getHtml: ->
		html = '<div class="articles">'
		html += '<div class="toolbar controls form-inline">'
		html += '<button class="btn btn-sm btn-default doCreateArticle">Vytvořit nový článek</button>'
		html += '<button class="btn btn-sm btn-default doCloseEditor">Zavřít editor</button>' if @opened?
		html += '&nbsp;<select class="form-control input-sm doChangeShowType">'
		html += '<option value="0">Zobrazovat celé články</option>'
		html += '<option value="1" ' + (if @length? then 'selected' else '') + '>Zobrazovat pouze náhledy článků</option>'
		html += '</select>&nbsp;'
		html += 'Délka náhledu: <input type="number" value="' + @length + '" min="0" class="form-control input-sm short doChangeLength"> znaků&nbsp;' if @length?
		html += '&nbsp;<input type="number" value="' + @count + '" min="0" class="form-control input-sm short doChangeCount"> článků na stránku'
		html += '</div>'
		html += '<div class="article_container" style="height: ' + (@getHeight() - 82) + 'px">'
		if @articles?
			for article,index in @articles
				if @opened is index
					wysiwyg = @getWysiwyg(index)
					html += '<div id="' + wysiwyg.getId() + '">' + wysiwyg.getHtml() + '</div>'
				else
					html += '<div class="article">' + article.html.substring(0,1024)
					html += '&nbsp;&nbsp;&nbsp;<button class="btn btn-sm btn-primary doEdit" data-index="' + index + '">Editovat</button>&nbsp;&nbsp;&nbsp;'
					html += '<button class="btn btn-sm btn-danger doRemove" data-index="' + index + '">Smazat</button>&nbsp;&nbsp;&nbsp;'
					html += '<button class="btn btn-sm btn-default doMoveDown" data-index="' + index + '">Posunout dolů</button>&nbsp;&nbsp;&nbsp;' if article.id? and index isnt @articles.length-1
					html += '<button class="btn btn-sm btn-default doMoveUp" data-index="' + index + '">Posunout nahoru</button>' if article.id? and index > 0
					html += '</div>'
		else
			html += 'Loading...'
		html += '</div></div>'
