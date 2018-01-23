#!/usr/bin/env ruby

# file: depviz.rb

require 'logger'
require 'pxgraphviz'
require 'xml_to_sliml'
require 'dependency_builder'


class DepViz
  
  class Item
    
    def initialize(s, root: nil, name: name)
      @s, @root, @name = s, root, name
    end
    
    def dependencies()
      
      a = LineTree.new(@s, root: @root).to_doc.root.xpath('//' + @name)
      
      s = a.map {|x| x.backtrack.to_s.split('/')[1..-1]}\
          .map {|x| x.map.with_index {|y,i| '  ' * i + y }.join("\n")}\
          .join("\n")
      
      dv3 = DepViz.new()
      dv3.read s
      dv3
      
    end
    
    def reverse_dependencies()

      a = LineTree.new(@s, root: @root).to_doc.root.xpath('//' + @name)
      
      s = a.select {|x| x.has_elements? }\
          .map{|x| XmlToSliml.new(x).to_s }.join("\n")
      
      dv3 = DepViz.new(root: nil)
      dv3.read s
      dv3
      
    end    
    
  end  

  def initialize(s='', root: 'platform', style: default_stylesheet())
    
    @style, @root = style, root
    @header = "
<?polyrex schema='items[type]/item[label]' delimiter =' # '?>
type: digraph

    "
    
    return if s.empty?
    
    @s = tree = DependencyBuilder.new(s).to_s    
    
    s = root ? (root + "\n" + tree.lines.map {|x| '  ' + x}.join) : tree

    @pxg = PxGraphViz.new(@header + s, style: style)

  end
  
  def item(name)
    
    Item.new @s, root: @root, name: name
    
  end
  
  def read(s)
    
    @s = s
    s2 = @root ? @root + "\n" + s.lines.map {|x| '  ' + x}.join : s
    @pxg = PxGraphViz.new(@header + s2, style: @style)
    
  end

  def to_s()
    @s
  end
  
  def to_svg()
    @pxg.to_svg
  end

  def to_xml()
    LineTree.new(@s, root: @root).to_xml
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