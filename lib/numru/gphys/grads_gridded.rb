=begin
= NumRu::GrADS_Gridded  -- a class for GrADS gridded datasets

by T Horinouchi and R Mizuta

==Overview

a GrADS_Gridded object corresponds to a GrADS control file,
through which the users can also access its binary data file(s).

==Current Limitations

* option 365_day_calendar is not interpreted
* Partial support of the "template" option 
  (only %y2,%y4,%m1,%m2,%d1,%d2,%h1,%h2,%n2) 
  (Time is assumed to be increasing monotonically).

==Class Methods

---GrADS_Gridded.new(ctlfilename, mode="r")
   same as GrADS_Gridded.open

---GrADS_Gridded.open(ctlfilename, mode="r")
   make a new GrADS_Gridded object. 

   ARGUMENTS
   * ctlfilename (String): name of the control file to open
   * mode (String): IO mode. "r" (read only) or "w" (write only).

   REMARK
   * You can modify the object through instance methods even if mode=="r".
     In that case, the modification will not be written in the original
     control file.

---GrADS_Gridded.create(ctlfilename, noclobber=false, share=false)
   make a new GrADS_Gridded object with creating a new control file

   REMARK
   * It is used with writing methods, but currently writing methods 
     does not work. 

==Methods
---ndims
   returns the number of dimensions in the file (always 4). 

---nvars
   returns the number of variables in the file. 

---natts
   returns the number of attributes of the variable.

---path
   returns the path of the control file.

---put_att( attname, value )
   set global attribute

   ARGUMENTS
   * attrname (String): name of an attribute
   * value (String): value of an attribute

---def_var(name="noname",nlev=0,option="99",description="")
   define a variable

   ARGUMENTS
   * name (String): name of the variable
   * nlev (Integer): number of vertical levels
   * option (String): variable placement option 
     ("99": normal, "-1,30": transpose lon and lat)

---var( varname=nil )
   opens an existing variable in the file. 

   ARGUMENTS
   * varname (String): name of the variable to open

   RETURN VALUE
   * a GrADSVar object. 

---vars( names=nil )
   opens existing variables in the file. 

   ARGUMENTS
   * names (Array): names(String) of the variable to open

   RETURN VALUE
   * Array of GrADSVar objects. 
     returns all variables if names==nil

---get_att( key=nil )
   returns tha value of the global attribute

---dim_names
   returns the names of all dimensions in the control file.

---var_names
   returns the names of all variables in the control file.

---att_names
   returns the names of all the global attributes.

---to_ctl
   returns the contents of the corresponding control file as a String.

   REMARK
   * The contents is reconstructed from the internal data of the object.
     Therefore, even when the object is based on a read-only control file,
     it is not necessarily the same as the original one. It is especially
     true when the object was modified after it is opened.

---get(name, z, t)
   reads the binary data and returns as a NArray.

   ARGUMENTS
   * name (String): name of the variable to read
   * z (Integer, currently): vertical level to read (0,1,2,...; starting 
     from 0). Currently only one vertical levels must be chosen, but in the
     future, it is planned to support multiple levels.
   * t (Integer, currently): time to read (0,1,2,...;  starting 
     from 0). Currently only one time must be chosen, but in the
     future, it is planned to support multiple times.

---put(ary)
   writes the NArray on the binary data file. 

   ARGUMENTS
   * ary (NArray): data to write. 

---varnames
   Returns names of the variable in the GrADS file as an Array in the order
   placed.

---dimensions
   Returns info on the four dimensions.

   RETURN VALUE
   * an Array of 4 elements: dimension[0] for x, dimension[1] for y,
     dimension[2] for z, and dimension[3] for t. Each of them is a
     Hash like the following:
       {:name=>"x", 
       :len=>132, 
       :flag=>"LINEAR",
       :spec=>"-0.7500         1.5000",
       :start=>-0.75, :increment=>1.5,
       :description=>"longitude", 
       :units=>"degrees_east"}
     Here, :len, :flag, and :spec are directly from the control file, while
     others are derived properties for internal use. 

   WARNING
   * Each elements of the return value is not a clone but is a direct 
     association to an internal object of the object. Therefore, to 
     modify it is to modify the object. That is, dimensions[0][:len]=10
     would actually change the internal variable, while dimensions[0]=nil
     has no effect (the former is a substitution IN a Hash, while the latter
     is a substitution OF the Hash).

---get_dim(dim)
   returns positions of a dimension as an NArray.

   ARGUMENTS
   * dim (String): a dimension name

   RETURN VALUE
   * an NArray


---title
---title=
   get/set the title

---undef
---undef=
   get/set the undef value

---dset
---dset=
   get/set the dset string



= GrADSVar  -- a class for a variable of GrADS gridded datasets

by R Mizuta

==Overview

a GrADSVar object corresponds to one variable in a GrADS control file. 
It is intended to behave as a correspondent of a NetCDFVar object. 

==Current Limitations

* Only a part of the methods can work. 
* Writing methods are not supported. 

==Class Methods

---GrADSVar.new(file, varname)
   make a new GrADSVar object. 

   ARGUMENTS
   * file (GrADS_Gridded or String): a GrADS_Gridded object or 
     a name of the control file to open
   * varname (String): name of the variable to open


==Methods

---shape_ul0
   returns the shape of the variable, but the length of the unlimited 
   dimension is set to zero.

   RETURN VALUE
   *  Array. [length of 0th dim, length of 1st dim,.. ]

---shape_current
   returns the current shape of the variable.

   RETURN VALUE
   *  Array. [length of 0th dim, length of 1st dim,.. ]

---dim_names
   returns the names of all dimensions of the variable.

