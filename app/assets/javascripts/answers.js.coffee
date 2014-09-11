
bind_tab_toggle = ->
  $("a[data-toggle=\"tab\"]").on "shown.bs.tab", (e) ->
    $(".assignment-rubric").toggleClass "span4"
    return
  return
$(document).on 'ready page:load', bind_tab_toggle