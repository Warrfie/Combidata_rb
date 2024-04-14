require 'deep_clone'

module Combidata
  class CombinatoricsError < StandardError; end

  def should_keep(x)
    x.length > 1
  end

  def form_seed(gen_lib)
    gen_lib.transform_values { |modes| modes.keys.first }
  end

  class MDG
    attr_accessor :init_lib, :types_for_generation, :logger, :generator_id, :neutral_lib

    def initialize(init_lib, types_for_generation: nil, logger: nil, generator_id: nil)
      @init_lib = DeepClone.clone(init_lib)
      @types_for_generation = types_for_generation
      @logger = logger
      @generator_id = generator_id
      @neutral_lib = form_neutral_lib
    end

    def seed(main_case)
      if result = can_combine(@neutral_lib, main_case, @types_for_generation)
        form_seed(result)
      else
        raise CombinatoricsError
      end
    end

    def can_combine(main_case)
      !!can_combine(@neutral_lib, main_case, @types_for_generation)
    end

    def form_neutral_lib
      template = form_template(@init_lib)

      @init_lib.each do |field, modes|
        modes.each_key do |mode|
          next unless @init_lib[field][mode].requirements

          @init_lib[field][mode].requirements.each do |req_unit, req_modes|
            next unless template.keys.include?(req_unit) && template[field].keys.include?(mode)

            intersected_modes = req_modes & template[field][mode].requirements[req_unit]
            if intersected_modes.empty?
              template[field].delete(mode)
              log_deletion(mode, field) if @logger
            else
              template[field][mode].requirements[req_unit] = intersected_modes
              modes_for_hunt = template[req_unit].keys - intersected_modes
              update_requirements(template, req_unit, modes_for_hunt, field, mode)
            end
          end
        end
      end

      template
    end

    private

    def log_deletion(mode, field)
      @logger.add_log(@generator_id, "Mode: #{mode} in field: #{field}: Was deleted because will never use in generation")
    end

    def update_requirements(template, req_unit, modes_for_hunt, field, mode)
      modes_for_hunt.each do |target_mode|
        updated_requirements = template[req_unit][target_mode].requirements[field] - [mode]
        if updated_requirements.empty?
          template[req_unit].delete(target_mode)
          log_deletion(target_mode, req_unit) if @logger
        else
          template[req_unit][target_mode].requirements[field] = updated_requirements
        end
      end
    end
  end
end

