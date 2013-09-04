=begin
=Status
* only a Lon-Lat coordinate is supported
* only simple pakking is supported
* variable list is not complete for NCEP and ECMWF
=end
require "narray_miss"
require "date"
require "time"

module NumRu
  module GribUtils
    require "numru/gphys/grib_params"
    private
    def str2uint1(str)
      return nil if str.length==0
      return str[0]
    end
    def str2uint2(str)
      return nil if str.length==0
      return (str[0]<<8)+str[1]
    end
    def str2uint3(str)
      return nil if str.length==0
      return (str[0]<<16)+(str[1]<<8)+str[2]
    end
=begin
    def str2uint(str)
      return nil until str
      return str.unpack("H*")[0].hex
    end
=end
    def str2int1(str)
      n = str2uint1(str)
      return n && n > 127 ? 128-n : n
    end
    def str2int2(str)
      n = str2uint2(str)
      return n && n > 32767 ? 32768-n : n
    end
    def str2int3(str)
      n = str2uint3(str)
      return n && n > 8388607 ? 8388608-n : n
    end
=begin
    def str2int(str)
      return nil if str.length==0
      ary = str.unpack("H*")
      top = ary[0]
      fact = 1
      if top[0,1]>"7"
        ary[0][0] = (top[0,1].hex-8).to_s
        fact = -1
      end
      return ary.join("").hex*fact
    end