---att_names
   returns the names of all attributes of the variable.

---name
   returns the name of the variable. 

---ndims
   returns the number of dimensions in the file (always 4). 

---rank
   alias of ndims

---vartype
   returns "sfloat" in order to behave as NetCDFVar#vartype. 

---natts
   returns the number of attributes of the variable.

---file
   returns the file name that controls the variable. 

---get_att( name=nil )
   returns tha value of the attribute of the variable.

---put_att( name, value )
   set an attribute of the variable. 

   ARGUMENTS
   * name (String): name of an attribute
   * value (String): value of an attribute

---get(hash=nil)
   returns values of the variable.

   ARGUMENTS
   * hash (Hash) : Optional argument to limit the portion of the
     variable to output values. If omitted, the whole variable is
     subject to the output. This argument accepts a Hash whose keys
     contain either "index" or a combination of "start","end", and
     "stride". The value of "index" points the index of a scalar
     portion of the variable. The other case is used to designate a
     regularly ordered subset, where "start" and "end" specifies
     bounds in each dimension and "stride" specifies intervals in
     it. As in Array "start", "end", and "index" can take negative
     values to specify index backward from the end. However,
     "stride" has to be positive, so reversing the array must be
     done afterwards if you like.

   RETURN VALUE
   *  an NArray object

   REMARK
   "stride","index" is not supported yet.

---[]
   Same as GrADSVar#get but a subset is specified as in the method [] 
   of NArray. 


=end

require "date"
require "narray_miss"
require "numru/gphys/attribute"

module NumRu
 class GrADS_Gridded

  class << self
    alias open new

    def create(ctlfilename,noclobber=false,share=false)
      #if(noclobber)
      #  raise "noclobber = true is not supported."
      #end
      if(share)
        raise "share = true is not supported."
      end
      #if (File.exists?(ctlfilename))
      if(noclobber && File.exists?(ctlfilename))
        print "#{ctlfilename} already exists.\n"
        print "overwrite #{ctlfilename} (y/n)? "
        ans = gets[0].chr
        if ans != "y"
          raise "#{ctlfilename} already exists."
        end
      end

#      GrADS_Gridded.new(ctlfilename, "w+")
      GrADS_Gridded.new(ctlfilename, "w")
    end
  end

  def initialize(ctlfilename, mode="r")

    case(mode)
    when /^r/
      @mode = 'rb'
    when /^w/
      @mode = 'wb'
    else
      raise ArgumentError, "Unsupported IO mode: #{mode}"
    end

#    @ctlfile = File.open(ctlfilename, mode)
    @options = {    # initialization
      "yrev"=>nil, 
      "zrev"=>nil,
      "sequential"=>nil,
      "byteswapped"=>nil,
      "template"=>nil,
      "big_endian"=>nil,
      "little_endian"=>nil,
      "cray_32bit_ieee"=>nil,
      "365_day_calendar"=>nil,
    }

    case(@mode)
    when('rb')
      if (File.exists?(ctlfilename))
        @ctlfile = File.open(ctlfilename, mode)
        parse_ctl
      else
        raise "File #{ctlfilename} does not exist."
      end
    when('wb')
      @ctlfile = File.open(ctlfilename, mode)
      
      @dimensions = []
      @variables = []
      
      #<attributes>
      @dset = nil
#      @title = nil
      @title = ""
      @undef = nil
      @fileheader_len = 0
      
      #<internal control parameters>
      @define_mode = true
      @ctl_dumped = false
    else
      raise ArgumentError, "Unsupported IO mode: #{@mode}"
    end
  end

  def close
    @ctlfile.close
  end

  def path
    @ctlfile.path
  end

  def ndims
    4
  end

  def nvars
    @variables.length
  end

  def natts
    2
  end

  def put_att(key,value)
    case key
    when "dset"
      @dset = value
    when "title"
      @title = value
    when "undef"
      @undef = value
    else
      if ! (value.is_a?(TrueClass) || value.is_a?(NilClass) )
        raise ArgumentError, "2nd arg: not a true nor nil" 
      end
      if (@options.has_key?(key))
        @options[key] = value
      else
        raise "Invalid/unsupported option: "+key
      end
    end
  end

  def def_var(name="noname",nlev=0,option="99",description="")
    @variables.push({:name=>name.to_s, :nlev=>nlev.to_s,
                     :option=>option.to_s, :description=>description.to_s})
  end

  def var( varname=nil )
    GrADSVar.new(self,varname)
  end

  def vars( names=nil )   # return all if names==nil
#    if names == nil
#      vars = (0..nvars()-1).collect{ |varid| id2var(varid) }
#    else
      raise TypeError, "names is not an array" if ! names.is_a?(Array)
      vars = names.collect{|name| var(name)}
      raise ArgumentError, "One or more variables do not exist" if vars.include?(nil)
#    end
    vars
  end

#  def att
  def get_att( key=nil )
    case(key)
    when("dset")
      att = @dset
    when("title")
      att = @title
    when "undef"
      att = @undef
    else
      raise "Invalid/unsupported option: "+key
    end
    att
  end

#  def fill=
#  def each_dim
#  def each_var
#  def each_att

  def dim_names
    ary = Array.new()
    @dimensions.each{|dim| ary.push(dim[:name])}
    ary
  end

  def var_names
    ary = Array.new()
    @variables.each{|dim| ary.push(dim[:name])}
    ary
  end

  def att_names
    ary = ["dset","title","undef"]
    ary
  end

  def to_ctl
    if( !@dimensions[3][:spec] ) 
      start = generate_starttime(@dimensions[3][:startdatetime])
      increment = generate_timeincrement(@dimensions[3][:increment],@dimensions[3][:increment_units])
      @dimensions[3][:spec] = "#{start} #{increment}"
    end
    @title = "<no title>" if @title==""
    @undef = -999.0 if @undef==nil
    return <<EOS
