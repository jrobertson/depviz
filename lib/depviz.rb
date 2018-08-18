#!/usr/bin/env ruby

# file: depviz.rb

require 'logger'
require 'pxgraphviz'
require 'xml_to_sliml'
require 'dependency_builder'


class DepViz
  
  class Item
    
    def initialize(s, root: nil, name: name, debug: false)
      @s, @root, @name, @debug = s, root, name, debug
    end
    
    def dependencies()
      
      if @debug then
        puts 'inside DepViz::Item::dependencies'
        puts '@s: ' + @s.inspect
        puts '@root: ' + @root.inspect
      end
      
      a = LineTree.new(@s).to_doc.root.xpath('//' + @name)
      puts 'dep: a: ' + a.inspect if @debug
      
      a2 = a.map do |x|
        puts '  dependencies x: ' + x.inspect if @debug
        x.backtrack.to_s.split('/')[1..-1]
      end
      puts 'a2: ' + a2.inspect if @debug
      
      s = a2.map {|x| x.map.with_index {|y,i| '  ' * i + y }.join("\n")}\
          .join("\n")
      puts 'child s: ' + s.inspect if @debug

      dv3 = DepViz.new()
      dv3.read s
      dv3
      
    end
    
    def reverse_dependencies()

      a = LineTree.new(@s, root: @root).to_doc.root.xpath('//' + @name)

      s = a.select {|x| x.has_elements? }\
          .map{|x| XmlToSliml.new(x).to_s }.join("\n")

      return if s.empty?
      
      dv3 = DepViz.new(root: nil)
      dv3.read s
      dv3
      
    end    
    
  end  

  def initialize(s='', root: 'platform', style: default_stylesheet(), debug: false)
    
    @style, @root, @debug = style, root, debug
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
    
    puts 'inside DepViz::item for ' + name.inspect if @debug
    puts '_@s : ' + @s.inspect if @debug
    Item.new @s, root: @root, name: name, debug: @debug
    
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
