
class Cms.HtmlEditor extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@text = ''

	getElTextareaId: -> @id + '-textarea'

	setContent: (@text)-> @

	getCodeMirror: ->
		if not @codeMirror
			config =
				mode: 'text/html'
				lineNumbers: yes
				lineWrapping: yes
				extraKeys:
					"'<'" : (cm, pred) ->
						cur = cm.getCursor()
						if not pred or pred()
							setTimeout( ->
								cm.showHint( completeSingle: no ) if not cm.state.completionActive
							, 100)
						CodeMirror.Pass

			ta = document.getElementById(@getElTextareaId())
			if ta?
				@codeMirror = CodeMirror.fromTextArea(ta, config)
				@codeMirror.on 'change', => @getEvent('change').fire(@codeMirror.getValue())
				@codeMirror.setSize(@parent.width, @parent.height - 85)
		@codeMirror

	click: (element) ->
		if element.hasClass('doSave')
			@parent.save(@getCodeMirror().getValue())
		@

	renderFinish: ->
		@codeMirror = null
		@getCodeMirror()

	getHtml: ->
		#doSave btn btn-primary btn-sm
		html = '<div class="cke_top cke_reset_all"><div class="cke_toolgroup"><a class="cke_button cke_button__save cke_button_off">'
		html += '<span class="cke_button_icon cke_button__save_icon doSave" style="background-image:url(\'http://cms.dev/bower_components/ckeditor/plugins/icons.png?t=FB9E\');background-position:0 -1704px;background-size:auto;">&nbsp;</span>'
		html += '</a></div></div>'
		html += '<textarea id="' + @getElTextareaId() + '">' + @text + ' </textarea>'
