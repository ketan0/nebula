// code to setup tippy.js tooltips
async function setupTooltips() {
  // hacky CSS for now to only match internal links, and not the homepage
  const links = document.querySelectorAll('a:not([href^="http"],[href="/"],.no-tippy)')
  const parser = new DOMParser()
  for (let link of links) {
    // when hover over a link, fetch its preview
    link.addEventListener('mouseover', async (event) => {
      if (event.target._tippy) { // already loaded the tippy no need to do it again!
        return
      }
      const url = event.target.getAttribute('href')
      const response = await fetch(url)
      const htmlText = await response.text()
      const htmlDoc = parser.parseFromString(htmlText, 'text/html')
      const containers = htmlDoc.querySelectorAll('[id^=outline-container-]')
      containers.forEach(container => {
        const [ , headingId] = container.id.split('outline-container-')
        const heading = container.querySelector(`#${headingId}`)
        // HACK: to make same-page anchor links work properly,
        // need to set the ID's in the tippy to be something different,
        // because the tippy duplicates all the heading ids.
        if (heading) {
          heading.id = 'TIPPY-' + heading.id
        }
      })
      const citeprocItems = htmlDoc.querySelectorAll('[id^=citeproc_bib_item_]')
      citeprocItems.forEach(citeprocItem => {
        citeprocItem.id = 'TIPPY-' + citeprocItem.id
      })
      const content = htmlDoc.getElementById('content').innerHTML
      const [ , id] = url.split('#')
      const instance = tippy(event.target, {
        allowHTML: true,
        interactive: true,
        delay: [250, null],
        touch: ['hold', 250],
        maxWidth: '30rem',
        inlinePositioning: false,
        placement: 'auto',
        theme: 'light-border',
        onMount(instance) { // attempt to scroll to the anchor position
          if (!id) return // URL may not have contained anchor link
          const anchor = document.querySelector(`.tippy-content #TIPPY-${id}`)
          if (anchor) {
            // highlight the background of the selected node
            // TODO: work on this styling / decompose out to CSS variable
            // TODO: setting the parent element's bg doesn't seem super robust
            // (^ this happens to work well for org IDs and citeproc IDs, but...might not generalize)
            anchor.parentElement.style.borderRadius = '2px';
            anchor.parentElement.style.borderWidth = '2px';
            anchor.parentElement.style.borderStyle = 'solid';
            anchor.parentElement.style.borderColor = '#039be5';

            anchor.parentElement.style.borderRadius = '10px';
            const parent = anchor.closest('.tippy-content')
            // scroll the outer container to the top of the desired headline
            // TODO: once again, using the parent element might not be robust
            parent.scrollTop = anchor.parentElement.offsetTop
          }
        },
      })
      tippy.hideAll({ duration: 0 }) // hide other tippys before showing this one
      instance.setContent(content)
      instance.show()
    })
  }
}

setupTooltips()
