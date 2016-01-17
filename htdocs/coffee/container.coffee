
class Cms.Container extends Cms.Content

	setTypes: (@types) -> @

	change: (element) ->
		@sendRequest('saveContentType', {oldTypeId: @typeId, newTypeId: element.value, menuId: @menuId}, @saveResponse)
		@setType(element.value*1)

	click: (element) ->
		super(element)
		@getParent().removeContainer(@menuId) if element.hasClass('doRemove') and confirm('Opravdu chcete odstranit tento kontejner?')
		@

	getTabs: ->
		html = ''
		switch @typeId
			when 1
				html += '<div class="tab doChangeTab ' + (if @tab is 'wysiwyg' then 'active' else '') + '" data-tab="wysiwyg">WYSIWYG</div>'
				html += '<div class="tab doChangeTab ' + (if @tab is 'html' then 'active' else '') + '" data-tab="html">HTML</div>'
			when 2
				html += '<div class="tab doChangeTab ' + (if @tab is 'gallery' then 'active' else '') + '" data-tab="gallery">Galerie</div>'
				html += '<div class="tab doChangeTab ' + (if @tab is 'wysiwyg' then 'active' else '') + '" data-tab="wysiwyg">WYSIWYG</div>'
				html += '<div class="tab doChangeTab ' + (if @tab is 'html' then 'active' else '') + '" data-tab="html">HTML</div>'
		html

	getHtml: ->
		content = @getContent()?.setHeight(@getHeight())
		content.setContent(@content) if @tab in ['html', 'wysiwyg']
		html = '<div class="container-toolbar controls form-inline"><label>'
		html += 'Typ obsahu: <select class="form-control input-sm">'
		html += '<option value="' + type.id + '" ' + ('selected' if @typeId is type.id) + '>' + type.name + '</option>' for type in @types
		html += '</select></label><button class="btn btn-danger btn-sm doRemove right-float">Odstranit</button>'
		html += @getTabs()
		html += '</div>'
		html += '<div id="' + content.getId() + '">' + content.getHtml() + '</div>' if content?
		html
