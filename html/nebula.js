// function randn_bm() {
//   var u = 0, v = 0;
//   while(u === 0) u = Math.random(); //Converting [0,1) to (0,1)
//   while(v === 0) v = Math.random();
//   return Math.sqrt( -2.0 * Math.log( u ) ) * Math.cos( 2.0 * Math.PI * v );
// }

async function pulse_circles() {
  const ARRAY_LENGTH = 50
  const POSSIBLE_COLORS = ['#bb00bb', '#bb0000', '#0000bb']
  const circle_data = Array.from(Array(ARRAY_LENGTH)).map(() => ({
    'x': (Math.random() * 35) + 5,
    'y': (Math.random() * 35) + 5,
    // 'fill': POSSIBLE_COLORS[Math.floor(POSSIBLE_COLORS.length * Math.random())],
    'fill': '#f4edc6',
  }))
  await d3.select(".circles")
    .selectAll('circle')
    .data(circle_data)
    .join("circle")
    .attr("r", 0.25)
    .attr("cx", d => d['x'])
    .attr("cy", d => d['y'])
    // .style('fill', (d, i) => POSSIBLE_COLORS[i % 3])
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
  pulse_circles();
}

pulse_circles();
// while(true) {
//   await new Promise(r => setTimeout(r, 2000));
//   var circles = plot_area.selectAll("circle").data(data);
//   circles.enter()
//          .append("circle")
//          .attr("r", 2)
//          .attr("cx", Math.random() * 200)
//          .attr("cy", Math.random() * 200)
//          .attr("opacity", 0);
//   // .attr("stroke-width", 2);

//   glow(circles);

//   function glow(selection) {
//     selection.transition()
//              .duration(2000)
//              .attr('opacity', 1)
//              .ease('bounce-in')
//              .transition()
//              .duration(2000)
//              .attr('opacity', 0)
//              .ease('sin-in')
//              .remove();

//   }

// }

// function pulsate(selection) {
//   recursive_transitions();

//   function recursive_transitions() {
//     if (selection.data()[0].pulse) {
//       selection.transition()
//                .duration(400)
//                .attr("stroke-width", 2)
//                .attr("r", 8)
//                .ease('sin-in')
//                .transition()
//                .duration(800)
//                .attr('stroke-width', 3)
//                .attr("r", 12)
//                .ease('bounce-in')
//                .each("end", recursive_transitions);
//     } else {
//       // transition back to normal
//       selection.transition()
//                .duration(200)
//                .attr("r", 8)
//                .attr("stroke-width", 2)
//                .attr("stroke-dasharray", "1, 0");
//     }
//   }
// }
