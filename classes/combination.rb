require 'deep_clone'

module Combidata
  class Process
    # Assume Process class has been defined here
  end

  def current_workflow(workflow, is_all_steps: false)
    if workflow.first.is_a?(Process)
      workflow.each do |process|
        yield process
      end
    elsif is_all_steps
      workflow.each do |stage|
        stage.each do |process|
          yield process
        end
      end
    else
      workflow.first.each do |process|
        yield process
      end
      workflow.shift
    end
  end

  def step_not_done(current_step_name, combi)
    combi.step_done != current_step_name && !combi.step_done.is_a?(Exception)
  end

  class Combination
    attr_accessor :test_seed, :formed_data, :step_done, :init_lib, :main_case, :template, :tools, :generated_data, :other_cases, :cache, :workflow, :logger, :generator_id, :types_for_generation

    def initialize(case_instance, workflow, init_lib, template, tools, logger, generator_id, types_for_generation)
      @init_lib = DeepClone.clone(init_lib)
      @main_case = case_instance
      @template = template
      @tools = tools
      @logger = logger
      @generator_id = generator_id
      @generated_data = {}
      @other_cases = {}
      @cache = {}
      @workflow = DeepClone.clone(workflow)
      @types_for_generation = types_for_generation
    end

    def run
      current_workflow(@workflow) do |current_step|
        while step_not_done(current_step.name, self)
          next if @step_done == current_step.name

          @logger.start_step(@generator_id, current_step.name) if @logger
          begin
            current_step.activate(self)
          rescue => e
            @step_done = e
            if @logger
              error_details = "An exception occurred: #{e.class.name}. Error message: #{e.message}. "
              last_traceback = e.backtrace_locations.last
              file_name = last_traceback.path
              line_number = last_traceback.lineno
              error_details += "Occurred at: #{file_name}:#{line_number}."
              @logger.end_step(@generator_id, error_details)
            end
          else
            @logger.end_step(@generator_id) if @logger
          end
        end
      end
    end
  end
end

