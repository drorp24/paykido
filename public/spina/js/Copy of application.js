$('document').ready(function() {


  /*******
    PJAX UNCOMMENT THIS FOR PJAX FUNCTIONALITY
  *******/
  
/*
   $('nav#primary a').click(function() {
       window.location = $(this).attr("href");
       return false;
     });
     
     $('nav#secondary a').pjax({
       container: '#main',
       success: function(data) {
         init();
       }
     });

     $('a').pjax({
       container: '#main',
       success: function(data) {
         init();
       }
     });
*/  
  /******************
    Tablet rotation
  ******************/
  
  var isiPad = navigator.userAgent.match(/iPad/i) != null;
  
  if(isiPad) {
    $('body').prepend('<div id="rotatedevice"><h1>Please rotate your device 90 degrees.</div>');
  }
  
  /********
    Login
  ********/
  
  $('#login_entry > a').click(function() {    
    $(this).fadeOut(200, function() {
      $('#login_form').fadeIn();
    });

    return false;
  });
  
  /********************
    Modal preparation
  ********************/
  
  $('body').prepend('<div id="overlay"><div id="modalcontainer"></div></div>');
  
  /****************
    Notifications
  ****************/
  
  $('#notifications ul li').livequery(function() {
    $('#notifications').fadeIn();
  });
  
  $('#notifications').prepend('<a href="#">Show all notifications</a>');
  
  $('#notifications > a').click(function() {
    var container = $('#notifications');
    var height = $('#notifications ul').height() + 24;
    
    if(container.hasClass('expanded')) {
      container.animate({'height': 42}, 200);
      container.removeClass('expanded');
      $(this).html('show all notifications');
    } else {
      container.animate({'height': height}, 200);
      container.addClass('expanded');
      $(this).html('hide notifications');
    }
    
    return false;
  });
  
  function sp_init() {
     
    /*************
      Datepicker
    *************/

/*    
    $('.datepicker').datepicker();
*/        
    /*************
      Datatables
    *************/
  
    $('.datatable').dataTable({
      "sPaginationType": "full_numbers",
      "bStateSave": true
    });
  
    $('.dataTables_wrapper').each(function() {
      var table = $(this);
      var info = table.find('.dataTables_info');
      var paginate = table.find('.dataTables_paginate');
    
      table.find('.datatable').after('<div class="action_bar nomargin"></div>');
      table.find('.action_bar').prepend(info).append(paginate);
    });
    
    /************************
      Combined input fields
    ************************/
    
    $('div.combined p:last-child').addClass('last-child');
  
    /**********
      Sliders
    **********/
  
    $(".slider").each(function() {
      var options = $(this).metadata();
      $(this).slider(options, {
        animate: true
      });
    });
  
    $(".slider-vertical").each(function() {
      var options = $(this).metadata();
      $(this).slider(options, {
        animate: true
      });
    });
    
    /****************
      Progress bars
    ****************/
  
    $(".progressbar").each(function() {
      var options = $(this).metadata();
      $(this).progressbar(options);
    });
  
    /**********************
      Modal functionality
    **********************/
  
    $('a.sp_modal').each(function() {
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
  
    $('.sp_close').click(function() {
      $('#modalcontainer > div').hide();
      $('#overlay').hide();
    
      return false;
    });
    
    /***********************
      Secondary navigation
    ***********************/
    
    $('nav#secondary > ul > li > a').click(function() {
      $('nav#secondary li').removeClass('active');
      $(this).parent().addClass('active');
    });
  
    /********************
      Pretty checkboxes
    ********************/
/*  multiplies the pretty checkboxes on the purchase approval modal window 
    $('input[type=checkbox], input[type=radio]').each(function() {
      if($(this).siblings('label').length > 0) {
        $(this).prettyCheckboxes();
      }
    });
*/  
    
    /*******
      Tabs
    *******/
  
    // Hide all .tab-content divs
    $('.tab-content').livequery(function() {
      $(this).hide();
    });

    // Show all active tabs
    $('.box-header ul li.active a').livequery(function() {
      var target = $(this).attr('href');
      $(target).show();
    });
  
    // Add click eventhandler
    $('.box-header ul li').livequery(function() {
      $(this).click(function() {
        var item = $(this);
        var target = item.find('a').attr('href');
        
        if($(target).parent('form').length > 0) {
          if($(target).parent('form').valid()) {
            item.siblings().removeClass('active');
            item.addClass('active');
    
            item.parents('.box').find('.tab-content').hide();
            $(target).show();
          }
        } else {
          item.siblings().removeClass('active');
          item.addClass('active');
    
          item.parents('.box').find('.tab-content').hide();
          $(target).show(); 
        }
    
        return false;
      });
    });
    
    /***********
      Tooltips
    ***********/
    
    $('.tooltip').tipsy({gravity: 's'});
  
    /******************
      Form Validation
    ******************/
/*  
    $('form').validate({
      wrapper: 'span class="error"',
      meta: 'validate',
      highlight: function(element, errorClass, validClass) {
        if (element.type === 'radio') {
          this.findByName(element.name).addClass(errorClass).removeClass(validClass);
        } else {
          $(element).addClass(errorClass).removeClass(validClass);
        }
      
        // Show icon in parent element
        var error = $(element).parent().find('span.error');
      
        error.siblings('.icon').hide(0, function() {
          error.show();
        });
      },
      unhighlight: function(element, errorClass, validClass) {
        if (element.type === 'radio') {
          this.findByName(element.name).removeClass(errorClass).addClass(validClass);
        } else {
          $(element).removeClass(errorClass).addClass(validClass);
        }
      
        // Hide icon in parent element
        $(element).parent().find('span.error').hide(0, function() {
          $(element).parent().find('span.valid').fadeIn(200);
        });
      }
    });
*/    

    // Calendar icon fix
    $('form p > .error').livequery(function() {
      $(this).siblings('span.calendar').hide();
    });
  
    // Add valid icons to validatable fields
    $('form p > *').each(function() {
      var element = $(this);
      if(element.metadata().validate) {
        element.parent().append('<span class="icon tick valid"></span>');
      }
    });
  }
 
  sp_init();
});



/*************************
  Notification function!
*************************/

function notification(message, error, icon, image) {
  if(icon == null) {
    icon = 'tick2';
  }
  
  if(image) {
    image = 'icon16';
  } else {
    image = 'glyph';
  }
  
  var now = new Date();
  var hours = now.getHours();
  var minutes = now.getMinutes();
    
  if (hours < 10) {
    hours = "0" + hours;
  }
  
  if (minutes < 10) {
    minutes = "0" + minutes;
  }
  
  var time = hours + ':' + minutes;
  
  if(error) {
    $('#notifications ul').append('<li class="error"><span class="' + image + ' cross"></span> ' + message + ' <span class="time">' + time + '</span></li>');
  } else {
    $('#notifications ul').append('<li><span class="' + image + ' ' + icon + '"></span> ' + message + ' <span class="time">' + time + '</span></li>');
  }
  
  $('#notifications ul li:last-child').hide();
  $('#notifications ul li:last-child').slideDown(200);
}