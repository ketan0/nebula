// code to setup tippy.js tooltips
function setupTooltips() {
    // hacky CSS for now to only match internal links, and not the homepage
    const links = document.querySelectorAll('a:not([href^="http"],[href="/"])');
    var parser = new DOMParser();
    for (let link of links) {
        // when hover over a link, fetch its preview
        link.addEventListener('mouseover', async (event) => {
            if (event.target._tippy) {
                return;
            }
            const response = await fetch(event.target.getAttribute('href'));
            const htmlText = await response.text();
            var htmlDoc = parser.parseFromString(htmlText, 'text/html');
            const content = htmlDoc.getElementById('content').innerHTML;
            const instance = tippy(event.target, {
                                       allowHTML: true,
                                       interactive: true,
                                       touch: ['hold', 500],
                                       maxWidth: '30rem',
                                       inlinePositioning: false,
                                       placement: 'auto',
                                       theme: 'light-border',
                                   });
            instance.setContent(content);
            instance.show();
        })
    }
}

setupTooltips();
