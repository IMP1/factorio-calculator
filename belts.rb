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
        @lanes = [] # 0 = left, 1 = right
        ox, oy = *Direction.to_offset(@direction)
        x, y = *@position
        @outputs.push( [x + ox, y + oy] )
        @inputs.push( [x, y] )
    end

    def refresh
        puts "#{@upstream_entities.size} -> #{name}"
        if @upstream_entities.count { |i| i.is_a?(Belt) } > 1
            # TODO: add manually to lanes from inputs.
            same_direction = @upstream_entities.find { |i| i.is_a?(Belt) and i.direction == @direction }
            unless same_direction.nil?
                # @lanes[0] += same_direction.lanes[0]
                # @lanes[1] += same_direction.lanes[1]
            end
            # TODO: add to just one lane
        elsif @upstream_entities.count { |i| i.is_a?(Belt) } > 0
            
        end
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
        puts "#{@upstream_entities.size} -> #{name}"
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
        p data.type
    end

    def setup(map)
        if data.type == "input"
            output = nil
            x, y = *@position
            p [x, y]
            ox, oy = *Direction.to_offset(@direction)
            x += ox
            y += oy
            1.upto(5) do
                entity = map.find do |e| 
                    next if e == self
                    next unless e.is_a?(UndergroundBelt)
                    next unless e.data.type == "output"
                    p e
                    e_x, e_y = *e.position
                    e_x == x && e_y == y
                end
                p entity
                if entity
                    output = entity
                    break
                end
                x += ox
                y += oy
            end
            if output
                # @outputs.push( [x, y] )
            end
        end
    end

    def refresh
        puts "#{@upstream_entities.size} -> #{name}"
    end

end