DSET    #{if @dset[0]=="/" then @dset else "^"+@dset end}
TITLE   #{@title}
UNDEF   #{@undef}
OPTIONS #{op=""; @options.each{|key,val| op += key+" " if(val)}; op}
XDEF    #{@dimensions[0][:len]} #{@dimensions[0][:flag]} #{@dimensions[0][:spec]}
YDEF    #{@dimensions[1][:len]} #{@dimensions[1][:flag]} #{@dimensions[1][:spec]}
ZDEF    #{@dimensions[2][:len]} #{@dimensions[2][:flag]} #{@dimensions[2][:spec]}
TDEF    #{@dimensions[3][:len]} #{@dimensions[3][:flag]} #{@dimensions[3][:spec]}
VARS    #{nvars}
#{@variables.collect{|i| i[:name]+" "+i[:nlev].to_s+" "+i[:option].to_s+
       " "+i[:description]}.join("\n")}
ENDVARS
EOS
  end

  def inspect
    return <<EOS
#{self.class}
file: #{@ctlfile.path}
DSET #{@dset}
OPTIONS #{@options.inspect}
XDIM #{@dimensions[0].inspect}
YDIM #{@dimensions[1].inspect}
ZDIM #{@dimensions[2].inspect}
TDIM #{@dimensions[3].inspect}
VARS
#{@variables.collect{|i| "  "+i[:name]+"\t"+i[:nlev].to_s+"\t"+i[:option].to_s+
       "\t"+i[:description]}.join("\n")}
ENDVARS
EOS
  end

  def put(ary)

    if( ary.class == NArrayMiss )
      raise "UNDEF is not specified" if @undef == nil
      ary = ary.to_na(@undef)
    end

    ary = convert_endian_write(ary)

    raise "DSET is not  specified" if @dset == nil

    putfile = File.open(@dset,"wb")
    putfile << ary.to_s
    putfile.close

  end

  def get(name, z, t, lonlat=nil)

