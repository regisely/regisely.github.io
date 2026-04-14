(function () {
    var STORAGE_KEY = 'preferred-lang';
    var SUPPORTED = ['en', 'pt'];
    var LANDING_PATHS = ['/', '/pt/'];

    var links = document.querySelectorAll('.lang-switcher__link');
    Array.prototype.forEach.call(links, function (a) {
        a.addEventListener('click', function () {
            try { localStorage.setItem(STORAGE_KEY, a.dataset.lang); } catch (_) {}
        });
    });

    if (LANDING_PATHS.indexOf(window.location.pathname) === -1) return;

    var stored = null;
    try { stored = localStorage.getItem(STORAGE_KEY); } catch (_) {}
    if (stored) return;

    var browser = (navigator.language || navigator.userLanguage || 'en').toLowerCase();
    var preferred = browser.indexOf('pt') === 0 ? 'pt' : 'en';
    var currentLang = document.documentElement.lang || 'en';

    if (preferred === currentLang || SUPPORTED.indexOf(preferred) === -1) return;

    try { localStorage.setItem(STORAGE_KEY, preferred); } catch (_) {}
    window.location.replace(preferred === 'pt' ? '/pt/' : '/');
})();
