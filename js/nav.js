(function () {
    var nav = document.querySelector('.site-nav');
    var btn = nav && nav.querySelector('.menu-icon');
    var panel = nav && nav.querySelector('.trigger');
    if (!nav || !btn || !panel) return;

    var submenuItems = nav.querySelectorAll('.menu-item--has-submenu');
    var submenuToggles = nav.querySelectorAll('.submenu-toggle');
    var links = nav.querySelectorAll('.trigger a');
    var mobileQuery = window.matchMedia ? window.matchMedia('(max-width: 600px)') : null;

    function isMobileView() {
        return mobileQuery ? mobileQuery.matches : window.innerWidth <= 600;
    }

    function setMenuState(open) {
        nav.classList.toggle('is-open', open);
        btn.setAttribute('aria-expanded', open ? 'true' : 'false');
        btn.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');

        if (isMobileView()) {
            panel.setAttribute('aria-hidden', open ? 'false' : 'true');
        } else {
            panel.removeAttribute('aria-hidden');
        }
    }

    function setSubmenuState(item, open) {
        var toggle = item.querySelector('.submenu-toggle');
        var submenu = item.querySelector('.sub-menu');
        var label = toggle && toggle.getAttribute('data-submenu-label');

        if (!toggle || !submenu) return;

        item.classList.toggle('is-submenu-open', open);
        toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        toggle.setAttribute('aria-label', (open ? 'Collapse ' : 'Expand ') + label + ' submenu');

        if (isMobileView()) {
            submenu.setAttribute('aria-hidden', open ? 'false' : 'true');
        } else {
            submenu.removeAttribute('aria-hidden');
        }
    }

    function closeAllSubmenus() {
        Array.prototype.forEach.call(submenuItems, function (item) {
            setSubmenuState(item, false);
        });
    }

    function close(options) {
        setMenuState(false);
        closeAllSubmenus();

        if (options && options.focusButton) {
            btn.focus();
        }
    }

    btn.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();

        if (!isMobileView()) return;

        var open = !nav.classList.contains('is-open');
        setMenuState(open);

        if (!open) {
            closeAllSubmenus();
        }
    });

    Array.prototype.forEach.call(links, function (link) {
        link.addEventListener('click', function () {
            close();
        });
    });

    Array.prototype.forEach.call(submenuToggles, function (toggle) {
        toggle.addEventListener('click', function (e) {
            var item = toggle.parentNode;
            var open;

            e.preventDefault();
            e.stopPropagation();

            if (!isMobileView()) return;

            open = !item.classList.contains('is-submenu-open');

            Array.prototype.forEach.call(submenuItems, function (otherItem) {
                if (otherItem !== item) {
                    setSubmenuState(otherItem, false);
                }
            });

            setSubmenuState(item, open);
        });
    });

    document.addEventListener('click', function (e) {
        if (nav.classList.contains('is-open') && !nav.contains(e.target)) {
            close();
        }
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && nav.classList.contains('is-open')) {
            close({ focusButton: true });
        }
    });

    function syncForViewport() {
        if (!isMobileView()) {
            close();
        }
    }

    if (mobileQuery) {
        if (mobileQuery.addEventListener) {
            mobileQuery.addEventListener('change', syncForViewport);
        } else if (mobileQuery.addListener) {
            mobileQuery.addListener(syncForViewport);
        }
    }

    setMenuState(false);
    closeAllSubmenus();
})();