# t:    [0,1,2,..] : record number
# time: [0,1/24,2/24,...] days since 00:00Z01jan2000 : Numeric with units
# date: [00:00Z01jan2000,01:00Z01jan2000,...] : DateTime class

    if ( @options["template"] )

      ary_time = get_dim(@dimensions[3])
      start_date = @dimensions[3][:startdatetime]

      case dimensions[3][:increment_units]
      when 'years'
        target_date = start_date >> (ary_time[t]*12)
      when 'months'
        target_date = start_date >> ary_time[t]
      when 'days'
        target_date = start_date + ary_time[t]
      when 'hours'
        target_date = start_date + Rational((ary_time[t]*60).to_i,24*60)
      when 'minutes'
        target_date = start_date + Rational(ary_time[t].to_i,24*60)
      end

      # substitute DSET by the target file name
      # and determine first record in the target file (="init_xxxx")

      init_year = start_date.year
      init_month = start_date.month
      init_day = start_date.day
      init_hour = start_date.hour
      init_min = start_date.min

      @dset_r = @dset.dup
      if ( @dset_r =~ /%y[24]/ )
        init_year = target_date.year
        init_month = 1  if !( @dset_r =~ /%m[12]/ )
        init_day = 1    if !( @dset_r =~ /%d[12]/ )
        init_hour = 0   if !( @dset_r =~ /%h[12]/ )
        init_min = 0 if !( @dset_r =~ /%n2/ )
        @dset_r.gsub!( /%y2/, sprintf("%02d",init_year%100) )
        @dset_r.gsub!( /%y4/, sprintf("%04d",init_year) )
      end
      if ( @dset_r =~ /%m[12]/ )
        init_month = target_date.month
        init_day = 1    if !( @dset_r =~ /%d[12]/ )
        init_hour = 0   if !( @dset_r =~ /%h[12]/ )
        init_min = 0 if !( @dset_r =~ /%n2/ )
        @dset_r.gsub!( /%m1/, sprintf("%d",init_month) )
        @dset_r.gsub!( /%m2/, sprintf("%02d",init_month) )
      end
      if ( @dset_r =~ /%d[12]/ )
        init_day = target_date.day
        init_hour = 0   if !( @dset_r =~ /%h[12]/ )
        init_min = 0 if !( @dset_r =~ /%n2/ )
        @dset_r.gsub!( /%d1/, sprintf("%d",init_day) )
        @dset_r.gsub!( /%d2/, sprintf("%02d",init_day) )
      end
      if ( @dset_r =~ /%h[12]/ )
        init_hour = target_date.hour
        init_min = 0 if !( @dset_r =~ /%n2/ )
        @dset_r.gsub!( /%h1/, sprintf("%d",init_hour) )
        @dset_r.gsub!( /%h2/, sprintf("%02d",init_hour) )
      end
      if ( @dset_r =~ /%n2/ )
        init_min = target_date.min
        @dset_r.gsub!( /%n2/, sprintf("%02d",init_min) )
      end

      init_date = DateTime.new(init_year,init_month,init_day,init_hour,init_min)
      init_t = 0

      ary_time[0..t].to_a.each_with_index{ |time, idx| 

        case dimensions[3][:increment_units]
        when 'years'
          before_target_file = ((start_date >> (time*12)) < init_date)
        when 'months'
          before_target_file = ((start_date >> time) < init_date)
        when 'days'
          before_target_file = ((start_date + time)  < init_date)
        when 'hours'
          before_target_file = ((start_date + Rational((time*60).to_i,24*60)) < init_date)
        when 'minutes'
          before_target_file = ((start_date + Rational(time.to_i,24*60)) < init_date)
        end
        init_t = idx + 1 if before_target_file
      }

      t_in_target_file = t - init_t

      start_byte = start_byte(name, z, t_in_target_file)
      @datafile = File.open(@dset_r,"rb")
    else
      start_byte = start_byte(name, z, t)
      @datafile = File.open(@dset,"rb")
    end

    @x_len = @dimensions[0][:len]
    @y_len = @dimensions[1][:len]

    if(lonlat)
      if !(lonlat.is_a?(Array) || lonlat.is_a?(NArray))
        raise "lonlat must be given Array or NArray"
      end
      lon_str = lonlat[0]
      lon_end = lonlat[1]
      lat_str = lonlat[2]
      lat_end = lonlat[3]
      
      if( @map[name][:xytranspose] )
        @datafile.pos = start_byte + @y_len*lon_str*@map[name][:byte]
        readdata = @datafile.read(@y_len*(lon_end-lon_str+1)*@map[name][:byte])

        if( readdata == nil )
          raise "File Read Error: #{@datafile.path}, " +
            "#{@x_len*(lat_end-lat_str+1)*@map[name][:byte]} bytes " +
            "at #{@datafile.pos} bytes\n" +
            "specified by #{@ctlfile.path}, #{name} ( z=#{z}, t=#{t} ) (Perhaps there is a mismatch between the control and data files)"
        end

        ary = NArray.to_na(readdata, @map[name][:type], @y_len, lon_end-lon_str+1)

        ary = convert_endian_read(ary)
        ary = ary[lat_str..lat_end,true].transpose
      else
        @datafile.pos = start_byte + @x_len*lat_str*@map[name][:byte]
        readdata = @datafile.read(@x_len*(lat_end-lat_str+1)*@map[name][:byte])

        if( readdata == nil )
          raise "File Read Error: #{@datafile.path}, " +
            "#{@x_len*(lat_end-lat_str+1)*@map[name][:byte]} bytes " +
            "at #{@datafile.pos} bytes\n" +
            "specified by #{@ctlfile.path}, #{name} ( z=#{z}, t=#{t} ) (Perhaps there is a mismatch between the control and data files)"
        end

        ary = NArray.to_na(readdata, @map[name][:type], @x_len, lat_end-lat_str+1)

        ary = convert_endian_read(ary)
        ary = ary[lon_str..lon_end,true]
      end
    else
      @datafile.pos = start_byte
      readdata = @datafile.read(@x_len*@y_len*@map[name][:byte])

      if( readdata == nil )
        raise "File Read Error: #{@datafile.path}, " +
          "#{@x_len*(lat_end-lat_str+1)*@map[name][:byte]} bytes " +
          "at #{@datafile.pos} bytes\n" +
          "specified by #{@ctlfile.path}, #{name} ( z=#{z}, t=#{t} ) (Perhaps there is a mismatch between the control and data files)"
      end

      ary = NArray.to_na(readdata, @map[name][:type], @dimensions[0][:len],@dimensions[1][:len])

      ary = convert_endian_read(ary)
      ary = ary.transpose if ( @map[name][:xytranspose] )
    end

    @datafile.close
    ary
  end

  attr_accessor(:title, :undef, :dset, :dimensions, :variables)
  attr_reader(:ctlfile)

  def get_dim(dim)
    name = dim[:name]
      if (dim[:levels])
        var_dim = NArray.to_na(dim[:levels])
      elsif (dim[:start] && dim[:increment] && dim[:len])
        var_dim = NArray.float(dim[:len]).indgen!*dim[:increment]+dim[:start]
      else
        raise "cannot define dimension "+name
      end
      var_dim = var_dim[-1..0] if (name == 'y' && @options["yrev"])
      var_dim = var_dim[-1..0] if (name == 'z' && @options["zrev"])
    return var_dim
  end

  def varnames
    @variables.collect{|i| i[:name]}
  end

  def get_alldim 
    ax = Hash.new
    @dimensions.each{|dim|
      name = dim[:name]
      ax[name] = get_dim(dim)
    }
    return ax
  end

  def ctlfilename # obsolete
    @ctlfile.path
  end

  ########## private methods #############
  private
  
  def parse_ctl
    @ctlfile.rewind
    @fileheader_len = 0     # defalut value
    @title = ""        
    @variables = []         # initalization
    @dimensions = []        # initalization
    while ( line = @ctlfile.gets )
      case(line)
      when /^\s*\*/,/^\s*$/
        # do nothing
      when /^\s*DSET\s*(\S*)/i
        if ($1)
#         @dset = $1
#         @dset = $1.gsub(/(\^)/,"./")  # replace "^" with "./"
         @dset = $1.gsub(/(^\^|^([^\/]))/,File.dirname(@ctlfile.path)+'/\2')
                   # relative -> absolute path (e.g. '^a' or 'a' -> '/hoge/a')
#         @datafile = File.open(@dset,@mode)
        else
          raise "Invalid line: "+line
        end
      when /^\s*TITLE\s*(\S+.*)$/i
        if ($1)
          @title = $1
        else
          raise "Invalid line: "+line
        end
      when /^\s*UNDEF\s*(\S*)/i
        if ($1)
          @undef = $1.to_f
        else
          raise "Invalid line: "+line
        end
      when /^\s*FILEHEADER\s*(\S*)/i
        if ($1)
          @fileheader_len = $1.to_i
        else
          raise "Invalid line: "+line
        end
      when /^\s*BYTESWAPPED\s*$/i
        @options["byteswapped"] = true
      when /^\s*OPTIONS\s*(\S+.*)$/i
        if ($1)
