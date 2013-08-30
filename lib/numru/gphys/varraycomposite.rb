require "numru/gphys/varray"

=begin
=class NumRu::VArrayComposite < NumRu::VArray

a VArray that consists of multiple VArrays tiled regularly
(possibly in multi-dimension). Except for the constructer
"new" and ((<attr_update>)), the usage of this class is the same as VArray.

Note that the name and the attributes of a VArrayComposite is 
borrowed form one of the VArrays contained (actually, the first one
is used). Currently, no check is made 
regarding whether the names and attributes are the same among the 
VArrays contained. If you rename a VArrayComposite, the change will
be made with all the VArrays contained. However, currently, 
change of the attributes are only reflected only in the first 
VArray. You have to call ((<attr_update>)) separately.

==Class methods
---VArrayComposite.new(varrays)
    Constructor

    ARGUMENTS
    * varrays (NArray of VArray) : VArrays to be included, gridded 
      regularly in a NArray.

    RETURN VALUE
    * a VArrayComposite

    EXAMPLES
    * Suppose that you have VArrays va00, va01, va10, va00,
      with va00 and va10 having a same 0th dimension length,
      va01 and va11 having a same 0th dimension length,
      and va00 and va01 having a same 1st dimention length.

        varrays = NArray[ [ va00, va01 ],
                          [ va10, va11 ] ]
        vac = VArrayComposite.new(varrays)

      This will create a composite VArray tiled two-dimensionally.

    * You can create a VArray that lacks one or more VArrays as
      long as the shape is unambiguous:

        vac = VArrayComposite.new(  NArray[ [ va00, va01 ],
                                            [ va10, nil ] ] )
      is allowed, but 
        vac = VArrayComposite.new(  NArray[ [ va00, nil ],
                                            [ va10, nil ] ] )
      is prohibited.

      NOTICE: At this moment, handling of such nil-contianing 
      VArrayComposite is very limited, and many methods do not work.

    * Suppose that you have 3D VArrays va0, va1, va2, va3,
      and you want to concatenate them with the 3rd dimension.

        varrays = NArray[ va0,va1,va2,va3 ].newdim(0,0)

      This will create a 3D NArray with a shape of [1,1,4].
      Then you can make the composite as follows:

        vac = VArrayComposite.new(varrays)

Usage of all the other class methods are the same as in VArray.

=end

