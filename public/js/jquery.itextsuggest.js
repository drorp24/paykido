/**
 * jQuery-Plugin "iTextSuggest"
 * 
 * @version: 1.0, 11.06.2011
 * 
 * @author: VivantDesigns
 *          admin@vivantdesigns.com
 *          http://themeforest.net/user/vivantdesigns
 * 
 * @example: $('selector').iTextSuggest();
 * 
 */
(function($){
    $.iTextSuggest = function(el, options){
        // To avoid scope issues, use 'base' instead of 'this'
        // to reference this class from internal events and functions.
        var base = this;
        
        var container = null;
        
        // Access to jQuery and DOM versions of element
        base.$el = $(el);
        base.el = el;
        
        // Add a reverse reference to the DOM object
        base.$el.data("iTextSuggest", base);
        
        base.init = function(){
            base.options = $.extend({},$.iTextSuggest.defaultOptions, options);
            
			$('body').append("<div id='"+base.options.id+"'></div>");

            var preloader = $('<span class="itextsuggestpreloader"></span>'),
			startPos = 0,
			timer = null;

			container = $('#'+base.options.id);
            
            base.$el.before(preloader);

			if(base.$el.attr(base.options.attribute) == undefined) {
				base.$el.attr(base.options.attribute, base.$el.val()).addClass(base.options.blurClass);
			}

			base.$el.focus(function() {
				if(base.$el.val() == base.$el.attr(base.options.attribute)) {
					base.$el.val('').removeClass(base.options.blurClass).addClass(base.options.activeClass);
				}

				if(base.options.minLength<=base.$el.val().length){
					container.show();
				}
			});

			base.$el.blur(function() {
				if(base.$el.val() == '') {
					base.$el.val(base.$el.attr(base.options.attribute)).removeClass(base.options.activeClass).addClass(base.options.blurClass);
				}
				setTimeout(function(){ container.hide(); }, 200);
			});

			$(window).resize(function(){
				base.setPos();
			});

			$('ul li a', container).live('mouseover', function(){
                $('ul li a', container).removeClass('active');
			});
            
			if($.isFunction(base.options.onSelect)) {
                $('ul li a', container).live('click', function(){
                    base.$el.val($(this).text());
                    startPos = $(this).text().length;
                    base.$el.trigger('keyup').focus();
                    base.options.onSelect($(this).text());
                    return false;
                });
            }

			base.$el.keyup(function(e){
				var txt = base.$el.val(),
                    query = encodeURIComponent(txt),
                    index = $('ul li a', container).index($('a.active')),
                    len = $('ul li a', container).length;

				base.setPos();
				clearTimeout(timer);
				$('ul li a', container).removeClass('active');

                switch(e.keyCode){
                case 38:
                case 40:
                    var current = e.keyCode == 38?
                        index<0? $('ul li a:last', container) : $('ul li a', container).eq(index-1) :
                        index<0 || index==(len-1)? $('ul li a:first', container) : $('ul li a', container).eq(index+1);

                    current.addClass('active');
                    base.$el.val(current.text());
                    if ($.isFunction(base.options.onChange)) base.options.onChange(current.text());
                    break;
                case 13:
                    base.$el.trigger('submit.itextsuggest');
                    break;
                default:
					if(txt.length==0) {
                        base.$el.trigger('empty.itextsuggest');
					} else if(base.options.minLength>txt.length) {
                        container.hide();
                    } else {
						startPos = txt.length;
						if(base.options.minLength<=txt.length) timer = setTimeout(function() {
							preloader.show();
							$.get(base.options.url, 'q='+query+'&target='+base.options.targetMode, function(res) {
								if(res.length>3){
									container.html(res).show();
								} else {
									container.hide().empty();
								}
							})
                            .complete(function(){
                                preloader.hide();
                            });
						}, 250);
                        
                        base.$el.trigger('keydown.itextsuggest');
					}
                }
			});
        };
        
        base.$el.bind('empty.itextsuggest', function(){
            if($.isFunction(base.options.onEmpty)) {
                base.options.onEmpty();
            }
        });
        
        base.$el.bind('submit.itextsuggest', function(){
            if($.isFunction(base.options.onSubmit)) {
                base.options.onSubmit(base.$el.val());
            }
        });
        
        base.$el.bind('keydown.itextsuggest', function(){
            if($.isFunction(base.options.onKeydown)) {
                base.options.onKeydown(base.$el.val());
            }
        });
        
        base.setPos = function(){
            var width = base.$el.parents('div.searchbox').outerWidth();
            var height = base.$el.parents('div.searchbox').outerHeight();
            var top = base.$el.parents('div.searchbox').offset().top+4;
            var left = base.$el.parents('div.searchbox').offset().left;

            container.css({
                'width':width+'px',
                'top':(top+height)+'px',
                'left':left+'px'
            });
        }

        // Run initializer
        base.init();
    };
    
    $.iTextSuggest.defaultOptions = {
        attribute: 'rel',
        id: 'itextsuggest',
        minLength: 1,
        targetMode: '',
        url: 'php/google_suggestions_results.php',

        // Classes
        activeClass: 'fieldActive',
        blurClass: 'fieldBlurred',
        
        // Events
        onKeydown: null,
        onSelect: null,
        onChange: null,
        onSubmit: null,
        onEmpty: null
    };
    
    $.fn.iTextSuggest = function(options){
        return this.each(function(){
            (new $.iTextSuggest(this, options));
        });
    };
    
})(jQuery);