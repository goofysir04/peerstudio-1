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


	verification_tour = {
		"id": "hello-verification"
		'steps': [
			{
				"title": "Here's how verification works",
				"target": "tour-launch",
				"content": "A quick guide to verification. On this page, we show
				 you what your classmates marked for student answers. You will if they are marked correctly. Answers that are marked incorrectly will be graded by more peers."
				"placement": "left"
			},

			{
				"title": "Here's the question",
				"target": $("#question-title").get(0),
				"content": "Here's the question. All answers on this page are for this question."
				"placement": "bottom"
			}
			{
				"title": "Here's a student answer",
				"target": $(".answer").get(0),
				"content": "Here's one student's answer to the above question"
				"placement": "right"
			}
			{
				"title": "Peer assessment",
				"target": $(".answer-attribute").get(0),
				"content": "A peer marked this answer as  '#{$(".answer-attribute").get(0).innerText}'"
				"placement": "bottom"
			}
			{
				"title": "Is this assessment correct?",
				"target": $(".assessment-options").get(0),
				"content": "<p><strong>This is the most important part.</strong>
				 Was the answer assessed correctly? If the marked attribute applies to this answer, choose yes. If the peer made a mistake and chose an attribute that does not apply to this answer, choose no.</p>
				 <p>Note that we're <strong>not</strong> asking if the answer was correct. We're only asking &ldquo;was the answer was assessed correctly by the peer?&rdquo;</p>
				 <p><strong>Choose Yes or No.</strong></p>"
				"placement": "left"
				"showNextButton": no
				"nextOnTargetClick": yes
			}
			{
				"title": "Great! You're ready!",
				"target": $(".answer").get(1),
				"content": "You should repeat this process for all other answers. Read the answer, see what it was marked as, and choose whether it was marked appropriately."
				"placement": "right"
			}
		],
		i18n: {doneBtn: "Ok, got it!"}
	}

	if window.showVerificationTour
		hopscotch.startTour(verification_tour)

	$("#grading_form").submit (event) ->
		unless $(".incorrect-check,.correct-check").is(":checked")
			$("#collapseIncorrect").collapse("show")
			$("#collapseCorrect").collapse("hide")
			event.preventDefault()
			alert("Choose at least one correct or incorrect attribute (try 'Other' if none match)")
			return false