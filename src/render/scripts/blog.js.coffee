# =================================
# Navbar

navbar = $("nav.navbar-fixed-top")
buttonShowTags = $("#show-tags")
navTags = $("#nav-tags")

# Enable auto hiding navbar
navbar.autoHidingNavbar {animationDuration: 100}

offsetSetClass = navbar.height() + 50
$(window).on "scroll", ->
  scrollTop = $(window).scrollTop()
  # Remove class background to navbar if scroll on top
  if( scrollTop < offsetSetClass and navbar.hasClass 'navbar-custom-background' )
    navbar.removeClass 'navbar-custom-background'
  # Add class background to navbar if scroll isn't on top
  else if( scrollTop > offsetSetClass and not navbar.hasClass 'navbar-custom-background' )
    navbar.addClass 'navbar-custom-background'
  # Hide nav-tags when navbar is hidden
  if(navbar.hasClass 'navbar-hidden')
    navTags.hide()

# Handle click on button show tags
buttonShowTags.click ->
  navTags.toggle(100)
  return false

