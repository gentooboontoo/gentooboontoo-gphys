=begin
= Gtool3 形式 IO ライブラリー（といっても O (書き) はなし）

== 軸ファイル（格子情報ファイル）について

環境変数 GTAXDIR で，軸ファイルのありかを指定するか,
Gtool3.gtaxdir= メソッドを使って指定する．

== Development Memo / 開発メモ

複数（一個以上）の変数の組の繰り返しを仮定する．よって，ヘッダを読んで
いって，変数名が，T,U,PS,T,..などと同じのに戻ったら，その時点で T,U,PS
の3変数の繰り返しであるとみなす．こうすることで，GrADS とほぼ同じように
扱えるようになる．なお，実際の Gtool3 ファイルはすべてこれでいけるはず．

エンディアンはブロック区切りから自動判別する．



=end

require "narray_miss"
require "date"
require "numru/gphys/unumeric"

module NumRu

  module IndexMixin
    def gen_idx(fst,lst,stp,len)
      fst = 0 if fst.nil?
      lst = len-1 if lst.nil?
      stp = 1 if stp.nil?
      lst += len if lst<0
      idx = Array.new
      fst.step(lst,stp){|i| idx.push(i)}
      idx
    end

    def slicer2idx(sl,len)
      sl = slicer_negproc(sl,len)
      case sl
      when NArray
        if sl.length == len and sl.typecode == NArray::BYTE
          sl.where
        else
          sl
        end
      when Array
        NArray[*sl]
      when true
        NArray.int(len).indgen!
      when Integer
        sl
      when Range
        NArray[*sl.to_a]
      when Hash
        rg = sl.first[0]
        fst = rg.first
        lenr = (rg.last - fst + (rg.exclude_end? ? 0 : 1))
        stp = sl.first[1]
        len = (lenr-1)/stp+1
        NArray.int(len).indgen!(fst,stp)
      else
        raise ArgumentError, "Unsupported slicer #{sl.inspect}"
      end
    end

    def slicer_minmax(sl,len)
      sl = slicer_negproc(sl,len)
      if sl.is_a?(Array)
        sl = NArray[*sl]
      end
      case sl
      when NArray
        if sl.length == len and sl.typecode == NArray::BYTE
          w = sl.where
          [ w[0], w[-1] ]
        else
          [ sl.min, sl.max ]
        end
      when true
        [ 0, len-1 ]
      when Integer
        [sl, sl]
      when Range
        [ sl.first, (sl.exclude_end? ? sl.last-1 : sl.last ) ]
      when Hash
        sl = slicer2idx(sl,len)
        [ sl.min, sl.max ]
      else
        raise ArgumentError, "Unsupported slicer #{sl.inspect}"
      end
    end

    def slicer_len(sl,len)
      sl = slicer_negproc(sl,len)
      case sl
      when NArray
        if sl.length == len and sl.typecode == NArray::BYTE
          sl.count_true
        else
          sl.length
        end
      when Array
        sl.length
      when true
        len
      when Integer
        1
      when Range
        sl.length
      when Hash
        sl.first[0].length / sl.first[1]
      else
        raise ArgumentError, "Unsupported slicer #{sl.inspect}"
      end
    end

    def slicer_negproc(sl,len)
      case sl
      when NArray
        if sl.min < 0
          sls = sl.dup
          sls[sl.lt(0)] += len
          sls
        else
          sl
        end
      when Array
        sl.collect{|i| i>=0 ? i : i+len}
      when true
        (0...len).collect{|i| i}
      when Integer
        sl += len if sl<0
        sl
      when Range
        range_negproc(sl,len)
      when Hash
        { range_negproc(sl.first[0],len) => sl.first[1] }
      else
        raise ArgumentError, "Unsupported slicer #{sl.inspect}"
      end
    end

    def range_negproc(rg,len)
      if ( (f=rg.first) < 0 or rg.last < 0 )
        f += len if f < 0
        l += len if (l=rg.last) < 0
        if rg.exclude_end?
          f...l
        else
          f..l
        end
      else
        rg
      end
    end

    def rubber_expansion( args, rank )
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

  class Gtool3

    include IndexMixin

    FLDLEN = 16          # length of each header element
    HEADLEN = 1024       # length a gtool3 header (64*16)
    NFLD = 64            # number of fields
    RLEN = {"UR4"=>4,"UR"=>4,"UR8"=>8}  # length of float types in bytes
    NATYP = {"UR4"=>NArray::SFLOAT,"UR"=>NArray::SFLOAT,"UR8"=>NArray::DFLOAT}
    AXES_IGNORED = ["SFC1"]  # special treatment (must be one-element axes)

    @@default_calender = "360_day"

    @@max_delimlen = 8   # maximum length of fortran unformated IO delimiter.
                         # actual length is found heulistically from files.
    @@gtaxdir = ENV["GTAXDIR"]

    @@fmtid = /(.*)            (9009|9010)/

    @@default_endian = :big

    @@hditems = %w!IDFM DSET ITEM EDIT1 EDIT2 EDIT3 EDIT4 EDIT5 EDIT6 EDIT7 EDIT8 FNUM DNUM TITL1 TITL2 UNIT ETTL1 ETTL2 ETTL3 ETTL4 ETTL5 ETTL6 ETTL7 ETTL8 TIME UTIM DATE TDUR AITM1 ASTR1 AEND1 AITM2 ASTR2 AEND2 AITM3 ASTR3 AEND3 DFMT MISS DMIN DMAX DIVS DIVL STYP OPT1 OPT2 OPT3 MEMO1 MEMO2 MEMO3 MEMO4 MEMO5 MEMO6 MEMO7 MEMO8 MEMO9 MEMO10 MEMO11 MEMO12 CDATE CSIGN MDATE MSIGN SIZE!
    @@intitems = %w!FNUM DNUM TIME TDUR ASTR1 AEND1 ASTR2 AEND2 ASTR3 AEND3 STYP SIZE!
    @@fltitems = %w!MISS DMIN DMAX DIVS DIVL!

    class << self
      alias open new

      def is_a_Gtool3?(path)
        file = File.open(path,"rb")
        head = file.read(FLDLEN + @@max_delimlen)
        file.close
        (@@fmtid=~head) and delimiter=head[0,$1.length]
      end

      def gtaxdir=(path)
        @@gtaxdir = path
      end

      def gtaxdir
        @@gtaxdir
      end

      def default_calender=(str)
        @@default_calender = str
      end
      def default_calender
        @@default_calender
      end
    end

    def initialize(path, mode="r")
      case(mode)
      when /^r/
        (delim=Gtool3.is_a_Gtool3?(path)) or raise("not a Gtool3 file: #{path}")
        @file = File.open(path, "rb")
        @delimlen, @bigendian = interpret_delim(delim)
        @headlen = HEADLEN + @delimlen*2
        @vars = @varh = @timeblock_lenb = nil  # to be set in parse_file
        @calender = @@default_calender  # can be modified with Gtool3#calender
        parse_file
      else
        raise ArgumentError, "Unsupported IO mode: #{mode}"
      end
    end

    def calender=(str)
      @calender = str
    end
    def calender
      @calender
    end

    def close
      @file.close
    end

    def path
      @file.path
    end

    def nvars
      @variables.length
    end

    def var( varname )
      Gtool3Var.new(self,varname)
    end

    def var_names
      @vars.collect{|var| var["ITEM"]} # use @vars to reflect the order in file
    end

    def has_var?(varname)
      @varh.has_key?(varname)
    end

    def inspect
      "<#{self.class}:#{path}>"
    end

