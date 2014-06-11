
bind_tab_toggle = ->
  $("a[data-toggle=\"tab\"]").on "shown.bs.tab", (e) ->
    $(".assignment-rubric").toggleClass "span4"
    return
  return
$(document).ready bind_tab_toggle