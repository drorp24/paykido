/**
 * jQuery-Plugin "iContacts"
 * 
 * @version: 1.0, 11.12.2011
 * 
 * @author: VivantDesigns
 *          admin@vivantdesigns.com
 *          http://themeforest.net/user/vivantdesigns
 * 
 * @example: $('selector').iContacts('#searchbox');
 * 
 */
(function($){
    $.iContacts = function(el, searchbox, options){
        // To avoid scope issues, use 'base' instead of 'this'
        // to reference this class from internal events and functions.
        var base = this;
        
        // Access to jQuery and DOM versions of element
        base.$el = $(el);
        base.el = el;
        
        // Add a reverse reference to the DOM object
        base.$el.data("iContacts", base);
        
        base.init = function(){
            base.searchbox = searchbox;
            base.$searchbox = $(searchbox);
            
            base.options = $.extend({},$.iContacts.defaultOptions, options);
            
            // Put your initialization code here
			base.$searchbox.keyup(function(e){
				var txt = base.$searchbox.val();

                if(txt.length==0) {
                    base.$el.find('li').show();
                } else {
                    base.$el.find('li').hide();
                    base.$el.find('> li > ul > li').filter(function(index){
                        var regexp = new RegExp(txt, "i");
                        return regexp.test($('a', this).text()) == true;
                    }).show().parents('li').show();
                }
			});
        };
        
        // Run initializer
        base.init();
    };
    
    $.iContacts.defaultOptions = {
    };
    
    $.fn.iContacts = function(searchbox, options){
        return this.each(function(){
            (new $.iContacts(this, searchbox, options));
        });
    };
    
})(jQuery);