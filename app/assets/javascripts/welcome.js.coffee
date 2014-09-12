# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = () ->
	$('.enable-password-login').click () ->
		$('.password-login').show()
		$('.omniauth-login').hide()
		$('.enable-password-login').hide()
		return false
	$(".login_button").click () ->
    	$(".login-progress").show()
    	return true

$(document).on 'ready page:load', ready