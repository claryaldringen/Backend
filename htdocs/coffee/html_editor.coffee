
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
		html = '<div class="toolbar"><button class="doSave btn btn-primary btn-sm">Uložit</button></div>'
		html += '<textarea id="' + @getElTextareaId() + '">' + @text + ' </textarea>'
