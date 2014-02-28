do_on_load = ->
  $("#s3_uploader").S3Uploader
    remove_completed_progress_bar: false
    progress_bar_target: $("#uploads_container")
    allow_multiple_files: true

  $("#s3_uploader").bind "s3_upload_failed", (e, content) ->
    alert content.filename + " failed to upload due to a timeout."

  $("#s3_uploader").bind "s3_upload_complete", (e, content) ->
    
    #insert any post progress bar complete stuff here.
    $("#answer_direct_upload_url").val content.url
    $("#answer_asset_file_name").val content.filename
    $("#answer_asset_file_path").val content.filepath
    $("#answer_asset_file_size").val content.filesize
    $("#answer_asset_content_type").val content.filetype
    return

  return

$(document).ready do_on_load
$(window).bind "page:change", do_on_load