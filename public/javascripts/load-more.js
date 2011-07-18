(function($){
  $('.show-more').live('click', function(e) {
    e.preventDefault();

    var $link = $(this);
    $link.html('<img src="/images/loading.gif" alt="loading" />');

    $.get($link.attr('href'), function(data) {
      $link.replaceWith(data);
    });
  });
})(jQuery);
