getPreviousDeadline = ->
	currentDateInUTC = getCurrentDateinUTC()
	prevDeadlineHour = getPreviousDeadlineHour(currentDateInUTC.getHours())
	previousDeadline = new Date(currentDateInUTC.getFullYear(), currentDateInUTC.getMonth(), currentDateInUTC.getDate(), prevDeadlineHour, 0, 0) #new previous deadline date item
	return previousDeadline

getPreviousDeadlineHour = (hour) ->
	prevDeadlineHour = switch 
		when 0 <= hour < 4 then 0
		when 4 <= hour < 8 then 4
		when 8 <= hour < 12 then 8
		when 12 <= hour < 16 then 12
		when 16 <= hour < 20 then 16
		when 20 <= hour <= 23 then 20 
	return prevDeadlineHour

getCurrentDateinUTC = ->
	date = new Date()
	return new Date(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), date.getUTCHours(), date.getUTCMinutes(), date.getUTCSeconds())

getTimeDiff = (nextDeadline)->
	currTime = getCurrentDateinUTC()
	return Math.floor((nextDeadline-currTime)/(1000)) #divided into seconds 

getLaterTime = (currTime, hours) ->
	laterTime = new Date(currTime)
	laterTime.setHours(currTime.getHours() + hours)
	return laterTime

toHHMMSS = (time) ->
	hr = Math.floor(time/3600)
	min = Math.floor((time % 3600)/60)
	sec = time - (hr*3600) - (min*60)
	if hr == 1
		return hr + " hour, " + min + " minutes, and " + sec + " seconds"
	else
		return hr + " hours, " + min + " minutes, and " + sec + " seconds"

getFeedbackDeadlineDay = (feedbackDeadline) ->
	localCurrTime = new Date()
	localFeedbackTime = new Date(feedbackDeadline + ' UTC')
	if localCurrTime.getDay() == localFeedbackTime.getDay()
		return "today"
	else 
		return "tomorrow"

getFeedbackDeadlineTime = (feedbackDeadline) ->
	localFeedbackTime = new Date(feedbackDeadline + ' UTC')
	hour = localFeedbackTime.getHours()
	if hour > 12
		return hour - 12 + " PM"
	else if hour == 0
		return "12 AM"
	return hour + " AM"

setNewTime = (clock, feedbackTime, feedbackDay) ->
	prevDeadline = getPreviousDeadline()
	nextDeadline = getLaterTime(prevDeadline, 4)
	timeDiff = getTimeDiff(nextDeadline)
	feedbackDeadline = getLaterTime(nextDeadline, 8)
	clock.text(toHHMMSS(timeDiff))
	feedbackTime.text(getFeedbackDeadlineTime(feedbackDeadline))
	feedbackDay.text(getFeedbackDeadlineDay(feedbackDeadline)) 


$(document).on 'ready page:load', ->
	clock = $("#time-left")
	feedbackTime = $("#feedback-time")
	feedbackDay = $("#feedback-day")
	if clock? and feedbackTime? and feedbackDay?
		setNewTime(clock, feedbackTime, feedbackDay)
		$('#countdown-banner').show()
		setInterval ->
			setNewTime(clock, feedbackTime, feedbackDay)
		, 1000
