/*
 * Paykido Payment Window API for merchants and IPSP
 *
 * Usage:
 *
 *  jQuery(document).ready(function() {
 *    jQuery('a[rel*=paykido]').paykido()
 *  })
 *
 *  <a href="#terms" rel="paykido">Terms</a>
 *    Loads the #terms div in the box
 *
 *  <a href="terms.html" rel="paykido">Terms</a>
 *    Loads the terms.html page in the box
 *
 *  <a href="terms.png" rel="paykido">Terms</a>
 *    Loads the terms.png image in the box
 *
 *
 *  You can also use it programmatically:
 *
 *    jQuery.paykido('some html')
 *    jQuery.paykido('some html', 'my-groovy-style')
 *
 *  The above will open a paykido with "some html" as the content.
 *
 *    jQuery.paykido(function($) {
 *      $.get('blah.html', function(data) { $.paykido(data) })
 *    })
 *
 *  The above will show a loading screen before the passed function is called,
 *  allowing for a better ajaxy experience.
 *
 *  The paykido function can also display an ajax page, an image, or the contents of a div:
 *
 *    jQuery.paykido({ ajax: 'remote.html' })
 *    jQuery.paykido({ ajax: 'remote.html' }, 'my-groovy-style')
 *    jQuery.paykido({ image: 'stairs.jpg' })
 *    jQuery.paykido({ image: 'stairs.jpg' }, 'my-groovy-style')
 *    jQuery.paykido({ div: '#box' })
 *    jQuery.paykido({ div: '#box' }, 'my-groovy-style')
 *
 *  Want to close the paykido?  Trigger the 'close.paykido' document event:
 *
 *    jQuery(document).trigger('close.paykido')
 *
 *  paykido also has a bunch of other hooks:
 *
 *    loading.paykido
 *    beforeReveal.paykido
 *    reveal.paykido (aliased as 'afterReveal.paykido')
 *    init.paykido
 *    afterClose.paykido
 *
 *  Simply bind a function to any of these hooks:
 *
 *   $(document).bind('reveal.paykido', function() { ...stuff to do after the paykido and contents are revealed... })
 *
 */
