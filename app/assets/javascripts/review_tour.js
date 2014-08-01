// Define the tour!
var reviewtour = {
  id: "review-hopscotch",
  steps: [
    {
      title: "Here is your peer's submission!",
      content: "You'll be giving feedback on this submission.",
      target: "student-work",
      placement: "bottom"
    },
    {
      title: "Here is an example submission that received perfect marks.",
      target: "excellent-work",
      content: "Use this example to gain greater perspective and give better feedback. Compare the example and the student submission often, especially when confused!",
      placement: "bottom"
    },
    {
      title: "Here is the rubric you'll use to give feedback.",
      content: "Each rubric section has a checkbox to note any unclearness, as well as a box for additional comments. The more examples/explanations you offer, the clearer your feedback becomes!",
      target:  "review-rubric",
      placement: "right"
    },
    {
      title: "Add any overall comments!",
      content: "Fill this text box with any additional comments about the clarity of the submission, such as eloquent sentences, impeccable grammar, and clear organization.",
      target: "overall-comments",
      smoothScroll: true,
      placement: "right"
    },
    {
      title: "If this submission is especially incredible, go ahead and check this off!",
      target: "out-of-box",
      placement: "right"
    },
    {
      title: "When you're done, click submit! It's that simple!",
      target:"submit-button",
      placement: "top"
    }
  ]
};

init = function() {
  var startButton = document.getElementById("startReviewTourBtn");
  state = hopscotch.getState();
  if (startButton !== null) {
    startButton.onclick = function() {hopscotch.startTour(reviewtour);};
  }
};

window.onload = function() {
  init();
};

// hopscotch.startTour(reviewtour);




