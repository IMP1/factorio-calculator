class Entity

    attr_reader :name
    attr_reader :data
    attr_reader :position
    attr_reader :direction
    attr_reader :outputs
    attr_reader :inputs
    attr_reader :downstream_entities
    attr_reader :upstream_entities

    attr_accessor :throughput
    attr_accessor :overflow

    @@classes = {}

    def self.register(name, class_obj)
        @@classes[name] = class_obj
    end

    def initialize(name, position, direction, data)
        @name = name
        @data = data
        @position = position
        @direction = direction
        @inputs = []
        @outputs = []
        @downstream_entities = []
        @upstream_entities = []
        @throughput = nil
        @overflow = false
    end

    # To be overridden by child classes
    def setup(map)
    end

    # To be overridden by child classes
    def refresh
    end

    def add_input(entity, suppress_refresh=false)
        @upstream_entities.push(entity)
        refresh unless suppress_refresh
    end

    def add_output(entity, suppress_refresh=false)
        @downstream_entities.push(entity)
        refresh unless suppress_refresh
    end

    def self.from_blueprint(blueprint_data)
        position = [blueprint_data.position.x, blueprint_data.position.y]
        direction = blueprint_data.direction || 0
        class_obj = @@classes[blueprint_data.name]
        if class_obj.nil?
            raise "undefined factorio entity `#{blueprint_data.name}'"
        end
        return class_obj.new(position, direction, blueprint_data)
    end

end

class Inserter < Entity
end