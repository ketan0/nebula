async function setupTooltips() {
    // hacky CSS for now to only match internal links, and not the homepage
    const links = document.querySelectorAll('a:not([href^="http"],[href="/"])');
    var parser = new DOMParser();
    for (let link of links) {
        const { data } = await axios.get(link.getAttribute('href'));
        var htmlDoc = parser.parseFromString(data, 'text/html');
        const content = htmlDoc.getElementById('content').innerHTML;
        // const title = htmlDoc.getElementsByClassName('title')[0].outerHTML;
        // const descList = Array.from(htmlDoc.querySelectorAll('div#content > p'));
        // const desc = descList.reduce((acc, curr) => acc + curr.outerHTML, '');
        // link.setAttribute('data-tippy-content', title + desc)
        link.setAttribute('data-tippy-content', content)
    }

    tippy('[data-tippy-content]', {
        allowHTML: true,
        interactive: true,
        // trigger: 'click',
        // hideOnClick: false,
        maxWidth: '30rem',
        touch: false,
        delay: 100,
        // appendTo: document.body,
        popperOptions: {
            strategy: 'fixed',
            modifiers: [
                {
                    name: 'preventOverflow',
                    options: {
                        // padding: { top: 64 },
                        // mainAxis: true,
                        altAxis: true,
                    },
                },
                // {
                //     name: 'flip',
                //     options: {
                //         padding: { top: 600 },
                //         fallbackPlacements: ['bottom', 'right']
                //     }
                // },
            ],
        },
    });
}

setupTooltips();
