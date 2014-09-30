namespace :adocspec do

  ##
  # Prompt the user to input something.
  #
  # @param message [String] The message to display before input.
  # @param choices [Array] Array of strings of acceptable answers or nil for any answer.
  # @return [String] The user's answer.
  #
  def prompt(message, choices = nil)
    begin
      print(message)
      answer = STDIN.gets.chomp
    end while !choices.nil? && !choices.include?(answer)
    answer
  end
end
