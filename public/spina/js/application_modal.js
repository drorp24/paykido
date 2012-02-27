$('document').ready(function() {

  $('body').prepend('<div id="overlay"><div id="modalcontainer"></div></div>');

    $('a.modal').each(function() {
      var link = $(this);
      var id = link.attr('href');
      var target = $(id);
      
      if($("#modalcontainer " + id).length == 0) {
        $("#modalcontainer").append(target);
      }
      
      $("#main " + id).remove();
    
      link.click(function() {
        $('#modalcontainer > div').hide();
        target.show();
        $('#overlay').show();
          
            return false;
          });
        });
      
        $('.close').click(function() {
      $('#modalcontainer > div').hide();
      $('#overlay').hide();
    
      return false;
    });    

})