#         $1.split.each{ |opt|
          $1.downcase.split.each{ |opt|
            if (@options.has_key?(opt))
              @options[opt] = true
            else
              raise "Invalid/unsupported option: "+opt
            end
          }
        else
          raise "Invalid line: "+line
        end
      when /^\s*[XYZT]DEF/i
#        /^\s*([XYZT])DEF\s+(\d+)\s+(\S+)\s+(.*)$/i =~ line
        /^\s*([XYZT])DEF\s+(\d+)\s+(\S+)+(.*)$/i =~ line
        if ( (len=$2) && (flag=$3) && (spec=$4))
          dim = {:len=>len.to_i, :flag=>flag, :spec=>spec}
          case $1
          when /X/i
            idim=0
            dim[:name] = 'x'
            dim[:description] = 'longitude'
            dim[:units] = 'degrees_east'
          when /Y/i
            idim=1
            dim[:name] = 'y'
            dim[:description] = 'latitude'
            dim[:units] = 'degrees_north'
          when /Z/i
            idim=2
            dim[:name] = 'z'
            dim[:description] = 'pressure level'
            dim[:units] = 'hPa'
          when /T/i
            dim[:name] = 't'
            dim[:description] = 'time'
            idim=3
          end
          if (idim!=3)
            if (dim[:flag] =~ /LINEAR/i)
              begin
                dim[:start],dim[:increment] = spec.split.collect!{|i| i.to_f}
              rescue NameError,StandardError
                raise $!.to_s+"\nCannot read start and increment from: "+spec
              end
            elsif (dim[:flag] =~ /LEVELS/i)
              dim[:levels] = []
              pos = @ctlfile.pos    # back up for a one-line rewind
#              dim[:spec] = "\n"
              dim[:spec] += levs = spec+"\n"
              if( /^\s*[\d\-\.]/ =~ levs )
                dim[:levels] += levs.split.collect!{|i| i.to_f}
              end
#              while (dim[:spec] += levs = @ctlfile.gets)
              while (levs = @ctlfile.gets)
                if( /^\s*[\d\-\.]/ =~ levs )
                  dim[:spec] += levs
                  dim[:levels] += levs.split.collect!{|i| i.to_f}
                  #p '###  levels',dim[:levels].length,"  ",levs.split
                  pos = @ctlfile.pos    # back up for a one-line rewind
                else
                  @ctlfile.pos = pos  # one-line rewind (note: IO#lineno= doesn't work for this purpose)
                  break
                end
              end
            else
              raise "invalid or not-yet-supported dimension flag: "+dim[:flag]
            end
          else
            # idim = 3 --- time
            if (dim[:flag] =~ /LINEAR/i)
              start,increment= spec.split
              dim[:start] = 0.0
              dim[:startdatetime] = parse_starttime(start)
              dim[:increment],dim[:increment_units] = parse_timeincrement(increment)
              dim[:units] = dim[:increment_units]+" since "+dim[:startdatetime].strftime("%Y-%m-%d %H:%MZ")

            else
              raise "invalid dimension flag(only LINEAR is available for time)"
            end
          end
          @dimensions[idim]=dim
        else
          raise "Invalid line: "+line
        end
      when /^\s*VARS/i
        total_lev_bytes=0
        while ( vline = @ctlfile.gets )
          case(vline)
          when /^\s*\*/,/^\s*$/
            # do nothing
          when /^\s*ENDVARS/i
            break
          else
            vline =~ /^\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+.*?)\s*$/
#            vline =~ /^\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*(\S+.*?)\s*$/
            if( !($1 && $2 && $3 && $4) )
              raise "Something is wrong with this line: "+vline
            end
            name = $1; option = $3; description = $4; units = $5
            nlev = max($2.to_i,1)
#            total_levs += nlev
#            case ($3)
            case (option)
            when /^0/,/^99/,/^-1,30/
              byte=4; type="sfloat"
            when /^-1,40,4/
              byte=4; type="int"
            when /^-1,40,2,-1/
              byte=2; type="sint"
            when /^-1,40,1/
              byte=1; type="byte"
            else
              p option
              raise "invalid or unsupported variable placement option: "
            end
            total_lev_bytes += nlev*byte
#            @variables.push({:name=>$1,:nlev=>nlev,:option=>$3,
#                              :description=>$4})
            if( ! $5 ) 
              @variables.push({:name=>name,:nlev=>nlev,:option=>$3,:type=>type,:byte=>byte,
                                :description=>description})
            else
              @variables.push({:name=>$1,:nlev=>nlev,:option=>$3,:type=>type,:byte=>byte,
                                :description=>description, :units=>$5})
            end
          end
        end
        @map=Hash.new
        cum_lev_bytes = 0
        @variables.each{|i|
          varname = i[:name]
          @map[varname]={:offset=>@fileheader_len,:nlev=>i[:nlev],
            :start=>cum_lev_bytes,:zstep=>i[:byte],:tstep=>total_lev_bytes, 
            :type=>i[:type],:byte=>i[:byte]}
          if i[:option] =~ /^-1,30/
            @map[varname][:xytranspose]=true
          end
          cum_lev_bytes += i[:nlev]*i[:byte]
        }
      end

    end

    #<check whether all the mandatory specifications are done>
    for i in 0..3
      raise "#{i}-th dimension is not found " if( ! @dimensions[i] )
    end
    raise "UNDEF field is not found" if(!@undef)
    raise "DSET field is not found" if(!@dset)
    raise "VARS field is not found" if(!@variables)

