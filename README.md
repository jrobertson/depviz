# Introducing the depviz gem

    require 'depviz'


    s = "
    ra0
      sshfs
      apache

    rse
      spspublog
      reg
      apache
      sps

    elis
      ra0

    reg
      sshfs
    "

    File.write 'dependencies.svg', DepViz.new(s).to_svg

The above example reads a string containing branches of disparate dependencies from various local services. The depviz gem generates 1 tree diagram from left to right representing a consolidation of dependencies and outputs it to an SVG file.

Output:

![An example of dependencies in a tree layout](http://www.jamesrobertson.eu/r/svg/2018/jan/21/dependencies.svg)

depviz tree gem pxgraphviz graphviz dependencies
