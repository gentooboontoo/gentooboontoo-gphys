require "narray"

module NumRu
=begin
=class Attribute < Hash
A Hash class compatible with NetCDF attributes.
* Values are restricted to NetCDFAttr values
* Keys must be String or Symbol (Symbol is converted into String such that
  they are used interchangeably. E.g., attr[:units] == attr["units"] )
=end
   class Attribute < Hash 
      # privatalize all so that public methods must be set explicitly
      private( *((Hash.instance_methods(false) - Object.new.methods).
                 collect{|i| i.intern} - [:[], :default]))
      #":[]" and ":default" should not be private on ruby 1.9. 
      #Once they become private, super does not work well.

      #protected :[], :[]=   # to be aliased 
      #-> Alias does not work well in this case on ruby 1.9 !!!
      public :each, :each_key, :length, :keys, :delete, :delete_if
      public :has_key?, :include?, :key?, :merge, :update

      def initialize
	 super
      end

      class << self
	 ## < class methods > ##

	 def [](*keyval)
	    attr = new
	    0.step(keyval.length-1,2){ |i|
	       key,val = keyval[i],keyval[i+1]
	       if key.is_a?(Symbol)
		  key=key.to_s
	       elsif ! key.is_a?(String)
		  raise ArgumentError,"Attribute key must be String or Symbol: #{key} -- #{key.class}."
	       end
	       attr[key]=val
	    }
	    attr
	 end
      end

      ## < methods > ##

      def copy(to=nil)
	 # deep copy (clone), or addition to "to" if given.
	 if to == nil
	    to = NumRu::Attribute.new
	 end
	 self.each{|key, val|
	    if(val)
	       to[key] = val.clone
	    else
	       to[key] = val
	    end
	 }
	 to
      end

      def [](key)
	 if key.is_a?(Symbol)
	    key = key.to_s
	 elsif ! key.is_a?(String)
	    raise ArgumentError, "Attribute key must be Symbol or String: #{key} -- #{key.class}." 
	 end
	 if /^[A-Za-z_]\w*$/ !~ key
	   raise ArgumentError, "Attribute key must match /^[A-Za-z_]\w*$/"
         end
         super(key)
      end

      def []=(key, val)
	 if _val_allowed?(val)
	    if key.is_a?(Symbol)
	       key = key.to_s
	    elsif ! key.is_a?(String)
	       raise ArgumentError, "Attribute key must be Symbol or String: #{key} -- #{key.class}." 
	    end
	    super(key, val)
	 else
	    raise ArgumentError, "Not allowed as an attribute value: #{val} (String or NArray/Array of numerics are required`)" 
	 end
	 val
      end

      def rename(key_from, key_to)
	 v = self[key_from]
	 if v==nil; raise "attribute #{key_from} does not exist"; end
         self[key_to]=v
	 self.delete(key_from)
      end

      ## < private methods > ##
      private
      def _val_allowed?(val)
	 # to ensure the compatibility with NetCDFAttr
	 begin
	    val.is_a?(String) || 
	    ##   val.is_a?(Numeric) ||   # disabled 2005/03/25 by horinout
	       val.is_a?(NilClass) ||
	       ( ( (val.is_a?(NArray) && val.rank==1) || 
	           (val.is_a?(Array) && val=NArray.to_na(val)) ) &&
	         val.typecode <= NArray::DFLOAT )
	 rescue
	    # for possible error in val=NArray.to_na(val)) above
	    false
	 end
      end
   end
end

if __FILE__ == $0
   a = NumRu::Attribute.new
   p a
   a["name"]="takeshi"
   p a
   b = @attr = NumRu::Attribute[:name2,"var", :units,"m/s", :valid_range,nil]
   p b[:units]
   p b["units"]
   p b
   p b["allowd"] = [1,10]
   begin
      b["not_allowd"] = [1,10,'no, no']
   rescue
      print "(OK): exception raised as expected\n"
   end
end
