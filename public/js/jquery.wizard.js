/**
 * jQuery-Plugin "Wizard"
 * 
 * @version: 1.0, 11.14.2011
 * 
 * @author: VivantDesigns
 *          admin@vivantdesigns.com
 *          http://themeforest.net/user/vivantdesigns
 * 
 * @example: $('selector').wizard();
 * 
 */
(function($){
    $.wizard = function(el, options){
        // To avoid scope issues, use 'base' instead of 'this'
        // to reference this class from internal events and functions.
        var base = this;
        
        // Access to jQuery and DOM versions of element
        base.$el = $(el);
        base.el = el;
        
        // Add a reverse reference to the DOM object
        base.$el.data("wizard", base);
        
        base.init = function(){
            base.options = $.extend({},$.wizard.defaultOptions, options);
            
            // Put your initialization code here
            base.$el.validator();

            $('.items > section:first', base.$el).addClass('current');

            base.$el.scrollable();

            // some variables that we need
            var api = base.$el.scrollable();

            $(".items > section", base.$el).each(function(){
                $('input, select', this).validator({messageClass: 'wizard-error'});
            });

            // validation logic is done inside the onBeforeSeek callback
            api.onBeforeSeek(function(event, i) {
                if (i > api.getIndex()) {
                    if ($('input, select', $('.items > section', base.$el).eq(api.getIndex())).data("validator").checkValidity() == false) {
                        $('.wizard-error').remove();
                        return false;
                    }
                }
                
                // update status bar
                $("nav > ul li", base.$el).removeClass("active").eq(i).addClass("active");

                // update current screen
                $(".items > section", base.$el).removeClass("current").eq(i).addClass("current");
                
                base.updateWizard();
            });
            
            $("button.next", base.$el).keydown(function(e) {
                if (e.keyCode == 9) {

                    // seeks to next tab by executing our validation routine
                    api.next();
                    e.preventDefault();
                }
            });
        };

        base.updateWizard = function() {
            if (base.$el.is(':visible')) {
                var height = $('> nav', base.$el).height() + $('.items > section.current', base.$el).height();
                if (height > 0) {
                    base.$el.animate({height: height}, 'fast');
                }
                $("> .items > section", base.$el).each(function(){
                    if (base.$el.width() > 0) {
                        $(this).width(base.$el.width());
                    }
                });
            }
        }

        $(window).bind('resize drilldown load', function(){
            base.updateWizard();
        });
        
        // Run initializer
        base.init();
    };
    
    $.wizard.defaultOptions = {
    };
    
    $.fn.wizard = function(options){
        return this.each(function(){
            (new $.wizard(this, options));
        });
    };
    
})(jQuery);