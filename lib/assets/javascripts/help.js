(function($) {
  $(document).ready(function() {
    $("#help-toggle").click(function() {
        $("#help-contents").toggle();
        if ($("#help-contents").css("display") == "none") {
            $(this).text("Show Help");
        } else {
            $(this).text("Hide Help");
        }
    });
  });

})(jQuery);
