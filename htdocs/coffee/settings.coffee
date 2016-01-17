
class Cms.Settings extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@user = null

	load: ->
		@sendRequest('loadUser', {}, @loadResponse)

	loadResponse: (response) ->
		@user = response
		@render()

	validateUser: ->
		errors = {login: [], email: [], password: []}
		errors.login.push('Vyplňte prosím login.') if @user.login.length is 0
		errors.login.push('Login může mít maximálně 32 znaků, prosím zkraťte jej.') if @user.login.length > 32
		errors.email.push('Vyplňte prosím e-mail.') if @user.email.length is 0
		patt = new RegExp('^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$')
		errors.email.push('E-mail je neplatný.') if not patt.test(@user.email) and @user.email.length
		errors.password.push('Hesla se neshodují.') if @user.password1 isnt @user.password2
		document.getElementById(@id + '-' + type).innerHTML = errs.join('<br>') for type,errs of errors
		if errors.login.length or errors.email.length or errors.password.length then $('#' + @id + '-submit').hide() else $('#' + @id + '-submit').show()

	keyUp: (element) ->
		if element.hasClass('doChangeName')
			@user.name = element.value
		if element.hasClass('doChangeLogin')
			@user.login = element.value
		if element.hasClass('doChangeEmail')
			@user.email = element.value
		if element.hasClass('doChangePassword1')
			@user.password1 = element.value
		if element.hasClass('doChangePassword2')
			@user.password2 = element.value
		@validateUser()

	click: (element) ->
		if element.hasClass('doSave')
			@sendRequest('saveUser', @user, -> alert('Uloženo'))

	getHtml: ->
		if @user?
			html = '<table>'
			html += '<tr><td>Jméno:</td><td><input class="form-control input-sm doChangeName" type="text" value="' + @user.name + '"></td>'
			html += '<tr><td>Login:</td><td><input class="form-control input-sm doChangeLogin" type="text" value="' + @user.login + '"><span id="' + @id + '-login" class="error"></span></td>'
			html += '<tr><td>E-mail:</td><td><input class="form-control input-sm doChangeEmail" type="email" value="' + @user.email + '"><span id="' + @id + '-email" class="error"></span></td>'
			html += '<tr><td>Nové heslo:</td><td><input class="form-control input-sm doChangePassword1" type="password" value=""></td>'
			html += '<tr><td>Znovu heslo:</td><td><input class="form-control input-sm doChangePassword2" type="password" value=""><span id="' + @id + '-password" class="error"></span></td>'
			html += '<tr><td></td><td><button id="' + @id + '-submit" class="btn btn-primary doSave">Uložit</button></td>'
			html += '</table>'
		else
			@load()
			@html = 'Loading...'