=begin
    # subsetting of each dimension must be specified either
    # with idx or (fst,lst,stp) -- idx has a higher precedence
    def get(name, it, fst=[], lst=[], stp=[], idx=[])
      var = @varh[name] or raise(ArgumentError,"vardiable #{name} is not found")
      ld = var[:rankb] - 1   # last dimension of the block
      id = ( idx[ld] || gen_idx(fst[ld],lst[ld],stp[ld],var[:shapeb][ld]) )
      slb = 1
      bl = @timeblock_lenb
      (0..ld-1).each{|d| slb *= var[:shapeb][d]}
      slb *= var[:rlen]  # slb --> length of subblocks
      id.each do |k|
        @file.seek(it*bl + slb*k)
        buf = @file.read(slb)
        
      end
    end
=end

    # to redirect Gtool3Var#[sel] (the subsetting method) or Gtool3Var#get
    # (for sel==nil)
    def get(name, *sel)
      var = @varh[name] or raise(ArgumentError,"vardiable #{name} is not found")
      rk = var[:rank]
      if sel.empty?
        sel = [true]*rk 
      else
        sel = rubber_expansion( sel, rk )
      end

      sb = var[:start_byte]
      lb = @timeblock_lenb

      if var[:time_seq]
        tidx = slicer2idx( sel[rk-1], var[:shape][rk-1] )
        #val = NArray.new(var[:natyp], *var[:shape])
        val = nil
        selb = sel[0...var[:rankb]]
        if tidx.is_a?(Integer)
          val = read_block(sb+tidx*lb,selb,var[:natyp],var[:rlen],var[:shapeb])
        else
          for i in 0...tidx.length
            it = tidx[i]
            vb = read_block(sb+it*lb,selb,var[:natyp],var[:rlen],var[:shapeb])
            if val.nil?
              shp = vb.shape + [tidx.length]
              val = NArray.new(var[:natyp], *shp)
            end
            val[false,i] = vb
          end
        end
      else
        val = read_block(sb,sel,var[:natyp],var[:rlen],var[:shapeb])
      end
      NArrayMiss.to_nam_no_dup(val,val.ne(var["MISS"]))
    end

    def read_block(strb,selb,natyp,rlen,shapeb)
      ##print "***rb*** #{strb} #{selb.inspect}\n"
      zidx = slicer2idx(selb[-1],shapeb[-1])   # z simbolically represents the last dim of block
      if zidx.is_a?(Integer)
        min = max = zidx
        zidxoff = 0
      else
        min = zidx.min
        max = zidx.max
        zidxoff = zidx.collect{|i| i-min}
      end
      for i in 0...shapeb.length-1
        selb[i] = slicer2idx(selb[i],shapeb[i]) if selb[i].is_a?(Hash)
      end

      #min,max = slicer_minmax(selb[-1])   # first and last of last dim in block
      subblen = product(shapeb[0..-2])
      offs = min*subblen*rlen
      len = (max-min+1)*subblen*rlen   # ie, read by [false,min..max]
      @file.seek(strb+offs+@delimlen)
      buf = @file.read(len)
      zsubsh = shapeb[0..-2] + [max-min+1]
      #p "$$$",len,product(zsubsh)*rlen,rlen,natyp
      zsubsel = selb[0..-2] + [ zidxoff ]
      #p "$$$",zidx, zsubsh,zsubsel
      allint = true; zsubsel.each{|s| allint = false unless s.is_a?(Integer)}
      zsubsel[-1] = [zsubsel[-1]..zsubsel[-1]] if allint
      na = NArray.to_na(buf, natyp, *zsubsh)[*zsubsel]
      if @bigendian
        na.ntoh
      else
        na.vtoh
      end
    end

    def varinfo(name)
      @varh[name]
    end

