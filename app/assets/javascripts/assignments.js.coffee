# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# $('.typeahead-usernames').typeahead({
#   # name: 'accounts',
#   local: ['timtrueman', 'JakeHarding', 'vskarich']
# })

$(".typeahead-usernames").typeahead({
      name: 'accounts',
    local: ["Apache", "Cochise", "Coconino", "Gila", "Graham", "Greenlee", "La Paz", "Maricopa", "Mohave", "Navajo", "Pima", "Pinal", "Santa Cruz", "Yavapai", "Yuma"]
});
