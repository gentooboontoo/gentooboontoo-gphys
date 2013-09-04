require "narray"

module NumRu

   class SubsetMapping

      def initialize(shape, slicer, mapping1Ds=nil)
	 #USAGE:
	 #   SubsetMapping.new(shape, slicer)
	 # or 
	 #   SubsetMapping.new(nil, nil, mapping1Ds)
	 #
	 # shape [Array]: shape of the array onto which mapping is made
	 # slicer [Array]: mapping specification for each dim.
	 #   (shape and slicer are used to create SubsetMapping1D's)
	 # mapping1Ds [Array]: collected SubsetMapping1D's
	 #
	 # NOTE shape.length must be equal to mappings.length
	 if mapping1Ds
	    @maps = mapping1Ds
	    len = mapping1Ds.length
	 else
	    len=shape.length

	    if slicer.length == 0
	       @maps = Array.new
	       for i in 0...len do
		  p  shape[i],0..-1
		  @maps[i] = SubsetMapping1D.new(shape[i],0..-1)
	       end
	    else
	       if len != slicer.length
		  raise "lengths of shape and slicer do not agree (#{len} vs #{slicer.length})"
	       end
	       @maps = Array.new
	       for i in 0...len do
		  @maps[i] = SubsetMapping1D.new(shape[i],slicer[i])
	       end
	    end
	 end
	 @dims_retained = Array.new
	 @dims_collapsed = Array.new
	 for i in 0...len do
           @maps[i].collapsed ? @dims_collapsed.push(i) : @dims_retained.push(i)
	 end
	 @rank = @dims_retained.length
	 @shape = Array.new
	 @maps.each{|mp| @shape.push(mp.length) if ! mp.collapsed}
      end

      attr_reader :shape, :rank, :maps
      protected :maps

      def total
	 tt=1
	 @shape.each{|i| tt *= i}
	 tt
      end
      alias length total

      def slicer
	 @maps.collect{|mp| mp.slicer}
      end

      def composite( other )
	 if @rank != (other.maps.length)
	    raise ArgumentError, "the original rank (#{other.maps.length}) must agree with the rank of this mapping (#{@rank})"
	 end
	 newmap = Array.new()
	 for i in 0...@rank do
	    id = @dims_retained[i]
	    newmap[id] = @maps[id].composite( other.maps[i] )
	 end
	 @dims_collapsed.each{ |i| newmap[i] = @maps[i] }
	 SubsetMapping.new(nil,nil,newmap)
      end

      def map( *indices_sub )
	 # map an index to an element in the subset to that in the original
	 if @rank != (indices_sub.length)
	    raise ArgumentError, "number of arguments (#{indices_sub.length}) must agree with the rank of this mapping (#{@rank})"
	 end
	 indices_mapped = Array.new
	 for i in 0...@rank do
	    id = @dims_retained[i]
	    indices_mapped[id] = @maps[id].map(indices_sub[i])
	 end
	 @dims_collapsed.each{ |i| indices_mapped[i] = @maps[i].first }
	 indices_mapped
      end
      def imap( *indices_mapped )
	 # inverse operation of the map method
	 if @maps.length != (indices_mapped.length)
	    raise ArgumentError, "number of arguments (#{indies_mapped.length}) must agree with the rank of the array mapped to (#{@maps.length})"
	 end
	 work = Array.new
	 indices_mapped.each_index{|i|
	    work[i] = @maps[i].imap( indices_mapped[i] )
	 }
	 if work.include?(nil)
	    indices_sub = nil
	 else
