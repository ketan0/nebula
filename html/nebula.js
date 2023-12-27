async function pulse_circles() {
  if (location.pathname !== '/start' &&
      location.pathname !== '/start.html') {
    return;
  }

  const svg = document.querySelector('svg');

  const container = document.getElementsByClassName('svg-container')[0];

  let { width, height } = container.getBoundingClientRect();
  svg.setAttribute('viewBox', "0 0 " + width + " " + height);
  svg.setAttribute('width', width);
  svg.setAttribute('height', height);

  const resizeObserver = new ResizeObserver(entries => {
    for (let entry of entries) {
      width = entry.contentRect.width;
      height = entry.contentRect.height;
      svg.setAttribute('viewBox', "0 0 " + width + " " + height);
      svg.setAttribute('width', width);
      svg.setAttribute('height', height);
    }
  });

  // Start observing the container
  resizeObserver.observe(container);

  const ARRAY_LENGTH = 50
  const POSSIBLE_COLORS = ['#9bb0ff', '#aabfff', '#cad7ff', '#f8f7ff', '#fff4ea', '#ffd2a1', '#ffcc6f']
  Array.prototype.sample = function() {
    return this[Math.floor(Math.random()*this.length)];
  }
  while (true) {
    const circle_data = Array.from(Array(ARRAY_LENGTH)).map(() => ({
      x: (Math.random() * 100),
      y: (Math.random() * 100),
      r: (Math.random() * 0.25 + 0.125),
      fill: POSSIBLE_COLORS.sample(),
    }))
    await d3.select(".circles")
            .selectAll('circle')
            .data(circle_data)
            .join("circle")
            .attr("r", d => `${d.r}%`)
            .attr("cx", d => `${d.x}%`)
            .attr("cy", d => `${d.y}%`)
            .style('fill', d => d.fill)
            .attr("opacity", 0)
            .transition()
            .duration(250)
            .delay((_, i) => i * 250)
            .attr("opacity", 1)
            .end();
    await d3.selectAll("circle").transition()
            .duration(750)
            .delay((_, i) => (circle_data.length - i) * 250)
            .attr("opacity", 0)
            .end();
  }
}

pulse_circles();
