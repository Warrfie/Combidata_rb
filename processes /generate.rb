require 'random'

def generate_value(all_fields, case_data, combination)
  generated_data = combination.generated_data
  test_seed = combination.test_seed
  cases = combination.other_cases

  if case_data.options.nil?
    if case_data.gen_func.nil?
      item_value = case_data.value
    else
      item_value = case_data.gen_func.call(case_data.value)
    end
  else
    options = {}
    case_data.options.each do |key, field|
      if field.is_a?(String) && test_seed.keys.include?(field)
        if generated_data.key?(field)
          options[key] = generated_data[field]
        elsif !combination.init_lib[field][test_seed[field]].is_presented
          options[key] = combination.init_lib[field][test_seed[field]].value
        else
          generate_value(all_fields, cases[field], combination)
          options[key] = generated_data[field]
        end
      elsif field == "combination"
        options[key] = combination
      elsif field == "value"
        options[key] = case_data.value
      else
        options[key] = field
      end
    end
    item_value = case_data.gen_func.call(**options) if options.any?
  end

  if case_data.is_presented
    generated_data[case_data.field_name] = item_value
  end
  all_fields.delete(case_data) if all_fields.include?(case_data)
end

def generate(combination)
  all_fields = combination.other_cases.values.to_a
  generate_value(all_fields, combination.main_case, combination)

  while all_fields.any?
    case_data = all_fields.sample
    generate_value(all_fields, case_data, combination)
  end

  if combination.logger
    combination.logger.add_log(combination.generator_id, "Generated data: #{combination.generated_data.inspect}")
  end

  true
end


