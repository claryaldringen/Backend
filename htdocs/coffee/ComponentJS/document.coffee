
class CJS.Document extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@binded = no

	findId: (target) ->
		if target.id? and target.id isnt ''
			target.id.split('-')[0]
		else
			@findId(target.parentElement)

	addMethodHasClass: (element) ->
		if not element.hasClass?
			element.hasClass = (className) ->
				return yes for elClass in element.className.split(' ') when elClass is className
				no
		@

	bindEvents: ->
		$('body').bind 'focusin', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target)).focusIn(event.target)
		$('body').bind 'focusout', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target)).focusOut(event.target)
		$('body').bind 'click', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target)).click(event.target)
		$('body').bind 'change', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target)).change(event.target)
		$('body').bind 'keyup', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target)).keyUp(event.target)
		$('body').bind 'dragstart', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target)).dragStart(event.target)
		$(window).bind 'resize', (event) => @render()

	render: ->
		super()
		if not @binded
			@bindEvents()
			@binded = yes
		@
