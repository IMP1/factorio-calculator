require_relative "entity"
require_relative "direction"

class Belt < Entity
end

class TransportBelt < Belt

    NAME = "transport-belt"
    Entity.register(NAME, self)

    attr_reader :lanes
    
    def initialize(position, direction, data)
        super(NAME, position, direction, data)
        @max_throughput = 15
        @lanes = Array.new(2) { [] } # 0 = left, 1 = right
        ox, oy = *Direction.to_offset(@direction)
        x, y = *@position
        @outputs.push( [x + ox, y + oy] )
        @inputs.push( [x, y] )
    end

    def refresh
        return if @upstream_entities.empty?
        puts "#{@upstream_entities.map { |e| e.name }} -> #{name}"

        if @upstream_entities.count { |i| i.is_a?(Belt) } > 1
            same_direction_belt = @upstream_entities.find { |i| i.is_a?(Belt) and i.direction == @direction }
            unless same_direction_belt.nil?
                @lanes[0].push( -> { belt.throughput.map { |item, amount| [item, amount / 2] }.to_h } )
                @lanes[1].push( -> { belt.throughput.map { |item, amount| [item, amount / 2] }.to_h } )
            end
            other_directions = @upstream_entities - [same_direction_belt]
            other_directions.each do |e|
                # TODO: Find the correct lane and add to it
                lane_index = 0
                @lanes[lane_index].push( -> { e.throughput } )
            end
        elsif @upstream_entities.count { |i| i.is_a?(Belt) } == 1
            belt = @upstream_entities.find { |i| i.is_a?(Belt) }
            @lanes[0].push( -> { belt.throughput.map { |item, amount| [item, amount / 2] }.to_h } )
            @lanes[1].push( -> { belt.throughput.map { |item, amount| [item, amount / 2] }.to_h } )
        end

        @upstream_entities.select { |e| e.is_a?(Inserter) }.each do |e|
            # TODO: Find the correct lane and add to it
            lane_index = 0
            @lanes[lane_index].push( -> { e.throughput } )
        end

        @upstream_entities.select { |e| e.is_a?(SystemInput) }.each do |e|
            p e
            # TODO: Find the correct lane and add to it
            @lanes[0].push( -> { e.throughput.map { |item, amount| [item, amount / 2] }.to_h } )
            @lanes[1].push( -> { e.throughput.map { |item, amount| [item, amount / 2] }.to_h } )
        end
    end

    def throughput
        output = {}
        @lanes.each do |lane|
            lane.each do |input|
                input_throughput = input.call
                input_throughput.each do |item, amount|
                    output[item] ||= 0
                    output[item] += amount
                end
            end
        end
        return output
    end

end

class Splitter < Belt

    NAME = "splitter"
    Entity.register(NAME, self)

    attr_reader :lanes
    
    def initialize(position, direction, data)
        super(NAME, position, direction, data)
        @max_throughput = 15
        @lanes = [] # 0 = left, 1 = right
        ox, oy = *Direction.to_offset(@direction)
        x, y = *position
        if !x.integer?
            @outputs.push( [(x + ox + 0.5).round, y + oy] )
            @outputs.push( [(x + ox - 0.5).round, y + oy] )
            @inputs.push( [(x + 0.5).round, y] )
            @inputs.push( [(x - 0.5).round, y] )
        end
        if !y.integer?
            @outputs.push( [x + ox, (y + oy + 0.5).round] )
            @outputs.push( [x + ox, (y + oy - 0.5).round] )
            @inputs.push( [x, (y + 0.5).round] )
            @inputs.push( [x, (y - 0.5).round] )
        end
    end

    def refresh
        puts "#{@upstream_entities.map { |e| e.name }} -> #{name}"
    end

end

class UndergroundBelt < Belt

    NAME = "underground-belt"
    Entity.register(NAME, self)

    attr_reader :lanes
    
    def initialize(position, direction, data)
        super(NAME, position, direction, data)
        @max_throughput = 15
        @lanes = [] # 0 = left, 1 = right
        ox, oy = *Direction.to_offset(@direction)
        x, y = *@position
        @inputs.push( [x, y] )
        if @data.type == "output"
            @outputs.push( [x + ox, y + oy] )
        end
    end

    def setup(map)
        if data.type == "input"
            output = nil
            x, y = *@position
            ox, oy = *Direction.to_offset(@direction)
            x += ox
            y += oy
            1.upto(5) do
                entity = map.find do |e| 
                    next if e == self
                    next unless e.is_a?(UndergroundBelt)
                    next unless e.data.type == "output"
                    e_x, e_y = *e.position
                    e_x == x && e_y == y
                end
                if entity
                    output = entity
                    break
                end
                x += ox
                y += oy
            end
            if output
                @outputs.push( [*output.position] )
            end
        end
    end

    def refresh
        puts "#{@upstream_entities.map { |e| e.name }} -> #{name}"
    end

end
