(function () {
    var nav = document.querySelector('.site-nav');
    var btn = nav && nav.querySelector('.menu-icon');
    if (!nav || !btn) return;

    function close() {
        nav.classList.remove('is-open');
        btn.setAttribute('aria-expanded', 'false');
    }

    btn.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        var open = nav.classList.toggle('is-open');
        btn.setAttribute('aria-expanded', open ? 'true' : 'false');
    });

    var links = nav.querySelectorAll('.trigger a');
    Array.prototype.forEach.call(links, function (link) {
        link.addEventListener('click', close);
    });

    document.addEventListener('click', function (e) {
        if (nav.classList.contains('is-open') && !nav.contains(e.target)) {
            close();
        }
    });
})();
