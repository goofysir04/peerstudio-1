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
      onNext: ->
        window.location = "/answers/23/edit" #5, because first assignment for Barb's class
        return
    }
    {
      title: "Write your answer here!"
      content: "We have a template ready for you to use. Use the template to guide the direction of your work."
      target: "answer_response"
      placement: "left"
    }
    {
      title: "Use this rubric to evaluate your work as you draft your answer."
      target: "assessment-tab"
      placement: "bottom"
    }
    {
      title: "Click here to view any reviews you may have gotten on this work."
      target: "review-tab"
      placement: "bottom"
    }
    {
      title: "Click here to save your draft, especially before submitting your work!"
      content: "We have an autosave feature implemented, but it can never hurt to be safe :)"
      target:  "save-draft-btn"
      placement: "right"
    }
    {
      title: "Click here to submit your work for early feedback!"
      content: "By getting feedback from your peers before turning in your work, you can iterate on your work, and continue improving!"
      target: "early-feedback-btn"
      placement: "left"
    }
    {
      title: "Click here to submit your final draft for review!"
      content: "You won't be able to make any changes after submitting this. If you want feedback on your work before turning in this final draft, click the 'Get Early Feedback' button!"
      target: "final-feedback-btn"
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
    skipIfNoElement: true
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