=end
    def uint2str(i,len)
      str = [sprintf("%0#{len*2}x",i)].pack("H*")
      str.length==len || raise("str length is not valid")
      return str
    end
    def int2str(i,len)
      flag = i<0
      i = -i if flag
      str = sprintf("%0#{len*2}x",i)
      str[0..0] = sprintf("%x",str[0..0].hex+8) if flag
      str = [str].pack("H*")
      str.length==len || raise("str length is not valid")
      return str
    end
    def float_value( str )
      str.length==4 || raise("str length must be 4")
      sa = str2int1( str[0,1] )
      s = (sa<0) ? -1 : 1
      a = sa.abs
      b = str2uint3( str[1,3] )
      return s*(2.0)**(-24.0)*b*(16.0)**(a-64.0)
    end
    def get_bits( str, nstep, nbits, sbu, ebu, type )
      len = str.length
      bx = NArray.to_na(str,NArray::BYTE)
      nb = nbits/nstep
      y = NArray.new(type,nb).indgen(nb-1,-1)
      if nstep==8
        x = bx.to_type(type)
        y = 256**y
      elsif nstep==4
        x = NArray.new(type,2,len)
        x[0,true] = (bx&240)/16
        x[1,true] = bx&15
        x.reshape!(len*2)
        y = 16**y
      elsif nstep==2
        x = NArray.new(type,4,len)
        x[0,true] = (bx&192)/64
        x[1,true] = (bx&48)/16
        x[2,true] = (bx&12)/4
        x[3,true] = bx&3
        x.reshape!(len*4)
        y = 4**y
      else
        x = NArray.new(type,8,len)
        x[0,true] = (bx&128)/128
        x[1,true] = (bx&64)/64
        x[2,true] = (bx&32)/32
        x[3,true] = (bx&16)/16
        x[4,true] = (bx&8)/8
        x[5,true] = (bx&4)/4
        x[6,true] = (bx&2)/2
        x[7,true] = bx&1
        x.reshape!(len*8)
        y = 2**y
      end
      x = x[sbu..-1-ebu]
      x.reshape!(nb,x.length/nb)
      return (x*y).sum(0)
    end
    def data2str(data, nstep, nbits)
      len = data.length
      data.reshape!(len)
      nb = nbits/nstep
      x = NArray.byte(nb,len)
      nb.times{|n|
        x[nb-n-1,true] = (data/2**(n*nstep))&(2**nstep-1)
      }
      nb2 = 8/nstep
      y = NArray.byte(nb2).indgen(nb2-1,-1)
      y = (2**nstep)**y
      ebu = nb2-x.length%nb2
      ebu = 0 if ebu==nb2
      x2 = NArray.byte(x.length+ebu)
      x2[0..-1-ebu] = x.reshape!(x.length)
      x2.reshape!(nb2,x2.length/nb2)
      x2 = (x2*y).sum(0)
      return [x2.to_s,ebu*nstep]
    end

    def gausslat(ny)
      # this method was written by Y.Kitamura
      # and modified by S.Nishizawa
      glat    = NArray.sfloat(ny)
      gweight = NArray.sfloat(ny)

      eps = 1.0
      while (eps + 1.0 != 1.0)
        eps = eps/2.0
      end
      eps = eps*16.0

      0.upto(ny/2-1) do |i|
        y = Math::sin(Math::PI*(ny + 1.0 - 2.0*(i+1.0))/(2.0*ny + 1.0))
        tmp = 1.0
        while ((tmp/y).abs > eps)
          p0 = 0.0
          p1 = 1.0
          1.step(ny-1, 2) do |j|
            p0 = ((2*j-1)*y*p1 - (j-1)*p0)/j
            p1 = ((2*j+1)*y*p0 - j*p1)/(j+1)
          end
          p2 = ny*(p0 - y*p1)/(1.0 - y*y)
          tmp = p1/p2
          y = y - tmp
        end
        glat[i]      =  y
        glat[ny-i-1] = -y
        gweight[i]      = 1.0/(p2*p2*(1.0 - glat[i]*glat[i]))
        gweight[ny-i-1] = gweight[i]
      end
      return NMath::asin(glat)*180/Math::PI
    end

    def get_time(ary)
      d = (ary[0]-D19000101).to_i
      h,m = ary[1]
      return d*24+h+m/60
    end

  end

  class Grib
    private
    class GribSegment
      class << self
        include GribUtils
        def create(file)
          obj = GribSegment.new
          obj.file = file
          obj.is = GribIS.new(obj)
          obj.pds = GribPDS.new(obj)
          obj.gds = GribGDS.new(obj)
          obj.bms = GribBMS.new(obj)
          obj.bds = GribBDS.new(obj)
          obj.es = GribES.new(obj)
          obj.is.update_total_length
          return obj
        end
        def parse(file)
          obj = GribSegment.new
          obj.file = file
          obj.pos = file.pos

          is = GribIS.new(obj,file.read(8))
          unless is.grib?
            raise "This file is not Grib file (INITIAL SECTION)"
          end
          obj.is = is

          pds = GribPDS.new(obj,file.read(str2uint3(file.read(3))-3))
          obj.pds = pds

          str = pds.gds? ? file.read(str2uint3(file.read(3))-3) : nil
          gds = GribGDS.new(obj,str)
          obj.gds = gds

          str = pds.bms? ? file.read(str2uint3(file.read(3))-3) : nil
          bms = GribBMS.new(obj,str)
          obj.bms = bms

          len = str2uint3(file.read(3))
          bds = GribBDS.new(obj,file.pos,len)
          obj.bds = bds
          file.seek(len-3,IO::SEEK_CUR)

          es = GribES.new(obj,file.read(4))
          unless es.grib?
            raise "This file is not Grib file (END SECTION)"
          end
          obj.es = es

          if is.total_length!=is.length+pds.length+gds.length+bms.length+bds.length+es.length
            raise "total length is not equal to the sum of each section"
          end

          return obj
        end
      end
      attr_accessor :file, :pos
      attr_accessor :is, :pds, :gds, :bms, :bds, :es
      def set_xy(x,y)
        pds.set_gds(true)
        if x.att("long_name").downcase=="longitude" && y.att("long_name").downcase=="latitude"
          xv = x.val
          yv = y.val
          rel = false
          if (xv[1]-xv[0])==(xv[-1]-xv[-2]) && (yv[1]-yv[0])==(yv[-1]-yv[-2])
            id = 0
          else
            raise "not defined yet"
          end
        elsif y.att("long_name").downcase=="longitude" && x.att("long_name").downcase=="latitude"
          xv = y.val
          yv = x.val
          rel = true
          if (xv[1]-xv[0])==(xv[-1]-xv[-2]) && (yv[1]-yv[0])==(yv[-1]-yv[-2])
            id = 0
          else
            raise "not defined yet"
          end
        else
          raise "not defined yet"
        end
        gds.set_grid(id,xv,yv,rel)
      end
      def set_level(z)
        if Array===z
          id = Z_TYPES.invert[Z_TYPES.values.assoc(z[0])]
          id = 100 if id.nil?
          pds.set_z_id(id)
          pds.set_z_value(z[1])
        else
          id = Z_TYPES.invert[Z_TYPES.values.assoc(z)]
          pds.set_z_id(id)
        end
      end
      def set_time(t)
        if String===t
          ye,mo,da,ho,mi, = Time.parse(t).to_a.reverse![4..-2]
        else
          if t.nil?
            ye = 0
            mo = 1
            da = 1
            ho = 0
            mi = 0
          else
            d = D19000101 + t/24
            ye = d.year
            mo = d.month
            da = d.day
            ho = t%24
            mi = 0
          end
        end
        pds.set_initial(ye,mo,da,ho,mi)
      end
      def set_var(var,name,units)
        is.set_version(1)
        pds.set_version(2)
        pds.set_center_id(0)
        pds.set_pid(0)
        id = PARAMS_2.invert[NAMES_UNITS.invert[NAMES_UNITS.values.assoc(name)]]
        id = 000 if id.nil?
        pds.set_name_id(id)
        pds.set_time_unit_id(0)
        pds.set_p1(0)
        pds.set_p2(0)
        pds.set_time_range_id(1)
        pds.set_ave(0)
        pds.set_miss(0)
        pds.set_sub_center_id(0)
        pds.set_dfact(0)
        if NArrayMiss===var
          mask = var.get_mask!
          if mask.count_false>0
            pds.set_bms(true)
            bms.set_map_number(0)
            bms.set_map(mask)
          end
        end
        bds.set_grid(true)
        bds.set_simple(true)
        if units && pds.unit
          f,o = Units[units].factor_and_offset(Units[pds.unit])
          var = var*f+o
        end
        if var.typecode==NArray::SINT || var.typecode==NArray::INT
          bds.set_ingeger(true)
        else
          bds.set_float(true)
        end
        bds.set_value(var)
      end
      def write
        tlen = is.update_total_length
        len = 0
        len += @file.write(is.get)
        len += @file.write(pds.get)
        len += @file.write(gds.get)
        len += @file.write(bms.get)
        len += @file.write(bds.get)
        len += @file.write(es.get)
        tlen==len || raise("length is not correct")
      end
    end # end definition of class GribSegment
    class GribIS
      include GribUtils
      def initialize(sgm,str=nil)
        @sgm = sgm
        @is = str || "GRIB"+uint2str(8,3)+uint2str(2,1)
      end
      def length
        return 8
      end
      def grib?
        return @is[0..3]=="GRIB"
      end
      def total_length
        return str2uint3( @is[4,3] )
      end
      def update_total_length
        len = self.length+@sgm.pds.length+@sgm.gds.length+@sgm.bms.length+@sgm.bds.length+@sgm.es.length
        @is[4..6] = uint2str(len,3)
        return len
      end
      def varsion
        return str2uint1( @is[7,1] )
      end
      def set_version(ver)
        @is[7..7] = uint2str(ver,1)
        return ver
      end
      alias :version= :set_version
      def get
        @is
      end
    end # end definition of class GribIS
    class GribPDS
      include GribUtils
      private
      def param
        nid = str2uint1(@pds[5,1])
        params = nil
        case version
        when 0
          params = PARAMS_0
        when 1
          params = PARAMS_1
        when 2,3
          if nid<128
            params = PARAMS_2
          else
            if cid==7 # NCEP
              params = PARAMS_NCEP_2
            end
          end
        else
          if cid==98 # ECMWF
            if version==128
              params = PARAMS_ECMWF_128
            elsif version == 162
              params = PARAMS_ECMWF_162
            end
          end
        end
        if params
          if para_id = params[nid]
            if para = NAMES_UNITS[para_id]
              return para
            else
              $stderr.printf "parameter ID #{nid} in version #{version} has not defined yet\n"
            end
          else
            $stderr.printf "parameter ID #{nid} in version #{version} has not defined yet\n"
          end
        else
          $stderr.printf "parameter table version #{version} has not defined yet\n"
        end
        return ["unknown (#{nid})", nid.to_s, "-", nil]
      end
      def cid
        return str2uint1(@pds[1,1])
      end
      def initialize(sgm,str=nil)
        @sgm = sgm
        @pds = str || "\000"*25
      end
      public
      def length
        @pds.length+3
      end
      def version
        return str2uint1( @pds[0,1] )
      end
      def set_version(ver)
        @pds[0..0] = uint2str(ver,1)
        return ver
      end
      alias :version= :set_version
      def center
        return CENTERS[cid]
      end
      def set_center_id(id)
        @pds[1..1] = uint2str(id,1)
      end
      alias :center_id= :set_center_id
      def pid
        return str2uint1( @pds[2,1] )
      end
      def set_pid(id)
        @pds[2..2] = uint2str(id,1)
        return id
      end
      alias :pid= :set_pid
      def gid
        return str2uint1( @pds[3,1] )
      end
      def set_gid(id)
        @pds[3..3] = uint2str(id,1)
        return id
      end
      alias :gid= :set_gid
      def gds?
        flag = str2uint1( @pds[4,1] )
        return (flag>>7)&1==1
      end
      def set_gds(gds)
        flag = bms? ? 64 : 0
        if gds
          flag += 128
          @pds[4..4] = uint2str(flag,1)
          @sgm.gds.exist
          set_gid(255)
          return true
        else
          @pds[4..4] = uint2str(flag,1)
          @sgm.gds.not_exist
          return false
        end
      end
      alias :gds= :set_gds
      def bms?
        flag = str2uint1( @pds[4,1] )
        return (flag>>6)&1==1
      end
      def set_bms(bms)
        flag = gds? ? 128 : 0
        if bms
          flag += 64
          @pds[4..4] = uint2str(flag,1)
          @sgm.bms.exist
          return true
        else
          @pds[4..4] = uint2str(flag,1)
          @sgm.bms.not_exist
          return false
        end
      end
      alias :bms= :set_bms
      def name
        return param[0]
      end
      def standard_name
        return param[3]
      end
      def set_name_id(id)
        @pds[5..5] = uint2str(id,1)
        return id
      end
      alias :name_id= :set_name_id
      def sname
        zid = str2uint1( @pds[6,1] )
        sn = param[1]
        zt = Z_TYPES[zid]
        zn = zt ? zt[1] : zid.to_s
        return zn=="level" ? sn : sn+"_"+zn
      end
      def unit
        return param[2]
      end
      def z_type
        zid = str2uint1( @pds[6,1] )
        zt = Z_TYPES[zid]
        if zt
          return zt[0]
        else
          $stderr.printf "z type (#{zid}) is not defined yet\n"
          return zid.to_s
        end
      end
      def set_z_id(id)
        @pds[6..6] = uint2str(id,1)
        return id
      end
      alias :z_id= :set_z_id
      def z_sname
        zid = str2uint1( @pds[6,1] )
        if zn = Z_TYPES[zid]
          return zn[1]
        else
          $stderr.printf "z type (#{zid}) is not defined yet\n"
          return "unknown_#{zid}"
        end
      end
      def z_value
        type = str2uint1( @pds[6,1] )
        str = @pds[7,2]
        ary = Z_LEVELS[type]
        if ary.nil?
          ary = []
        else
          ary = ary.dup
        end
        if ary.length==1
          ary[0] = ary[0].dup.update( {"value"=> str2uint2(str)} )
        elsif ary.length==2
          ary[0] = ary[0].dup.update( {"value"=> str2uint1(str[0,1])} )
          ary[1] = ary[1].dup.update( {"value"=> str2uint1(str[1,1])} )
        end
        return ary
      end
      def set_z_value(val)
        type = str2uint1( @pds[6,1] )
        ary = Z_LEVELS[type]
        val.length==ary.length || raise("length of val is not collect")
        if val.length==1
          @pds[7,2] = uint2str(val[0],2)
        elsif val.length==2
          @pds[7,1] = uint2str(val[0],1)
          @pds[8,1] = uint2str(val[1],1)
        else
          raise "length of val is too large"
        end
        return val
      end
      alias :z_value= :set_z_value
      def initial
        return [str2uint1( @pds[21,1] ), str2uint1( @pds[9,1] ), str2uint1( @pds[10,1] ), str2uint1( @pds[11,1] ), str2uint1( @pds[12,1] ), str2uint1( @pds[13,1] )]
      end
      def set_initial(year,month,day,hour,min)
        cent = year/100+1
        year = year%100
        @pds[21,1] = uint2str(cent,1)
        @pds[9,1] = uint2str(year,1)
        @pds[10,1] = uint2str(month,1)
        @pds[11,1] = uint2str(day,1)
        @pds[12,1] = uint2str(hour,1)
        @pds[13,1] = uint2str(min,1)
        return initial
      end
      alias :initial= :set_initial
      def date
        d = Date.new((str2uint1( @pds[21,1] )-1)*100+str2uint1( @pds[9,1] ),
                     str2uint1( @pds[10,1] ),
                     str2uint1( @pds[11,1] ) )
        h = [str2uint1( @pds[12,1] ),str2uint1( @pds[13,1] )]
        return [d,h]
      end
      def time_unit
        return TIME_UNITS[ str2uint1( @pds[14,1] ) ]
      end
      def set_time_unit_id(id)
        @pds[14,1] = uint2str(id,1)
        return id
      end
      alias :time_unit_id= :set_time_unit_id
      def p1
        return str2uint1( @pds[15,1] )
      end
      def set_p1(i)
        @pds[15,1] = uint2str(i,1)
        return i
      end
      alias :p1= :set_p1
      def p2
        return str2uint1( @pds[16,1] )
      end
      def set_p2(i)
        @pds[16,1] = uint2str(i,1)
        return i
      end
      alias :p2= :set_p2
      def time_range
        return str2uint1( @pds[17,1] )
      end
      def set_time_range_id(id)
        @pds[17,1] = uint2str(id,1)
        return id
      end
      alias :time_range_id= :set_time_range_id
      def ave
        return str2uint2( @pds[18,2] )
      end
      def set_ave(val)
        @pds[18,2] = uint2str(val,2)
        return val
      end
      alias :ave= :set_ave
      def miss
        return str2uint1( @pds[20,1] )
      end
      def set_miss(val)
        @pds[20,1] = uint2str(val,1)
        return val
      end
      alias :miss= :set_miss
      def sub_center
        return str2uint1( @pds[22,1] )
      end
      def set_sub_center_id(id)
        @pds[22,1] = uint2str(id,1)
        return id
      end
      alias :sub_center_id= :set_sub_center_id
      def dfact
        return str2int2( @pds[23,2] )
      end
      def set_dfact(val)
        @pds[23..24] = int2str(val,2)
        return val
      end
      alias :dfact= :set_dfact
      def get
        uint2str(length,3)<<@pds
      end
    end # end definition of class GribPDS
    class GribGDS
      include GribUtils
      private
      def gtype
        return str2uint1( @gds[2,1] )
      end
      def get_x_y(grid)
      case gtype
        when 0,4
          #lon_lat (+GussLat)
          flag = str2uint1( grid[10,1] )
          flag_inc = (flag>>7)&1
          flag = str2uint1( grid[21,1] )
          flag_scani = (flag>>7)&1
          flag_scanj = (flag>>6)&1
          flag_ij = (flag>>5)&1

          lon = Hash.new
          lon["short_name"] = "lon"
          lon["long_name"] = "longitude"
          lon["units"] = "degrees_east"
          nlon = str2uint2( grid[0,2] )
          nlon=="ffff".hex && raise("not defined yet")
          lo1 = str2int3( grid[7,3] )
          lo2 = str2int3( grid[14,3] )
          dlon = str2uint2( grid[17,2] )
          if (!flag_inc)&&dlon==-"7fff".hex
            dlon = (lo2-lo1)/(nlon-1)
          else
            if lo1>lo2
              if dlon*(nlon-1)!=lo1-lo2
                lo2 += 360000
              else
                dlon = -dlon
              end
            end
          end
          dlon2 = (lo2-lo1).to_f/(nlon-1)
          dlon2.round==dlon.round || $stderr.print("Warning: dlon is not same: #{dlon2/1000} != #{dlon.to_f/1000}\n")
          vlon = NArray.sfloat(nlon).indgen*dlon2+lo1
          if flag_scani==1
            vlon = vlon[-1..0]
          end
          lon["value"] = vlon/1000
          lon["length"] = vlon.length

          lat = Hash.new
          lat["short_name"] = "lat"
          lat["long_name"] = "latitude"
          lat["units"] = "degrees_north"
          nlat = str2uint2( grid[2,2] )
          nlat=="ffff".hex && raise("not defined yet")
          la1 = str2int3( grid[4,3] )
          la2 = str2int3( grid[11,3] )
          dlat = str2uint2( grid[19,2] )
          if gtype==0
            if (!flag_inc)&&dlat==-"7fff".hex
              dlat = (la2-la1)/(nlat-1)
            else
              dlat = -dlat if la1>la2
            end
            dlat2 = (la2-la1).to_f/(nlat-1)
            dlat2.round==dlat.round || raise("dlat is not same: #{dlat2/1000} != #{dlat.to_f/1000}\n")
            vlat = NArray.sfloat(nlat).indgen*dlat2+la1
            vlat = vlat/1000
          elsif gtype==4
            j = NArray.sfloat(dlat*2).indgen(1)
