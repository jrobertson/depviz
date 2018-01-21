#!/usr/bin/env ruby

# file: depviz.rb

require 'logger'
require 'pxgraphviz'
require 'dependency_builder'


class DepViz

  def initialize(s, root: 'platform', style: default_stylesheet())

    header = "
<?polyrex schema='items[type]/item[label]' delimiter =' # '?>
type: digraph

    "
    tree = DependencyBuilder.new(s).to_s
    s2 = root + "\n" + tree.lines.map {|x| '  ' + x}.join
    @pxg = PxGraphViz.new(header + s2, style: style)

  end

  def to_svg()
    @pxg.to_svg
  end

  def to_xml()
    @pxg.doc.xml(pretty: true)
  end

  private

  def default_stylesheet()

<<STYLE
  node { 
    color: #ddaa66; 
    fillcolor: #447722;
    fontcolor: #ffeecc; 
    fontname: 'Trebuchet MS';
    fontsize: 10; 
    margin: 0.1;
    penwidth: 1.3; 
    style: filled;
  }
  
  a node {
    color: #0011ee;   
  }

  edge {
    arrowsize: 0.9;
    color: #666; 
    fontcolor: #444444; 
    fontname: Verdana; 
    fontsize: 8; 
    dir: forward;
    weight: 1;
  }
STYLE

  end

end