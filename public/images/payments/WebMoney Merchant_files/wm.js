/**
 * syncHeight - jQuery plugin to automagically Sync the heights of columns
 * Made to seemlessly work with the CCS-Framework YAML (yaml.de)
 * @requires jQuery v1.0.3 or newer
 *
 * http://blog.ginader.de/dev/syncheight/
 *
 * Copyright (c) 2007-2013
 * Dirk Ginader (ginader.de)
 * Dirk Jesse (yaml.de)
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * Version: 1.5
 *
 * Changelog
 * * v1.5 fixes issue with box-sizing: border-box
 * * v1.4: new Method unSyncHeight() that removes previously added syncs i.e. for responsive layouts
 * * v1.3: compatibility fix for jQuery 1.9.x (removed $.browser)
 *
 * Usage sync:
  $(window).load(function(){
    $('p').syncHeight();
  });
 * Usage unsync: 
  $(window).resize(function(){
    if($(window).width() < 500){
      $('p').unSyncHeight();
    }
  });
 */

(function ($) {
    var getHeightProperty = function () {
        var browser_id = 0;
        var property = [
          // To avoid content overflow in synchronised boxes on font scaling, we
          // use 'min-height' property for modern browsers ...
          ['min-height', '0px'],
          // and 'height' property for Internet Explorer.
          ['height', '1%']
        ];

        var bMatch = /(msie) ([\w.]+)/.exec(navigator.userAgent.toLowerCase()) || [],
          browser = bMatch[1] || "",
          browserVersion = bMatch[2] || "0";

        // check for IE6 ...
        if (browser === 'msie' && browserVersion < 7) {
            browser_id = 1;
        }

        return {
            'name': property[browser_id][0],
            'autoheightVal': property[browser_id][1]
        };
    };

    $.getSyncedHeight = function (selector) {
        var max = 0;
        var heightProperty = getHeightProperty();
        // get maximum element height ...
        $(selector).each(function () {
            // fallback to auto height before height check ...
            $(this).css(heightProperty.name, heightProperty.autoheightVal);
            var val = parseInt($(this).css('height'), 10);
            if (val > max) {
                max = val;
            }
        });
        return max;
    };

    $.fn.syncHeight = function (config) {
        var defaults = {
            updateOnResize: false,  // re-sync element heights after a browser resize event (useful in flexible layouts)
            height: false
        };

        var options = $.extend(defaults, config);
        var e = this;
        var max = 0;
        var heightPropertyName = getHeightProperty().name;

        if (typeof (options.height) === "number") {
            max = options.height;
        } else {
            max = $.getSyncedHeight(this);
        }

        // set synchronized element height ...
        $(this).each(function () {
            $(this).css(heightPropertyName, max + 'px');
        });

        // optional sync refresh on resize event ...
        if (options.updateOnResize === true) {
            $(window).bind('resize.syncHeight', function () {
                $(e).syncHeight();
            });
        }
        return this;
    };

    $.fn.unSyncHeight = function () {
        // unbind optional resize event ...
        $(window).unbind('resize.syncHeight');

        var heightPropertyName = getHeightProperty().name;
        $(this).each(function () {
            $(this).css(heightPropertyName, '');
        });
    };
})(jQuery);

/*
 * Simple Placeholder by @marcgg under MIT License
 * Report bugs or contribute on Gihub: https://github.com/marcgg/Simple-Placeholder
*/

(function ($) {
    $.simplePlaceholder = {
        placeholderClass: null,

        hidePlaceholder: function () {
            var $this = $(this);
            if ($this.val() == $this.attr('placeholder') && $this.data($.simplePlaceholder.placeholderData)) {
                $this
                  .val("")
                  .removeClass($.simplePlaceholder.placeholderClass)
                  .data($.simplePlaceholder.placeholderData, false);
            }
        },

        showPlaceholder: function () {
            var $this = $(this);
            if ($this.val() == "") {
                $this
                  .val($this.attr('placeholder'))
                  .addClass($.simplePlaceholder.placeholderClass)
                  .data($.simplePlaceholder.placeholderData, true);
            }
        },

        preventPlaceholderSubmit: function () {
            $(this).find(".simple-placeholder").each(function (e) {
                var $this = $(this);
                if ($this.val() == $this.attr('placeholder') && $this.data($.simplePlaceholder.placeholderData)) {
                    $this.val('');
                }
            });
            return true;
        }
    };

    $.fn.simplePlaceholder = function (options) {
        if (document.createElement('input').placeholder == undefined) {
            var config = {
                placeholderClass: 'placeholding',
                placeholderData: 'simplePlaceholder.placeholding'
            };

            if (options) $.extend(config, options);
            $.extend($.simplePlaceholder, config);

            this.each(function () {
                var $this = $(this);
                $this.focus($.simplePlaceholder.hidePlaceholder);
                $this.blur($.simplePlaceholder.showPlaceholder);
                $this.data($.simplePlaceholder.placeholderData, false);
                if ($this.val() == '') {
                    $this.val($this.attr("placeholder"));
                    $this.addClass($.simplePlaceholder.placeholderClass);
                    $this.data($.simplePlaceholder.placeholderData, true);
                }
                $this.addClass("simple-placeholder");
                $(this.form).submit($.simplePlaceholder.preventPlaceholderSubmit);
            });
        }

        return this;
    };

})(jQuery);

