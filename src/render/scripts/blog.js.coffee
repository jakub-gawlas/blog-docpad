navbar = $("nav.navbar-fixed-top")

# Enable auto hiding navbar
navbar.autoHidingNavbar {animationDuration: 100}

# Add class background to navbar if scroll isn't on top and remove it if scroll on top
offsetSetClass = navbar.height() + 50
$(window).on "scroll", ->
  scrollTop = $(window).scrollTop()
  if( scrollTop < offsetSetClass and navbar.hasClass 'navbar-custom-background' )
    navbar.removeClass 'navbar-custom-background'
  else if( scrollTop > offsetSetClass and not navbar.hasClass 'navbar-custom-background' )
    navbar.addClass 'navbar-custom-background'



