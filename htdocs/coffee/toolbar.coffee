
class Cms.Toolbar extends CJS.Component

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
		html = '<label>Jazyk:&nbsp;'
		html += '</label><select class="form-control input-sm doChangeLanguage">'
		if @languages?
			html += '<option value="' + language.id + '" ' + (if language.id is @selectedLanguage*1 then 'selected' else '') + '>' + language.name + '</option>' for language in @languages
		else
			html += '<option>Loading...</option>'
		html += '</select></label>&nbsp;&nbsp;'
		html += '<button class="btn btn-primary btn-sm doLogout">Odhlásit se</button>'