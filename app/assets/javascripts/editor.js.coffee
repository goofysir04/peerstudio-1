editor = null
$(document).ready ->
	editor = new MediumEditor('.editable')
	$('.editable').mediumInsert({editor: editor, images: true, imagesUploadScript: "upload_attachment.js"})
	syncContents = (text, element) ->
		$(element).val(text)

	loadEditorText = () ->
		for element in editor.elements
			$(element).innerHTML = $('#'+$(element).data('syncwith')).text()

	# $('.editable').keyup () ->
	# 	syncContents((editor.serialize())[$(this).attr('id')].value, '#'+$(this).data('syncwith'))
	# 	return true

	$('form').submit () ->
		#Sync the richedit text for the real deal.
		for element in editor.elements
			syncContents((editor.serialize())[$(element).attr('id')].value, '#'+$(element).data('syncwith'))
			return yes
