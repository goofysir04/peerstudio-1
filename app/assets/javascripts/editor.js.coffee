
editor_completion_metadata = {}

editor = null
selectEverything = () ->
    $('.selectAll').click () ->
        $(this).select()

$(document).on 'ready page:load', ->
    $('.clickable').click ()-> 
        console.log "You clicked, haha"
        if $('.clickable:checked').length == $('.clickable').length
            console.log "WE MADE IT!"
    $('.editable').redactor({s3: '/uploads/create.js'})

    if($('#save-draft').length > 0)
        lastUpdated = 0
        updateInterval = 10
        saveInterval = 60
        window.setInterval (() ->
            $(".answer-save-status").text("Autosaved every minute. Last saved #{lastUpdated} seconds ago")
            lastUpdated+=updateInterval
            ), updateInterval*1000

        window.setInterval (() ->
            $('#answer_form').submit()
            lastUpdated = 0
            ), saveInterval*1000


    $('.expandable').on('keyup', () ->
        this.style.overflow = 'hidden'
        this.style.height = this.style.min_height
        this.style.height = this.scrollHeight + 'px'
        return true
      )
    uploadCompleted = (r) ->
        $("#attachment_progress").hide()
        $("#attachments").html(r.responseText)
        selectEverything()
    $('a.see-example').click showExample
    # shakeStage
    # console.log $('#rubric input[type="checkbox"]')

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