#	    indices_sub = work.indices( *@dims_retained )  # indices: obsolete in ruby 1.8
	    indices_sub = work.values_at( *@dims_retained )
	 end
	 indices_sub
      end
   end

   class SubsetMapping1D

      attr_reader :slicer,
                  :regular, 
                  :collapsed, 
	          :first, 
	          :step, 
	          :index_array

      class << self
	 alias  new0  new
      end
      def initialize()
	 # To complete the initialization, use initialize_regular
	 # or initialize_irregular later.
	 @slicer = nil
	 @regular = nil
	 @collapsed = false
	 @first = nil
	 @length = nil
	 @step = nil
	 @index_array = nil
      end

      def initialize_irregular(index_array)
	 @slicer = index_array
	 @regular = false
	 @collapsed = false
	 @first = nil
	 @length = nil
	 @step = nil
	 @index_array = index_array
	 self
      end

      def initialize_regular(slicer, collapsed, first, length, step)
	 @slicer = slicer
	 @regular = true
	 @collapsed = collapsed
	 @first = first
	 @length = length
	 @step = step
	 @index_array = nil
	 self
      end

      def SubsetMapping1D.new(dim_len, slicer, no_collapse=false)
	 case slicer
	 when Integer
	    idx = slicer
	    if idx < 0; idx += dim_len; end
	    if idx < 0 || idx >= dim_len
	       raise "mapping #{slicer} is out of range (dim_len=#{dim_len})"
	    end
	    first=idx
	    length=step=1
	    collapsed = no_collapse ? false : true
	    SubsetMapping1D.new0.initialize_regular(slicer, collapsed, 
						   first, length, step)
	 when Range, Hash, true
	    if (Range === slicer) 
	       range = slicer
	       step = 1
	    elsif (true === slicer) 
	       range = 0..-1
	       step = 1
	    else  # Hash
	       if slicer.length != 1; raise "not 1-key-val Hash"; end
	       range, step = slicer.to_a[0]
	    end
	    first = range.first
	    last = range.exclude_end? ? range.last-1 : range.last
	    if first < 0; first += dim_len; end
	    if last < 0; last += dim_len; end
	    if first<0 || first>=dim_len || last<0 || last>=dim_len || step==0
	       raise "mapping #{slicer.inspect} is invalid (dim_len=#{dim_len})"
	    end
	    first = first
	    step = -step if ( (last-first)*step < 0 )
	    length = (last-first) / step + 1
	    SubsetMapping1D.new0.initialize_regular(slicer, false, 
						   first, length, step)
	 else
	    index_array = NArray.int(1).coerce(slicer)[0]
	    if index_array.min < 0 || index_array.max >= dim_len
	       raise "array index mapping out of range (dim_len=#{dim_len})"
	    end
	    slicer = index_array
	    SubsetMapping1D.new0.initialize_irregular(index_array)
	 end
      end

      def composite(mapping)
	 # derive the composite mapping (mappig * self), where self is 
	 # applied first. ('*' here is meant to be a circle)
	 if @regular
	    if mapping.regular
	       fst = @first + @step * mapping.first
	       len = mapping.length
	       if len > @length; raise "length too large"; end
	       stp = @step * mapping.step
	       slicer = __make_regular_slicer((scl=mapping.collapsed),fst,len,stp)
	       SubsetMapping1D.new0.initialize_regular(slicer,scl,fst,len,stp)
	    else
	       mida = mapping.index_array
	       if  mida.min < 0 || mida.max >= @length
		  raise "array index mapping out of range"
	       end
	       idxary = @first + @step * mida
	       SubsetMapping1D.new0.initialize_irregular(idxary)
	    end
	 else
	    if mapping.regular
	       mida = mapping.first + 
		      mapping.step * NArray.int(mapping.length).indgen!
	    else
	       mida = mapping.index_array
	    end
	    if  mida.length < 0 || mida.max >= length
	       raise "array index mapping out of range"
	    end
	    idxary = @index_array[mida]
	    if idxary.length==1
	       fst = idxary[0]
	       len = step = 1
	       slicer = __make_regular_slicer((scl=mapping.collapsed),fst,len,stp)
	       SubsetMapping1D.new0.initialize_regular(slicer,scl,fst,len,stp)
	    else
	      SubsetMapping1D.new0.initialize_irregular(idxary)
	    end
	 end
      end

      def length
	 @length || @index_array.length
      end

      def map(i)
	 # map an index value
	 # i: shoud be Integer or Array of Integer
	 raise ArgumentError, "Integer required" if ! i.is_a?(Integer)
	 if @regular
	    i += @length if i<0
	    @first + @step * i
	 else
	    @index_array[i]
	 end
      end

      def imap(i)
	 # inversely map an index value
	 raise ArgumentError, "Integer required" if ! i.is_a?(Integer)
	 if @regular
	    if ( (i-@first) % @step == 0 )
	       imp = (i-@first)/@step
	       if imp >= 0 && imp < @length
		  imp
	       else
		  nil
	       end
	    else
	       nil     # not included
	    end
	 else
	    @index_array.index(i)  # returns nil if not included
	 end
      end

      ####### / private methods -->  #######
      private
      def __make_regular_slicer(collapsed, first, length, step)
	 if collapsed
	    first
	 else
	    last = first + (length-1)*step
	    if step == 1
	       first..last
	    else
	       {(first..last) => step}
	    end
	 end
      end

   end

end

####################################
## test program

if $0 == __FILE__
  include NumRu
   m =  SubsetMapping1D.new(40,{(1..-2) => 2})
   p '%%',m.slicer,m.regular,m.collapsed,m.first,m.length,m.step,m.index_array
   m2 =  SubsetMapping1D.new(10,{(1..9) => 4})
   print "+++ #{m.map(0)} #{m.map(1)} #{m.imap(0)} #{m.imap(1)}\n"
   p '##',m2.slicer,m2.regular,m2.collapsed,m2.first,m2.length,m2.step,m2.index_array
   m = m.composite(m2)
   p '%%',m.slicer,m.regular,m.collapsed,m.first,m.length,m.step,m.index_array

   print "########\n"
   m =  SubsetMapping1D.new(40,{(-2..1) => -2})
   p '%%',m.slicer,m.regular,m.collapsed,m.first,m.length,m.step,m.index_array
   m2 =  SubsetMapping1D.new(10,{(1..9) => 4})
   print "+++ #{m.map(0)} #{m.map(1)} #{m.imap(0)} #{m.imap(1)}\n"
   p '##',m2.slicer,m2.regular,m2.collapsed,m2.first,m2.length,m2.step,m2.index_array
   m = m.composite(m2)
   p '%%',m.slicer,m.regular,m.collapsed,m.first,m.length,m.step,m.index_array

   print "########\n"
   m =  SubsetMapping1D.new(10,[0..9,4])
   p '##',m.slicer,m.regular,m.collapsed,m.first,m.length,m.step,m.index_array
   mm = SubsetMapping.new([5,6,6],[1..3, -1, 3..-1])
   p '@@@@',mm,mm.shape
   p '@@', mp=mm.map( -1, -2 ), mm.imap(*mp)
   mmx = SubsetMapping.new([3,3],[0,0..1])
   p '@',mm.composite(mmx)
   mm2 = SubsetMapping.new(nil,nil,[m,m2])
   p '++++',mm2, mm2.shape, mm2.slicer.class, mm2.slicer
   mm3 = SubsetMapping.new(mm.shape,[1..2, 0..1])
   p 'xxxx',mm3
   p mmc = mm.composite(mm3), mmc.slicer
end
