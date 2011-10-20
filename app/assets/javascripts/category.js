jQuery.noConflict();

(function($) {

	function setupCommand(cmd, model) {
		var prefix = "#" + cmd + "-" + model + "-";
		$(prefix + "open").click(function () {
			$(".cmd-box").hide();
			$(prefix + "box").show();
			return false;
		});
		$(prefix + "close").click(function() {
			$(prefix + "box").hide();
			$("#select-command-box").show();
			return false;
		});
	}
	
	$.ajaxSetup({ 
	  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
	})
	
	$.fn.submitWithAjax = function() {
	  this.submit(function() {
            $("#ajax-indicator").show();
            $("#message_box").empty();
	    $.post(this.action, $(this).serialize(), null, "script");
	    return false;
	  })
	  return this;
	};
	
	/* Designed for an IMG nested directly in a FORM. */
	$.fn.clickWithAjax = function() {
	  this.click(function() {
		form = $(this).parent('form');
		$.post(form.action, form.serialize(), null, "script");
	    return false;
	  })
	  return this;
	};
	
	$(document).ready(function() {
	
		$("tr").click(function () {
		      $(this).effect("highlight", {}, 3000);
		});
		$(".ajax-form").submitWithAjax();
		$(".ajax-image").clickWithAjax();
		setupCommand("create", "category");
		setupCommand("delete", "category");
		setupCommand("rename", "category");
		setupCommand("reparent", "category");
		setupCommand("add-family", "category");
		$("#select-command-box").show();
	});

})(jQuery);