#    #<post processing>
#    @xybytes = 4 * @dimensions[0][:len] * @dimensions[1][:len]
#    @xy = @dimensions[0][:len] * @dimensions[1][:len]

  end

  def start_byte(name, level, time)
    # offset to read an xy section of the variable with NAME
    # at LEVEL(counted from 0) at TIME(conted from 0)
    if (map = @map[name] )
      if (level<0 || level>=map[:nlev])
        raise "Level #{level} is out of the range of the variable #{name}"
      end
      if (time<0 || time>=@dimensions[3][:len])
        raise "Time #{time} is not in the data period"
      end
      iblock = map[:start]+level*map[:zstep]+time*map[:tstep]
      str_byte = map[:offset] + @dimensions[0][:len] * @dimensions[1][:len] * iblock
      if( @options["sequential"] )
        str_byte += iblock*2 + 4
      end
    else
      raise "Variable does not exist: "+name
    end
    str_byte
  end

  def parse_starttime(string)
    ## interpret the hh:mmZddmmmyyyy format for grads
    
    if (/([\d:]*)Z(.*)/i =~ string)
      stime = $1
      sdate = $2
    else
      # must be date, not time, since month and year are mandatory
      sdate = string  
      stime = ''
    end
    
    if ( /(\d\d):(\d\d)/ =~ stime )
      begin
        shour = $1
        smin = $2
        hour = shour.to_i
        min = smin.to_i
      rescue StandardError,NameError
        raise "Cannot convert hour or time into interger: "+stime
      end
    else
      hour = 0
      min = 0
    end

    if ( /(\d*)(\w\w\w)(\d\d\d\d)/ =~ sdate )
      sday = $1
      smon = $2
      syear = $3
      begin
        if(sday == "")
          day = 1
        else
          day = sday.to_i
        end
        year = syear.to_i
        mon=['jan','feb','mar','apr','may','jun','jul','aug','sep',
          'oct','nov','dec'].index(smon.downcase) + 1
      rescue StandardError, NameError
        raise "Could not parse the date string: "+sdate+"\n"+$!
      end
    else
      raise "The date part must be [dd]mmmyyyy, but what was given is: "+sdate
    end

    return DateTime.new(year,mon,day,hour,min)
  end

  def parse_timeincrement(string)
    if ( /(\d+)(\w\w)/ =~ string )
      sincrement = $1.to_i
      sunits = $2
      case sunits
      when /mn/i
#        fact = 1.0/1440.0   # factor to convert into days
#        units = 'days'
        fact = 1.0
        units = 'minutes'
        increment = sincrement * fact
      when /hr/i
#        fact = 1.0/24.0
#        units = 'days'
        fact = 1.0
        units = 'hours'
        increment = sincrement * fact
      when /dy/i
        fact = 1.0
        units = 'days'
        increment = sincrement * fact
      when /mo/i
        fact = 1.0
        units = 'months'
        increment = sincrement * fact
      when /yr/i
        fact = 1.0
        units = 'years'
        increment = sincrement * fact
      else
        raise "invalid units: "+sunits
      end
    else
      raise "invalid time-increment string: #{sunits}"
    end
    return [increment, units]
  end

  def max(a,b)
    a>b ? a : b
  end

  def generate_starttime(datetime)
    mon = Date::ABBR_MONTHNAMES[datetime.mon]
    return datetime.strftime("%H:%MZ%d#{mon}%Y")
  end

  def generate_timeincrement(increment,units)
    increment = increment[0] if(increment.class==NArray) 
    sincrement = increment
    case units
    when /min/i
      sunits = "mn"
    when /hour/i
      sunits = "hr"
    when /day/i
      sunits = "dy"
    when /mon/i
      sunits = "mo"
    when /year/i
      sunits = "yr"
    else
      raise "invalid time increment units: #{units}"
    end

    if(sunits == "dy")
      if( increment < 0.0 )
        raise "invalid time increment: #{increment}"
      elsif( increment >= 365 && (increment.to_f/365) / (increment.to_i/365) < 1.003 )
        sincrement = (increment/365).to_i
        sunits = "yr"
      elsif( increment >= 28 &&  (increment.to_f/28) / (increment.to_i/28) < 1.11 )
        sincrement = (increment/28).to_i
        sunits = "mo"
      elsif( increment < 1.0 )
        if( increment >= 0.0416 && (increment*1440)%60 < 5 )
          sincrement = (increment*24).to_i
          sunits = "hr"
        else
          sincrement = increment*1440
          sunits = "mn"
        end
      end
    end

    return sprintf("%2d",sincrement)+sunits
  end

  def convert_endian_read(ary)

    if( (@options["big_endian"] || @options["cray_32bit_ieee"]) &&
        @options["little_endian"] )
      raise "endian specification error"
    end

    if( @options["big_endian"] || @options["cray_32bit_ieee"] )
      ary = ary.ntoh
    elsif( @options["little_endian"] )
      ary = ary.vtoh
    elsif( @options["byteswapped"] )
      ary = ary.swap_byte
    end

    ary
  end

  def convert_endian_write(ary)

    if( (@options["big_endian"] || @options["cray_32bit_ieee"]) &&
        @options["little_endian"] )
      raise "endian specification error"
    end

    if( @options["big_endian"] || @options["cray_32bit_ieee"] )
      ary = ary.hton
    elsif( @options["little_endian"] )
      ary = ary.htov
    elsif( @options["byteswapped"] )
      ary = ary.swap_byte
    end

    ary
  end

 end

 class GrADSVar

  def initialize(file,varname)
    @varname = varname

    if file.is_a?(String)
      file = GrADS_Gridded.open(file)
    elsif ! file.is_a?(GrADS_Gridded)
      raise ArgumentError, "1st arg must be a GrADS_Gridded or a file name"
    end
    @ctl = file  # control file name
