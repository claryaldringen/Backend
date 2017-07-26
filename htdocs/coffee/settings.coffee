
Component = require './ComponentJS/component'
UserSetting = require './user_setting'
EmailSetting = require './email_setting'

class Settings extends Component

	getUserSetting: ->
		childId= @id + '_user'
		child = @getChildById(childId)
		if not child?
			child = new UserSetting(childId, @)
		child

	getEmailSetting: ->
		childId= @id + '_email'
		child = @getChildById(childId)
		if not child?
			child = new EmailSetting(childId, @)
		child

	load: ->
		child.load() for child in @getChildren()

	getHtml: ->
		userSetting = @getUserSetting();
		html = '<div id="' + userSetting.getId() + '">' + userSetting.getHtml() + '</div>'
		emailSetting = @getEmailSetting();
		html += '<div id="' + emailSetting.getId() + '">' + emailSetting.getHtml() + '</div>'

module.exports = Settings