=begin
    def get_performance_test
      var = @vars[0]
      sb = var[:start_byte]
      nz = var[:shapeb][2]
      nxy = var[:shapeb][0] * var[:shapeb][1]
      bl = @timeblock_lenb
      sz = File.size(@file.path)
      nt = sz/bl
      p nt,nz,nxy
      for it in 0...nt
        @file.seek(it*bl + sb)
        for iz in 0..nz
          #test 1
          @file.read(nxy*RLEN[var["DFMT"]])
          #test 2
          # @file.read(4)
          # @file.seek(nxy*RLEN[var["DFMT"]]-4, IO::SEEK_CUR)
          #test 3
          (nxy/20).times{@file.read(4*20)}
        end
      end
    end
=end

    ########## private methods #############
    private
    def parse_file
      @vars = Array.new
      @varh = Hash.new    # same as @vars but is a Hash to speed up to find
      start_byte = 0
      time_seq = false  # initial setting
      while(varinfo = read_header(@file)) do
        iv = @vars.length
        if iv==0 or @vars[-1]["ITEM"] != varinfo["ITEM"]
          start_byte += @headlen
          varinfo[:start_byte] = start_byte  # start byte in time block
          varinfo[:axes] = interpret_axes(varinfo)
          varinfo[:rankb] = varinfo[:axes].length  # rank of a block
          varinfo[:shapeb] = varinfo[:axes].collect{|v| v["LOC"][:val].length}
          @vars.push(varinfo)
          varinfo[:rlen] = RLEN[varinfo["DFMT"]] or raise("Unsupported numerical format")
          #p "*****",varinfo[:rlen]
          varinfo[:natyp] = NATYP[varinfo["DFMT"]]
          @varh[ varinfo["ITEM"] ] = varinfo
          start_byte += skip_a_data_block(varinfo, @file)  # shapeと型の利用にかえるべき
        else
          time_seq = true    # second turn --> regarded as a time sequence
          break
        end
      end
      @vars.each{|v| v[:time_seq] = time_seq}  # for all var
      @vars.each{|v| v[:rank] = (time_seq ? v[:rankb]+1 : v[:rankb])}
      @timeblock_lenb = start_byte    # lengh of a time block in bytes
      if time_seq
        bl = @timeblock_lenb
        sz = File.size(@file.path)
        nt = sz/bl
        @vars.each{|v| v[:shape] = v[:shapeb] + [nt]}
        timax = interpret_time_axis(varinfo)
        @vars.each{|v| v[:axes].push(timax)}
      else
        @vars.each{|v| v[:shape] = v[:shapeb]}
      end
  
    end

    def interpret_delim(delim)
      length = delim.length
      case length
      when 0
        bigendian = ( @@default_endian == :big )
      when 4
        if delim.unpack("N").first == HEADLEN
          bigendian = true
        elsif delim.unpack("V").first == HEADLEN
          bigendian = false
        else
          raise "Cannot interpret the delimiter #{delim.inspect}"
        end
      when 8
        if delim[4,4].unpack("N").first == HEADLEN
          bigendian = true
        elsif delim[0,4].unpack("V").first == HEADLEN
          bigendian = false
        else
          raise "Cannot interpret the delimiter #{delim.inspect}"
        end
      else
        raise "Unsupported fortran sequential IO delimiter length: #{length}"
      end
      [length, bigendian]
    end

    def read_header(file)
      hdstr = file.read(@headlen)
      if hdstr and (@@fmtid=~hdstr)
        hdstr = hdstr[@delimlen, HEADLEN] if @delimlen!=0 
        head = Hash.new
        (0...NFLD).each do |i|
          head[@@hditems[i]] = hdstr[i*FLDLEN,FLDLEN].strip
        end
        @@intitems.each{|k| head[k] = head[k].to_i}
        @@fltitems.each{|k| head[k] = head[k].to_f}
        head["TITLE"] = head.delete("TITL1") + head.delete("TITL2")
        head
      else
        nil
      end
    end

    def read_axis_data(file, len, skip, fmt)
      file.seek(@delimlen + RLEN[fmt]*skip, IO::SEEK_CUR)
      val = NArray.to_na(file.read(RLEN[fmt]*len),NATYP[fmt])
      file.seek(@delimlen, IO::SEEK_CUR)
      if @bigendian
        val.ntoh
      else
        val.vtoh
      end
    end

    def skip_a_data_block(head, file)
      len = head["SIZE"]
      b = RLEN[head["DFMT"]] or raise("Unsupported numerical format")
      lenb = len * b + @delimlen*2
      file.seek(lenb, IO::SEEK_CUR)
      lenb
    end