#            glat = NMath::asin(NMath::cos((j-0.5)*Math::PI/dlat/2))*180/Math::PI
            glat = gausslat(dlat*2)
            glat = glat[-1..0] if la1>la2
            tmp = (glat-la1.to_f/1000).abs
            is = tmp.eq(tmp.min).where[0]
            tmp = (glat-la2.to_f/1000).abs
            ie = tmp.eq(tmp.min).where[0]
            vlat = glat[is..ie]
            vlat.length==nlat || raise("length of latitude is not same: #{vlat.length} != #{nlat}")
            (vlat[0]*1000).round==la1.round || $stderr.printf("Warning: first of latitude is not same: #{vlat[0]} != #{la1.to_f/1000}\n")
            (vlat[-1]*1000).round==la2.round || $stderr.printf("Warning: last of latitude is not same: #{vlat[-1]} != #{la2.to_f/1000}\n")
            lat["type"] = "Gaussian latitude"
            lat["number_of_latitude_circles"] = NArray[dlat*2]
          end
          if flag_scanj==1
            vlat = vlat[-1..0]
          end
          lat["value"] = vlat
          lat["length"] = vlat.length

          if flag_ij==0
            lon["ij"] = 0
            lat["ij"] = 1
          else
            lon["ij"] = 1
            lat["ij"] = 0
          end
          return [lon,lat]
        when 1
          #mercator
          raise "not defined yet"
        when 3
          #lambert
          raise "not defined yet"
        when 5
          #polar
          raise "not defined yet"
        when 50
          #spherical
          raise "not defined yet"
        when 90
          #space
          raise "not defined yet"
        else
          raise "not defined yet"
        end
      end
      def grid2str(gtype,x,y,rev=false)
        case gtype
        when 0,4
          #lat_lon
          grid = "\000"*26
          nlon = x.length
          nlat = y.length
          grid[0,2] = uint2str(nlon,2)
          grid[2,2] = uint2str(nlat,2)
          vlon = x*1000
          vlat = y*1000
          grid[4,3] = int2str(vlat[0],3)
          grid[7,3] = int2str(vlon[0],3)
          flag = 1<<7
          grid[10,1] = uint2str(flag,1)
          grid[11,3] = int2str(vlat[-1],3)
          grid[14,3] = int2str(vlon[-1],3)
          dlon = ((vlon[-1]-vlon[0])/(nlon-1)).abs
          grid[17,2] = uint2str(dlon,2)
          if gtype==0
            dlat = ((vlat[0]-vlat[-1])/(nlat-1)).abs
            grid[19,2] = uint2str(dlat,2)
          else
            raise "not defined yet"
          end
          if rev
            flag=1<<5
          else
            flag=0
          end
          grid[21,1] = uint2str(flag,1)
          return grid
        when 1
          #mercator
          raise "not defined yet"
        when 3
          #lambert
          raise "not defined yet"
        when 5
          #polar
          raise "not defined yet"
        when 50
          #spherical
          raise "not defined yet"
        when 90
          #space
          raise "not defined yet"
        else
          raise "not defined yet"
        end
      end
      def initialize(sgm,str=nil)
        @sgm = sgm
        @gds = str
      end

      public
      def exist
        @gds = "\000"*41
        @gds[1,1] = uint2str(255,1)
        @sgm.is.update_total_length
      end
      def not_exist
        @gds = nil
        @sgm.is.update_total_length
      end
      def length
        if @gds
          return @gds.length+3
        else
          return 0
        end
      end
      def nv
        return str2uint1( @gds[0,1] )
      end
      def pv
        pv = str2uint1( @gds[1,1] )
        return nil if pv==255 || nv==0
        return pv
      end
      def pl
        pl = str2uint1( @gds[1,1] )
        return nil if pl==255
        return nv*4+pl
      end
      def grid_type
        return GRID_TYPES[ gtype ]
      end
      def grid
        if gtype==3||gtype==1
          grid = @gds[3..38]
        elsif gtype==90
          grid = @gds[3..40]
        else
          grid = @gds[3..28]
        end
        return get_x_y(grid)
      end
      def set_grid(id,x,y,rev)
        @gds[2..2] = uint2str(id,1)
        if id==3||id==1
          str = grid2str(id,x,y,rev)
          str.length==36 || raise("length is not correct")
          @gds[3..38] = str
          @sgm.is.update_total_length
        elsif id==90
          str = grid2str(id,x,y,rev)
          str.length==38 || raise("length is not correct")
          @gds[3..40] = str
          @sgm.is.update_total_length
        else
          str = grid2str(id,x,y,rev)
          str.length==26 || raise("length is not correct")
          @gds[3..28] = str
          @sgm.is.update_total_length
        end
        return [id,x,y]
      end
      def list_pv
        return nil unless pv
        list = NArray.float(nv)
        nv.times{|n|
          list[n] = float_value( @gds[pv-4+n*4...pv-4+(n+1)*4] )
        }
        return list
      end
      def set_list_pv(list)
        nv = list.length/4
        @gds[0..0] = uint2str(nv,1)
        raise "not defined yet"
        if gtype==3||gtype==1
          pv = 43
        elsif gtype==90
          pv = 45
        else
          pv = 33
        end
        @gds[1..1] = uint2str(pv,1)
        @gds[pv-4..-1] = list
        return true
      end
      alias :list_pv= :set_list_pv
      def list_pl
        return @gds[pl-4..-1] if pl
        return nil
      end
      def set_list_pl(list)
        raise "not defined yet"
        pl = nv*4+pv
        @gds[1..1] = uint2str(pl,1)
        @gds[pl-4..-1] = list
        return true
      end
      alias :list_pv= :set_list_pv
      def eq?(str)
        @gds==str
      end
      def ==(other)
        if GribGDS===other
          return other.eq?(@gds)
        else
          return false
        end
      end
      def get
        @gds && uint2str(length,3)<<@gds
      end
    end # end definition of class GribGDS
    class GribBMS
      include GribUtils
      def initialize(sgm,str=nil)
        @sgm = sgm
        @bms = str
      end
      def exist
        @bms = "\000"*3
        @sgm.is.update_total_length
      end
      def not_exist
        @bms = nil
        @sgm.is.update_total_length
      end
      def length
        if @bms
          return @bms.length+3
        else
          return 0
        end
      end
      def map_number
        nmap = str2uint2( @bms[1,2] )
        nmap = false if nmap==0
        return nmap
      end
      def set_map_number(n)
        @bms[1..2] = uint2str(n,2)
        return n
      end
      alias :map_number= :set_map_number
      def has_map?
        return nil if @bms.nil?
        return !map_number
      end
      def map
        return nil unless has_map?
        return get_bits( @bms[3..-1], 1,1, 0,str2uint1(@bms[0,1]), NArray::BYTE )
      end
      def set_map(mask)
        map,n = data2str(mask,1,1)
        @bms[0..0] = uint2str(n,1)
        @bms = @bms[0,3]<<map
        @sgm.is.update_total_length
        return true
      end
      def get
        @bms && uint2str(length,3)<<@bms
      end
    end # end definition of class GribBMS
    class GribBDS
      include GribUtils
      private
      def oct4
        return @oct4 if @oct4
        @sgm.file.seek(@pos, IO::SEEK_SET)
        @oct4 = str2uint1( @sgm.file.read(1) ) 
        return @oct4
      end
      def oct14
        return nil if flag4==0
        return @oct14 if @oct14
        @sgm.file.seek(@pos+10, IO::SEEK_SET)
        @oct14 = str2uint1( @sgm.file.read(1) )
        return @oct14
      end
      def flag1
        return (oct4>>7)&1
      end
      def flag2
        return (oct4>>6)&1
      end
      def flag3
        return (oct4>>5)&1
      end
      def flag4
        return (oct4>>4)&1
      end
      def flag6
        return oct14 && (oct14>>6)&1
      end
      def flag7 
        return oct14 && (oct14>>5)&1
      end
      def flag8
        return oct14 && (oct14>>4)&1
      end
      def initialize(sgm,pos=nil,len=nil)
        @sgm = sgm
        @pos = pos
        if @pos.nil?
          @bds = "\000"*8
          @oct4 = 0
          @oct14 = 0
        else
          @length = len
        end
      end
      def get_value(file,pos,sb,eb,nbits,nstep)
        sbu = (sb%8)/nstep
        sb = sb/8
        ebu = eb%8
        ebu = (8-eb%8)/nstep unless ebu==0
        eb = (eb+7)/8
        return NArray.float(0) if (eb-sb)==0
        file.seek(pos+sb,IO::SEEK_SET)
        str = file.read(eb-sb)
        return get_bits(str,nstep,nbits,sbu,ebu,NArray::FLOAT)
      end

      public
      def length
        if @pos
          return @length
        else
          return @bds.length+3
        end
      end
      def grid?
        return flag1==0
      end
      def set_grid(l)
        @oct4 = oct4&"7f".hex
        @oct4 += 128 unless l
        @bds[0,1] = uint2str(@oct4,1)
        return l
      end
      def spectrum?
        return flag1==1
      end
      def set_spectrum(l)
        @oct4 = oct4&"7f".hex
        @oct4 += 128 if l
        @bds[0,1] = uint2str(@oct4,1)
        return l
      end
      def simple?
        return flag2==0
      end
      def set_simple(l)
        @oct4 = oct4&"bf".hex
        @oct4 += 64 unless l
        @bds[0,1] = uint2str(@oct4,1)
        return l
      end
      def complex?
        return flag2==1
      end
      def set_complex(l)
        @oct4 = oct4&"bf".hex
        @oct4 += 64 if l
        @bds[0,1] = uint2str(@oct4,1)
        return l
      end
      def float?
        return flag3==0
      end
      def set_float(l)
        @oct4 = oct4&"df".hex
        @oct4 += 32 unless l
        @bds[0,1] = uint2str(@oct4,1)
        return l
      end
      def integer?
        return flag3==1
      end
      def set_integer(l)
        @oct4 = oct4&"df".hex
        @oct4 += 32 if l
        @bds[0,1] = uint2str(@oct4,1)
        return l
      end
      def single?
        return flag6 && flag6==0
      end
      def set_single(l)
        @oct14 = oct14&"7f".hex
        @oct14 += 128 unless l
        @oct4 = (oct4&"ef".hex)+16
        @bds[0,1] = uint2str(@oct4,1)
        @bds[10,1] = uint2str(@oct14,1)
        return l
      end
      def matrix?
        return flag6 && flag6==1
      end
      def set_matrix(l)
        @oct14 = oct14&"7f".hex
        @oct14 += 128 if l
        @oct4 = (oct4&"ef".hex)+16
        @bds[0,1] = uint2str(@oct4,1)
        @bds[10,1] = uint2str(@oct14,1)
        return l
      end
      def bit_maps?
        return flag7 && flag7==1
      end
      def set_bit_map(l)
        @oct14 = oct14&"bf".hex
        @oct14 += 64 if l
        @oct4 = (oct4&"ef".hex)+16
        @bds[0,1] = uint2str(@oct4,1)
        @bds[10,1] = uint2str(@oct14,1)
        return l
      end
      def constant?
        return flag8 && flag8==0
      end
      def set_constant(l)
        @oct14 = oct14&"df".hex
        @oct14 += 32 unless l
        @oct4 = (oct4&"ef".hex)+16
        @bds[0,1] = uint2str(@oct4,1)
        @bds[10,1] = uint2str(@oct14,1)
        return l
      end
      def offset
        return @offset if @offset
        @sgm.file.seek(@pos+3, IO::SEEK_SET)
        @offset = float_value(@sgm.file.read(4))
        return @offset
      end
      def efactor
        return @efactor if @efactor
        @sgm.file.seek(@pos+1, IO::SEEK_SET)
        @efactor = 2.0**str2int2( @sgm.file.read(2) )
        return @efactor
      end
      def value(shape,*arg)
        nbits_unuse = oct4&15
        @sgm.file.seek(@pos+7, IO::SEEK_SET)
        nbits_pack = str2uint1( @sgm.file.read(1) )
        if (nbits_pack%8) == 0
          nstep = 8
        elsif (nbits_pack%4) == 0
          nstep = 4
        elsif (nbits_pack%2) == 0
          nstep = 2
        else
          nstep = 1
        end
        r = offset
        e = efactor
        map = @sgm.bms.map
        nmiss =  map ? map.count_false : 0
        if flag4==0
          nlen = ((length-3-8)*8-nbits_unuse)/nbits_pack
          nlon,nlat = shape
          (nlon*nlat)==nlen+nmiss || raise("length is not collect")
          if arg.length!=0
            index, shape2 = arg
            index = index.collect{|el| Fixnum===el ? el..el : el }
            j = nil
            i = nil
            if map
              var = NArrayMiss.float(*shape2)
              map.reshape!(nlon,nlat)
              mask = map[*index]
              index[1].each{|j|
                jj = j-index[1].first
                sb = j*nlon+index[0].first
                sb = sb-map[true,0..jj-1].count_false if jj>0
                sb = sb*nbits_pack
                eb = sb+mask[true,j].count_true*nbits_pack
                if sb!=eb
                  var[mask[true,j].where,jj] = get_value(@sgm.file,@pos+8,sb,eb,nbits_pack,nstep)
                end
              }
            else
              var = NArray.float(*shape2)
              index[1].each{|j|
                sb = (j*nlon+index[0].first)*nbits_pack
                eb = (j*nlon+index[0].end+1)*nbits_pack
                jj = j-index[1].first
                var[true,jj] = get_value(@sgm.file,@pos+8,sb,eb,nbits_pack,nstep)
              }
            end
          else
            if map
              eb = nlen*nbits_pack
              var = NArrayMiss.float(nlon,nlat)
              var[map.where] = get_value(@sgm.file,@pos+8,0,eb,nbits_pack,nstep)
            else
              eb = nlen*nbits_pack
              var = get_value(@sgm.file,@pos+8,0,eb,nbits_pack,nstep)
              var.reshape!(nlon,nlat)
            end
          end
          var = var*e+r
          return var
        else
          raise "not defined yet"
          n1 = str2uint2( @file.read(2) )
          @sgm.file.seek(1, IO::SEEK_CUR)
          n2 = str2uint2( @sgm.file.read(2) )
          p1 = str2uint2( @sgm.file.read(2) )
          p2 = str2uint2( @sgm.file.read(2) ) # @bds[15..16]
          #        width = str2uint( @bds[18..??] )
          #        bitmap = str2uint( @bds[??+1..n1-4] )
        end
      end
      def set_value(val)
        val = val.reshape!(val.length)
        if NArrayMiss===val
          val = val.get_array![val.get_mask!.where]
        end
        dfact = @sgm.pds.dfact
        val = val*10**dfact
        ref = val.min
        val = val-ref
        max = val.max
        nbits = 16
        e =  (Math::log(max)/Math::log(2)).ceil-nbits
        val = val*2**(-e)
        if (nbits%8) == 0
          nstep = 8
        elsif (nbits%4) == 0
          nstep = 4
        elsif (nbits%2) == 0
          nstep == 2
        else
          nstep == 1
        end
        str, bu = data2str(val.to_type(NArray::INT),nstep,nbits)
        @oct4 = (@oct4&15)+bu*16
        @bds[0,1] = uint2str(@oct4,1)
        @bds[1,2] = int2str(e,2)
        s = (ref<0) ? -1 : 1
        ref = ref.abs
        a = (Math::log(ref)/Math::log(16)).ceil+64
        a<0 && raise("invalid range")
        a = 127 if a>127
        b = ref*2**24*16**(64-a)
        a = a*s
        @bds[3,4] = int2str(a,1)<<uint2str(b,3)
        @bds[7,1] = uint2str(nbits,1)
        @bds = @bds[0,8]<<str
        @sgm.is.update_total_length
      end
      def get
        uint2str(length,3)<<@bds
      end
    end # end definition of class GribBDS
    class GribES
      def initialize(sgm,str=nil)
        @sgm = sgm
        @es = str || "7777"
      end
      def length
        return 4
      end
      def grib?
        @es=="7777"
      end
      def get
        @es
      end
    end # end definition of class GribES

    def initialize(fname,mode="r")
      case mode
      when "r","rb"
	mode = "rb"
      when "w","wb"
	mode = "wb"
      else
        raise "Unsupported file mode '#{mode}'. Use 'r' or 'w'."
      end
      @file = File.open(fname, mode)
      @vars = Hash.new
      @attr = Hash.new
    end

    public
