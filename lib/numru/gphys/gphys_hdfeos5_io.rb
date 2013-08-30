require "numru/gphys/gphys"
require "numru/gphys/varrayhdfeos5"

module NumRu

  class GPhys

    module HE5_IO

      module_function

      PredefCoordNames = ["Time","Longitude","Latitude","Colatitude"]  
                       # ^ In the order of precedence

      @@predef_gdcoords = [/^altitude$/i, /^altitude/i, /^pressure$/i, /^wavelength$/i, /^wavelength/i,/^wavenumber$/i, /^wavenumber/i, /^time$/i,/time$/i]
                       # ^ In the order of precedence

      @@predef_zacoords = [/^latitude$/i, /^latitude/i, /^altitude$/i, /^altitude/i, /^pressure$/i, /^wavelength$/i, /^wavelength/i,/^wavenumber$/i, /^wavenumber/i, /^time$/i, /time$/i, /^solarzenithangle$/i, /^solarzenithangle/i]
                       # ^ In the order of precedence

      def self.add_predef_gdcoords(regexp)
        raise ArgumentError, "arg must be a regexp" unless regexp.is_a?(Regexp)
        @@predef_gdcoords.push(regexp)
      end

      def self.predef_gdcoords
        @@predef_gdcoords
      end

      def self.add_predef_zacoords(regexp)
        raise ArgumentError, "arg must be a regexp" unless regexp.is_a?(Regexp)
        @@predef_gdcoords.push(regexp)
      end

      def self.predef_zacoords
        @@predef_gdcoords
      end

      def is_a_HE5?(filename)
        file = nil
        begin
          file = File.open(filename,"rb")
          str = file.read(4)
        ensure
          file.close if file
        end
        return str=="\211HDF"
      end

      def open(files, varname)
	files, var0, varname, gridtype = __interpret_files( files, varname )
        case gridtype
        when "swath"
          _sw_open(var0, varname)
        when "grid"
          _gd_open(var0, varname)
        when "za"
          _za_open(var0, varname)
        else
          raise "Sorry. Currently, only the Swath type is supported"
        end
      end

      def _sw_open(var0, varname)
        swath = var0.swath
  	data = __files2varray( swath, varname )
	rank = data.rank
        dim_names = var0.dim_names

        #< coordiante varables >

        geo_names = swath.geo_names  # geolocation varables
        coords = Array.new(rank)
        assoccoords = Array.new

        proc = Proc.new{|nm|
          vdns = swath.var(nm).dim_names
          if vdns.length==1 && (dim=dim_names.index(vdns[0])) && !coords[dim]
            coords[dim] = __files2varray( swath, nm)
          elsif ( (vdns - dim_names).length==0 )  # all dims are covered
            dimids = vdns.collect{|s| dim_names.index(s)}
            assoccoords.push( [dimids, __files2varray( swath, nm)] )
          end
        }

        # (first precedence) Predefined coordinate variable names
        PredefCoordNames.each do |nm|
          proc.call(nm) if geo_names.delete(nm)  # if included, delete and call
        end

        # (second precedence) Variables having the same name as a dimension
        dim_names.each do |nm|
          proc.call(nm) if geo_names.delete(nm)  # if included, delete and call
        end

        # (else)
        geo_names.each do |nm|
          proc.call(nm) if  swath.geo(nm).ntype != "char"
        end

=begin
        # if no geolocation variable was found for a dim, search variables too
        if coords.include?(nil)
          swath.var_names.each do |nm|
            vdns = swath.var(nm).dim_names
            if vdns.length==1 && (dim=dim_names.index(vdns[0])) && !coords[dim]
              coords[dim] = __files2varray( swath, nm)
            end
            break if !coords.include?(nil)
          end
        end
