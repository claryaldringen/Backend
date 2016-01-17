
class Cms.WysiwygEditor extends CJS.Component

	constructor: (id, parent) ->
		super(id,parent)
		@type = 'full'

	getElTextAreaId: -> @id + '-ta'

	setContent: (@text) -> @

	setType: (@type) -> @

	submit: (element) ->
		console.log element
		no

	renderFinish: ->
		config =
			width: @parent.width
			height: (if @parent.height then @parent.height else @getHeight()) - 195
			language: 'cs'
			toolbar: @type + 'Toolbar'
			filebrowserImageBrowseUrl: '/image-browser.html'
			filebrowserBrowseUrl: '/file-browser.html'
			toolbar_fullToolbar: [
				{ name: 'document', items : [ 'Save','NewPage','DocProps','Preview','Print','-','Templates' ] },
				{ name: 'clipboard', items : [ 'Cut','Copy','Paste','PasteText','PasteFromWord','-','Undo','Redo' ] },
				{ name: 'editing', items : [ 'Find','Replace','-','SelectAll'] },
				{ name: 'basicstyles', items : [ 'Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat' ] },
				{ name: 'paragraph', items : [ 'NumberedList','BulletedList','-','Outdent','Indent','-','Blockquote','CreateDiv', '-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-','BidiLtr','BidiRtl' ] },
				{ name: 'links', items : [ 'Link','Unlink','Anchor' ] },
				{ name: 'insert', items : [ 'Image','Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak','Iframe' ] },
				{ name: 'styles', items : [ 'Styles','Format','Font','FontSize' ] },
				{ name: 'colors', items : [ 'TextColor','BGColor' ] },
				{ name: 'tools', items : [ 'Maximize', 'ShowBlocks','-','About' ] }
			]
			toolbar_miniToolbar: [
				{ name: 'clipboard', items : [ 'Cut','Copy','Paste','PasteText','PasteFromWord','-','Undo','Redo' ] },
				{ name: 'editing', items : [ 'Find','Replace','-','SelectAll'] },
				{ name: 'basicstyles', items : [ 'Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat' ] },
				{ name: 'links', items : [ 'Link','Unlink','Anchor' ] },
				{ name: 'insert', items : ['Smiley','SpecialChar'] },
				{ name: 'tools', items : [ 'Maximize', 'ShowBlocks','-','About' ] }
			]
		window.setTimeout =>
				CKEDITOR.replace(@getElTextAreaId(), config)
				CKEDITOR.instances[@getElTextAreaId()].on 'save', (event) =>
					@parent.save(event.editor.getData())
					no
				CKEDITOR.instances[@getElTextAreaId()].on 'change', (event) => @getEvent('change').fire(event.editor.getData())
			, 100

	getHtml: -> '<form><textarea id="' + @getElTextAreaId() + '" name="' + @getElTextAreaId() + '">' + @text + '</textarea></form>'