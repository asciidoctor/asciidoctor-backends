#
# File: tex-converter.rb
# Author: J. Carlson (jxxcarlson@gmail.com)
# Date: 9/26/2014
#
# This is a first step towards writing a LaTeX backend
# for Asciidoctor. It is based on the 
# Dan Allen's demo-converter.rb and differs
# from it only in the redefinition of the
# methods "document node" and "section node"
#
# Usage: 
#
#   $ asciidoctor -r ./tex-converter.rb -b latex sample1.ad -o sample1.tex
#
# Comments
#
#   1.  The "warn" clause in the converter code is quite useful.  
#       For example, you will discover in running the converter on 
#       "sample-1.ad" that you have not implemented code for 
#       the "olist" node. Thus you can work through ever more complex 
#       examples to discover what you need to do to increase the coverage
#       of the converter. Hackish and ad hoc, but a process nonetheless.
#
#   2.  The converter simply passes on what it does not understand, e.g.,
#       LaTeX, This is good. However, we will have to map constructs
#       like"+\( a^2 = b^2 \)+" to $ a^2 + b^2 $, etc.
#       This can be done at the preprocessor level.
#
#   3.  In view of the preceding, we may need to chain a frontend
#       (preprocessor) to the backend. In any case, the main work 
#       is in transforming Asciidoc elements to TeX elements.
#       Other than the asciidoc ->  tex mapping, the tex-converter 
#       does not need to understand tex.
#
#   4.  Included in this repo is the file "sample1.ad"
#
#
#  CURRENT STATUS
#
#  The following constructs are processed
#
#  - sections to a depth of five, e.g., == foo, === foobar, etc.
#  - ordered and unordered lists, thugh nestings is untested and
#    likely does not work.
#  - *bold* and _italic_
#


require 'asciidoctor'

class LaTeXConverter
  include Asciidoctor::Converter
  register_for 'latex'

  def convert node, transform = nil
    transform ||= node.node_name
    if respond_to? transform
      send transform, node
    else
      warn %(\e[1;34mNode to implement: \e[1;31m#{transform}\e[0m)
    end
  end

  def document node
    node.content
  end

  def section node
    space = " "*2*(node.level-1)
    puts "Node level #{node.level}: #{space}#{node.title}"
    case node.level
    when 1
       "\\section\{#{node.title}\}\n\n#{node.content}\n\n"
     when 2
       "\\subsection\{#{node.title}\}\n\n#{node.content}\n\n"
     when 3
       "\\subsubsection\{#{node.title}\}\n\n#{node.content}\n\n"
     when 4
       "\\paragraph\{#{node.title}\}\n\n#{node.content}\n\n"
     when 5
       "\\subparagraph\{#{node.title}\}\n\n#{node.content}\n\n"
     end
  end

  def paragraph node
    # node.content.tr("\n", ' ') << "\n"
    node.content << "\n\n"
  end
  
  def ulist node
    puts "Node: \e[1;31mulist, #{node.content.count} items\e[0m"
   
    list = "\\begin{itemize}\n\n"
    node.content.each do |item|
      puts "item: #{item.text}"
      list << "\\item #{item.text}\n\n"
    end
    list << "\\end{itemize}\n\n"     
  end
  
  def olist node
    puts "Node: \e[1;31molist, #{node.content.count} items\e[0m"
   
    list = "\\begin{enumerate}\n\n"
    node.content.each do |item|
      puts "item: #{item.text}"
      list << "\\item #{item.text}\n\n"
    end
    list << "\\end{enumerate}\n\n"     
  end
  
  def inline_quoted node
    puts "Node, inline quoted, type[#{node.type}]: \e[1;31m#{node.text}\e[0m"
    case node.type
    when :strong
      "\\textbf\{#{node.text}\}"
    when :emphasis
      "\\emph\{#{node.text}\}"
    else
      "\\unknown\\{#{node.text}\\}"
    end   
  end
  
  
end

