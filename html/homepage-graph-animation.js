// TODO: link force + draw links between connected nodes
async function homePageGraphAnimation() {
  // select <a> nodes, get their x/y coords
  d3.select('#text-org45f9e30')
    .style('position', 'relative');
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
    return { x: boundingRect.x, y: boundingRect.y}
  });
  const updateSelection = selection.data(nodes);
  d3.forceSimulation(nodes)
    .force('x', d3.forceX(320))
    .force('y', d3.forceY(150).strength(0.2))
    .force('collide', d3.forceCollide(13))
    .force('charge', d3.forceManyBody().strength(-600))
    .on('tick', function () {
      updateSelection
        .style('left', d => {
          return `${d.x}px`;
        }).style('top', d => {
          return `${d.y}px`
        });
    })
}

homePageGraphAnimation();