=end

        #< make axes >
        axes = Array.new
        coords.each_with_index do |crd, dim|
          if crd
            axis = Axis.new
            axis.set_pos( crd )
          else
            axis = Axis.new(false, true)
            dimnm = dim_names[dim]
            len = data.shape_current[dim]
            axis.set_pos( VArray.new(NArray.float(len).indgen!).rename(dimnm) )
          end
          axes.push( axis )
        end

        #< make grid >
        grid = Grid.new( *axes )

        if assoccoords.length > 0
          assoccoords.collect! do |dimids, vary|
            acgrid = Grid.new( *(dimids.collect{|dim| axes[dim]}) )
            gphys = GPhys.new(acgrid, vary)
          end
          grid.set_assoc_coords( assoccoords )
        end

        #< make gphys >
        GPhys.new(grid,data)
      end
      private :_sw_open

      def _gd_open(var0, varname)
        #< make axes >
        grid = var0.grid
        data = __files2varray( grid, varname )
        axes = __make_gd_axes(var0, grid, data)

        #< make grid >
        new_grid = Grid.new( *axes )

        #< make gphys >
        GPhys.new(new_grid,data)
      end
      private :_gd_open

      def _za_open(var0, varname)
        #< make axes >
        za = var0.za

        data = __files2varray( za, varname )
        axes = __make_za_axes(var0, za, data)

        #< make grid >
        new_za = Grid.new( *axes )

        #< make gphys >
        GPhys.new(new_za,data)
      end
      private :_za_open

      def write(file, gphys, name=nil)
        name = gphys.name if name.nil?
        dims = Array.new
        gphys.rank.times{|n|
          dims[n] = gphys.coord(n)
        }

        case file
        when HE5Sw
          VArrayHE5SwField.write(file,gphys.data,name,dims)
        when HE5Gd
          VArrayHE5GdField.write(file,gphys.data,name,dims)
        when HE5Za
        else
          raise ArgumentError, "arg must be a HE5Sw, a HE5Gd or a HE5Za"
        end

        nil
      end

      def var_names(files)
        case files
        when HE5
          file = files
          opened = true
        when String
          file = HE5.open(files)
          opened = false
        else
          raise ArgumentError, "arg must be a HDF-EOS5 or a file name"
        end
        raise "file must be a HDF-EOS5 swath filed" if !file.has_swath?()
        swathlist=file.swath_names()
        varnames=[]
        for i in 0..swathlist.size-1
          sfile=file.swath(swathlist[i])
          sfile.var_names.each{|name|
            f, var, varname, gridtype = __interpret_files( sfile, name )
            if var.rank>1 || var.name!=var.dim_names[0]
              varnames.push(swathlist[i]+"/"+name)
            end
          }
          sfile.closed           # close Swath field
        end
        file.close unless opened # close Swath field & close HDF-EOS5 file
        return varnames
      end

      def var_names_except_coordinates(files)
        var_names(files)
      end

      ############################################################
      def __convertTime( axisname )
        # Convert Geo Location Field "Time" or "LocalTime"