=begin
=NumRu::Grib  -- a class for Grib datasets

==Class Methods
---Grib.new(filename, mode="r")
   make a new Grib object.

   ARGUMENTS
   * filename (String): name of the file to open
   * mode (String): IO mode. "r" (read only) or "w" (write only).

---Grib.open(filename)
   open a Grib file.

---Grib.create(filename)
   create a Grib file.

---Grib.is_aGrib?(filename)
   return true when file is a Grib dataset

==Methods
---close
---parse
---path
---var_names
---var( name )
---def_var( name )
---enddef
---write
=end
    class << self
      def is_a_Grib?(fname)
        file = nil
        begin
          file = File.open(fname,"rb")
          is = (file.read(4) == "GRIB")
        ensure
          file.close if file
        end
        return defined?(is) && is
      end
      def open(fname)
        f = Grib.new(fname,"r")
        f.parse
        return f
      end
      def create(fname)
        Grib.new(fname,"w")
      end
    end

    def close
      @grib_vars = nil
      @vars = nil
      @attr = nil
      @file.close
    end
    def parse
      @file.rewind
      while true
        @file.read(1)=="\000" && next
        @file.eof? && break
        @file.seek(-1, IO::SEEK_CUR)
        sgm = GribSegment.parse(@file)
        name = sgm.pds.sname
        if @vars.has_key?(name)
          @vars[name].push(sgm)
        else
          @vars[name] = [sgm]
        end
      end
      return self
    end
    def path
      @file.path
    end
    def var_names
      @vars.keys
    end
    def var(name)
      var = @vars[name]
      return nil if var.nil?
      return GribVar.parse(self,var,name)
    end
    def def_var(name)
      until @file.stat.writable?
        raise("File #{@file.path} is not writable.")
      end
      if !String===name
        raise "def_var(String)"
      end
      raise "#{name} is already defined" if @vars.has_key?(name)
      var = GribVar.new(@file,name)
      @vars[name] = var
      return var
    end
    def att_names
      @attr.keys
    end
    def att(name)
      @attr[name]
    end
    def write
      iz=0
      it=0
      izmax = 0
      vn = var_names
      @file.rewind
      while (vn.length>0)
        vn.dup.each{|name|
          var = @vars[name]
          sgm = nil
          if var.rank==2
            sgm = GribSegment.create(@file)
            val = [var.get,var.att("long_name"),var.att("units")]
            z = var.att("level")
            t = var.att("time")
            vn.delete(name)
          elsif var.rank==4
            sha = var.shape
            izmax < sha[2] && izmax = sha[2]
            if iz<sha[2]&&it<sha[3]
              sgm = GribSegment.create(@file)
              val = [var[true,true,iz,it],var.att("long_name"),var.att("units")]
              zd = var.dim(2)
              zv = zd.get
              if Array===zv
                zv = zv.collect{|a| a["value"][iz] }
              else
                zv = [zv[iz]]
              end
              z = [zd.att("long_name"), zv]
              t = var.dim(3)[it]
            elsif it==sha[3]
              vn.delete(name)
            end
          elsif !var.dim_names.include?("time")
            sha = var.shape
            izmax < sha[2] && izmax = sha[2]
            if iz<sha[2]
              sgm = GribSegment.create(@file)
              val = [var[true,true,iz],var.att("long_name"),var.att("units")]
              zd = var.dim(2)
              zv = zd.get
              if Array===zv
                zv = zv.collect{|a| a["value"][iz] }
              else
                zv = [zv[iz]]
              end
              z = [zd.att("long_name"), zv]
              t = var.att("time")
            end
            vn.delete(name) if iz==sha[2]-1
          else
            sha = var.shape
            if it<sha[2]
              sgm = GribSegment.create(@file)
              val = [var[true,true,it],var.att("long_name"),var.att("units")]
              z = var.att("level")
              t = var.dim(2)[it]
            else
              vn.delete(name)
            end
          end
          if sgm
            sgm.set_xy(var.dim(0),var.dim(1))
            sgm.set_level(z)
            sgm.set_time(t)
            sgm.set_var(*val)
            sgm.write
          end
          if iz==izmax-1
            iz = 0
            it += 1
          else
            iz += 1
          end
        }
      end
    end
    def inspect
      "Grib: #{path}"
    end
  end # end of definition of class Grib