## Use head["SIZE"] instead
#    def datalen(head)
#      shape3 = [ head["AEND1"] - head["ASTR1"] + 1, \
#                 head["AEND2"] - head["ASTR2"] + 1, \
#                 head["AEND3"] - head["ASTR3"] + 1 ]
#      datalen = shape3[0] * shape3[1] * shape3[2]
#    end

    def interpret_axes(head)
      axes = Array.new
      ["AITM1","AITM2","AITM3"].each do |dnm|
        if ( (axnm = head[dnm]) != "" and !AXES_IGNORED.include?(axnm) )
          ax = Hash.new
          dim =dnm.sub(/^AITM/,"")
          fst = head["ASTR#{dim}"]
          len = head["AEND#{dim}"]-fst+1
          ["LOC","WGT"].each do |lw|
            axv = ax[lw] = {"ITEM" => axnm}
            if ( File.exist?(fn=File.dirname(@file.path)+"/GTAX#{lw}."+axnm) or 
                 @@gtaxdir and File.exist?(fn=File.expand_path(@@gtaxdir)+"/GTAX#{lw}."+axnm) )
              File.open(fn,"rb"){|axfile|
                hd = read_header(axfile)
                ["UNIT","TITLE","DMIN","DMAX","STYP"].each{|k| axv[k] = hd[k]}
                axv[:val] = read_axis_data(axfile,len,fst-1,hd["DFMT"])
              }
            elsif @@gtaxdir.nil?
              #raise( "GTAX#{lw}.#{axnm} is not found. You may need to set " +
              #       "a directory using Gtool3.gtaxdir=" )
              warn "#{__FILE__}:#{__LINE__}: GTAX#{lw}.#{axnm} is not found --> Use dummy indices (len:#{len}) (You may need to specify a directory by setting the environmental variable GTAXDIR or by using Gtool3.gtaxdir= )"
              na = NArray.float(len)
              axv[:val] = ( lw=="LOC" ? na.indgen!(fst-1) : na.fill(1) )
            end
          end
          axes.push(ax)
        end
      end
      axes
    end

    def interpret_time_axis(head)
      time_ax = Hash.new
      t0 = head["TIME"]
      units = Units[head["UTIM"].downcase]
      t0d = units.convert2(t0,"day")
      if /^(\d\d\d\d)(\d\d)(\d\d) *(\d\d)(\d\d)(\d\d)/ =~ head["DATE"]
        y4 = $1.to_i
        mon = $2.to_i
        day = $3.to_i
        hr = $4.to_i
        min = $5.to_i
        sec = $6.to_i
        date0 = DateTime.new(y4,mon,day,hr,min,sec)
        un0 = UNumeric[ -t0d, Units["days since #{date0.to_s}"] ]
        date_origin = un0.to_datetime(0.0, @calendar)
        if date_origin
          units = Units[ units.to_s + " since "+date_origin.to_s ]
        end
      end
      timax = {"LOC"=>{"UNIT"=>units.to_s, "TITLE"=>"time", "ITEM"=>"time"}}
      timax["LOC"][:val] = Gtool3TimeVal.new(@vars[0][:shape][-1], 
                                      @file, @delimlen, @timeblock_lenb)
      timax
    end

    def product(ary)
      prd = 1
      ary.each{|x| prd *= x}
      prd
    end
  end

  class Gtool3Var
    @@attkeys = %w!DSET ITEM TITLE UNIT TIME DATE UTIM TDUR MISS CDATE CSIGN MDATE MSIGN!

    def initialize(file,name)
      case file
      when String
        file = Gtool3.open(file)
      when Gtool3
      else
        raise ArgumentError, "not a Gtool3 or a String #{file.inspect}"
      end
      raise("Var '#{name}' is not in (#{file.path})") unless file.has_var?(name)
      @file = file
      @name = name
      @varinfo = file.varinfo(name)
    end

    def [](*sel)
      @file.get(@name,*sel)
    end

    def get
      self[]
    end

    def name
      @name
    end

    def typecode
      @varinfo[:natyp]
    end

    def rank
      @varinfo[:rank]
    end

    def dim_names
      @varinfo[:axes].collect{|ax| ax["ITEM"]}
    end

    def shape
      @varinfo[:shape].dup
    end
    alias shape_current shape

    def shape_ul0
      if @varinfo[:time_seq]
        sh = @varinfo[:shape].dup
        sh[-1] = 0
        sh
      else
        @varinfo[:shape].dup
      end
    end

    def file
      @file
    end

    def attr
      att = Hash.new
      @@attkeys.each{|k| att[k] = @varinfo[k]}
      att
    end

    def axis(d)
      @varinfo[:axes][d]
    end

  end


  # Behave like a NArray (by using method_missing)
  class Gtool3TimeVal

    include IndexMixin

    def initialize(len, file, delimlen, timblen)
      @length = len
      @boffset = 24*Gtool3::FLDLEN + delimlen
      @timeblen = timblen
      @file = file
      @val = nil
    end
    
    attr_reader :length, :file

    def get
      if @val.nil?
        @val = NArray.float(@length)
        for i in 0...@length
          @file.seek( @boffset + i*@timeblen )
          @val[i] = @file.read(Gtool3::FLDLEN).to_i
        end
      end
      @val
    end

    @@na_methods = Hash.new   # Hash for fast lookup
    NArray.float(1).methods.each{|nm| @@na_methods[nm.to_sym] = true}

    def [](arg)
      sl = slicer2idx(arg,@length)
      if @val.nil? && sl.length <= @length/20 
        # if the request is only for a small portion, it would 
        # be better just read it, rather than to put data in cache.
        val = NArray.float(@length)
        for i in sl
          @file.seek( @boffset + i*@timeblen )
          val[i] = @file.read(Gtool3::FLDLEN).to_i
        end
        val
      else
        get[sl]
      end
    end

    def method_missing(name, *args)
      if @@na_methods[name]
        get.__send__(name, *args)
      else
        super(name, *args)
      end
    end
  end

