# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready () ->
	$('.rubric_item:checkbox').click () ->
		console.log "You clicked, haha"
		recalculateGrade()
	#On page load, recalculateGrade
	recalculateGrade()

	$('.review_text').keyup () ->
		getReviewQuality($(this).val())

	# debugTokenList()

recalculateGrade = () ->
	sum = 0
	for elem in $('.rubric_item:checked')
		sum += +$(elem).val()
	$("#calculatedGrade").val(sum)

token_list = {
	"concep" : {regex: new RegExp("\\s" + "concep","gi"), score: 5} #conceptual...
	"descri" : {regex: new RegExp("\\s" + "descri","gi"), score: 10} #describe
	"I" : {regex: new RegExp("\\s" + "I\\s","gi"), score: 3}
	"observ" : {regex: new RegExp("\\s" + "observ","gi"), score: 2}
	"overall" : {regex: new RegExp("\\s" + "overall","gi"), score: 3}
	"activit" : {regex: new RegExp("\\s" + "activit","gi"), score: 3}
	"analy" : {regex: new RegExp("\\s" + "analy","gi"), score: 11}
	"argument" : {regex: new RegExp("\\s" + "argument","gi"), score: 1}
	"author" : {regex: new RegExp("\\s" + "author","gi"), score: 3}
	"better" : {regex: new RegExp("\\s" + "better","gi"), score: 2}
	"but" : {regex: new RegExp("\\s" + "but","gi"), score: 3}
	"cite" : {regex: new RegExp("\\s" + "cite","gi"), score: 1}
	"cognit" : {regex: new RegExp("\\s" + "cognit","gi"), score: 4}
	"connect" : {regex: new RegExp("\\s" + "connect","gi"), score: 1}
	"content" : {regex: new RegExp("\\s" + "content","gi"), score: 1}
	"contribute" : {regex: new RegExp("\\s" + "contribute","gi"), score: 1}
	"could" : {regex: new RegExp("\\s" + "could","gi"), score: 2} 
	"deep" : {regex: new RegExp("\\s" + "deep","gi"), score: 1}
	"depth" : {regex: new RegExp("\\s" + "depth","gi"), score: 1}
	"detail" : {regex: new RegExp("\\s" + "detail","gi"), score: 3}
	"elaborat" : {regex: new RegExp("\\s" + "elaborat","gi"), score: 1}
	"enhance" : {regex: new RegExp("\\s" + "enhance","gi"), score: 1}
	"enough" : {regex: new RegExp("\\s" + "enough","gi"), score: 1}
	"event" : {regex: new RegExp("\\s" + "event","gi"), score: 3} 
	"eviden" : {regex: new RegExp("\\s" + "eviden","gi"), score: 1} #evident, evidence, evidentially,...
	"experience" : {regex: new RegExp("\\s" + "experience","gi"), score: 1} 
	"explanat" : {regex: new RegExp("\\s" + "explanat","gi"), score: 2}
	"grammat" : {regex: new RegExp("\\s" + "grammat","gi"), score: -1, feedback: "Don't comment on grammar"} #don't talk about grammar
	"grammar" : {regex: new RegExp("\\s" + "grammar","gi"), score: -1, feedback: "Don't comment on grammar"}
	"lecture" : {regex: new RegExp("\\s" + "lecture","gi"), score: 2}
	"like" : {regex: new RegExp("\\s" + "like","gi"), score: 2}
	"link" : {regex: new RegExp("\\s" + "link","gi"), score: 1}
	"little" : {regex: new RegExp("\\s" + "little","gi"), score: 2}
	"more" : {regex: new RegExp("\\s" + "more","gi"), score: 3} #more, moreover...
	"observa" : {regex: new RegExp("\\s" + "observa","gi"), score: 1}
	"opportunit" : {regex: new RegExp("\\s" + "opportunit","gi"), score: 1}
	"otherwise" : {regex: new RegExp("\\s" + "otherwise","gi"), score: 2}
	"phenomen" : {regex: new RegExp("\\s" + "phenomen","gi"), score: 1}
	"process" : {regex: new RegExp("\\s" + "process","gi"), score: 2}
	"read" : {regex: new RegExp("\\s" + "read","gi"), score: 6} #read, reading, readings...
	"referenc" : {regex: new RegExp("\\s" + "referenc","gi"), score: 4}
	"relate" : {regex: new RegExp("\\s" + "relate","gi"), score: 1} #relate, related, ...
	"separat" : {regex: new RegExp("\\s" + "separat","gi"), score: 2}
	"show" : {regex: new RegExp("\\s" + "show","gi"), score: 2}
	"specif" : {regex: new RegExp("\\s" + "specif","gi"), score: 2} #specify, specific, specification...
	"structur" : {regex: new RegExp("\\s" + "structur","gi"), score: 1}
	"style" : {regex: new RegExp("\\s" + "style","gi"), score: -1}
	"task" : {regex: new RegExp("\\s" + "task","gi"), score: 3}
	"text" : {regex: new RegExp("\\s" + "text","gi"), score: 5}
	"use" : {regex: new RegExp("\\s" + "use","gi"), score: 2}
	"would" : {regex: new RegExp("\\s" + "would","gi"), score: 4}
	"writ" : {regex: new RegExp("\\s" + "writ","gi"), score: 5}
	"realHackersReadSourceCode": {regex: new RegExp("realHackersReadSourceCode"), score: 0, feedback: "Howdy hacker! It seems like you've found our review-writing advice columns.\nWant to help us make education better? Drop us a line at talkabout [at] cs.stanford.edu and say how you found us!"}
}



getReviewQuality = (text) ->
	content_score = 0 
	feedback = []
	for token, matcher of token_list
		count = (text?.match(matcher.regex) or []).length
		content_score += count*matcher.score
		if count > 0 and matcher.feedback?
			feedback.push matcher.feedback
		if count > 40
			feedback.push "Please don't try to game the system."
	lengthScore = Math.floor(Math.pow(((text.match(/\s+/g) or []).length),0.8))

	if lengthScore < 10
		feedback.push "Say more..."

	if (content_score - lengthScore)/(1.0+lengthScore) < 0.5 and lengthScore > 8	
		feedback.push("Quick check: Is your feedback actionable? Are you expressing yourself succinctly?")


	totalScore = content_score + lengthScore
	console.log "Content score: #{content_score}, lengthScore: #{lengthScore}, totalScore: #{totalScore} feedback: #{feedback}"
	
	$('#review_tips').html(feedback.join(" "))
	return {totalScore: totalScore, feedback: feedback, lengthScore: lengthScore}


debugTokenList = () ->
	txt = ""
	for token, matcher of token_list
		txt += ("#{token}... : #{matcher.score}\n")
	console.log txt