=begin
=NumRu::GribDim

==Class Methods
---new( vat, name, length )

==Methods
---var
---length
---name
---typecode
---get
---[](indices)
---put_att(key,val)
---set_att(key,val)
---att(key)
---att_names
---inspect

=end
  class GribDim
    def initialize(var,name)
      @var = var
      @name = name
      @attr = Hash.new
    end
    def var
      @var
    end
    def length
      @length
    end
    alias :total :length
    def name
      @name
    end
    def get
      @ary
    end
    def typecode
      if NArray===@ary
        @ary.typecode
      elsif Array===@ary
        @ary[0]["value"].typecode
      end
    end
    def val
      if Array===@ary
        if att("long_name")=="Hybrid level"
          return @ary[0]["value"]
        else
          return @ary[1]["value"]
        end
      else
        return @ary
      end
    end
    def [](*ind)
      return val[*ind]
    end
    def put(ary)
      @ary = ary
      @length = val.length
      return @ary
    end
    def put_att(key,val)
      @attr[key]=val
    end
    alias :set_att :put_att
    def att(key)
      @attr[key]
    end
    def att_names
      @attr.keys
    end
    def inspect
      "GribDim: #{name}"
    end
  end

=begin
=NumRu::GribVar

==Class Methods
---new( file, name, obj, dims )

