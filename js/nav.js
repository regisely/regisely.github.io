(function () {
    var nav = document.querySelector('.site-nav');
    var btn = nav && nav.querySelector('.menu-icon');
    if (!nav || !btn) return;

    btn.addEventListener('click', function (e) {
        e.preventDefault();
        var open = nav.classList.toggle('is-open');
        btn.setAttribute('aria-expanded', open ? 'true' : 'false');
    });

    var mobileQuery = window.matchMedia('(max-width: 600px)');
    var items = nav.querySelectorAll('.menu-item > .page-link');
    Array.prototype.forEach.call(items, function (link) {
        var li = link.parentElement;
        if (!li.querySelector('.sub-menu')) return;
        link.addEventListener('click', function (e) {
            if (mobileQuery.matches) {
                e.preventDefault();
                li.classList.toggle('is-open');
            }
        });
    });
})();
