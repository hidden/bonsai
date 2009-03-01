function initialize() {
    // find flash and hide it after to 10 seconds
    var flash = $('flash');
    if(flash != null) {
        Effect.Fade.delay(5, 'flash');
    }
}

Event.observe(window, 'load', initialize);