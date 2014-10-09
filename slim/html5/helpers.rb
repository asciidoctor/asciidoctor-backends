# Add custom functions to this module that you want to use in your Slim
# templates. Within the template you must namespace the function
# (unless someone can show me how to include them in the evaluation context).
# You can change the namespace to whatever you want.
module Helpers

  # Formats the given hash as CSS declarations for inline style.
  def self.style_value(hash)
    decls = []
    hash.each do |prop, value|
      prop = prop.to_s.gsub('_', '-')
      decls << "#{prop}: #{value}" if value
    end
    decls.empty? ? nil : decls.join('; ') + ';'
  end
end
