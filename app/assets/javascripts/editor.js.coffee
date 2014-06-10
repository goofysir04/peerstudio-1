editor = null
selectEverything = () ->
	$('.selectAll').click () ->
		$(this).select()

$(document).ready ->
	$('.editable').redactor({
        s3: '/uploads/create.js'
    })
	window.setInterval (() ->
		unless $(".answer-save-status").hasClass("label-danger label-warning") 
			lastUpdated = 1
			$(".answer-save-status").addClass("label-danger label-warning") 
		$(".answer-save-status").text("Last saved #{lastUpdated} min ago")
		lastUpdated++
		), 60*1000


	uploadCompleted = (r) ->
		$("#attachment_progress").hide()
		$("#attachments").html(r.responseText)
		selectEverything()






