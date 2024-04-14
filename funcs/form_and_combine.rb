require 'deep_clone'
require 'set'

module Combidata
  def should_keep(x)
    x.length > 1
  end

  def form_template(lib)
    template = {}
    lib.each do |field, modes|
      template[field] = {}
      modes.each do |mode, details|
        template[field][mode] = DeepClone.clone(details)  # Using deep_clone gem for deep copy in Ruby
        lib.each do |seed_field, seed_modes|
          next if seed_field == field
          template[field][mode]['requirements'][seed_field] = Set.new(seed_modes.keys)
        end
      end
    end
    template
  end

  def can_combine(neutral_lib, current_case, types_for_generation)
    case_copy = DeepClone.clone(current_case)
    return false unless neutral_lib.key?(case_copy.field_name) &&
      neutral_lib[case_copy.field_name].key?(case_copy.field_mode)

    case_copy.requirements = neutral_lib[case_copy.field_name][case_copy.field_mode]['requirements']
    copied_lib = DeepClone.clone(neutral_lib)

    neutral_lib[case_copy.field_name].keys.each do |mode|
      copied_lib[case_copy.field_name].delete(mode) if mode != case_copy.field_mode
    end

    neutral_lib.each do |field, modes|
      next if field == case_copy.field_name
      modes.keys.each do |mode|
        copied_lib[field].delete(mode) unless case_copy.requirements[field].include?(mode)
      end
    end

    modes_count = copied_lib.values.sum { |modes| modes.empty? ? 0 : modes.size }
    return false if modes_count != copied_lib.keys.size

    copied_lib.each do |field, modes|
      modes.each_value do |case_details|
        case_details['requirements'].each do |case_field, case_modes|
          return false unless copied_lib[case_field].keys.first.in?(case_modes)
        end
      end
    end

    fields = copied_lib.values.map(&:values).flatten
    fields.shuffle!
    fields = fields.select { |f| should_keep(f) }
    fields.first.shuffle.each do |case_details|
      next unless case_details.type_of_case.in?(types_for_generation)
      result = can_combine(copied_lib, case_details, types_for_generation)
      return result if result
    end

    false
  end

  def unlimited_cases(init_lib, cases_lib, workflow, types_for_generation)
    correct_cases = {}
    is_full = false
    current_keys_list = []
    counter = 0

    workflow = DeepClone.clone(workflow)
    must_prove = workflow.any? { |process| process.name == 'ST_COMBINE' }

    if must_prove
      correct_cases = DeepClone.clone(cases_lib)
      is_full = true
      current_keys_list = correct_cases.keys.shuffle
    end

    loop do
      if is_full
        if current_keys_list.any?
          combination_name = current_keys_list.pop
          yield({combination_name => cases_lib[combination_name]})
        else
          current_keys_list = correct_cases.keys.shuffle
          counter += 1
          combination_name = current_keys_list.pop
          yield({combination_name => cases_lib[combination_name]})
        end
      else
        combinations = cases_lib.keys.shuffle
        combinations.each do |combination_name|
          main_case = cases_lib[combination_name].main_case
          if main_case.field_name.in?(combi_graph.neutral_lib.keys) &&
            main_case.field_mode.in?(combi_graph.neutral_lib[main_case.field_name].keys) &&
            combi_graph.can_combine(main_case)
            correct_cases[combination_name] = main_case
            yield({combination_name => cases_lib[combination_name]})
          end
        end
        is_full = true
        current_keys_list = correct_cases.keys.shuffle
        counter += 1
      end
    end
  end
end
