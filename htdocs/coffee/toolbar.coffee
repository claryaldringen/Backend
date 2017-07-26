
React = require 'react'
ReactDOM = require 'react-dom'

Component = require './ComponentJS/component'
SiteSelect = require '../jsx/components/site_select'

class Toolbar extends Component

	click: (element) ->
		if element.hasClass('doLogout')
			@sendRequest('logout', {}, @redirect)

	redirect: (response) ->
		document.location.href = response;

	load: ->
		@sendRequest('loadLanguages', {}, @loadResponse)

	loadResponse: (response) ->
		@languages = response.languages
		@selectedLanguage = response.selected
		@render()

	change: (element) ->
		if element.hasClass('doChangeLanguage')
			@getEvent('languageChange').fire(element.value)

	getHtml: ->
		html = '<div id="site-select" style="display: inline-block;height: 36px;"></div>'
		html += '<label>Jazyk:&nbsp;'
		html += '</label><select class="form-control input-sm doChangeLanguage">'
		if @languages?
			html += '<option value="' + language.id + '" ' + (if language.id is @selectedLanguage*1 then 'selected' else '') + '>' + language.name + '</option>' for language in @languages
		else
			html += '<option>Loading...</option>'
		html += '</select></label>&nbsp;&nbsp;'
		html += '<button class="btn btn-primary btn-sm doLogout">Odhlásit se</button>'

	renderFinish: ->
		super()
		ReactDOM.render(React.createElement(SiteSelect),document.getElementById('site-select'))

module.exports = Toolbar