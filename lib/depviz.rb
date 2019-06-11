#!/usr/bin/env ruby

# file: depviz.rb

require 'logger'
require 'pxgraphviz'
require 'xml_to_sliml'
require 'dependency_builder'


module RegGem

  def self.register()
'
hkey_gems
  doctype
    depviz
      require depviz
      class DepViz
      media_type svg
'      
  end
end

class DepViz < PxGraphViz
  using ColouredText
  
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
      
      enclose = ->(a) do
        a.length > 1 ? [a.first] << enclose.call(a[1..-1]) : a
      end
            
      a2 = a.map do |x|
        puts '  dependencies x: ' + x.inspect if @debug
        enclose.call x.backtrack.to_s.split('/')[1..-1]
      end
      
      puts 'a2: ' + a2.inspect if @debug
      
      # group the items in order to merge branches with the same parent
      a3 = a2.group_by(&:first)
      a4 = a3.map {|x| [x.first] + x.last.map(&:last)}      
            
      treeize = ->(obj, indent=-2) do

        if obj.is_a? Array then
          
          r = obj.map {|x| treeize.call(x, indent+1)}.join("\n")
          puts 'r: ' + r.inspect if @debug
          r

        else

          '  ' * indent + obj

        end
      end      
      
      s = treeize.call(a4)
      
      puts 'child s: ' + s.inspect if @debug

      dv3 = DepViz.new()
      dv3.read s
      dv3
      
    end
    
    # returns a DepViz document
    #
    def reverse_dependencies()

      a = LineTree.new(@s, root: @root).to_doc.root.xpath('//' + @name)

      s = a.select {|x| x.has_elements? }\
          .map{|x| XmlToSliml.new(x).to_s }.join("\n")

      return DepViz.new if s.empty?
      
      dv3 = DepViz.new(root: nil)
      dv3.read s
      dv3
      
    end    
    
  end  

  def initialize(s='',  fields: %w(label shape), delimiter: ' # ', 
                 root: 'platform', style: nil, 
                 debug: false, fill: '#ccffcc', stroke: '#999999', 
                 text_color: '#330055')
    
    @style, @root, @debug = style, root, debug
    @header = "
<?polyrex schema='items[type]/item[label]' delimiter =' # '?>
type: digraph

    "
    if s.length > 0 then 
      
      if s =~ /<?depviz / then
          
        raw_dv = s.clone
        s2 = raw_dv.slice!(/<\?depviz [^>]+\?>/)

        # attributes being sought =>  root fields delimiter id
        attributes = Shellwords::shellwords(s).map {|x| key, 
                          value = x.split(/=/, 2); [key.to_sym, value]}.to_h
        
        h = {
          fields: fields.join(', '), 
          delimiter: delimiter
        }.merge attributes          

        s = if h[:root] then
          "\n\n" + h[:root] + "\n" + 
            raw_dv.strip.lines.map {|line| '  ' + line}.join
        else
          raw_dv
        end
        
        delimiter = h[:delimiter]
        fields = h[:fields].split(/ *, */)

      end            
    
      @s = tree = DependencyBuilder.new(s).to_s          
      s3 = @root ? (@root + "\n" + tree.lines.map {|x| '  ' + x}.join) : tree
      @pxg = super(@header + s3, style: @style)      
      
    end
    

  end
  
  def count()
    return 0 unless @s
    child_nodes.length
  end
  
  def item(name)
    
    puts 'inside DepViz::item for ' + name.inspect if @debug
    puts '_@s : ' + @s.inspect if @debug
    Item.new @s, root: @root, name: name, debug: @debug
    
  end
  
  def nodes()
    
    child_nodes.map {|x| x.name}.uniq
    
  end
  
  def read(s)
    
    @s = s
    s2 = @root ? @root + "\n" + s.lines.map {|x| '  ' + x}.join : s
    @pxg = PxGraphViz.new(@header + s2, style: @style)
    
  end
  
  def to_doc()
    Rexle.new(LineTree.new(@s, root: @root).to_xml).root.elements.first
  end

  def to_s()
    @s
  end  

  def to_xml()
    to_doc.xml
  end        

  private
  
  def child_nodes()
    to_doc.root.xpath('//*')
  end

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
