require "narray"

module NumRu
  class MDStorage
    def initialize(rank=1)
      raise(ArgumentError,"rank must be a positive integer") if !(rank>0)
      @rank = rank
      @shape = []
      rank.times{@shape.push(1)}
      @data = [nil]
      (rank-1).times{
        @data = [@data]
      }
    end

    attr_reader :rank

    def shape
      @shape.dup
    end

    # add a new dimension to the last
    def add_dim
      @rank += 1
      @shape.push(1)
      @data = [@data]
    end

    # increase the length of a dimension by one
    def extend(dim)
      if dim<0 or dim>=rank
        raise(ArgumentError,"invalid dim (#{dim}): not in #{0..rank-1}")
      end
      yield_at_depth(@data,rank-1-dim){|a| 
        a.push( dim==0 ? nil : make_nested_array(shape[0..dim-1]) )
      }
      @shape[dim] += 1
      self
    end

    # substituion at a position specified with integers (only one element)
    def []=(*args)
      val = args.pop
      raise(ArgumentError,"# of args != rank (#{rank})") if args.length != rank
      x = @data
      (rank-1).downto(1) do |d|
        idx = args[d]
        raise(ArgumentError,"all args must be integers") if !idx.is_a?(Integer)
        len = shape[d]
        idx += len if idx<0
        raise("Too big negative index for dim #{d}: #{idx-len}") if idx<0
        if 0<=idx and idx<len
          x = x[idx]
        elsif idx >= len
          (idx-len+1).times{extend(d)}
          x = x[idx]
        else
          raise(ArgumentError,"invalid specification")
        end
      end

      idx = args[0]
      len = shape[0]
      idx += len if idx<0
      raise("Too big negative index for dim #{0}: #{idx-len}") if idx<0
      if idx >= len
        (idx-len+1).times{extend(0)}
      end
      x[idx] = val
    end

    # read from a position specified with integers (only one element)
    def [](*args)
      raise(ArgumentError,"# of args != rank (#{rank})") if args.length != rank
      x = @data
      args.reverse_each do |idx|
        raise(ArgumentError,"all args must be integers") if !idx.is_a?(Integer)
        x = x[idx]
        return(x) if x.nil?
      end
      x
    end

    def to_na
      NArray.to_na(@data)
    end

    #############################################
    ## < private methods >
    private
=begin
    def __rubber_expansion( args )
      if (id = args.index(false))  # substitution into id
        # false is incuded
        alen = args.length
        if args.rindex(false) != id
          raise ArguemntError,"only one rubber dimension is permitted"
        elsif alen > rank+1
          raise ArgumentError, "too many args"
        end
        ar = ( id!=0 ? args[0..id-1] : [] )
        args = ar + [true]*(rank-alen+1) + args[id+1..-1]
      end
      args
    end
=end

    # make a neste multi-D Array filled with nil
    def make_nested_array(shape)
      if shape.length == 1
        Array.new(shape[0])      # => [nil,nil,...,nil]
      elsif shape.length > 1   # recursive construction
        (0...shape[-1]).collect{make_nested_array(shape[0..-2])}
      else
        raise ArgumentError, "shape must have 1 or more elements"
      end
    end

    # call the block at the depth in the nested array
    def yield_at_depth(ary,depth, &blk)
      if depth==0
        blk.call(ary)    # call the block
      elsif depth>0
        ary.each{|sub| yield_at_depth(sub,depth-1,&blk)}
      else
        raise ArgumentError, "depth must be >= 0"
      end
    end
  end
end

if $0 == __FILE__
  include NumRu
  a = MDStorage.new(3)
  p a
  p a.extend(2)
  p a.extend(2)
  p a.extend(0)
  a[0,0,0] = 10.9
  a[1,0,-1] = "XX"
  p a, a[0,0,0], a[1,0,-1]
  a[2,0,2] = '###'
  p a
  p a.to_na
end