#    @ctl = ctl

    @idim = -1
    for i in 0...@ctl.dimensions.length
#      p @ctl.dimensions[i][:name]
      if @varname == @ctl.dimensions[i][:name]
        @idim = i
      end
    end

    @attr = NumRu::Attribute.new
    if( @idim != -1 )
      @dimensions = [ @ctl.dimensions[@idim] ]
      @rank = 1
      @attr[:name] = @dimensions[0][:name]
      @attr[:long_name] = @dimensions[0][:description]
      @attr[:units] = @dimensions[0][:units]

      @shape = [@dimensions[0][:len]]
    else
      @dimensions = @ctl.dimensions
      @rank = @dimensions.length
      found = false
      for i in 0...@ctl.variables.length
        if @varname == @ctl.variables[i][:name]
          @attr[:long_name] = @ctl.variables[i][:description]
          @attr[:nlev] = @ctl.variables[i][:nlev].to_s

          @shape = [@dimensions[0][:len],@dimensions[1][:len],
                    @dimensions[2][:len],@dimensions[3][:len]]
          @shape[2] = @ctl.variables[i][:nlev].to_i if( @ctl.variables[i][:nlev] )

          @attr[:missing_value] = NArray.sfloat(1).fill!(@ctl.undef)
          found = true
        end
      end
      raise "variable #{@varname} is not found" if !found
    end
  end

  attr_accessor (:rank)
  alias :ndims :rank

#  def dim(name)
#  def dims(names)

  def dim_names
    ary = Array.new()
    @dimensions.each{|dim| ary.push(dim[:name])}
    ary
  end

  def name
    @varname
  end

  def name=
    raise "name= not supported"
  end

  def ndims
    @rank
  end

  def vartype
    if( @idim == -1 )
      for i in 0...@ctl.variables.length
        if @varname == @ctl.variables[i][:name]
          type = @ctl.variables[i][:type]
        end
      end
    else
      type = "float"
    end
    type
  end
  alias ntype vartype

  def typecode
    if( @idim == -1 )
      for i in 0...@ctl.variables.length
        if @varname == @ctl.variables[i][:name]
          byte = @ctl.variables[i][:byte]
        end
      end
    else
      byte = 4
    end
    byte
  end

  def att(name)
    raise "use get_att instead of att"
  end

  def get_att(name)
    @attr[name]
  end

  def natts
    @attr.length
  end

  def att_names
    @attr.keys
  end

  def each_att
    raise "each_att not supported"
  end

  def put_att(name,value)
    @attr[name] = value
  end

  def attr # obsolete
    @attr
  end

  def file
    @ctl.ctlfile
  end

#  def shape_ul0
#    sh = []
#    @dimensions.each{|dim|
##      if d.unlimited? then
##        sh.push(0)
##      else
#        sh.push(dim[:len])
##      end
#    }
#    sh
#  end

  def shape_current
#    sh = []
#    @dimensions.each{|dim|
#      sh.push(dim[:len])
#    }
#    sh
    @shape
  end

  alias shape_ul0 shape_current

  def scaled_put(var,hash=nil)
    raise "scaled_put not supported"
  end

  def scaled_get(hash=nil)
    raise "scaled_get not supported"
  end

  def put(var,hash=nil)
    raise "put not supported"
  end

  def get(hash=nil)
    if @idim != -1
      na = @ctl.get_dim(@dimensions[0])
      if hash == nil
        
      elsif hash.key?("start")==true
        h_sta = hash["start"]
        endq = hash.key?("end")
        strq = hash.key?("stride")
        if endq == false && strq == false
          na = na[h_sta[0]..-1]
        elsif endq == true && strq == false
          h_end = hash["end"]
          na = na[h_sta[0]..h_end[0]]
        elsif endq == false && strq == true
          h_str = hash["stride"]
          raise "sorry, stride is not supported yet."
        else endq == true && strq == true
          h_end = hash["end"]
          h_str = hash["stride"]
          raise "sorry, stride is not supported yet."
        end
      end
    else
      h_sta = [0, 0, 0, 0]
      h_end = [-1, -1, -1, -1]
      if hash == nil
