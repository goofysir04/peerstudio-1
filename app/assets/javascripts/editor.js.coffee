editor = null
selectEverything = () ->
	$('.selectAll').click () ->
		$(this).select()

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

	formatData = (file) ->
        formData = new FormData();
        formData.append('file', file)
        return formData

	$('.upload').click () ->
		selectFile = $('<input type="file">').click();
		selectFile.change () ->
			files = this.files
			uploadFiles(files)
		return false

	uploadFiles = (files) ->
		for file in files
			$.ajax({
				type: "post",
				url: "upload_attachment.js",
				cache: false,
				contentType: false,
				complete: uploadCompleted,
				processData: false,
				data: formatData(file)
			})

	lastUpdated = 1
	window.setInterval (() ->
		unless $(".answer-save-status").hasClass("label-danger label-warning") 
			lastUpdated = 1
			$(".answer-save-status").addClass("label-danger label-warning") 
		$(".answer-save-status").text("Last saved #{lastUpdated} min ago")
		lastUpdated++
		), 60*1000


	uploadCompleted = (r) ->
		$("#attachments").html(r.responseText)
		selectEverything()






