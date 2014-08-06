setRoundedHour = (date, hour) ->
	date.setHours(hour)
	date.setMinutes(0)
	date.setSeconds(0)
	return date

convertCurrentDateToUTC = ->
	date = new Date()
	return new Date(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), date.getUTCHours(), date.getUTCMinutes(), date.getUTCSeconds())

findNextDeadline = (current_time) -> 
	add_time = current_time.getHours()
	if add_time > 12
		afternoon = true
		add_time = add_time - 12
	add_time += 4
	mod_time = add_time % 4
	next_deadline_hour = add_time - mod_time
	if afternoon
		new_time = setRoundedHour(current_time, next_deadline_hour+12) #set to rounded deadline...
	else
		new_time = setRoundedHour(current_time, next_deadline_hour)
	return new_time

get_time_diff = (time1)->
	time2 = convertCurrentDateToUTC()
	return Math.floor((time1-time2)/(60*1000)) #divided into minutes 

change_into_hr_min = (time) ->
	hr = Math.floor(time/60)
	min = time % 60
	if hr == 1
		return hr + " hour and " + min + " minutes"
	else
		return hr + " hours and " + min + " minutes"

setNewTime = (clock) ->
	current_time_in_UTC = convertCurrentDateToUTC()
	console.log(current_time_in_UTC)
	next_deadline = findNextDeadline(current_time_in_UTC)
	console.log(next_deadline)
	time_diff = get_time_diff(next_deadline)
	readable_time_diff = change_into_hr_min(time_diff)
	clock.text("Submit within the next " + readable_time_diff + " to get feedback within 8 hours!")	

$(document).on 'ready page:load', ->
	clock = $("#timer-element")
	if clock? 
        setInterval ->
        	setNewTime(clock)
        , 1000
