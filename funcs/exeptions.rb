class CombinatoricsError < StandardError
  # Bad combinatorics.
  def initialize(message = "You can't combine that case")
    super(message)
  end
end
