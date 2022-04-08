async function pulse_circles() {
  const svg = document.querySelector('svg');

  const container = document.getElementsByClassName('outline-text-2')[0];
  container.style.display = 'inline-block';
  container.style.position = 'relative';
  container.style.width = '100%';
  // container.style.paddingBottom = '100%';
  container.style.verticalAlign = 'top';
  container.style.overflow = 'hidden';

  container.addEventListener("change", () => {
    const { width, height } = container.getBoundingClientRect();
    svg.setAttribute('viewBox', "0 0 " + width + " " + height);
  });

  const ARRAY_LENGTH = 50
  const POSSIBLE_COLORS = ['#9bb0ff', '#aabfff', '#cad7ff', '#f8f7ff', '#fff4ea', '#ffd2a1', '#ffcc6f']
  Array.prototype.sample = function() {
    return this[Math.floor(Math.random()*this.length)];
  }
  const circle_data = Array.from(Array(ARRAY_LENGTH)).map(() => ({
    'x': (Math.random() * 100),
    'y': (Math.random() * 50),
    'fill': POSSIBLE_COLORS.sample(),
  }))
  while (true) {
    await d3.select(".circles")
            .selectAll('circle')
            .data(circle_data)
            .join("circle")
            .attr("r", () => Math.random() * 0.25 + 0.125)
            .attr("cx", d => d['x'])
            .attr("cy", d => d['y'])
            .style('fill', d => d['fill'])
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
