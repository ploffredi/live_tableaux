// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import topbar from "topbar"
import {LiveSocket} from "phoenix_live_view"

let Hooks = {}
Hooks.D3Tree = {
  mounted() {


    this.handleEvent("updateResultTree", (treeData) =>{

                  // set the dimensions and margins of the diagram
                  var margin = {top: 40, right: 0, bottom: 50, left: 0},
                  width = 500 - margin.left - margin.right,
                  height = 500 - margin.top - margin.bottom;

                  // declares a tree layout and assigns the size
                  var treemap = d3.tree()
                  .size([width, height]);

                  //  assigns the data to a hierarchy using parent-child relationships
                  var nodes = d3.hierarchy(treeData);

                  // maps the node data to the tree layout
                  nodes = treemap(nodes);

                  // append the svg object to the element of the page
                  // appends a 'group' element to 'svg'
                  // moves the 'group' element to the top left margin
                  
                  d3.select(".svg-container").remove();


                  var svg = d3.select("#" + this.el.id).append("svg")
                    .attr("class", "svg-container")
                    .attr("width", width + margin.left + margin.right)
                    .attr("height", height + margin.top + margin.bottom),
                  g = svg.append("g")
                    .attr("transform",
                          "translate(" + margin.left + "," + margin.top + ")");

                  // adds the links between the nodes
                  var link = g.selectAll(".link")
                  .data( nodes.descendants().slice(1))
                  .enter().append("path")
                  .attr("class", "link")
                  .attr("d", function(d) {
                    return "M" + d.x + "," + d.y
                      + "C" + d.x + "," + (d.y + d.parent.y) / 2
                      + " " + d.parent.x + "," +  (d.y + d.parent.y) / 2
                      + " " + d.parent.x + "," + d.parent.y;
                    });

                  // adds each node as a group
                  var nodes = g.selectAll(".node")
                  .data(nodes.descendants())
                  .enter().append("g")
                  .attr("class", function(d) {
                    return "node" +
                      (d.children ? " node--internal" : " node--leaf"); })
                  .attr("transform", function(d) {
                    return "translate(" + d.x + "," + d.y + ")"; });

                  // adds the circle to the node
                  nodes.append("circle")
                  .attr("r", 10)
                  .style("fill", function(d) { return d.data.color; });

                  // adds the text to the node
                  nodes.append("text")
                  .attr("dy", ".35em")
                  .attr("y", function(d) { return d.children ? -20 : 20; })
                  .style("text-anchor", "middle")
                  .text(function(d) { return d.data.name; });

    } );
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

