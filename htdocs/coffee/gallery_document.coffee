
class Cms.GalleryDocument extends CJS.Document

	setMenuId: (@menuId) -> @

	getGallery: ->
		gallery = @getChildById('gallery')
		if not gallery?
			gallery = new Cms.Gallery('gallery', @)
			gallery.select = (imageUrl) =>
				links =
					image: 'http://' + window.location.hostname + '/images/userimages/large/' + imageUrl
					all: '/download/' + imageUrl
				window.opener.CKEDITOR.tools.callFunction( @getUrlParam('CKEditorFuncNum'), links[@showType])
				window.close()
			gallery.renderFinish = -> gallery
		gallery.setMenuId(@menuId).setShowType(@showType)

	getUrlParam: (paramName) ->
		reParam = new RegExp( '(?:[\?&]|&)' + paramName + '=([^&]+)', 'i' )
		match = window.location.search.match(reParam)
		if match and match.length > 1 then match[ 1 ] else null

	setShowType: (@showType) -> @

	load: ->
		@getGallery().load()
		@render()

	getHtml: ->
		content = @getGallery()
		'<div id="' + content.getId() + '">' + content.getHtml() + '</div>'