end

if $0 == __FILE__
  include NumRu
  Gtool3.gtaxdir = File.expand_path("~/dennou/GTAXDIR")
  path = ARGV[0]
  varname = ARGV[1] or raise("Need two args")
  file = Gtool3.open(File.expand_path(path))
  #file.get_performance_test
  #p file.get(varname,false).mean(0)
  p file, file.var_names
  p file.varinfo(varname)
  var = file.var(varname)
#  p var[]  #.mean(0) 
#  p var.axis(0), var.attr
#  p "******"
#  p var.shape
#  p var[0..4,0..2,0..2,0]
#  p var[{0..4,2},{0..2,2},{0..3,2},0]
#  p var[0,2,0,0]
  (0...var.rank).each{|i| p var.axis(i)}
  tax = var.axis(-1)
  tv = tax["LOC"][:val]
  p tv.get, tv.length, tv[0], tv[-1]
end

=begin
    1     & IDFM   & I10   #& フォーマットid  & 9009
    2     & DSET   & A16   #& データセット名  & AP01
    3     & ITEM   & A16   #& 識別名称(変数名)& TMP
    4     & EDIT1  & A16   #& 編集略記号(1)   & TM1D
    5     & EDIT2  & A16   #& 編集略記号(2)   & XFK1
    ...
    11    & EDIT8  & A16   #& 編集略記号(8)   &  
    12    & FNUM   & I10   #& ファイル番号    & 1
    13    & DNUM   & I10   #& データ番号      & 100
    14    & TITL1  & A16   #& タイトル        & Temperature
    15    & TITL2  & A16   #& \ \ 〃 \ \ 続き & 
    16    & UNIT   & A16   #& 単位            & K
    17    & ETTL1  & A16   #& 編集タイトル(1) & Dayly mean
    18    & ETTL2  & A16   #& 編集タイトル(2) & filter (X)
    ...
    24    & ETTL8  & A16   #& 編集タイトル(8) &          
    25    & TIME   & I10   #& 時刻(通し)      & 18769650900
    27    & UTIM   & A16   #& 時刻単位        & SEC
    26    & DATE   & A16   #& 時刻(yyyymmddhhmmss) & 19900813122800
    28    & TDUR   & I10   #& データ代表時間  & 3600
    29    & AITM1  & A16   #& 軸1の格子識別名称 & GLON128
    30    & ASTR1  & I10   #& 軸1の格子番号始め &   1
    31    & AEND1  & I10   #& 軸1の格子番号終り & 128
    32    & AITM2  & A16   #& 軸2の格子識別名称 & GGLA64
    33    & ASTR2  & I10   #& 軸2の格子番号始め &   1
    34    & AEND2  & I10   #& 軸2の格子番号終り &  64
    35    & AITM3  & A16   #& 軸3の格子識別名称 & SIGA12
    36    & ASTR3  & I10   #& 軸3の格子番号始め &   1
    37    & AEND3  & I10   #& 軸3の格子番号終り &  12
    38    & DFMT   & A16   #& データフォーマット & (32F12.5) or UR4
    39    & MISS   & E15.7 #& 欠損値の値      & -9999.
    40    & DMIN   & E15.7 #& レンジ(最小)    & 100.  
    41    & DMAX   & E15.7 #& レンジ(最大)    & 300.  
    42    & DIVS   & E15.7 #& 間隔(小)        & 10.   
    43    & DIVL   & E15.7 #& 間隔(大)        & 50.   
    44    & STYP   & I10   #& スケーリングタイプ & 1  
    45--47& OPTNx  & A16   #& 空き            &
    48--59& MEMOxx & A16   #& メモ            &
    60    & CDATE  & A16   #& データ作成日付  & 19900813122800
    61    & CSIGN  & A16   #& データ作成者    & SWAMP     
    62    & MDATE  & A16   #& データ変更日付  & 19900926225422
    63    & MSIGN  & A16   #& データ変更者    & SWAMP     
    64    & SIZE   & I10   #& 配列のサイズ    & 98304

=end
