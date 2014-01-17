# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready () ->
	$('.rubric_item:checkbox').click () ->
		console.log "You clicked, haha"
		recalculateGrade()
	#On page load, recalculateGrade
	recalculateGrade()

recalculateGrade = () ->
	sum = 0
	for elem in $('.rubric_item:checked')
		sum += +$(elem).val()
	$("#calculatedGrade").val(sum)
