require "narray"
#require "numru/gphys_ext"

module NumRu

  # = Associated coordinates
  #
  # To use in a Grid in order to support non-rectangular coordnate systems
  #
  class AssocCoords

    # * assoc_crds : Array of GPhys
    # * axnames : Array of axis names of the original Grid
    #
    def initialize(assoc_crds, axnames)

      # < argument check >
      if assoc_crds.uniq.length != assoc_crds.length
	raise ArgumentError, "Names are not uniq: #{assoc_crds.inspect}."
      end
      assoc_crds.each do |gp|
	raise(ArgumentError,"Non-GPhys included") if !gp.is_a?(GPhys)
	if axnames.include?(gp.name)
	  raise ArgumentError, 
	      "'#{gp.name}' overwraps an axis name #{axnames.inspect}."
	end
      end

      # < some internal variables >

      @assoc_crds = Hash.new
      assoc_crds.each{|gp| @assoc_crds[gp.name] = gp}
      @axnames = axnames.dup
      @lost_assoc_crds = nil

      # < lengths of original axes >

      @axlens = Hash.new
      @axnames.each do |nm|
        len = nil
        lens = nil
        assoc_crds.each do |gp|
          if gp.axnames.include?(nm)
            len = gp.axis(nm).length
            if lens && len!=lens
              raise("Inconsistency in assoc coord length for ax #{nm}: #{len} (#{gp.name}) vs #{lens}") 
            end
            lens = len
          end
        end
        @axlens[nm] = len      # can be nil
      end

      # < grouping in terms of original-dimension sharing >
      @groups = Hash.new    # axnames => assoc coord names
      assoc_crds.each do |gp|
        pushed = false
        axnames_sv = acnames_sv = nil
        @groups.each do | axnames, acnames |
          a = gp.axnames
          if (axnames - a).length < axnames.length   # included?
            unless pushed
              # first time in this loop
              axnames.concat(a).uniq!
              acnames.push(gp.name)
              axnames_sv = axnames
              acnames_sv = acnames
            else
              # second or greater time in this loop --> need merger to the first
              @groups.delete(axnames)
              axnames_sv.concat(axnames).uniq!
              acnames_sv.concat(acnames).uniq!
            end
            pushed = true
            #break  # <-- old code; this doesn't work
          end
        end
        @groups[ gp.axnames ] = [gp.name] if !pushed  # new group
      end

      # < sort keys in @groups in the order of original axes >
      # -- though its necesity was not originally supposed, but...
      @groups.each_key do |axnames|
        axnames.replace( @axnames - (@axnames - axnames) )
      end
    end

    attr_reader :assoc_crds, :axnames, :axlens
    protected :assoc_crds, :axnames

    def merge(other)
      if other.nil?
        self
      else
        ac = self.assoc_crds.merge(other.assoc_crds)
        an = (self.axnames + other.axnames).uniq
        self.class.new(ac,an)
      end
    end

    def inspect
      "<AssocCoords  #{@assoc_crds.collect{|nm,gp| gp.data.inspect}.join("\n\t")}\n\t#{@groups.inspect}>"
    end

    def copy
      self.class.new( @assoc_crds.values.collect{|gp| gp.copy}, @axnames )
    end

    def coord(name)
      @assoc_crds[name].data   # return a VArray
    end

    def replace(gphys)
      raise(ArgumentError,"not a GPhys") unless gphys.is_a?(GPhys)
      nm = gphys.name
      raise("assoc coord '#{nm}' is not found") unless (old=@assoc_crds[nm])
      raise("shapes of the current and new '#{nm}' are different") unless old.shape==gphys.shape
      @assoc_crds[nm] = gphys
      self
    end

    def coord_gphys(name)
      @assoc_crds[name]   # return a GPhys
    end

    def has_coord?(name)
      @assoc_crds.has_key?(name)
    end

    def coordnames
      @assoc_crds.keys
    end

    # assoc_crds に関する座標値ベースの切り出し : 引数は Hash のみ
    def cut(hash)
      cutaxnms = hash.keys
      newcrds = Array.new
      slicer_hash = Hash.new
      @groups.each do |orgaxnms, group|
        ca2 = cutaxnms - group
        if ca2.length < cutaxnms.length
          # Some of cutaxnms are included in group
          # --> Do cutting regarding this group
          crds = Array.new
          crdnms = Array.new
          crdaxexist = Array.new
          masks = Array.new   # for NArrayMiss
          cuts = Array.new
          group.each do |nm|
            cutter = hash[nm]
            if !cutter.nil? && cutter!=true && cutter!=(0..-1)
              crdnms.push( nm )
              cuts.push( hash[nm] )
	      anms = @assoc_crds[nm].axnames
              crdaxexist.push( NArray.to_na(
		    orgaxnms.collect{|a| anms.include?(a) ? 1 : 0} ) )
              v = @assoc_crds[nm].val   # 座標値 (NArray or NArrayMiss)
              if v.is_a?(NArrayMiss)
                crds.push(v.to_na)
                masks.push(v.get_mask)
              else
                crds.push(v)
                masks.push(nil)
              end
            end
          end
          cuttype = cuts.collect{|x| x.class}.uniq
          if cuttype.length == 1
            orgaxlens = @axlens.values_at(*orgaxnms)
            if cuttype[0] == Range
	      vmins = Array.new
	      vmaxs = Array.new
	      cuts.each do |range|
		a = range.first
		b = range.last
		if (b<a)
		  vmins.push(b)
		  vmaxs.push(a)
		else
		  vmins.push(a)
		  vmaxs.push(b)
		end
	      end
              idxs = cut_range(vmins,vmaxs,crds,masks,crdaxexist,orgaxlens)
            elsif cuttype[0] == Numeric
              raise "SORRY!  cut_nearest is yet to be implemented."
              idxs = cut_nearest()  # YET TO BE IMPLEMENT
            else
              raise ArgumentError, "Not allowed cutting type (#{cuttype[0]})"
            end
            ncrds = group.collect{ |nm| 
              gp = @assoc_crds[nm]
              sl = gp.axnames.collect{|anm| idxs[orgaxnms.index(anm)]}
              gp[ *sl ]
            }
            newcrds.concat( ncrds )
            orgaxnms.each_with_index{|nm,i| slicer_hash[nm] = idxs[i]}
          else
            raise "Cutting specification for a group of assoc coords (here, #{group.inspect}) must be uniformly set to either by range or by point -- Cannot mix."
          end
        else
          # None of cutaxnms are included in group --> just copy
          ncrds = group.collect{ |nm| @assoc_crds[nm] }
          newcrds.concat( ncrds )
        end
        cutaxnms = ca2
        break if cutaxnms.length == 0     # cutting finished
      end
      new_assocoords = self.class.new( newcrds, @axnames )
      [ new_assocoords, slicer_hash ] 
    end

    # slicing in terms of the original axes
    #
    def [](*args)
      return self.dup if args.length == 0

      args = __rubber_expansion( args )
      slicer = Hash.new
      @axnames.each_with_index{|nm,i| slicer[nm] = args[i]}

      new_assoc_crds = Array.new
      lost_assoc_crds = Array.new
      @assoc_crds.each do |dummy, gp|
        sub = gp[ *( gp.axnames.collect{|nm| slicer[nm] || true} ) ]
        if sub.rank > 0
          new_assoc_crds.push( sub )
        else
          lost_assoc_crds.push( "#{sub.name}=#{sub.val}" )
        end
      end

      ret = self.class.new( new_assoc_crds, @axnames )
      ret.set_lost_coords( lost_assoc_crds ) if !lost_assoc_crds.empty?
      ret
    end

    # make a subset with assoc coords related only to axnames
    def subset_having_axnames( axnames )
      acnms = Array.new
      @groups.each do |ks,vs|
        acnms.concat(vs) if ( (ks-axnames).length == 0 )  # all of ks present
      end
      assoc_crds = acnms.collect{|nm| @assoc_crds[nm]}
      self.class.new(assoc_crds, axnames)
    end

    def set_lost_coords( lost_assoc_crds )
      @lost_assoc_crds = lost_assoc_crds   # Array of String
      self
    end

      def lost_coords
	@lost_assoc_crds.dup
      end

    def __rubber_expansion( args )
      if (id = args.index(false))  # substitution into id
        # false is incuded
        rank = @axnames.length
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
    private :__rubber_expansion

  end