module NumRu
  class VArrayComposite < VArray

    def initialize( varrays )

      if !varrays.is_a?(NArray) || varrays.typecode != NArray::OBJECT
	raise ArgumentError, "argument must be a NArray of VArray (or nil)"
      end

      nvas = varrays.shape
      vrank = nvas.length
      varrays.each{|va|
	if !va.nil?
	  @first_vary = va
	  @attr = @first_vary.attr_copy
	  @name = @first_vary.name
	  @crank = va.rank   # rank of the component VArrays
	  break
	end
      }
      if vrank > @crank
        @rank = vrank       #=>  @rank > @crank
      else
	@rank = @crank
        if vrank < @crank
          (@crank - vrank).times{
            varrays = varrays.newdim(vrank)
            nvas.push(1)
          }
          vrank = @crank   # rank of varrays is increased to @crank (==@rank)
        end
      end
      un0 = varrays[0].units
      for i in 1...varrays.length
        va = varrays[i]
        varrays[i] = va.convert_units(un0) if va && va.units != un0
      end

      @bound_idx = Array.new     # will be Array of Array
      for dim in 0...vrank
	@bound_idx[dim] = [0]    # the frst element is always 0
	for i in 0...nvas[dim]
	  idx = [true]*dim + [i..i,false]
	  set=false
	  len=0
	  varrays[*idx].each{|va|
	    if !set && va
              ### commented out for the duck typing:
	      #if !va.is_a?(VArray)
              #  raise ArgumentError,"Not a VArray: #{va.inspect}"
	      #end
              if dim < @crank
                len = va.shape_current[dim]
              else
                len = 1
              end
	      @bound_idx[dim][i+1] = @bound_idx[dim][i] + len
	      set=true
	    elsif va
              if dim < @crank
                lc = va.shape_current[dim]
              else
                lc = 1
              end
	      if lc != len
		raise ArgumentError,"Non-uniformity in the #{i}th element"+
                   " of the #{dim}th dimension (#{va.shape_current[dim]} for #{len})"
	      end
	    end
	  }
	  if !set
	    raise "No VArray is found in the #{i}th elem of the #{dim}th dim"
	  end
	end
      end
      #< finish >
      @varrays = varrays.dup
      @shape = @bound_idx.collect{|a| a[-1]}
      @length = 1
      @shape.each{|l| @length *= l}
      # p @bound_idx, @varrays
    end

    undef initialize_mapping

    def set_att(name,val)
      @varrays.each{|va|
	va.set_att(name,val)
      }
      self
    end

    undef :mapping, :varray, :ary

    def inspect
      "<#{self.class.to_s} shape=#{shape.inspect} #_of_tiles=#{@bound_idx.collect{|b| b.length-1}.inspect}>"
      # "bounds=#{@bound_idx.collect{|b| b[1..-2]}.inspect}"
    end

    def shape
      @shape
    end
    alias shape_current shape
    def rank
      @rank
    end
    def length
      @length
    end
    alias total length

    def val
      val = nil
      loop_multi_dim_index( @varrays.shape ){|index|
	vidx = Array.new
	for d in 0...@rank
          if d < @crank
            vidx[d] = (@bound_idx[d][index[d]])..(@bound_idx[d][index[d]+1]-1)
          else
            vidx[d] = @bound_idx[d][index[d]]
          end
	end
	v = @varrays[*index].val
	if !val
	  if NArray===v
	    val = NArray.new(v.typecode,*@shape)
	  elsif NArrayMiss===v
	    val = NArrayMiss.new(v.typecode,*@shape)
	  else
	    raise TypeError, "Unexpected type #{v.class}"
	  end
	end
	val[*vidx] = @varrays[*index].val
      }
      val
    end

    def val=(narray)
      loop_multi_dim_index( @varrays.shape ){|index|
	if narray.is_a?(Numeric)
	  sub = narray
	else
	  __check_ary_class(narray)
	  vidx = Array.new
	  for d in 0...@rank
            if d < @crank
              vidx[d] = (@bound_idx[d][index[d]])..(@bound_idx[d][index[d]+1]-1)
            else
              vidx[d] = @bound_idx[d][index[d]]
            end
	  end
	  sub=narray[*vidx]
	end
	@varrays[*index].val = sub
      }
      narray
    end

    def [](*slicer)
      slicer = __rubber_expansion(slicer)
      varrays = _div_idx(*slicer)
      if varrays.length == 1
	varrays[0]
      else
	VArrayComposite.new( varrays )
      end
    end

    def []=(*args)
      args = __rubber_expansion(args)
      val = args.pop
      slicer = args
      slicer.collect!{|i| (i.is_a?(Numeric)) ? i..i : i }
      subva = self[*slicer]
      val = val.val if val.is_a?(VArray)
      subva.val= val
      val
    end

#    def ntype
#      @first_vary.ntype
#    end
    def ntype
      __ntype(typecode)
    end

    def typecode
      @first_vary.typecode
    end

    def file
      @varrays.collect{|va| va.file}
    end

    def name=(nm)
      raise ArgumentError, "name should be a String" if ! nm.is_a?(String)
      @name = nm
      @varrays.each{|va| va.name=nm}
      nm
    end
    def rename(nm)
      raise "method rename is not vailable. (But rename! and name= are available)"
      ## self.dup.set_name_shallow(nm)
    end

