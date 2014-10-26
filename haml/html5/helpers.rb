# Add custom functions to this module that you want to use in your Haml
# templates. Within the template you can invoke them as top-level functions
# just like the built-in helper functions that Haml provides.
module Haml::Helpers

  def autowidth?
    option? :autowidth
  end

  def spread?
    'spread' if !(option? 'autowidth') && (attr :tablepcwidth) == 100
  end
end
