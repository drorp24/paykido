/**
 * jQuery-Plugin "iTextClear"
 * 
 * @version: 1.0, 11.04.2011
 * 
 * @author: VivantDesigns
 *          admin@vivantdesigns.com
 *          http://themeforest.net/user/vivantdesigns
 * 
 * @example: $('selector').iTextClear();
 * 
 */
(function($){
    $.iTextClear = function(el, options){
        // To avoid scope issues, use 'base' instead of 'this'
        // to reference this class from internal events and functions.
        var base = this;
        
        var clicked = false,
            iTextClearButton = $('<a class="iTextClearButton"></a>');
        
        // Access to jQuery and DOM versions of element
        base.$el = $(el);
        base.el = el;
        
        // Add a reverse reference to the DOM object
        base.$el.data("iTextClear", base);
        
        base.init = function(){
            base.options = $.extend({},$.iTextClear.defaultOptions, options);
            
            base.$el
                .wrap("<span class=\"iTextClearButtonContainer\"></span>")
                .after(iTextClearButton.hide())
                .bind('focus.itextclear', function() {
                    iTextClearButton.show();
                })
                .bind('focusout.itextclear', function() {
                    clicked? clicked = false : iTextClearButton.hide();
                });

            iTextClearButton.bind('mousedown.itextclear', function() {
                clicked = true;
                base.$el.val("");
                setTimeout(function() { base.$el.focus(); }, 0);
            });
        };
        
        // Run initializer
        base.init();
    };
    
    $.iTextClear.defaultOptions = {
    };
    
    $.fn.iTextClear = function(options){
        return this.each(function(){
            (new $.iTextClear(this, options));
        });
    };
    
})(jQuery);