#    def set_name_shallow(nm)
#      raise ArgumentError, "name should be a String" if ! nm.is_a?(String)
#      @name = nm
#      self
#    end
#    protected set_name_shallow

    #def reshape!( *shape )
    #  raise "cannot reshape a #{class}. Use copy first to make it a VArray with NArray"
    #end
    undef reshape!

    ## Not needed, so far:
    #def convention
    #  @first_vary.convention
    #end

    ################# private #####################
    private

    def loop_multi_dim_index(shape)
      cumshape=[1]
      rank = shape.length
      (1..rank).each{|i| cumshape[i] = shape[i-1]*cumshape[i-1]}
      len = cumshape[-1]
      for i in 0...len
	index = (0...rank).collect{|d| (i/cumshape[d])%shape[d]}
	yield(index)
      end
    end

    def _div_idx(*idx)
      if idx.length != @rank
	raise ArgumentError, "length of args != rank"
      end
      imask = Array.new
      isub = Array.new
      idx.each_with_index{ |ix, dim|
	size = @bound_idx[dim][-1]
	imask[dim] = Array.new
	isub[dim] = Array.new if dim < @crank
	for j in 0...(@bound_idx[dim].length)
	  match, isb = _imatch( size, ix, @bound_idx[dim][j..j+1] )
	  if match
	    imask[dim].push(j)
	    isub[dim].push(isb) if dim < @crank
	  end
	end
      }
      varrays = @varrays[ *imask ]
      loop_multi_dim_index( varrays.shape ){ |index|
	slice = Array.new
	isub.each_with_index{|is, d| slice[d]=is[index[d]]}
	varrays[*index] = varrays[*index][*slice]
      }
      shape = varrays.shape
      (idx.length-1).downto(0){ |d|
	if idx[d].is_a?(Integer)
	  shape.delete_at(d)
	end
      }
      varrays.reshape!(*shape)
      varrays
    end

    def _imatch( size, index, bounds )
      first = bounds[0]
      last = bounds[-1]-1
      case index
      when Integer
	index += size if index < 0
	if first <= index && index <= last
	  return [true, index-first ]
	else
	  return [false, nil]
	end
      when Range, Hash, true
	if true === index
	  fst,lst = 0,size-1
	  stp = 1
	elsif Range === index
	  fst = index.first
	  fst += size if fst < 0
	  lst = index.exclude_end? ? index.last-1 : index.last
	  lst += size if lst < 0
	  stp = 1
	else # Hash
	  range, stp = index.to_a[0]
          if stp<=0
            raise(ArgumentError,"Currently only positive step is supported")
            # development note: current handling of fst and lst assumes a
            # positive step
          end
	  range = 0..-1 if range==true
	  fst = range.first
	  fst += size if fst < 0
	  lst = range.last
	  lst += size if lst < 0
	  if range.exclude_end?
	    stp>=0 ? lst-=1 : lst+=1
	  end
	end
	if fst <= last && lst >= first
	  a = ( (fst >= first) ? fst-first : (fst - first).modulo(stp) )
	  b = ( (lst <= last) ? lst-first : last-first )
	  if stp==1
	    return [true, a..b ]
	  else
            len = last-first+1
            if a<len
              return [true, {(a..b)  => stp} ]
            else
              return [false, nil]
            end
	  end
	else
	  return [false, nil]
	end
      when Array
        match = false
        isb = []
        index.each{ |idx|
          idx += size if idx < 0
          if first <= idx && idx <= last
            match = true
            isb.push(idx-first)
          end
        }
        isb = nil if isb == []
        return [match, isb]
      else
	raise "Unsupported type for indexing: #{index.class}"
      end
    end

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

  end
end

###############################################

if __FILE__ == $0
  include NumRu
  va00 = VArray.new( NArray.float(2,3,2).indgen!,    nil, 'TEST' )
  va01 = VArray.new( NArray.float(2,4,2).indgen!+100 )
  va10 = VArray.new( NArray.float(5,3,2).indgen!+200 )
  va11 = VArray.new( NArray.float(5,4,2).indgen!+300 )
  varrays = NArray[ [ va00, va10 ],
                    [ va01, va11 ] ]
  p vac = VArrayComposite.new(varrays)
  varrays = NArray[ [ va00.copy, nil       ],
                    [ va01.copy, va11.copy ] ]
  p vac2 = VArrayComposite.new(varrays)
  p vac.ntype, vac.typecode
  p vac.val
  vacs = vac[1..3,0..3,true]
  p vacs.val
  p vac[false,1]
  vacs.val *= -1
  p vac.val
  vacs.val = 999.0
  p vac.val
  vac[-1, 0..1, true] = 0.0
  p vac.val
  p( (vac*100.0).val, vac.sin.val )
  vac2[0, 0..1, true] = 1000.0
  p vac2[0..1, 0..1, true].val
  p vac.name
  p vac.name='test'
  p va01.name
  vac.set_att('long_name', 'test data')
  p vac.get_att('long_name')
  p va01.get_att('long_name')
  p vac.typecode,vac.ntype

  puts "testing rank extension.."
  va0 = VArray.new( NArray.float(3,2).indgen!,     {"units"=>"m/s"}, 'V' )
  va1 = VArray.new( NArray.float(3,2).indgen!+100, {"units"=>"m/s"}, 'V' )
  va2 = VArray.new( NArray.float(3,2).indgen!+200, {"units"=>"m/s"}, 'V' )
  va3 = VArray.new( NArray.float(3,2).indgen!+300, {"units"=>"m/s"}, 'V' )
  varrays = NArray.to_na([ [[va0]], [[va1]], [[va2]], [[va3]] ])
  vac = VArrayComposite.new(varrays)
  p vac, vac.val
  if vac[1,1,1].val == 104.0
    puts "test OK"
  else
    raise "test failed"
  end

  v = vac[0..1,0,{1..-1=>2}].val
  ans = NArray.to_na( [ [100.0,101.0], [300.0, 301.0] ] )
  if v==ans
    puts "test OK"
  else
    raise "test failed"
  end

  vac[-1,true,1..2] = -999.0
  if vac[-1,true,1..2].val.to_a.flatten.uniq == [-999.0 ] 
    puts "test OK"
  else
    raise "test failed"
  end
  #vac.val = NArray.float(3,2,4).random!
  #p vac.val
end
