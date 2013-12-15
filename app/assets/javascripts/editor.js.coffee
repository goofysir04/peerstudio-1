$(document).ready ->
  $("form[data-remote]").bind "ajax:before", ->
    for instance of CKEDITOR.instances
      CKEDITOR.instances[instance].updateElement()
