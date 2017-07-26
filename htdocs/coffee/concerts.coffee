
Component = require './ComponentJS/component'
Concert = require './concert'

class Concerts extends Component

	constructor: (id, parent) ->
		super(id, parent)
		@concerts = []

	setMenuId: (@menuId) -> @

	load: -> @sendRequest('loadConcerts', {menuId: @menuId}, @loadResponse)

	loadResponse: (response) ->
		@concerts = response.concerts
		@concerts.unshift({id: 0, menu_id: @menuId, name: '', text: '', place: '', start_time: '', ticket_uri: '', image_id: null})
		@render()

	getConcert: (concert) ->
		id = @id + '_' + concert.id
		child = @getChildById(id)
		if not child?
			child = new Concert(id, @)
		child.setConcert(concert)

	getHtml: ->
		html = '<div class="concerts" style="height: ' + (@getHeight() - 42) + 'px;">'
		for concert in @concerts
			child = @getConcert(concert)
			html += '<div id="' + child.getId() + '">' + child.getHtml() + '</div>'
		html += '</div>'

module.exports = Concerts
