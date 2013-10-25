# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready () ->
	$(".incorrect-check").click () ->
		if $(".incorrect-check").is(":checked")
			$("#pickCorrect").text("Continue")
		else
			$("#pickCorrect").text("None of the above errors")

	$("#pickCorrect").click (event) ->
		$("#collapseIncorrect").collapse("hide")
		$("#collapseCorrect").collapse("show")
		event.preventDefault()
		return false