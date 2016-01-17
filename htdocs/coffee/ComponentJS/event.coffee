
class CJS.Event

	constructor: ->
		@listeners = []

	subscribe: (obj, func) ->
		@listeners.push({func: func, obj: obj})
		@

	fire: -> listener.func.apply(listener.obj, Array.prototype.slice.call(arguments)) for listener in @listeners



