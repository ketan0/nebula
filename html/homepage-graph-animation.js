// TODO: link force + draw links between connected nodes
async function homePageGraphAnimation() {
  // that way the <a>'s are positioned absolutely, relative to the parent
  // https://css-tricks.com/absolute-positioning-inside-relative-positioning/
  container = d3.select('div[class^=\'outline-text\']')
                .style('position', 'relative');
  // select <a> nodes, get their x/y coords
  const selection = d3.selectAll('a:not([href^="http"],[href="/"])')

  // convert to absolute position
  await selection.transition()
                 .duration(1000)
                 .style('background-color', 'rgba(107, 114, 128, 0.05)')
                 .style('border-radius', '5px')
                 .style('padding', '2px')
                 .style('position', 'absolute')
                 .end();


  // start a d3 force simulation where the x/y coords are updated on tick
  const nodes = selection.nodes().map(n => {
    const boundingRect = n.getBoundingClientRect()
    return boundingRect
  });
  const updateSelection = selection.data(nodes);
  const simulation = d3.forceSimulation(nodes)
    .force('x', d3.forceX(50))
    .force('y', d3.forceY(50).strength(0.2))
    .force('collide', d3.forceCollide(10))
    .force('charge', d3.forceManyBody().strength(-1))
    .on('tick', function () {
      containerRect = container.node().getBoundingClientRect();
      // console.log(`container width: ${containerRect.width} height: ${containerRect.height}`)
      updateSelection
        .style('left', d => {
          // console.log(`d width pct: ${d.width / containerRect.width}`)
          return `${d.x - (d.width / containerRect.width) / 2 * 100}%`;
        }).style('top', d => {
          // console.log(`d height: ${d.height}`)
          return `${d.y - (d.height / containerRect.height) / 2 * 100}%`
        });
    });

  function drag(simulation) {
    function dragstarted(event) {
      if (!event.active) simulation.alphaTarget(0.5).restart();
      event.subject.fx = event.subject.x;
      event.subject.fy = event.subject.y;
    }

    function dragged(event) {
      event.subject.fx = event.x;
      event.subject.fy = event.y;
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
      simulation.alphaTarget(0.3).restart();
    }
  }
}

homePageGraphAnimation();
