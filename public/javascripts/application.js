// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery.noConflict();

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