# Define the tour!
introtour =
  id: "hello-hopscotch"
  steps: [
    {
      
      #set up a button so that when it clicks, this tour starts. 
      title: "All open courses are displayed here."
      target: "course_header"
      placement: "bottom"
      multipage: true
      onNext: ->
        window.location = "courses/4" #Barb Oakley's class is courses/4.This is manual. how can we make it non manual?
        return
    }
    {
      title: "All the assignments for the course are displayed here."
      target: "other_assignments"
      placement: "right"
      xOffset: -800 #how do we make it so that it's not affected by the div?
    }
    {
      title: "The assignment showcased here is due the soonest."
      target: "assignment_title" #this should be pointing at the very top assignment header
      placement: "bottom"
      multipage: true
      onNext: ->
        window.location = "/assignments/5" #5, because first assignment for Barb's class
        return
    }
    {
      title: "Write your answer here!"
      content: "We'll have a template set up for you to draft a great answer."
      target: "write"
      placement: "bottom"
    }
    {
      title: "Review your peers!"
      content: "Solidify your understanding of the material by giving feedback to your peers. Don't worry, the process is quick and simple."
      target: "give-feedback"
      placement: "bottom"
    }
    {
      title: "Your work is here!"
      content: "See your drafts, as well as any reviews you given and received."
      target: "assignment_answers"
      placement: "top"
    }
    {
      title: "Now you're ready to give and get feedback!"
      content: "Remember that PeerStudio runs on a give-and-get system: to get feedback, give feedback!"
      target: "write"
      placement: "bottom"
    }
  ]

init = ->
  startButton = $("#startTourBtn")
  state = hopscotch.getState()
  
  # Already started the tour at some point!
  hopscotch.startTour introtour  if state and state.indexOf("hello-hopscotch:") is 0
  $("#startTourBtn").click ->
    hopscotch.startTour introtour
    return

  return

$(document).on "ready page:load", ->
  init()
  return