(function($) {
  $.paykido = function(data, klass) {
    $.paykido.loading()

    if (data.ajax) fillpaykidoFromAjax(data.ajax, klass)
    else if (data.image) fillpaykidoFromImage(data.image, klass)
    else if (data.div) fillpaykidoFromHref(data.div, klass)
    else if ($.isFunction(data)) data.call($)
    else $.paykido.reveal(data, klass)
  }

  /*
   * Public, $.paykido methods
   */

  $.extend($.paykido, {
    settings: {
      opacity      : 0.4,
      overlay      : true,
      loadingImage : '/images/fbloading.gif',
      closeImage   : '/images/closelabel.png',
      imageTypes   : [ 'png', 'jpg', 'jpeg', 'gif' ],
      paykidoHtml  : '\
    <div id="paykido" style="display:none;"> \
      <div class="popup"> \
        <div class="content"> \
        </div> \
        <a href="#" class="close"><img src="/images/closelabel.png" title="close" class="close_image" /></a> \
      </div> \
    </div>'
    },

    loading: function() {
      init()
      if ($('#paykido .loading').length == 1) return true
      showOverlay()

      $('#paykido .content').empty()
      $('#paykido .body').children().hide().end().
        append('<div class="loading"><img src="'+$.paykido.settings.loadingImage+'"/></div>')

      $('#paykido').css({
        top:	getPageScroll()[1] + (getPageHeight() / 10),
        left:	$(window).width() / 2 - 205
      }).show()

      $(document).bind('keydown.paykido', function(e) {
        if (e.keyCode == 27) $.paykido.close()
        return true
      })
      $(document).trigger('loading.paykido')
    },

    reveal: function(data, klass) {
      $(document).trigger('beforeReveal.paykido')
      if (klass) $('#paykido .content').addClass(klass)
      $('#paykido .content').append(data)
      $('#paykido .loading').remove()
      $('#paykido .body').children().fadeIn('normal')
      $('#paykido').css('left', $(window).width() / 2 - ($('#paykido .popup').width() / 2))
      $(document).trigger('reveal.paykido').trigger('afterReveal.paykido')
    },

    close: function() {
      $(document).trigger('close.paykido')
      return false
    }
  })

  /*
   * Public, $.fn methods
   */

  $.fn.paykido = function(settings) {
    if ($(this).length == 0) return

    init(settings)

    function clickHandler() {
      $.paykido.loading(true)

      // support for rel="paykido.inline_popup" syntax, to add a class
      // also supports deprecated "paykido[.inline_popup]" syntax
      var klass = this.rel.match(/paykido\[?\.(\w+)\]?/)
      if (klass) klass = klass[1]

      fillpaykidoFromHref(this.href, klass)
      return false
    }

    return this.bind('click.paykido', clickHandler)
  }

  /*
   * Private methods
   */

  // called one time to setup paykido on this page
  function init(settings) {
    if ($.paykido.settings.inited) return true
    else $.paykido.settings.inited = true

    $(document).trigger('init.paykido')
    makeCompatible()

    var imageTypes = $.paykido.settings.imageTypes.join('|')
    $.paykido.settings.imageTypesRegexp = new RegExp('\.(' + imageTypes + ')$', 'i')

    if (settings) $.extend($.paykido.settings, settings)
    $('body').append($.paykido.settings.paykidoHtml)

    var preload = [ new Image(), new Image() ]
    preload[0].src = $.paykido.settings.closeImage
    preload[1].src = $.paykido.settings.loadingImage

    $('#paykido').find('.b:first, .bl').each(function() {
      preload.push(new Image())
      preload.slice(-1).src = $(this).css('background-image').replace(/url\((.+)\)/, '$1')
    })

    $('#paykido .close').click($.paykido.close)
    $('#paykido .close_image').attr('src', $.paykido.settings.closeImage)
  }

  // getPageScroll() by quirksmode.com
  function getPageScroll() {
    var xScroll, yScroll;
    if (self.pageYOffset) {
      yScroll = self.pageYOffset;
      xScroll = self.pageXOffset;
    } else if (document.documentElement && document.documentElement.scrollTop) {	 // Explorer 6 Strict
      yScroll = document.documentElement.scrollTop;
      xScroll = document.documentElement.scrollLeft;
    } else if (document.body) {// all other Explorers
      yScroll = document.body.scrollTop;
      xScroll = document.body.scrollLeft;
    }
    return new Array(xScroll,yScroll)
  }

  // Adapted from getPageSize() by quirksmode.com
  function getPageHeight() {
    var windowHeight
    if (self.innerHeight) {	// all except Explorer
      windowHeight = self.innerHeight;
    } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
      windowHeight = document.documentElement.clientHeight;
    } else if (document.body) { // other Explorers
      windowHeight = document.body.clientHeight;
    }
    return windowHeight
  }

  // Backwards compatibility
  function makeCompatible() {
    var $s = $.paykido.settings

    $s.loadingImage = $s.loading_image || $s.loadingImage
    $s.closeImage = $s.close_image || $s.closeImage
    $s.imageTypes = $s.image_types || $s.imageTypes
    $s.paykidoHtml = $s.paykido_html || $s.paykidoHtml
  }

  // Figures out what you want to display and displays it
  // formats are:
  //     div: #id
  //   image: blah.extension
  //    ajax: anything else
  function fillpaykidoFromHref(href, klass) {
    // div
    if (href.match(/#/)) {
      var url    = window.location.href.split('#')[0]
      var target = href.replace(url,'')
      if (target == '#') return
      $.paykido.reveal($(target).html(), klass)

    // image
    } else if (href.match($.paykido.settings.imageTypesRegexp)) {
      fillpaykidoFromImage(href, klass)
    // ajax
    } else {
      fillpaykidoFromAjax(href, klass)
    }
  }

  function fillpaykidoFromImage(href, klass) {
    var image = new Image()
    image.onload = function() {
      $.paykido.reveal('<div class="image"><img src="' + image.src + '" /></div>', klass)
    }
    image.src = href
  }

  function fillpaykidoFromAjax(href, klass) {
    $.get(href, function(data) { $.paykido.reveal(data, klass) })
  }

  function skipOverlay() {
    return $.paykido.settings.overlay == false || $.paykido.settings.opacity === null
  }

  function showOverlay() {
    if (skipOverlay()) return

    if ($('#paykido_overlay').length == 0)
      $("body").append('<div id="paykido_overlay" class="paykido_hide"></div>')

    $('#paykido_overlay').hide().addClass("paykido_overlayBG")
      .css('opacity', $.paykido.settings.opacity)
      .click(function() { $(document).trigger('close.paykido') })
      .fadeIn(200)
    return false
  }

  function hideOverlay() {
    if (skipOverlay()) return

    $('#paykido_overlay').fadeOut(200, function(){
      $("#paykido_overlay").removeClass("paykido_overlayBG")
      $("#paykido_overlay").addClass("paykido_hide")
      $("#paykido_overlay").remove()
    })

    return false
  }

  /*
   * Bindings
   */

  $(document).bind('close.paykido', function() {
    $(document).unbind('keydown.paykido')
    $('#paykido').fadeOut(function() {
      $('#paykido .content').removeClass().addClass('content')
      $('#paykido .loading').remove()
      $(document).trigger('afterClose.paykido')
    })
    hideOverlay()
  })

})(jQuery);
