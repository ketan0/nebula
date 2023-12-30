// TODO: link force + draw links between connected nodes
async function homePageGraphAnimation() {
  if (location.pathname !== '/start' &&
      location.pathname !== '/start.html') {
    return;
  }
  // that way the <a>'s are positioned absolutely, relative to the parent
  // https://css-tricks.com/absolute-positioning-inside-relative-positioning/
  const container = d3.select('div[class^=\'outline-text\']')
                .style('position', 'relative');
  // select <a> nodes, get their x/y coords
  const selection = d3.selectAll('a:not([href^="http"],[href="/"],[href="/start.html"])')

  // convert to absolute position
  await selection.transition()
                 .duration(1000)
                 .style('background-color', 'rgba(107, 114, 128, 0.20)')
                 .style('border-radius', '5px')
                 .style('padding', '2px')
                 .style('position', 'absolute')
                 .end();

  // start a d3 force simulation where the x/y coords are updated on tick
  const nodes = selection.nodes().map(n => n.getBoundingClientRect())
  const updateSelection = selection.data(nodes);
  let containerRect = container.node().getBoundingClientRect();
  const simulation = d3.forceSimulation(nodes)
    .force('x', d3.forceX(50))
    .force('y', d3.forceY(50).strength(0.2))
    .force('collide', d3.forceCollide().radius(d => d.width / containerRect.width / 2 * 100 + 1))
    .force('charge', d3.forceManyBody().strength(-20))
    .on('tick', function () {
      containerRect = container.node().getBoundingClientRect();
      updateSelection
        .style('left', d => {
          return `${d.x - (d.width / containerRect.width) / 2 * 100}%`;
        }).style('top', d => {
          return `${d.y - (d.height / containerRect.height) / 2 * 100}%`
        });
    });

  function drag(simulation) {
    function dragstarted(event) {
      if (!event.active) simulation.alphaTarget(0.5).restart();
      const x = (event.sourceEvent.clientX - containerRect.x) / containerRect.width * 100;
      const y = (event.sourceEvent.clientY - containerRect.y) / containerRect.height * 100;
      event.subject.fx = x;
      event.subject.fy = y;
    }

    function dragged(event) {
      const containerRect = container.node().getBoundingClientRect();
      const x = (event.sourceEvent.clientX - containerRect.x) / containerRect.width * 100;
      const y = (event.sourceEvent.clientY - containerRect.y) / containerRect.height * 100;
      event.subject.fx = x;
      event.subject.fy = y;
    }

    function dragended(event) {
      if (!event.active) simulation.alphaTarget(0);
      event.subject.fx = null;
      event.subject.fy = null;
    }

    return d3.drag()
             .on("start", dragstarted)
             .on("drag", dragged)
             .on("end", dragended);
  };
  updateSelection.call(drag(simulation));
  window.onresize = (event) => {
    if (!event.active) {
      console.log('resizing');
      simulation.alphaTarget(0.5).restart();
    }
  }
}

homePageGraphAnimation();
