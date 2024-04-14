def find_replace_in_dict(template, generated_data, keys)
  result = {}
  template.each do |key, value|
    if value.is_a?(Hash)
      result[key] = find_replace_in_dict(value, generated_data, keys)
    elsif value.is_a?(String) && keys.include?(value)
      result[key] = generated_data[value] if generated_data.key?(value)
    else
      result[key] = value
    end
  end
  result
end

def form(combination)
  combination.formed_data = find_replace_in_dict(combination.template, combination.generated_data, combination.init_lib.keys)

  if combination.logger
    combination.logger.add_log(combination.generator_id, "Formed data: #{combination.formed_data.inspect}")
  end

  true
end