==Methods
---file
---name
---rank
---total
---set_var
---set_miss
---dim_names
---dim( index )
---ndims
---def_dim(name,index)
---put_att( key, value )
---set_att( key, value )
---att( key )
---att_names
---shape
---typecode
---get( indics )
---[]( indics )
---inspect

=end
  class GribVar
    include GribUtils
    class << self
      include GribUtils
      private
      def vars_same?(var1,var2)
        pds1 = var1.pds
        pds2 = var2.pds
        if pds1.center!=pds2.center
          $stderr.printf("center is not same: #{pds1.center} != #{pds2.center}\n")
          return false
        end
        if pds1.gid!=pds2.gid
          $stderr.printf("gid is not same: #{pds1.gid} != #{pds2.gid}\n")
          return false
        end
        if pds1.unit!=pds2.unit
          $stderr.printf("unit is not same: #{pds1.unit} != #{pds2.unit}\n")
          return false
        end
        zt1 = pds1.z_type
        zt2 = pds2.z_type 
        if zt1 != zt2
          if zt1.nil? || zt2.nil?
            $stderr.printf("z type is not same: #{zt1 ? zt1 : "nil"} != #{zt2 ? zt2 : "nil"}\n")
          else
            $stderr.printf("z type is not same: #{zt1} != #{zt2}\n")
            return false
          end
        end
