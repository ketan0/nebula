// TODO: link force + draw links between connected nodes
async function homePageGraphAnimation() {
  if (location.pathname !== '/start.html') return;
  // that way the <a>'s are positioned absolutely, relative to the parent
  // https://css-tricks.com/absolute-positioning-inside-relative-positioning/
  const container = d3.select('.outline-text-2')
                      .style('position', 'relative');
  const containerRect = container.node().getBoundingClientRect();
  // select <a> nodes, get their x/y coords
  const selection = d3.selectAll('a:not([href^="http"],[href="/"]), #ketan-headshot')

  const nodesData = selection.nodes().map(n => {
    const rect = n.getBoundingClientRect()
    return {
      id: n.id || n.href,
      width: rect.width,
      height: rect.height,
      x: rect.x,
      y: rect.y
    }
  });
  console.log(nodesData)
  const linksData = nodesData.filter(n => n.id !== 'ketan-headshot')
                             .map(n => ({
                               source: 'ketan-headshot',
                               target: n.id
                             }))
  const link = d3.select('.links')
                 .attr("stroke", '#999')
                 .attr("stroke-opacity", '0.6')
                 .attr("stroke-width", '0.5')
                 .attr("stroke-linecap", 'round')
                 .selectAll("line")
                 .data(linksData)
                 .join("line");
  console.log(linksData)
  // convert to absolute position
  await selection.style('position', 'absolute')
                 .transition()
                 .duration(1000)
                 .style('left', '50%')
                 .style('top', '50%')
                 .end();

  // start a d3 force simulation where the x/y coords are updated on tick
  const updateSelection = selection.data(nodesData);
  const simulation = d3.forceSimulation(nodesData)
    .force('center', d3.forceCenter(50, 50))
    .force('link', d3.forceLink(linksData).id(n => n.id))
    .force('collide', d3.forceCollide(10))
    .force('charge', d3.forceManyBody())
    .on('tick', function () {
      // const containerRect = container.node().getBoundingClientRect();
      // console.log(`container width: ${containerRect.width} height: ${containerRect.height}`)
      updateSelection
        .style('left', d => {
          // if (d.id === 'ketan-headshot') {
          //   console.log(`d width: ${d.width}`)
          //   console.log(`container width: ${containerRect.width}`)
          //   console.log(`d width pct: ${d.width / containerRect.width}`)
          // }
          return `${d.x}%`;
        }).style('top', d => {
          // if (d.id === 'ketan-headshot') {
          //   console.log(`d height: ${d.height}`)
          //   console.log(`container height: ${containerRect.height}`)
          //   console.log(`d height pct: ${d.height / containerRect.height}`)
          // }
          return `${d.y}%`
        });
      link
        .attr("x1", d => {
          return `${d.source.x}`})
        .attr("y1", d => `${d.source.y}`)
        .attr("x2", d => `${d.target.x}`)
        .attr("y2", d => `${d.target.y}`);
    });

  function drag(simulation) {
    function dragstarted(event) {
      if (!event.active) simulation.alphaTarget(0.3).restart();
      // const containerRect = container.node().getBoundingClientRect();
      const headshot = document.getElementById('ketan-headshot')
      const d = headshot.getBoundingClientRect()
      // console.log(`old x: ${d.x}`)
      // console.log(`mouse x: ${event.x}`)
      // event.subject.fx = (event.x - containerRect.x) / containerRect.width * 100;
      // event.subject.fy = (event.y - containerRect.y) / containerRect.height * 100;
      event.subject.fx = event.subject.x
      event.subject.fy = event.subject.y
      // console.log(`new x: ${event.subject.fx}`)
    }

    function dragged(event) {
      // event.subject.fx = (event.x - containerRect.x) / containerRect.width * 100;
      // event.subject.fy = (event.y - containerRect.y) / containerRect.height * 100;
      const headshot = document.getElementById('ketan-headshot')
      const h = headshot.getBoundingClientRect()
      console.log(`old x: ${(h.x - containerRect.x)  / containerRect.width * 100}`)
      console.log(`mouse x: ${event.x}`)
      // event.subject.fx = (event.x - containerRect.x) / containerRect.width * 100
      // event.subject.fy = (event.y - containerRect.y) / containerRect.height * 100
      event.subject.fx = (event.x + containerRect.x + h.width) / containerRect.width * 100
      event.subject.fy = (event.y + containerRect.y + h.height) / containerRect.height * 100
      // console.log(`new x: ${event.subject.fx}`)
      // console.log(`new y: ${event.subject.fy}`)
    }

    function dragended(event) {
      if (!event.active) simulation.alphaTarget(0);
      event.subject.fx = null;
      event.subject.fy = null;
    }

    return d3.drag()
             .container(container.node())
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
