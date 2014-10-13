require 'htmlbeautifier'

module HtmlBeautifier

  def self.beautify(input)
    input = input.to_html unless input.is_a? String
    output = []
    Beautifier.new(output).scan(input)
    output.join
  end
end
