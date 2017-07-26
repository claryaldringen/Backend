
Component = require './ComponentJS/component'

class EmailSetting extends Component

	constructor: (id, parent) ->
		super(id, parent)
		@emails = []
		@showType = []

	load: -> @sendRequest('loadEmails', {}, @loadResponse)

	loadResponse: (response) ->
		if response.errorCode*1 is 2
			alert(response.error + ' Prosím opravte jej a poté znovu proveďte uložení.')
		else
			@emails = response.emails
			@domain = response.domain
			@render()

	change: (element) ->
		if element.hasClass('doShow')
			@showType[element.dataset.index] = if element.checked then 'text' else 'password'
			@render()
		if element.hasClass('doChangeName')
			@emails[element.dataset.index].username = element.value
			@emails[element.dataset.index].save = yes
		if element.hasClass('doChangePassword')
			@emails[element.dataset.index].password = element.value
			@emails[element.dataset.index].save = yes
		if element.hasClass('doChangeForward')
			@emails[element.dataset.index].alias = element.value
			@emails[element.dataset.index].save = yes

	click: (element) ->
		if element.hasClass('doSave')
			data = []
			data.push(email) for email in @emails when email.save
			@sendRequest('saveEmails', data, @loadResponse)
		if element.hasClass('doAdd')
			@emails.push({username: '', password: '', alias: ''})
			@render()
		if element.hasClass('doRemove')
			emailId = @emails[element.dataset.index].id
			if emailId?
				@sendRequest('removeEmail', {id: emailId}, @loadResponse) if confirm('Opravdu chcete odstranit tuto emailovou adresu?')
			else
				@emails.splice(element.dataset.index, 1)
				@render()

	getHtml: ->
		if @domain?
			html = '<table><tr><th>E-mail</th><th>Heslo</th></tr>'
			for email,index in @emails
				color = if index%2 then '#FFFFFF' else '#DDDDDD'
				@showType[index] = 'password' if not @showType[index]?
				html += '<tr style="background: ' + color + '"><td>'
				html += '<input type="text" data-index="' + index + '" value="' + email.username + '" class="doChangeName">'
				html += '@' + @domain + '</td><td>'
				html += '<input type="' + @showType[index] + '" value="' + email.password + '" data-index="' + index + '" class="doChangePassword"><br>'
				html += '<label style="font-weight: normal;"><input type="checkbox" class="doShow" data-index="' + index + '" ' + (if @showType[index] == 'text' then 'checked' else '') + '>Zobrazit heslo</label>'
				html += '</td></tr>'
				html += '<tr  style="background: ' + color + '"><td colspan="2">Přeposílat na (vkládejte emailové adresy oddělené čárkou):<br>'
				html += '<input type="text" value="' + (if email.alias? then email.alias else '') + '" data-index="' + index + '" class="form-control input-sm doChangeForward">'
				html += '<button class="btn btn-danger doRemove" data-index="' + index + '">Odstranit</button></td></tr>'
			html += '<tr style="text-align: center;"><td><button class="btn btn-default doAdd">Přidat další</button></td>'
			html += '<td><button class="btn btn-primary doSave">Uložit</button></td>'
			html += '</tr></table>'
		else
			@load()
			html = 'Loading...'

module.exports = EmailSetting