end



#######################################
## < test >
if $0 == __FILE__
  require "numru/gphys"
  include NumRu
  include NMath
  nx = 10
  ny = 7
  nz = 2
  x = (NArray.sfloat(nx).indgen! + 0.5) * (2*PI/nx)
  y = NArray.sfloat(ny).indgen! * (2*PI/(ny-1))
  z = NArray.sfloat(nz).indgen! 
  vx = VArray.new( x ).rename("x")
  vy = VArray.new( y ).rename("y")
  vz = VArray.new( z ).rename("z")
  xax = Axis.new().set_pos(vx)
  yax = Axis.new().set_pos(vy)
  zax = Axis.new().set_pos(vz)
  xygrid = Grid.new(xax, yax)
  xyzgrid = Grid.new(xax, yax, zax)
  p xygrid, xyzgrid

  sqrt2 = sqrt(2.0)

  p = NArray.sfloat(nx,ny)
  q = NArray.sfloat(nx,ny)
  for j in 0...ny
    p[true,j] = NArray.sfloat(nx).indgen!(2*j,1)*sqrt2
    q[true,j] = NArray.sfloat(nx).indgen!(2*j,-1)*sqrt2
  end
  vp = VArray.new( p ).rename("p")
  vq = VArray.new( q ).rename("q")
  gp = GPhys.new(xygrid, vp) 
  gq = GPhys.new(xygrid, vq) 

  r = NArray.sfloat(nz).indgen! * 2
  vr = VArray.new( r ).rename("r")
  gr = GPhys.new( Grid.new(zax), vr ) 

  assoc = AssocCoords.new([gp,gq], xyzgrid.axnames)
  assoc2 = AssocCoords.new([gp,gq,gr], xyzgrid.axnames)

  print "--- AssocCoord objects ---\n"
  p assoc, assoc2
  p assoc.coordnames
  p assoc.axlens

  print "\n----- Subsetting by [] -----\n"

  sa = assoc[0..3,{0..4=>2}]
  p sa.coord('p').val, sa.coord('q').val
  p sa.copy

  p assoc[1,2].lost_coords

  print "\n----- Subsetting by cut -----\n"

  ac,sl = assoc.cut('p'=>4.0..10.0)
  p ac.copy,sl
  ac2,sl = assoc2.cut('p'=>4.0..10.0)
  p ac2.copy,sl

  print "\n----- GPhys making -----\n"

  d = sin(x.newdim(1,1)) * cos(y.newdim(0,1)) + z.newdim(0,0)
  vd = VArray.new( d ).rename("d")
  gd = GPhys.new(xyzgrid, vd)
  gd.set_assoc_coords([gp,gq,gr])
  print "GPhys with associated coordinates:\n"
  p gd

  print "Coordiantes:\n"
  p gd.axnames
  p gd.coordnames
  p gd.coord("p")

  print "\n--- GPhys Subsetting ---\n"
  p gd[1..2,0,0].copy
  p gd[0,false].first2D

  p gd.cut('p'=>4.0..10.0, 'z'=>0).copy

=begin
  print "\n--- writing in a NetCDF file ---\n"
  file = NetCDF.create("tmp.nc")
  GPhys::IO.write(file,gd)
  file.close
=end

  print "\n--- GPhys methods that need proper AssocCoord handling ---\n"
  print "* mean(2)\n"
  p gd.mean(2)
  print "* stddev(0)\n"
  p gd.stddev(0)
  print "* integrate(0)\n"
  p gd.integrate(1)

  print "\n--- coord_dim ---\n"
  grid = gd.grid_copy
  grid.coordnames.each do |nm|
    print nm, "  ", grid.coord_dim_indices(nm).inspect, "\n"
  end

end

