
editor_completion_metadata = {}

editor = null
selectEverything = () ->
    $('.selectAll').click () ->
        $(this).select()

ready = () ->
    $('.clickable').click ()-> 
        console.log "You clicked, haha"
        if $('.clickable:checked').length == $('.clickable').length
            console.log "WE MADE IT!"
    $('.editable').redactor({s3: '/uploads/create.js'})
    lastUpdated = 0
    $('#answer_form').on 'ajax:success', () ->
        lastUpdated = 0
    $('#answer_form').on 'ajax:error', (e,status,error) ->
        console.log error
        alert("There was a problem saving your draft. Please make a backup, and try again in a bit. If you continue to see this error, please email hello@peerstudio.org")


    if($('#save-draft').length > 0)
        updateInterval = 10
        saveInterval = 60
        window.setInterval (() ->
            $(".answer-save-status").text("Autosaved every minute. Last saved #{lastUpdated} seconds ago")
            lastUpdated+=updateInterval
            ), updateInterval*1000

        window.setInterval (() ->
            $('#answer_form').submit()
            ), saveInterval*1000

        $('#submit-for-feedback').click () ->
            next_url = $(this).attr('href')
            $('#answer_form').on 'ajax:success', () ->
                console.log "finished saving, submitting for feedback"
                window.location= next_url
            $('#answer_form').on 'ajax:error', (e,status,error) ->
                console.log error
                alert("We had trouble saving your draft. Please try again in a while. If you continue to see this error, please email hello@peerstudio.org")
            console.log "saving now"
            $('#answer_form').submit()
            return false

    $('#submit-final').click () ->
        console.log "saving.."
        $('#answer_form').on 'ajax:success.submit-warning', () ->
           console.log "finished saving, submitting for feedback"
           $('#warn-final-modal').modal('show')
        $('#answer_form').on 'ajax:error.submit-warning', (e,status,error) ->
            console.log error
            alert("We had trouble saving your draft. Please try again in a while. If you continue to see this error, please email hello@peerstudio.org")
        $('#answer_form').submit()
        return false       

    $('#cancel-submit-grade').click () ->
        console.log "Canceling submit"
        $('#answer_form').off '.submit-warning'


    $('.expandable').on('keyup', () ->
        this.style.overflow = 'hidden'
        this.style.height = this.style.min_height
        this.style.height = this.scrollHeight + 'px'
        return true
      )
    # uploadCompleted = (r) ->
    #     $("#attachment_progress").hide()
    #     $("#attachments").html(r.responseText)
    #     selectEverything()
    # $('a.see-example').click showExample
    # # shakeStage
    # # console.log $('#rubric input[type="checkbox"]')


showExample = (el) ->
    console.log $(this).data("example")
    example_text = $("##{$(this).data("example")}").text()
    $('#example-review-modal .modal-body').html(example_text)
    $('#example-review-modal').modal('show')
    return false

shakeStage = () ->
    $('.clickable').click () ->
        console.log "You clicked, haha"
        if ('.clickable:checked').length == $('clickable').length
            console.log "WE MADE IT!"



$(document).on 'ready page:load', ready

    # server_edit_metadata = $('#editor_completion_metadata').val() + ""
    # try
    #   editor_completion_metadata = JSON.parse(server_edit_metadata)
    # catch e
    #   console.log("couldn't parse! ):")
    

# The main idea is that we want:
# 1. checkboxes that are clickable
        #to do this, we can establish each of the checkboxes to have a unique id + a class and make it so that you can click them...
        #do you need a hidden form??????????????????? ?????????????????????? 
# 2. progress bars that update when you click on checkboxes
# 3. when all the checkboxes of a "stage" (aka answer attributes of a rubric item) are clicked, something happens (pop up)
# 4. arbitrary *shaking* or *lighting up* of the checklist












