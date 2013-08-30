require "numru/netcdf.rb"
require "numru/gphys/attribute.rb"
require "numru/gphys/netcdf_convention"

=begin
=class Attribute_NetCDF
A class to handle NetCDF attributes in the same way as in the 
NumRu::Attribute class.
=end

module NumRu
   class AttributeNetCDF
      def initialize( ncvar )
	 raise TypeError unless NetCDFVar===ncvar || NetCDF===ncvar
	 @nv = ncvar
	 convention = NetCDF_Conventions.find(ncvar.file)
	 extend( convention::Attribute_Mixin )
      end

      def [](name)
	  ( att = @nv.att(name) ) ? att.get : att
      end

      def []=(name, val)
	 @nv.put_att(name,val)
	 val
      end

      def copy(to=nil)
	 # deep copy (clone), or addition to "to" if given.
	 # ATTENTION!  If the destination "to" is not given, it will
	 # be an Attribute (not AttributeNetCDF), which is on memory.
	 if to == nil
	    to = NumRu::Attribute.new
	 end
	 self.each{|key, val|
	    to[key] = val
	 }
	 to
      end

      def rename(key_from, key_to)
	 att = @nv.att(key_from)
	 if att==nil; raise "attribute #{key_from} does not exist"; end
         att.name= key_to
      end

      def each
	 @nv.each_att{|att| yield(att.name, att.get)}
      end

      def each_key
	 @nv.each_att{|att| yield(att.name)}
      end

      def length
	 @nv.natts
      end

      def keys
	 @nv.att_names
      end

      def delete(key)
	 @nv.att(key).delete
      end

      def delete_if
	 each{|key,val| delete(key) if yield(key,val)}
      end

      def has_key?(key)
	 @nv.att(key) ? true : false
      end
      alias :include? :has_key?
      alias :key? :has_key?

   end
end

