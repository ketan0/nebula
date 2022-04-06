async function pulse_circles() {
  const ARRAY_LENGTH = 50
  const POSSIBLE_COLORS = ['#bb00bb', '#bb0000', '#0000bb']
  const circle_data = Array.from(Array(ARRAY_LENGTH)).map(() => ({
    'x': (Math.random() * 35) + 5,
    'y': (Math.random() * 35) + 5,
    // 'fill': POSSIBLE_COLORS[Math.floor(POSSIBLE_COLORS.length * Math.random())],
    'fill': '#f4edc6',
  }))
  while (true) {
    await d3.select(".circles")
            .selectAll('circle')
            .data(circle_data)
            .join("circle")
            .attr("r", 0.25)
            .attr("cx", d => d['x'])
            .attr("cy", d => d['y'])
            .style('fill', d => d['fill'])
            .attr("opacity", 0)
            .transition()
            .duration(1000)
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
