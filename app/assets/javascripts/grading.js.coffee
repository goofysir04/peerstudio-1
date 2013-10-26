# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready () ->
	$(".incorrect-check").click () ->
		if $(".incorrect-check").is(":checked")
			$("#pickCorrect").addClass("btn-primary").text("Continue")
		else
			$("#pickCorrect").removeClass("btn-primary").text("No errors; Continue")

	$("#pickCorrect").click (event) ->
		$("#collapseIncorrect").collapse("hide")
		$("#collapseCorrect").collapse("show")
		event.preventDefault()
		return false
	$("#grading_form").submit (event) ->
		unless $(".incorrect-check,.correct-check").is(":checked")
			$("#collapseIncorrect").collapse("show")
			$("#collapseCorrect").collapse("hide")
			event.preventDefault()
			alert("Choose at least one correct or incorrect attribute (try 'Other' if none match)")
			return false