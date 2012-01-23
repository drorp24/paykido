/**
 * jQuery-Plugin "drillDownMenu"
 *
 * @version: 1.0, 09.09.2011
 *
 * @author: VivantDesigns
 *          admin@vivantdesigns.com
 *          http://themeforest.net/user/vivantdesigns
 *
 * @example: $('selector').drillDownMenu();
 *
 */

(function($){
    $.drillDownMenu = function(el, options){
        // To avoid scope issues, use 'base' instead of 'this'
        // to reference this class from internal events and functions.
        var base = this;

        // Access to jQuery and DOM versions of element
        base.$el = $(el);
        base.el = el;

        var tlm = $("> ul:first", base.$el),
        toolbar = $("> h1:first", base.$el),
        searchform = $("#searchform", base.$el);

        // Add a reverse reference to the DOM object
        base.$el.data("drillDownMenu", base);

        base.init = function(){
            base.options = $.extend({},$.drillDownMenu.defaultOptions, options);

            $(".title", base.$el).html(base.options.title);

            toolbar.hide();

            base._initUl(tlm);
            $("ul", tlm).hide();

            $('ul > li', base.$el).removeClass('current');
            var lis = $('ul > li > a[href="'+location.hash+'"]', base.$el).parent().addClass('current').parentsUntil(base.$el, 'li'),
                item;

            lis = $.makeArray(lis);
            while(item = lis.pop()) {
                $('>a',item).click();
            }

            $(".back", base.$el).bind("click.drillDownMenu", $.proxy(function (event) {
                var currUl = base.$el.data("currentMenu");
                if (currUl.length) {
                    currUl.trigger("goback");
                }
                event.preventDefault();
            },
            base.$el)
            );

        };

		base._initUl = function (ul) {
            $("> li:not(:has(ul))", ul).click(function(){
                $(" > ul li", base.$el).removeClass("current");
                $(this).addClass("current");
            });
            $("> li:has(ul)", ul).each(function(){
                var li = $(this),
                menuItem = $("> a:first", li),
                currUl = $("> ul:first", li);
                currUl.css({top: -li.position().top-1});
                base._initUl(currUl);

                currUl.bind("goback.drillDownMenu", function(event) {
                    var currUl = $(this);
                    var prevUl = $(this).parent().closest("ul");
                    if(prevUl.length) {
                        tlm.stop(false, true).animate({left: "+=100%"}, 300, "easeInOutQuart", function(){
                            currUl.hide();
                        });
                        base.$el.data("currentMenu", prevUl);
                        prevUl.hasClass("tlm") && (toolbar.hide(), searchform.show());
                    }
                    $(".title", base.$el).stop().fadeTo(150, 0, function () {
						$(".title", base.$el).html(prevUl.length && prevUl[0] != tlm[0]? $("> a > span", prevUl.parent()).html() : base.options.title);
					}).fadeTo(150, 1);
                    event.preventDefault();
                    return false;
                });

				menuItem.bind("click.drillDownMenu", $.proxy(function (event) {
                    var currUl = $(this).parent().closest("ul");
                    var li = this, nextUl = $("> ul:first", this);
                    nextUl.show();
                    tlm.stop(false, true).animate({left: "-=100%"}, 300, "easeInOutQuart");
                    base.$el.data("currentMenu", nextUl);
                    toolbar.is(':hidden') && (toolbar.show(), searchform.hide());
                    $(".title", base.$el).stop().fadeTo(150, 0, function () {
						$(".title", base.$el).html($("> a > span", li).html());
					}).fadeTo(150, 1);
                    event.preventDefault();
                },
                li));
            });
            return base;
		};

        // Run initializer
        base.init();
    };

    $.drillDownMenu.defaultOptions = {
        title: "Main Menu",
        target: "#main-content",
        pageDownloaded: function(data, anchor) {}
    };

    $.fn.drillDownMenu = function(options){
        return this.each(function(){
            (new $.drillDownMenu(this, options));
        });
    };

    // This function breaks the chain, but returns
    // the drillDownMenu if it has been attached to the object.
    $.fn.getdrillDownMenu = function(){
        this.data("drillDownMenu");
    };

})(jQuery);