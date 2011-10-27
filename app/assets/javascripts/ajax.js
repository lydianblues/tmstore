(function($){

  function success(data, textStatus, jqXHR) {
    $("#ajax-indicator img").hide();
  }

  $.fn.submitWithAjax = function() {
    $(this).submit(function(event) {
      $("#message_box").empty();
      $("#ajax-indicator img").show();
      $.post(this.action, $(this).serialize(), success, "script");
      return false;
    })
    return this;
  };
        
  /* Designed for an IMG nested directly in a FORM. */
  $.fn.clickWithAjax = function() {
    $(this).click(function(event) {
      form = $(this).parent('form');
      $("#ajax-indicator img").show();
      $.post(form.action, form.serialize(), success, "script");
      return false;
    })
    return this;
  };
})(jQuery);
