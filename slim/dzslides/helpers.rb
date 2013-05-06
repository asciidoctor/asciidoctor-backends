# Add custom functions to this module that you want to use in your Slim
# templates. Within the template you must namespace the function
# (unless someone can show me how to include them in the evaluation context).
# You can change the namespace to whatever you want.
module Helpers
  def self.capture_output(*args, &block)
    Proc.new { block.call(*args) }
  end
end
