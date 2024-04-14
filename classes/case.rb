require 'deep_clone'

class Case
  # Represents a specific variation or scenario for a given field.
  attr_accessor :field_name, :field_mode, :case_name, :gen_func, :value, :options, :is_presented, :requirements, :type_of_case, :additional_fields

  # Initializes a TestCase with given attributes and a hash containing specific case details.
  def initialize(case_details, field_name, field_mode)
    @field_name = field_name
    @field_mode = field_mode
    @case_name = case_details["name"]
    @value = case_details.fetch("value", nil)
    @type_of_case = case_details.fetch("type", "standard")
    @gen_func = case_details.fetch("gen_func", nil)
    @is_presented = case_details.fetch("is_presented", true)
    @options = case_details.fetch("options", nil)
    @requirements = handle_requirements(case_details["requirements"] || {})
    @additional_fields = form_additional_fields(case_details)
  end

  # Returns a string representation of the TestCase object's current state.
  def to_s
    instance_variables.map { |var| "#{var}: #{instance_variable_get(var)}" }.join(", ")
  end

  private

  # Handles the deep copying and conversion of requirements from hash or list to a set.
  def handle_requirements(requirements)
    return {} unless requirements.is_a?(Hash)

    requirements.transform_values do |mode|
      case mode
      when Array
        Set.new(mode)
      when String
        Set.new([mode])
      else
        raise "In case '#{self.case_name}', requirements modes must be an array or a string."
      end
    end
  end

  # Forms a hash of additional fields excluding predefined keys.
  def form_additional_fields(case_details)
    predefined_keys = ["name", "value", "type", "gen_func", "is_presented", "options", "requirements"]
    case_details.reject { |key, _| predefined_keys.include?(key) }
  end
end
