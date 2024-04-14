class Process
  # Process Class:
  # --------------
  # Represents a test step or process within the Combidata framework.
  #
  # Attributes:
  # - func: A Proc object that is executed as part of the test step. This function will continue to run until it
  #   returns `True`. The function must accept an argument of type `Combination`.
  #
  # - name: A unique identifier for the process. It must be distinct across all instances to avoid conflicts.
  #
  # Notes:
  #   - Ensure that the `name` attribute is unique to avoid any potential conflicts during execution.
  #
  # Usage:
  #   Define a test step by instantiating the Process class and providing the necessary attributes.

  attr_accessor :name, :func

  def initialize(name, func)
    @name = name
    @func = func
  end

  def activate(combination)
    if @func.call(combination)
      combination.step_done = @name
    end
  end
end