=begin
        if pds1.time_range!=pds2.time_range
          $stderr.printf("time range is not same: #{pds1.time_range} != #{pds2.time_range}\n")
          return true
#          return false
        end
=end
        if pds1.sub_center!=pds2.sub_center
          $stderr.printf("sub center is not same: #{pds1.sub_center} != #{pds2.sub_center}\n")
          return false
        end
        if var1.gds!=var2.gds
          $stderr.printf("gds is not same\n")
          return false
        end
        return true
      end

      public
      def parse(file,sgms,name)
        miss = false
        sgms.each{|sgm|
          pds = sgm.pds
          if !vars_same?(sgms[0],sgm)
            raise "coordinate is not same"
          end
          miss = miss | pds.bms?
        }
        pds = sgms[0].pds
        gds = sgms[0].gds
        va = GribVar.new(file,name)
        va.set_sgms(sgms)
        va.put_att("long_name",pds.name)
        std_name = pds.standard_name
        va.put_att("standard_name",std_name) if std_name
        va.put_att("units",pds.unit) if pds.unit
        va.set_miss(miss)
        vdim = Array.new
        x,y = gds.grid
        x_sname = x["short_name"]
        d = va.def_dim(x_sname,x["ij"])
        d.put(x["value"])
        x.each{|k,v|
          if k!="value"&&k!="ij"&&k!="length"
            d.put_att(k,v)
          end
        }
        y_sname = y["short_name"]
        d = va.def_dim(y_sname,y["ij"])
        d.put(y["value"])
        y.each{|k,v|
          if k!="value"&&k!="ij"&&k!="length"
            d.put_att(k,v)
          end
        }
        if sgms.length>=1
          nz = pds.z_value.length
          if nz!=0
            z = Array.new(nz).collect{Array.new}
            n=nil
            m=nil
            sgms.each{|sgm|
              zv = sgm.pds.z_value
              nz.times{|m|
                if zv[m]
                  z[m].push( zv[m]["value"] )
                else
                  z[m].push(m)
                end
              }
            }
            nz.times{|m|
              z[m].uniq!
              z[m].length==z[0].length || raise("length is not same")
            }
            if z[0].length>1
              d = va.def_dim(pds.z_sname,2)
              d.put_att("long_name",pds.z_type)
              if pds.z_type=="Hybrid level"
                list_pv = gds.list_pv
                zval = pds.z_value[0]
                tmp = Array.new
                z[0].each{|n|
                  tmp += [n-1,n]
                }
                tmp.uniq!
                tmp.sort!
                ap = list_pv[0...list_pv.length/2]
                b = list_pv[list_pv.length/2..-1]
                z[0] = {"value"=>NArray.to_na(z[0]),"name"=>zval["name"]}
                z[1] = {"value"=>ap[tmp], "name"=>"ap_half_lev", "long_name"=>"hybrid ap at half levels", "units"=>"Pa"}
                z[2] = {"value"=>b[tmp], "name"=>"b_half_lev", "long_name"=>"hybrid b at half levels", "units"=>"1"}
              elsif nz==1
                zval = pds.z_value[0]
                z = NArray.to_na(z[0])
                d.put_att("units",zval["units"])
                d.put_att("value_type",zval["name"])
              else
                nz.times{|mm|
                  m = nz-m-1
                  zval = pds.z_value[m]
                  z[m+1] = {"value"=>NArray.to_na(z[m]),"name"=>zval["name"],"units"=>zval["units"]}
                }
                z[0] = {"value"=>NArray.sint(z[0].length).indgen,"name"=>"level number"}
              end
              d.put(z)
            else
              va.put_att("level", pds.z_type)
              pds.z_value.each{|zz|
                va.put_att(zz["name"].gsub(/\s/,"_"), "#{zz["value"]} #{zz["units"]}")
              }
            end
          else
            va.put_att("level", pds.z_type)
          end
          len = sgms.length
          time = Array.new(len)
          len.times{|i|
            time[i] = get_time(sgms[i].pds.date)
          }