#      elsif hash.key?("index")==true
      else
        if hash.key?("start")==true
          h_sta = hash["start"]
          if hash.key?("end")==true
            h_end = hash["end"]
          end
        end
        if hash.key?("stride")==true
          raise "sorry, stride is not supported yet."
        end
      end

      idx_x = NArray.int(@shape[0]).indgen!
      idx_y = NArray.int(@shape[1]).indgen!
      idx_z = NArray.int(@shape[2]).indgen!
      idx_t = NArray.int(@shape[3]).indgen!
      str_x = idx_x[h_sta[0]]; end_x = idx_x[h_end[0]]
      str_y = idx_y[h_sta[1]]; end_y = idx_y[h_end[1]]
      str_z = idx_z[h_sta[2]]; end_z = idx_z[h_end[2]]
      str_t = idx_t[h_sta[3]]; end_t = idx_t[h_end[3]]

      na = NArrayMiss.new(vartype,end_x-str_x+1,end_y-str_y+1,end_z-str_z+1,end_t-str_t+1)
      for t in str_t..end_t
        for z in str_z..end_z
          na_xy = @ctl.get(@varname,z,t,[str_x,end_x,str_y,end_y])
          mask = ( na_xy.ne @ctl.undef )
          na[true,true,z-str_z,t-str_t] = NArrayMiss.to_nam(na_xy,mask)
        end
      end
    end
      na
  end

  alias simple_put put
  alias simple_get get

   def __rubber_expansion( args )  # copied from NetCDFVar class
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
     elsif args.length == 0   # to support empty [], []=
       args = [true]*rank
     end
     args
   end
   private :__rubber_expansion

   def [](*a)  # copied from NetCDFVar class
     a = __rubber_expansion(a)
     first = Array.new
     last = Array.new
     stride = Array.new
     set_stride = false
     a.each{|i|
       if(i.is_a?(Fixnum))
         first.push(i)
         last.push(i)
         stride.push(1)
       elsif(i.is_a?(Range))
         first.push(i.first)
         last.push(i.exclude_end? ? i.last-1 : i.last)
         stride.push(1)
       elsif(i.is_a?(Hash))
         r = (i.to_a[0])[0]
         s = (i.to_a[0])[1]
         if ( !( r.is_a?(Range) ) || ! ( s.is_a?(Integer) ) )
            raise TypeError, "Hash argument must be {a_Range, step}"
         end
         first.push(r.first) 
         last.push(r.exclude_end? ? r.last-1 : r.last)
         stride.push(s)
         set_stride = true
       elsif(i.is_a?(TrueClass))
         first.push(0)
         last.push(-1)
         stride.push(1)
       elsif( i.is_a?(Array) || i.is_a?(NArray))
         a_new = a.dup
         at = a.index(i)
         i = NArray.to_na(i) if i.is_a?(Array)
         for n in 0..i.length-1
           a_new[at] = i[n]..i[n]
           na_tmp = self[*a_new]
           if n==0 then
             k = at
             if at > 0
               a[0..at-1].each{|x| if x.is_a?(Fixnum) then k -= 1 end}
             end
             shape_tmp = na_tmp.shape
             shape_tmp[k] = i.length
             na = na_tmp.class.new(na_tmp.typecode,*shape_tmp)
             index_tmp = Array.new(shape_tmp.length,true)
           end
           index_tmp[k] = n..n
           na[*index_tmp] = na_tmp
         end
         return na
       else
         raise TypeError, "argument must be Fixnum, Range, Hash, TrueClass, Array, or NArray"
       end
     }

     if(set_stride)
       na = self.get({"start"=>first, "end"=>last, "stride"=>stride})
     else
       na = self.get({"start"=>first, "end"=>last})
     end
     shape = na.shape
     (a.length-1).downto(0){ |i|
         shape.delete_at(i) if a[i].is_a?(Fixnum)
      }
      na.reshape!( *shape )
     na
   end

   def []=(*a)  # copied from NetCDFVar class
     val = a.pop
     a = __rubber_expansion(a)
     first = Array.new
     last = Array.new
     stride = Array.new
     set_stride = false
     a.each{|i|
       if(i.is_a?(Fixnum))
         first.push(i)
         last.push(i)
         stride.push(1)
       elsif(i.is_a?(Range))
         first.push(i.first)
         last.push(i.exclude_end? ? i.last-1 : i.last)
         stride.push(1)
       elsif(i.is_a?(Hash))
         r = (i.to_a[0])[0]
         s = (i.to_a[0])[1]
         if ( !( r.is_a?(Range) ) || ! ( s.is_a?(Integer) ) )
            raise ArgumentError, "Hash argument must be {first..last, step}"
         end
         first.push(r.first) 
         last.push(r.exclude_end? ? r.last-1 : r.last)
         stride.push(s)
         set_stride = true
       elsif(i.is_a?(TrueClass))
         first.push(0)
         last.push(-1)
         stride.push(1)
       elsif(i.is_a?(Array) || i.is_a?(NArray))
         a_new = a.dup
         at = a.index(i)
         i = NArray.to_na(i) if i.is_a?(Array)
         val = NArray.to_na(val) if val.is_a?(Array)
         rank_of_subset = a.dup.delete_if{|v| v.is_a?(Fixnum)}.length
         if val.rank != rank_of_subset
           raise "rank of the rhs (#{val.rank}) is not equal to the rank "+
                 "of the subset specified by #{a.inspect} (#{rank_of_subset})"
         end
         k = at
         a[0..at-1].each{|x| if x.is_a?(Fixnum) then k -= 1 end}
         if i.length != val.shape[k]
           raise "length of the #{k+1}-th dim of rhs is incorrect "+
                 "(#{i.length} for #{val.shape[k]})"
         end
         index_tmp = Array.new(val.rank,true) if !val.is_a?(Numeric) #==>Array-like
         for n in 0..i.length-1
           a_new[at] = i[n]..i[n]
           if !val.is_a?(Numeric) then
             index_tmp[k] = n..n
             self[*a_new] = val[*index_tmp]
           else
             self[*a_new] = val
           end
         end
         return self
       else
         raise TypeError, "argument must be Fixnum, Range, Hash, TrueClass, Array, or NArray"
       end
     }

     if(set_stride)
        self.put(val, {"start"=>first, "end"=>last, "stride"=>stride})
     else
        self.put(val, {"start"=>first, "end"=>last})
     end
   end

 end

end

if __FILE__ == $0 then

  include NumRu

  begin
    gr = GrADS_Gridded.open("../../testdata/T.jan.ctl")
  rescue
    gr = GrADS_Gridded.open("../../../testdata/T.jan.ctl")
  end
  print gr.to_ctl
  p gr
  p gr.path
  p gr.var_names
  p gr.get_dim(gr.dimensions[2])
  p gr.get('T',0,0)

  begin
    grvar = GrADSVar.new("../../testdata/T.jan.ctl","T")
  rescue
    grvar = GrADSVar.new("../../../testdata/T.jan.ctl","T")
  end

  p grvar.dim_names
  p grvar.shape_ul0
  t = grvar[3..9,5..15,0,0]
  p t

end
