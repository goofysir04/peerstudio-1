# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready () ->
	$(".pickIncorrect").click (event) ->
		$("#collapseIncorrect").collapse("show")
		$("#collapseComments").collapse("hide")
		$("#collapseCorrect").collapse("hide")
		event.preventDefault()
		return false

	$(".pickCorrect").click (event) ->
		$("#collapseIncorrect").collapse("hide")
		$("#collapseComments").collapse("hide")
		$("#collapseCorrect").collapse("show")
		event.preventDefault()
		return false

	$(".addComments").click (event) ->
		$("#collapseIncorrect").collapse("hide")
		$("#collapseCorrect").collapse("hide")
		$("#collapseComments").collapse("show")
		event.preventDefault()
		return false

	$('.accordion-toggle,.incorrect-check,.correct-check').click (event) ->
		attributes = $(':checked').map () ->
			$(this).parent().text()
		res = "<p>You chose</p><ul>"
		for attr in attributes
			res += "<li>#{attr}</li>"
		res += "</ul>"
		$("#chosenAttributes").html(res)

	$("#grading_form").submit (event) ->
		unless $(".incorrect-check,.correct-check").is(":checked")
			$("#collapseIncorrect").collapse("show")
			$("#collapseCorrect").collapse("hide")
			event.preventDefault()
			alert("Choose at least one correct or incorrect attribute (try 'Other' if none match)")
			return false