#          sgms.each{|sgm|
#            time.push( get_time(sgm.pds.date) )
#          }
          time.uniq!
          if time.length>1
            time = NArray.to_na(time)
            d = va.def_dim("time",-1)
            d.put(time)
            d.put_att("long_name","time")
            d.put_att("units","hours since 1900-01-01 00:00:0.0")
          else
            date = pds.date
            va.put_att("time","#{date[0]} #{"%02d"%date[1][0]}:#{"%02d"%date[1][1]}:0.0")
          end
        end
        return va
      end
    end # end definition of class methods GribVar

    def initialize(file,name)
      @file = file
      @name = name
      @attr = Hash.new
      @miss = false
      @dims = Array.new
    end
    def file
      @file
    end
    def name
      @name
    end
    def set_sgms(sgms)
      @obj = sgms
    end
    def set_miss(miss)
      @miss = miss
    end
    def rank
      dim_names.length
    end
    def total
      total = 1
      ndims.times{|i|
        total = total*dim(i).length
      }
      total
    end
    def dim_names
      @dims.collect{|d| d.name }
    end
    def dim(index)
      index = dim_names.index(index) if String===index
      return nil if index.nil?
      @dims[index]
    end
    def ndims
      @dims.length
    end
    def def_dim(name,index)
      d = GribDim.new(self,name)
      if index==-1
        @dims.push(d)
      else
        @dims[index] = d
      end
      return d
    end
    def put_att(key,val)
      @attr[key]=val
    end
    alias :set_att :put_att
    def att(key)
      @attr[key]
    end
    def att_names
      @attr.keys
    end
    def shape
      @dims.collect{|d| d.length }
    end
    def typecode
      if @obj.nil?
        nil
      elsif Array===@obj
        NArray::FLOAT
      else
        @obj.typecode
      end
    end
    def get(*indices)
      if @obj.nil?
        return nil
      elsif NArray===@obj||NArrayMiss===@obj
        return @obj[*indices]
      else
        sha = shape
        if indices.length!=0
          if indices[0] == false
            indices[0] = [true]*(sha.length-indices.length+1)
          elsif indices[-1] == false
            indices[-1] = [true]*(sha.length-indices.length+1)
          elsif indices.include?(false)
            raise "invalid indices"
          elsif sha.length!=indices.length
            raise "invalid indices"
          end
          sha.length.times{|n|
            ind = indices[n]
            if ind==true
              indices[n] = 0..sha[n]-1
              next
            elsif Fixnum===ind
              sha[n] = 1
              next
            elsif Range===ind
              f = ind.first
              e = ind.end
              e = sha[n]-1 if e==-1
              e -= 1 if ind.exclude_end?
              sha[n] = e-f+1
              indices[n] = f..e
              next
            else
              raise "invalid indices"
            end
          }
          if rank>2
            mask = NArray.byte(*shape[2..-1])
            mask[*indices[2..-1]]= 1
            first = Array.new(indices.length-2)
	    first.length.times{|i|
              ind = indices[2+i]
              if Fixnum===ind
	        first[i] = ind < 0 ? shape[2+i]+ind : ind
              elsif Range===ind
                first[i] = ind.first
              else
                raise "invalid indices"
              end
            }
          else
            mask = true
          end
        else
          mask = true
        end
        value = @miss ? NArrayMiss.float(*sha) : NArray.float(*sha)
        if rank==2
          vz = nil
         vt = nil
          index = []
        elsif rank==4
          vz = dim(2).val
          vt = dim(3).val
          index = Array.new(2)
        elsif !dim_names.include?("time")
          vz = dim(2).val
          vt = nil
          index = Array.new(1)
        else
          vt = dim(2).val
          vz = nil
          index = Array.new(1)
        end
        @obj.each{|sgm|
          pds = sgm.pds
          if vz
            index[0] = vz.eq(pds.z_value[0]["value"]).where[0]
          end
          if vt
            index[-1] = vt.eq(get_time(pds.date)).where[0]
          end
          next if (mask!=true && mask[*index]==0)
          bds = sgm.bds
          if indices.length==0 || (indices[0]==true&&indices[1]==true)
            val = bds.value(shape[0..1])
          else
            val = bds.value(shape[0..1],indices[0..1],sha[0..1])
          end
          d = pds.dfact
          val = val*10.0**(-d)
          if mask!=true
            index.length==first.length || raise("invalide indices")
            index.length.times{|i|
              index[i] = index[i]-first[i]
            }
          end
          value[true,true,*index] = val
        }
        sha.delete(1)
        value.reshape!(*sha)
        return value
      end
    end
    alias :[] :get
    alias :val :get
    def put(val)
      @obj = val
    end
    def inspect
      "GribVar: #{@file.path}?var=#{@name}"
    end
  end

end


#####################################################
if $0 == __FILE__

  include NumRu

  if ARGV.length>0
    infname = ARGV.shift
  else
    infname = "../../../testdata/T.jan.grib"
  end


  Grib.is_a_Grib?(infname) || raise("file is not a Grib dataset")
  p grib = Grib.open(infname)



  print "\nVars\n"
  grib.var_names.each{|vn|
    p v = grib.var(vn)
    p v.dim_names
    v.dim_names.each{|dn| p dn; p v.dim(dn).get }
    p v.shape
    v.att_names.each{|an| print an, " => ", v.att(an), "\n" }
    puts "\n"
  }




end
