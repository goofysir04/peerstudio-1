// Define the tour!
var introtour = {
  id: "hello-hopscotch",
  steps: [
    {
      //set up a button so that when it clicks, this tour starts. 
      title: "All open courses are displayed here.",
      target: "course_header",
      placement: "bottom",
      multipage: true,
      onNext: function() {
        window.location = "courses/2"; //CHANGE THIS TO 4!!!!!!!!!!!! this is manual. how can we make it non manual?
      }
    },
    {
      title: "All the assignments for the course are displayed here.",
      target: "other_assignments",
      placement: "right",
      xOffset: -800 //how do we make it so that it's not affected by the div?
    },
    {
      title: "The assignment showcased here is due the soonest.",
      target: "assignment_title", //this should be pointing at the very top assignment header
      placement: "bottom", //not right, because "div"
      multipage: true,
      onNext: function() {
        window.location = "/assignments/7"; //change this to the correct one
      }
    },
    {
      title: "Write your answer here!",
      content: "We'll have a template set up for you to draft a great answer.",
      target:  "write",//write answer button
      placement: "bottom",
    },
    {
      title: "Review your peers!",
      content: "Solidify your understanding of the material by giving feedback to your peers. Don't worry, the process is quick and simple.",
      target: "give-feedback", //review button
      placement: "bottom"
    },
    {
      title: "Your work is here!",
      content: "See your drafts, as well as any reviews you given and received.",
      target: "assignment_answers",//the bottom stuff...
      placement: "top"
    },
    {
      title: "Now you're ready to give and get feedback!",
      content: "Remember that PeerStudio runs on a give-and-get system: to get feedback, give feedback!",
      target:"write",
      placement: "bottom"
    }
  ]
};

init = function() {
  var startButton = document.getElementById("startTourBtn");
  state = hopscotch.getState();
  if (state && state.indexOf('hello-hopscotch:') === 0) {
    // Already started the tour at some point!
    hopscotch.startTour(introtour);
  }
  if (startButton !== null) {
    startButton.onclick = function() {hopscotch.startTour(introtour);};
  }
};

window.onload = function() {
  init();
};







