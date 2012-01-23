(function($){
    $.popover = function(el, target, options){
        var KEY_ESC = 27;
        // To avoid scope issues, use 'base' instead of 'this'
        // to reference this class from internal events and functions.
        var base = this;

        // Access to jQuery and DOM versions of element
        base.$el = $(el);
        base.el = el;

        // Add a reverse reference to the DOM object
        base.$el.data("popover", base);

        base.init = function(){
            base.options = $.extend({},$.popover.defaultOptions, options);

            $(target).appendTo($('body')).prepend('<div class="triangle"></div>');

            base.options.triangle$ = $('.triangle', $(target));

            // remember last opened popup
            $.fn.popover.openedPopup = null;

            // setup global document bindings
            $(document).unbind(".popover");

            // document click closes active popover
            $(document).bind("click.popover", function(event) {
                if (($(event.target).parents(".popover").length == 0)
                        && (!$(event.target).data("popover"))) {
                    $.popover.close();
                }
            });

            // document Esc key listener
            if (base.options.closeOnEsc) {
                $(document).bind('keydown', function(event) {
                    if (!event.altKey && !event.ctrlKey && !event.shiftKey
                                && (event.keyCode == KEY_ESC)) {
                        base.$el.trigger('close.popover');
                    }
                });
            }

            base.$el.live('click', function(event) {
                base.toggle($(event.target));
                return false;
            });

            base.$el.live('open.popover', function(event) {
                base.open($(event.target));
                return false;
            });

            base.$el.live('close.popover', function(event) {
                base.close($(event.target));
                return false;
            });

            return base.$el;
        };

        // functions to claculate popover direction and position

        base.calcPopoverDirPossible = function(trigger, coord) {
            var possibleDir = {
                left: false,
                right: false,
                top: false,
                bottom: false
            }

            if (trigger.offset().top + coord.buttonHeight + coord.triangleSize + coord.popoverHeight <=
                                    coord.docHeight - base.options.padding) {
                possibleDir.bottom = true;
            }

            if (trigger.offset().top - coord.triangleSize - coord.popoverHeight >= base.options.padding) {
                possibleDir.top = true;
            }

            if (trigger.offset().left + coord.buttonWidth + coord.triangleSize + coord.popoverWidth <=
                                    coord.docWidth - base.options.padding) {
                possibleDir.right = true;
            }

            if (trigger.offset().left - coord.triangleSize - coord.popoverWidth >= base.options.padding) {
                possibleDir.left = true;
            }

            return possibleDir;
        }

        base.chooseDir = function(possibleDir) {
            // remove directions prevented by base.options
            if (base.options.preventBottom)
                possibleDir.bottom = false;
            if (base.options.preventTop)
                possibleDir.top = false;
            if (base.options.preventLeft)
                possibleDir.left = false;
            if (base.options.preventRight)
                possibleDir.right = false;

            // determine default direction if nothing works out
            // make sure it is not one of the prevented directions
            var dir = 'right';
            if (base.options.preventRight)
                dir = 'bottom';
            if (base.options.preventBottom)
                dir = 'top';
            if (base.options.preventTop)
                dir = 'left';

            if (possibleDir.right)
                dir = 'right';
            else if (possibleDir.bottom)
                dir = 'bottom';
            else if (possibleDir.left)
                dir = 'left';
            else if (possibleDir.top)
                dir = 'top';

            return dir;
        }
        
        base.calcPopoverPos = function(trigger) {
            // Set this first for the layout calculations to work.
            $(target).css('display', 'block');

            var coord = {
                popoverDir: 'bottom',
                left: trigger.offset().left,
                top: trigger.offset().top,
                offset: [0, 0],
                triangleX: 0,
                triangleY: 0,
                triangleSize: 20, // needs to be updated if triangle changed in css
                docWidth: $(window).width(),
                docHeight: $(window).height(),
                popoverWidth: $(target).outerWidth(),
                popoverHeight: $(target).outerHeight(),
                buttonWidth: trigger.outerWidth(),
                buttonHeight: trigger.outerHeight()
            }

            // calculate the possible directions based on popover size and trigger position
            var possibleDir = base.calcPopoverDirPossible(trigger, coord);

            // choose selected direction
            coord.popoverDir = base.chooseDir(possibleDir);

            // Calculate popover top
            if (coord.popoverDir == 'bottom')
                coord.top += coord.buttonHeight + coord.triangleSize;
            else if (coord.popoverDir == 'top')
                coord.top -= coord.triangleSize + coord.popoverHeight;
            else // same Y for left & right
                coord.top += (coord.buttonHeight - coord.popoverHeight)/2;

            // Calculate popover left
            if ((coord.popoverDir == 'bottom') || (coord.popoverDir == 'top')) {

                coord.left += (coord.buttonWidth - coord.popoverWidth)/2;

                if (coord.left < base.options.padding) {
                    // out of the document at left
                    coord.offset[0] = coord.left - base.options.padding;
                } else if (coord.left + coord.popoverWidth > coord.docWidth - base.options.padding) {
                    // out of the document right
                    coord.offset[0] = coord.left + coord.popoverWidth - coord.docWidth + base.options.padding;
                }

                // calc triangle pos
                coord.triangleX = coord.popoverWidth/2 - coord.triangleSize + coord.offset[0];
                coord.triangleY = 0;
            } else {    // left or right direction

                if (coord.popoverDir == 'right')
                    coord.left += coord.buttonWidth + coord.triangleSize;
                else // left
                    coord.left -= coord.triangleSize + coord.popoverWidth;

                if (coord.top < base.options.padding) {
                    // out of the document at top
                    coord.offset[1] = coord.top - base.options.padding;
                } else if (coord.top + coord.popoverHeight > coord.docHeight - base.options.padding) {
                    // out of the document bottom
                    coord.offset[1] = coord.top + coord.popoverHeight - coord.docHeight + base.options.padding;
                }

                // calc triangle pos
                coord.triangleX = 0;
                coord.triangleY = coord.popoverHeight/2 - coord.triangleSize + coord.offset[1];
            }

            return coord;
        }

        base.positionPopover = function(coord) {
            // set the triangle class for it's direction
            base.options.triangle$.removeClass("left top right bottom");
            base.options.triangle$.addClass(coord.popoverDir);

            if (coord.triangleX > 0) {
                base.options.triangle$.css('left', coord.triangleX);
            }

            if (coord.triangleY > 0) {
                base.options.triangle$.css('top', coord.triangleY);
            }

            // position popover
            $(target).offset({
                top: coord.top - coord.offset[1] + base.options.offset[1],
                left: coord.left - coord.offset[0] + base.options.offset[0]
            });

            // set popover css and show it
            $(target).show();
        }

        // toggle a popover. If show set to true do not toggle - always show
        base.toggle = function(trigger, show) {
            // if this popover is already open close it and return
            if ($.fn.popover.openedPopup &&
                ($.fn.popover.openedPopup.get(0) === trigger.get(0))) {
                if (!show)
                    $.popover.close();
                return;
            }
            
            base.open(trigger);
        }
        
        // open popover
        base.open = function(trigger) {
            // hide any open popover
            $.popover.close();

            // reset triangle
            base.options.triangle$.attr("style", "");

            // calculate all the coordinates needed for positioning the popover and position it
            base.positionPopover(base.calcPopoverPos(trigger));

            //Timeout for webkit transitions to take effect
            setTimeout(function() {
                $(target).addClass("active");
            }, 0);

            $.fn.popover.openedPopup = trigger;

            base.options.onOpen(trigger);
        }

        // close popover
        base.close = function(trigger) {
            $(target).removeClass("active").attr("style", "").hide();
            $.fn.popover.openedPopup = null;

            base.options.onClose(trigger);
        }
        
        base.getTrigger = function() {
            return base.$el;
        }
        
        base.getPopover = function() {
            return $(target);
        }

        // Run initializer
        base.init();
    };

    // close currently open popover
    $.popover.close = function() {
        if ($.fn.popover.openedPopup != null)
            $.fn.popover.openedPopup.trigger('close.popover');
    }

    $.popover.defaultOptions = {
        offset: [0, 0],
        padding: 18,
        closeOnEsc: true,
        preventLeft: false,
        preventRight: false,
        preventTop: false,
        preventBottom: false,
        
        // Events
        onOpen: function(trigger){},
        onClose: function(trigger){}
    };

    $.fn.popover = function(target, options){
        return this.each(function(){
            (new $.popover(this, target, options));
        });
    };

})(jQuery);