/*!
    jQuery scrollTopTop v1.0 - 2013-03-15
    (c) 2013 Yang Zhao - geniuscarrier.com
    license: http://www.opensource.org/licenses/mit-license.php
*/
(function ($) {
    $.fn.scrollToTop = function (options) {
        var config = {
            "speed": 800
        };

        if (options) {
            $.extend(config, {
                "speed": options
            });
        }

        return this.each(function () {

            var $this = $(this);

            $(window).scroll(function () {
                if ($(this).scrollTop() > 100) {
                    $this.fadeIn();
                } else {
                    $this.fadeOut();
                }
            });

            $this.click(function (e) {
                e.preventDefault();
                $("body, html").animate({
                    scrollTop: 0
                }, config.speed);
            });

        });
    };
})(jQuery);

/*
 * Jquery Spoiler Control (Iskander)
*/

/*
 * Jquery Spoiler Control (Iskander)
*/

$(document).ready(function () {
    $('.spoiler_links').click(function () {
        if ($(this).parent().find('div.spoiler_body').css("display") == "none") {
            //$(this).parent().find('a.spoiler_links').addClass('spoiler_links_opened');
            $(this).parent().find('div.spoiler_body').hide('normal');
            $(this).parent().find('div.spoiler_body').slideToggle('normal');
            //$(this).parent().find('a.spoiler_links').text('Скрыть');
            $(this).parent().find('a.spoiler_links_show').css('display', 'none');
            $(this).parent().find('a.spoiler_links_hide').css('display', 'inline');
        }
        else {
            //$(this).parent().find('a.spoiler_links').removeClass('spoiler_links_opened');
            $(this).parent().find('div.spoiler_body').hide('normal');
            //$(this).parent().find('a.spoiler_links').text('Показать');
            $(this).parent().find('a.spoiler_links_show').css('display', 'inline');
            $(this).parent().find('a.spoiler_links_hide').css('display', 'none');
        }
        ///
        return false;
    });
});

/* custom js */

$(document).ready(function () {
    $("div.content, div.content-table").on({
        mouseenter: function () {
            $(this).addClass("hovered");
        },
        mouseleave: function () {
            $(this).removeClass("hovered");
        }
    }, "table tbody tr");

	$('input:text[placeholder]').simplePlaceholder();

	$(function () {
	    $("a.scroll-to-top").scrollToTop();
	});

});

$(document).on("click", 'div.deal-clicked', function (e) {
	var $ths = $(this);
	$ths.removeClass('deal-clicked').addClass('deal-opened');
});

$(document).on("click", 'span.deal-toggler', function (e) {
	e.stopPropagation();
	var $ths = $(this).parent();
		$ths.addClass('deal-clicked').removeClass('deal-opened');
});

$(document).on("hover", '[rel="formHelper"]', function (e) {
	var ths = $(this);
	var posX = ths.offset().left + 20,
		posY = ths.offset().top + -5;
		ths.children('span').css({ left: posX, top: posY });
});

$(document).on("click", '[rel="toggle-actions"]', function(e) {
	e.stopPropagation();
	var $this = $(this);
	var $nohref = $this.children('a').eq(0);
	$('[rel="toggle-actions"]').not($this).removeClass('actions-opened');
	$nohref.removeAttr('href');

	if ( $this.hasClass('actions-opened') ) {
		$this.removeClass('actions-opened');
	} else {
		$this.addClass('actions-opened');
	}
});

$(document).click(function() {
	$('.actions-opened').removeClass('actions-opened');
});


$(document).click(function () {
    $('.submenu-opened').removeClass('submenu-opened');
});
