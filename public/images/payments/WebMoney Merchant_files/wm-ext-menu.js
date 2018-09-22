;(function(window, document, $, undefined) {
	var renderMenu = function(response, $container) {

		$container.html(response.data);

		if ( {'new.cms.com4s.ru': 1, 'new.webmoney.ru': 1}[window.location.host] ) {
			$container.find('a').each(function() {
				var $this = $(this),
					href = $this.attr('href');

				if (href) {
					$this.attr( 'href', href.replace('://www.webmoney.ru', '://' + window.location.host) );
				}
			});
		}

		var $toggleMenu = $('[rel="toggle-menu"]', $container),
			openedClass = 'submenu-opened';

		$toggleMenu.click(function(e) {
			e.stopPropagation();

			var $this = $(this);

			$toggleMenu.not($this).removeClass(openedClass);

			$this[$this.hasClass(openedClass) ? 'removeClass' : 'addClass'](openedClass);

		});

		$(document).click(function() {
			$('.' + openedClass, $container).removeClass(openedClass);
		});
	};

	$(function() {
		var $container = $('#wm-ext-menu');

		if (!$container.length) {
			return false;
		}

        window.WMExternalMenu = {
            JSONP: {
                callback: function(response) {
				    if (!response) {
					    return;
				    }

				    renderMenu(response, $container);
                }
            }
        };

		$.ajax({
			url: '//assets.webmoney.ru/json/wm-ext-menu_1505209389.json',
			dataType: 'jsonp',
			jsonp: false,
            cache: true
		});
	});

})(window, document, jQuery);
