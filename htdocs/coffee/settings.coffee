
class Cms.Settings extends CJS.Component

	getUserSetting: ->
		childId= @id + '_user'
		child = @getChildById(childId)
		if not child?
			child = new Cms.UserSetting(childId, @)
		child

	getEmailSetting: ->
		childId= @id + '_email'
		child = @getChildById(childId)
		if not child?
			child = new Cms.EmailSetting(childId, @)
		child

	load: ->
		console.log @getChildren()
		child.load() for child in @getChildren()

	getHtml: ->
		userSetting = @getUserSetting();
		html = '<div id="' + userSetting.getId() + '">' + userSetting.getHtml() + '</div>'
		emailSetting = @getEmailSetting();
		html += '<div id="' + emailSetting.getId() + '">' + emailSetting.getHtml() + '</div>'