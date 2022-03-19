var data = [
  {"x": 50, "y": 50, "pulse": false},
  {"x": 150, "y": 50, "pulse": false},
  {"x": 100, "y": 150, "pulse": false}
];

var svg = d3.select("svg")
console.log(svg)
var plot_area = svg
    .append("g")
    .attr("id", "plot-area")
    .attr("transform", "translate(0, 0)");

function randn_bm() {
  var u = 0, v = 0;
  while(u === 0) u = Math.random(); //Converting [0,1) to (0,1)
  while(v === 0) v = Math.random();
  return Math.sqrt( -2.0 * Math.log( u ) ) * Math.cos( 2.0 * Math.PI * v );
}

async function recursive_circles(selection) {
  const circles = plot_area.selectAll("circle").data(data);
  // thinking what I have to do:
  /*
   * Append a circle, transition it to opacity=1, await that
   * Append another circle (recurse; dont await)
   * Transition the old circle out
   */
  const c2 = await circles.enter()
                          .append("circle")
                          .attr("r", 2)
                          .attr("cx", Math.random() * 200)
                          .attr("cy", Math.random() * 200)
                          .attr("opacity", 0)
                          .append("circle")
                          .attr("r", 2)
                          .attr("cx", Math.random() * 200)
                          .attr("cy", Math.random() * 200)
                          .attr("opacity", 0)
                          .transition()
                          .duration(2000)
                          .attr('opacity', 1)
                          .transition()
                          .duration(2000)
                          .attr('opacity', 0)
                          .end();
  const c3 = await circles.enter()
                          .append("circle")
                          .attr("r", 2)
                          .attr("cx", Math.random() * 200)
                          .attr("cy", Math.random() * 200)
                          .attr("opacity", 0)
                          .transition()
                          .duration(2000)
                          .attr('opacity', 1)
                          .transition()
                          .duration(2000)
                          .attr('opacity', 0)
                          .end();
  // c2.transition()
  //   .duration(500)
  //   .attr('opacity', 0);
}

recursive_circles()
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

function pulsate(selection) {
  recursive_transitions();

  function recursive_transitions() {
    if (selection.data()[0].pulse) {
      selection.transition()
               .duration(400)
               .attr("stroke-width", 2)
               .attr("r", 8)
               .ease('sin-in')
               .transition()
               .duration(800)
               .attr('stroke-width', 3)
               .attr("r", 12)
               .ease('bounce-in')
               .each("end", recursive_transitions);
    } else {
      // transition back to normal
      selection.transition()
               .duration(200)
               .attr("r", 8)
               .attr("stroke-width", 2)
               .attr("stroke-dasharray", "1, 0");
    }
  }
}
