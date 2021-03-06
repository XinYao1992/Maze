require 'set'

class Maze
  #Each position in the maze can be designated by two coordinates, x (across) and y (down).
  #For a 4x5 maze the top row of positions (x,y) would be (0,0), (1,0), (2, 0) and (3,0).
  #The constructor of the Maze class should take two parameters for n and m. Note of course
  #that you need to represent the walls between cells not just the cells.
  def initialize(n, m)#n is the number of cells each row.
    num_rows = 2*m+1
    num_columns = 2*n+1
    @map = Array.new(num_columns){Array.new}
    (0...num_columns).each do |i|
      row = Array.new(num_rows)
      @map[i] = row
    end
    @adjacency_list = Hash.new
    @path = Array.new
  end

  #load(arg) method that initializes the maze using a string of ones and zeros as above
  def load(str)
    #build map
    num_columns = @map.length
    num_rows = @map[0].length
    index = 0
    for r in (0...num_rows)
      for c in (0...num_columns)
        @map[c][r] = str[index].to_s
        index += 1
      end
    end

    #build adjaceny list for DFS
    for r in (1...num_rows-1)
      for c in (1...num_columns-1)
        if @map[c][r] == "0"
          p = Point.new((c-1)/2, (r-1)/2)
          if !@adjacency_list.has_key?(p.value)
            @adjacency_list[p.value] = Array.new

            if @map[c][r-1] == "0"
              p1 = Point.new((c-1)/2, (r-3)/2)
              @adjacency_list[p.value].push(p1.value)
            end
            if @map[c-1][r] == "0"
              p2 = Point.new((c-3)/2, (r-1)/2)
              @adjacency_list[p.value].push(p2.value)
            end
            if @map[c+1][r] == "0"
              p3 = Point.new((c+1+1-1)/2, (r-1)/2)
              @adjacency_list[p.value].push(p3.value)
            end
            if @map[c][r+1] == "0"
              p4 = Point.new((c-1)/2, (r+1+1-1)/2)
              @adjacency_list[p.value].push(p4.value)
            end

          end
        end

      end
    end
  end

  #display method that prints a diagram of the maze on the console. It can be just a
  #simple character based printout like above or any other format you want.
  def display
    num_columns = @map.length
    num_rows = @map[0].length
    for r in (0...num_rows)
      str = ""
      for c in (0...num_columns)
        str += @map[c][r]
      end
      puts str
    end
  end

  #solve(begX, begY, endX, endY) method that determines if there’s a way to walk from a
  #specified beginning position to a specified ending position. Of course it can return an
  #error or false if there is no way.
  def solve(begX, begY, endX, endY)
    begP = Point.new(begX, begY)
    endP = Point.new(endX, endY)
    if !@adjacency_list.has_key?(begP.value)
      return false
    end
    if !@adjacency_list.has_key?(endP.value)
      return false
    end
    #if begin equals end, return true
    if begP.value == endP.value
      return true
    end
    #use dfs to see if there is a valid path.
    s = Set.new
    s.add(begP.value)
    path = Array.new
    path.push(begP.value)
    for v in @adjacency_list[begP.value]
      if !s.include?(v)
        s.add(v)
        path.push(v)
        if dfs(v, endP.value, s, path)
          return true
        end
        path.delete(v)
      end
    end
    return false
  end

  #depth-first search for solve
  def dfs(value, endP_v, s, path)
    if value == endP_v
      @path = path
      return true
    end
    for v in @adjacency_list[value]
      if !s.include?(v)
        s.add(v)
        path.push(v)
        if dfs(v, endP_v, s, path)
          return true
        end
        path.delete(v)
      end
    end
    return false
  end

  #trace(begX, begY, endX, endY) method that is just like solve() but traces the positions
  #that the solution visits.
  def trace(begX, begY, endX, endY)
    begP = Point.new(begX, begY)
    endP = Point.new(endX, endY)
    start_index = @path.index(begP.value)
    end_index = @path.length - 1
    @path = @path[start_index..end_index]
    return @path
  end

  #redesign() which will reset all the cells and walls and come up with a random new maze
  #of the same size. There are lots of algorithms out there to do this. Feel free to google
  #for ideas, but the code you hand in should be your own.
  def redesign()
    num_columns = @map.length
    num_rows = @map[0].length
    for c in (1...num_columns-1)
      r = 0
      if c % 2 == 1
        r = 2
      else
        r = 1
      end
      while (r < num_rows-1) do
        @map[c][r] = Random.rand(2).to_s
        r += 2
      end
    end
  end
  
end

class Point
  def initialize(x_value, y_value)
    @x = x_value
    @y = y_value
  end

  attr_accessor :x
  attr_accessor :y

  def print()
    puts x, y
  end

  def value()
    str = @x.to_s + "," + @y.to_s
    return str
  end
end


maze = Maze.new(4, 4)
maze.load("111111111100010001111010101100010101101110101100000101111011101100000101111111111")
maze.display
if maze.solve(1,1,2,0)
  print "The path:", maze.trace(1,1,2,0)
  puts ""
else
  puts "No path!"
end
puts "Redesigning the maze..."
maze.redesign
puts "The new maze:"
maze.display
