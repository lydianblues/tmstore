jQuery.noConflict();

(function($) {
	
	/*********** begin same as category.js ***********/
	
	$.ajaxSetup({ 
	  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
	})
	
	$.fn.submitWithAjax = function() {
	  this.submit(function() {
	    $.post(this.action, $(this).serialize(), null, "script");
	    return false;
	  })
	  return this;
	};
	
	/****************** end same as category.js ***********/
	
	$(function() {
		$("#search_product_attributes").submitWithAjax();
	});

})(jQuery);

