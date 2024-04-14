require_relative 'combidata/classes/mul_dim_graph'

def combine(combination)
  neutral_lib = combination.init_lib

  combi_graph = MDG.new(neutral_lib, combination.types_for_generation, combination.logger, combination.generator_id)

  main_case = combination.main_case

  combination.test_seed = combi_graph.seed(main_case)

  combination.other_cases = combination.init_lib.select do |field, modes|
    modes.keys.include?(combination.test_seed[field]) && field != main_case.field_name
  end.transform_values { |modes| modes[combination.test_seed.keys.first] }

  if combination.logger
    combination.logger.add_log(combination.generator_id, "Generated seed: #{combination.test_seed.inspect}")
  end

  true
end

