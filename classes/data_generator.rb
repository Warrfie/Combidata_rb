# frozen_string_literal: true

class DataGenerator
  attr_accessor :library, :banned_fields, :possible_fields, :possible_modes, :type_of_cases, :types_for_generation, :amount

  def initialize(library:, banned_fields: [], possible_fields: [], possible_modes: {}, type_of_cases: [], types_for_generation: [], amount: 10)
    @library = library
    @banned_fields = banned_fields
    @possible_fields = possible_fields
    @possible_modes = possible_modes
    @type_of_cases = type_of_cases
    @types_for_generation = types_for_generation
    @amount = amount
  end

  def run
    # Logic to generate data
    puts "Generating data..."
  end

  def retrieve_case(case_name)
    # Retrieve a single test case by name
    @library[case_name]
  end
end