#	if axisname.name == "Time" ||  axisname.name == "LocalTime"
#          axisname.val.each{|ax|
#            stun = axisname.units.to_s
#            since = DateTime.parse("1993-01-01 00:00:00+00:00")
#            tun = Units[stun]
#            sec = tun.convert( ax, Units['seconds'] ).round + 1e-1
#            datetime = since + (sec/86400.0)
#            ax =datetime.strftime("%Y-%m-%d %H:%M:%S")
#          }
#p axisname[0].val
#        end
      end

      def __files2varray( files, varname, dim=nil, gd_flag=nil, ntype=nil )
	if files.is_a?(HE5Sw)
	  # Single file. Returns a VArrayHE5SwField. dim is ignored.
	  file = files
	  var = file.var(varname)
	  raise "variable '#{varname}' not found in #{file}" if !var
	  if ntype != nil && gd_flag == 1
            VArrayHE5SwField.new2( var , varname, ntype,  dim)
	  elsif ntype != nil && gd_flag == 0
            VArrayHE5SwField.new3( file, varname, ntype,  dim)
	  else
            VArrayHE5SwField.new( var )
          end
        elsif files.is_a?(HE5Gd)
	  # Single file. Returns a VArrayHE5GdField. dim is ignored. 
	  file = files
	  var = file.var(varname)
	  raise "variable '#{varname}' not found in #{file}" if !var
	  if ntype != nil && gd_flag == 1
            VArrayHE5GdField.new2( var , varname, ntype,  dim)
	  else
            VArrayHE5GdField.new( var )
          end
        elsif files.is_a?(HE5Za)
	  # Single file. Returns a VArrayHE5ZaField. dim is ignored. 
	  file = files
	  var = file.var(varname)
	  raise "variable '#{varname}' not found in #{file}" if !var
	  if ntype != nil && gd_flag == 1
            VArrayHE5ZaField.new2( var , varname, ntype,  dim)
	  else
            VArrayHE5ZaField.new( var )
          end
	elsif files.is_a?(NArray)
	  # Suppose that files is a NArray of HDF-EOS5. Returns a VArrayCompsite.
	  if dim.is_a?(Integer) && dim>=0 && dim<files.rank
	    files = files[ *([0]*dim+[true]+[0]*(files.rank-dim-1)) ]
	  end
	  varys = NArray.object( *files.shape )
	  for i in 0...files.length
	    var = files[i].var( varname )
            ntype = var.ntype
            ntype = var.dim
	    raise "variable '#{varname}' not found in #{files[i].path}" if !var
   	    if ntype != nil && gd_flag == 1     # For Data Field
              varys[i] = VArrayHE5SwField.new2( var , varname, ntype,  dim)
	    elsif ntype != nil && gd_flag == 0  # For Geo Location Field
              varys[i] = VArrayHE5SwField.new3( file, varname, ntype,  dim)
	    else
              varys[i] = VArrayHE5SwField.new( var )
            end
	  end
	  if files.length != 1
	    VArrayComposite.new( varys )
	  else
	    varys[0]
	  end
	else
	  raise TypeError, "not a HDF-EOS5 or NArray"
	end
      end

      def __interpret_files( files, varname )
        gridtype = nil  # --> "swath", "grid", "za", ....
	case files
	when HE5, String
          files   = HE5.open(files) if files.is_a?(String)
          dirname, varname, = varname.split(/\//)

          if files.has_swath?
            swath = files.swath(dirname) or raise("Can't find a swath named #{dirname}")
            he5var0 = swath.var( varname )
            gridtype = 'swath'
          elsif files.has_grid?
            grid = files.grid(dirname) or raise("Can't find a grid named #{dirname}")
            he5var0 = grid.var( varname )
            gridtype = 'grid'
          elsif files.has_za?
            za = files.zonal(dirname) or raise("Can't find a zonal average named #{dirname}")
            he5var0 = za.var( varname )
            gridtype = 'za'
          else
            raise "Sorry. Currenly, only the Swath type is supported"
          end
	when HE5Sw
	  he5var0 = files.var( varname )
          gridtype = 'swath'
	when HE5Gd
	  he5var0 = files.var( varname )
          gridtype = 'grid'
        # when Regexp 
	else
	  raise TypeError, "argument files: not a HDF-EOS5, String, NArray, or Array"
	end
	[files, he5var0, varname, gridtype]
      end

      def __make_gd_axes(var0, grid, data)
        dim_names = var0.dim_names # 次元の名前
        unlocated_dim_names = var0.dim_names # まだ軸の決まっていない次元の名前
        unused_var_names = grid.var_names
        axes = Array.new

        # (#1) HDF-EOS5 standard rule.
        ["Longitude", "Latitude"].each do |provided_varname|
          unlocated_dim_names.each do |dim_nm|
            if (vary = __make_field_one_dimension(grid.var(provided_varname), dim_names.index(dim_nm)))
              axes.push(Axis.new().set_pos(vary))
              unlocated_dim_names.delete(dim_nm)
              unused_var_names.delete(provided_varname)
              break
            end
          end
        end
        if unused_var_names.include?("Longitude") || unused_var_names.include?("Latitude")
          raise("Sorry. Truely multidimensional longitudes/latitudes are yet to be supported. (2-dimensional lon/lat data that are actually one dimensional are supported.)")
        end

        # (#2) Empirical rule (from EOS-AURA, MLS, etc)
        # (#2-1) 軸が未確定の次元に対し、次元名と一致する名前を持つ1次元変数を座標変数として採用する
        unlocated_dim_names.each do |dim_nm|
          if unused_var_names.include?(dim_nm)
            vary = __files2varray( grid, dim_nm)
            if vary.rank == 1
              axes.push(Axis.new().set_pos(vary))
              unlocated_dim_names.delete(dim_nm)
              unused_var_names.delete(dim_nm)
            end
          end
        end

        # (#2-2) 軸が未確定の次元に対し、その次元を使って定義されている1次元変数を座標変数として採用する
        # (a) select variables match to Regexp. 
        @@predef_gdcoords.each do |reg_exp|
          unlocated_dim_names.each do |dim_nm|
            # get candidates
            candidate_var_names = Array.new
            unused_var_names.each do |var_nm|
              var = grid.var(var_nm)
              if reg_exp =~ var_nm && var.dim_names.include?(dim_nm)
                candidate_var_names.push(var_nm)
              end
            end
            
            # permute the candidates in order of length.
            candidate_var_names = candidate_var_names.sort {|a, b| a.length <=> b.length}
            candidate_var_names.each do |candidate|
              vary = __files2varray(grid, candidate)
              if vary.rank == 1
                axes.push(Axis.new().set_pos(vary))
                unlocated_dim_names.delete(dim_nm)
                unused_var_names.delete(candidate)
              end
              break if unlocated_dim_names.length == 0
            end
          end
        end

        # (#2-3) 座標変数はファイル中にないものとみなし，
        # ダミーとして 0,1,2,... が割り当てられるようにする．
        unlocated_dim_names.each do |dim_nm|
          nary_length = data.shape_current[dim_names.index(dim_nm)]
          nary = NArray[0...nary_length]
          vary = VArray.new(nary).rename(dim_nm + "_dummy")
          axis = Axis.new(false, true)
          axis.set_pos(vary)
          axes.push(axis)
        end

        return axes
      end
      private :__make_gd_axes

      def __make_za_axes(var0, za, data)
        dim_names = var0.dim_names # 次元の名前
        unlocated_dim_names = var0.dim_names # まだ軸の決まっていない次元の名前
        unused_var_names = za.var_names
        axes = Array.new

        # (#1) HDF-EOS5 standard rule is none.
        # (#2) Empirical rule (from EOS-AURA, MLS, etc)
        # (#2-1) 次元名と一致する名前を持つ1次元変数を座標変数として採用する
        unlocated_dim_names.each do |dim_nm|
          if unused_var_names.include?(dim_nm)
            vary = __files2varray( za, dim_nm)
            if vary.rank == 1
              axes.push(Axis.new().set_pos(vary))
              unlocated_dim_names.delete(dim_nm)
              unused_var_names.delete(dim_nm)
            end
          end
        end

        # (#2-2) 軸が未確定の次元に対し、その次元を使って定義されている1次元変数を座標変数として採用する
        # (a) select variables match to Regexp. 
        @@predef_zacoords.each do |reg_exp|
          unlocated_dim_names.each do |dim_nm|
            # get candidates
            candidate_var_names = Array.new
            unused_var_names.each do |var_nm|
              var = za.var(var_nm)
              if reg_exp =~ var_nm && var.dim_names.include?(dim_nm)
                candidate_var_names.push(var_nm)
              end
            end
            
            # permute the candidates in order of length.
            candidate_var_names = candidate_var_names.sort {|a, b| a.length <=> b.length}
            candidate_var_names.each do |candidate|
              vary = __files2varray(za, candidate)
              if vary.rank == 1
                axes.push(Axis.new().set_pos(vary))
                unlocated_dim_names.delete(dim_nm)
                unused_var_names.delete(candidate)
              end
              break if unlocated_dim_names.length == 0
            end
          end
        end

        # (#2-3) 座標変数はファイル中にないものとみなし，
        # ダミーとして 0,1,2,... が割り当てられるようにする．
        unlocated_dim_names.each do |dim_nm|
          nary_length = data.shape_current[dim_names.index(dim_nm)]
          nary = NArray[0...nary_length]
          vary = VArray.new(nary).rename(dim_nm + "_dummy")
          axis = Axis.new(false, true)
          axis.set_pos(vary)
          axes.push(axis)
        end

        return axes
      end
      private :__make_za_axes

      # dim_index に関して実質1次元の変数ならば VArray を返す。そうでなければ nil を返す。
      def __make_field_one_dimension(aHE5GdField, dim_index)
        rank = aHE5GdField.rank
        indexes = Array.new
        seps = (2**(-23).to_f) * 10
        deps = Float::EPSILON * 10 # (2**(-52).to_f) * 10
        permissible_diff = case aHE5GdField.simple_get.typecode
                           when NArray::SFLOAT, NArray::SCOMPLEX then seps
                           when NArray::DFLOAT, NArray::DCOMPLEX then deps
                           else 0
                           end

        for i in 0...rank do
          indexes.push(i) unless i == dim_index
        end
        mn = aHE5GdField.simple_get.min(*indexes)
        mx = aHE5GdField.simple_get.max(*indexes)
        maxdiff = (mx - mn).max
        maxval = ((mx1=mx.max)>(mx2=-mn.min)) ? mx1 : mx2        

        is_zero = (maxdiff/maxval <= permissible_diff)

        unless is_zero
          return nil 
        else
          ary = Array.new
          for j in 0...rank do
            if j == dim_index
              ary.push(true)
            else
              ary.push(0)
            end
          end
          return VArrayHE5GdField.new(aHE5GdField).[](*ary)
        end
      end          
      private :__make_field_one_dimension

    end
  end
end
######################################################
if $0 == __FILE__
   include NumRu
   require "numru/hdfeos5"
   require "numru/gphys/varray"

  ##### Read test #####
  # Swath
  #filename1, varname1 = "../../../testdata/MLS-Aura_L2GP-O3_v02-21-c01_2007d059.he5", "O3/L2gpValue"
  # Grid
  #filename1, varname1 = "../../../testdata/OMI-Aura_L3-OMAEROe_2008m0101_v003-2009m0114t114202.he5", "ColumnAmountAerosol/AerosolModelMW" 
  # Zonal Average
  filename1, varname1 = "../../../testdata/test_za.he5", "za1/Temperature"

  print "filename1 = \"#{filename1}\", varname1 = \"#{varname1}\"\n"
  file = HE5.open(filename1)
  print "zonal_names = "
  p file.zonal_names

  temp = GPhys::HE5_IO.open(file, varname1)

  print "temp = "
  p temp
exit

  ######



#   p temp.name, temp.shape_current
#   p temp.val.class
   temp2 = temp[true, 2]
#   p temp2.name, temp2.shape_current
   temp_xmean = temp#.average(0)
#   p temp.val
   temp_edy = ( temp - temp_xmean )
#   p '###',temp_edy.name,temp_edy.val[0,true]
#   p '@@@',temp
#   p '///',temp.copy
#   p '+++',temp2
   puts "\n** test write (tmp.he5) **"
   p v = temp_edy.axis(0).pos.copy.rename('lonlon')
   temp_edy.axis(0).set_aux('test',v)
   temp_edy.axis(0).set_aux('test2',(v/2).rename('lonlon2'))
   temp_edy.axis(0).set_aux('test2',(v/2).rename('lonlon3'))
  
  print "========== temp ===========\n"
  pp temp
  print "=====================\n"
  pp temp_edy
  print "========== temp_edy ==========\n"

  #### grid write test ####
  file2 = HE5.create('tmp.he5')
  gd = HE5Gd.create( file2, 'grid1', 1440, 720, [90.0, 180.0], [-90.0, -180.0])

  print "gd = "
  pp gd
  print "gd.gridinfo = "
  pp gd.gridinfo

  GPhys::HE5_IO.write(gd,temp_edy)
  file2.close
exit



#### swath write test ####
   file2 = HE5.create('tmp.he5')
   sw = HE5Sw.create( file2, 'swath1')

  print "sw = "
  pp sw

   GPhys::HE5_IO.write(sw,temp_edy)
   file2.close

   sw =  HE5Sw.create(file3 = HE5.create('tmp2.he5'),'swath1')
   GPhys::HE5_IO.write(sw,temp_xmean)
   file3.close

   p '** test composite **'

   temp = GPhys::HE5_IO.open(file,"O3/L2gpValue")
   sw = HE5Sw.create( f=HE5.create('tmp00.he5'), "swath3" )
   GPhys::HE5_IO.write( sw, temp[0..5,true] )
#   GPhys::HE5_IO.write( sw, temp[6..9,true] )
#   GPhys::HE5_IO.write( sw, temp[10..15,true] )
   f.close

=begin
   ###### Regexp test. ######
   files = /tmp(\d)(\d).he5/
   p gpcompo = GPhys::HE5_IO.open( files, "O3/L2gpValue")
   p gpcompo.coord(0).val
   p gpcompo[false,0].val
=end

  p '** test each_along_dims* **'

  f=HE5.create('tmpE1.he5')
  GPhys::HE5_IO.each_along_dims_write( temp, f, 1, 2 ){|sub|
    [sub.mean(0)]
  }
  f.close
  f=HE5.create('tmpE0.he5')
  GPhys::HE5_IO.write( f, temp.mean(0) )
  f.close

  print `he5dump tmpE0.he5 > tmpE0; he5dump tmpE1.he5 > tmpE1 ; diff -u tmpE[01]`

  f=HE5.create('tmpE2.he5')
  GPhys::HE5_IO.each_along_dims_write([temp,temp_edy], f, "level"){|s1,s2|
    [s1.mean(0),s2.mean(1).rename('T_edy')]
  }
  f.close

  f=HE5.create('tmpE3.he5')
  GPhys::HE5_IO.each_along_dims_write([temp,temp_xmean], f, "level"){|s1,s2|
    [s1.mean(1),s2.rename('T_x_mean'),s2.mean(0).rename('T_xy_mean')]
  }
  f.close

  print "\n\n** PACKED DATA TREATMENT **\n\n"

  file = HE5.open("../../../testdata/T.jan.packed.withmiss.he5")
  temp = GPhys::HE5_IO.open(file,"T")
  temp.att_names.each{|nm| p nm,temp.get_att(nm) if /(scale|offs)/ =~ nm}
  p( mls=temp.copy.att_names )
  p( (temp*10).att_names - mls )
  p( temp[0,false].copy.att_names - mls )


  print "\n\n** copying with write_grid **\n\n"
  f=HE5.create('tmpE4.he5')
  grid = GPhys::HE5_IO.write_grid(f,temp)
  p grid,grid.axis(0).pos.val
  f.close

  print "\n\n** axis conventions **\n\n"
  x = temp.axis(0).copy.to_gphys
  x.coord(0).set_att('topology','circular')
  x.coord(0).set_att('modulo',[360.0])
  p x
  f=HE5.create('tmpE5.he5')
  GPhys::HE5_IO.write_grid(f,x)
  f.close
  f=HE5.open('tmpE5.he5')
  x=GPhys::HE5_IO.open(f,'lon')
  p x.coord(0).axis_cyclic?
  p x.coord(0).axis_modulo



end
