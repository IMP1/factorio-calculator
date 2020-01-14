module Direction

    def self.to_offset(direction)
        case direction
        when 0
            return [0, -1]
        when 2
            return [1, 0]
        when 4
            return [0, 1]
        when 6
            return [-1, 0]
        end
    end

end