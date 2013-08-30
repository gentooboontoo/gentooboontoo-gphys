require "numru/units"
require "rational"    # for UNumeric#sqrt
require "date"        # for DateTime

## require "numru/gphys/gphys"   # --> in the test program

=begin
=class NumRu::UNumeric

Class of Numeric with Units.

Dependent on 
((<NumRu::Units|URL:http://ruby.gfd-dennou.org/products/numru=units>))
and Rational, a standard library.

==Class Methods

---new(val, uni)

    Constractor.

    ARGUMENTS
    * ((|val|)) (Numeric)
    * ((|units|)) (NumRu::Units or String):  if string, internally converted to
      a NumRu::Units

---[val, uni]

   Same as new

---from_date(date, units)

    Convert a DateTime (or Date) to a UNUmeric

    ARGUMENTS
    * date (Date or DateTime)
    * units (Units or String) : units of the UNumeric to be created

==Methods

---val

    RETURN VALUE
    * the value (Numeric)

---units

    RETURN VALUE
    * the units (NumRu::Units)

---inspect

    RETURN VALUE
    * a String (e.g., '1 m')

---to_s

    aliasesed to ((<inspect>)).

---to_f
    RETURN VALUE
    * val.to_f

---to_i
    RETURN VALUE
    * val.to_i

---convert(to_units)

    Convert to ((|to_units|)).

    RETURN VALUE
    * a UNumeric

    EXCEPTION
    * when the current units is incompatible with to_units.

---convert2

    Same as ((<convert>)), but returns ((|self|)) if the units are
    incompatible (Warned).

    EXCEPTION
    * none

    WARING MADE

    Warning is made to $stderr if the following
    condition is satisfied.

    * the units of ((|self|)) and ((|to_units|)) are incompatible.

---coerce(other)

    As you know. Can handle Numeric, Array, NArray.
    NOTE: VArray and GPhys know UNumeric.

--- *(other)

     Multiplication. Knows Numeric, UNumeric, VArray, and GPhys.
     The units are multipled too. (if other is Numeric, it is assumed 
     to be non-dimension)

     RETURN VALUE
     * a UNumeric, VArray, or GPhys

--- /(other)

     Division. See ((<*>)).

--- +(other)

     Addition. Knows Numeric, UNumeric, VArray, and GPhys.
     The return value will have the units of ((|self|)).

     SPECIAL REMARK!

     If ((|other|)) has units within a factor and/or offset
     of difference, It is CONVERTED before addition (by using ((<convert2>)))!
 
     RETURN VALUE
     * a UNumeric, VArray, or GPhys

     WARING MADE 

     Warning is made to $stderr if the following
     condition is satisfied.

     * the units of ((|self|)) and ((|to_units|)) are incompatible.
     * ((|other|)) is Numeric.

--- -(other)

     Subtraction. See ((<+>)).

--- **(num)

     Power.

--- abs

     Absolute value. Other math functions are also avialable as instance 
     methods.

---to_datetime(eps_sec=0.0)

    Convert a time UNumeric into a DateTime

    ARGUMENTS
    * eps_sec (Float) : Magic epsilon to prevent the round-off of 
      DateTime [seconds]. Recommended value is 0.1.

    RETURN VALUE
    * a DateTime    

    EXCEPTION
    * raised if self does not have a time unit with a since field

---strftime(fmt)

    Text expression of the date and time of a time UNumeric.
    Implemented as
      self.to_datetime(0.1).strftime(fmt)

    ARGUMENTS
    * fmt (Sting) : the format. Try
         % man 3 strftime
      to find how to write it.

    RETURN VALUE
    * a String

=end

module NumRu

  class UNumeric
    
    def initialize(val, uni)
      raise TypeError unless Numeric === val
      uni = Units.new(uni) if String === uni
      raise TypeError unless Units === uni
      @val, @uni = val, uni
    end
      
    def self::[](val, uni)
      new(val, uni)
    end

    @@supported_calendars = [nil,"gregorian", "standard", "proleptic_gregorian", 
                            "noleap", "365_day", "360_day"]

    def self::supported_calendar?(cal)
      @@supported_calendars.include?(cal)
    end

    def self::supported_calendars
      @@supported_calendars.dup
    end

    # * date (Date or DateTime)
    # * units (Units or String) : units of the UNumeric to be created
    def self::from_date(date, units, calendar=nil)
      sunits = units.to_s
      /(.*) *since *(.*)/ =~ sunits
      if (!$1 or !$2)
        raise("Units mismatch. Requires time units that includes 'since'")
      end
      tun = Units[$1]
      since = DateTime.parse(UNumeric::before_date_parse($2))
      if( tun =~ Units['months since 0001-01-01'] )
        year0,mon0 = since.year,since.mon
        year,mon = date.year,date.mon
        time = Units['months'].convert((year*12+mon)-(year0*12+mon0), tun)
      elsif( tun =~ Units['days since 0001-01-01'] )
        case calendar
        when nil, "gregorian", "standard"
          time = Units['days'].convert( date-since, tun )
        when "proleptic_gregorian"
          since = DateTime.parse(UNumeric::before_date_parse($2),false,Date::GREGORIAN)
          time = Units['days'].convert( date-since, tun )
        when "noleap", "365_day"
          since_yday = since - DateTime.new(since.year,1,1) # day number of year (0..364)
          since_yday = since_yday - 1 if( since.leap? && since.mon > 2 )
          date_yday = date - DateTime.new(date.year,1,1)
          if( date.leap? )
            if date_yday >= 60.0 # after Mar1
              date_yday = date_yday - 1
            elsif date_yday >= 59.0 # Feb29
              raise("Feb.29 is specified, but calendar is #{calendar}.")
            end
          end
          days = (date.year - since.year)*365 + (date_yday - since_yday)
          time = Units['days'].convert( days, tun )
        when "360_day" # does not work perfectly
          if date.day == 31
            raise("day=31 is specified, but calendar is #{calendar}.")
          end
          if date.is_a?(DateTime)
            date_hour,date_min,date_sec = date.hour,date.min,date.sec
          else
            date_hour,date_min,date_sec = 0,0,0
          end
          days = (date.year-since.year)*360 + (date.mon-since.mon)*30 + 
                 (date.day-since.day) + Rational(date_hour-since.hour,24) + 
                 Rational(date_min-since.min,1440) + Rational(date_sec-since.sec,86400)
          time = Units['days'].convert( days.to_f, tun )
        else
          #raise("Unrecognized calendar: #{calendar}")
          return nil
        end
      else
        #raise("Unrecognized time units #{tun.to_s}")
        return nil
      end
      time = time.to_f
      UNumeric[time, units]
    end


    # Always interpret y \d\d as 00\d\d and y \d as 000\d
    # (Date in Ruby 1.9 interprets them as 20\d\d etc.)
    def self::before_date_parse(str)
      if /^\d\d-\d/ =~ str
        str = "00"+str
      elsif /^\d-\d/ =~ str
        str = "00"+str
      end
      str
    end

    def val; @val; end

    def units; @uni; end

    def inspect
      val.to_s + ' ' +units.to_s
    end

    alias to_s inspect

    def to_f; @val.to_f; end
    def to_i; @val.to_i; end

    def convert(to_units)
      if ( units == to_units )
	self
      else
	UNumeric[ units.convert(val, to_units), to_units ]
      end
    end

    def convert2(to_units)
      # returns self if the units are incompatible
      begin
	convert(to_units)
      rescue
	#if $VERBOSE
	$stderr.print(
                   "WARNING: incompatible units: #{units.to_s} - #{to_units.to_s}\n")
	#end   # warn in Ruby 1.8
	self
      end
    end

    def strftime(fmt)
      self.to_datetime(0.1).strftime(fmt)
    end

    # * eps_sec : Magic epsilon to prevent the round-off of DateTime [seconds].
    #             Recommended value is 0.1.
    def to_datetime(eps_sec=0.0,calendar=nil)
      time = self.val
      sunits = self.units.to_s
      /(.*) *since *(.*)/ =~ sunits
      if (!$1 or !$2)
  	raise("Units mismatch. Requires time units that includes 'since'")
      end
      tun = Units[$1]
      sincestr = $2.sub(/(^\d{1,2}-\d+-\d)/,'00\1') 
              #^ correction for Ruby 1.9 to prevent 1- or 2-digit years
              #  (e.g. 1, 02) to be interpreted as in 2000's (e.g., 2001, 2002)
      since = DateTime.parse(UNumeric::before_date_parse(sincestr))
      if( tun =~ Units['months since 0001-01-01'] )
        datetime = since >> tun.convert( time, Units['months'] )
      elsif( tun =~ Units['days since 0001-01-01'] )
        case calendar
        when nil, "gregorian", "standard"
          # default: Julian calendar before 1582-10-15, Gregorian calendar afterward
          datetime = since + tun.convert( time, Units['days'] )
        when "proleptic_gregorian"
          # Gregorian calendar extended to the past
          since = DateTime.parse(UNumeric::before_date_parse(sincestr),false,Date::GREGORIAN)
          datetime = since + tun.convert( time, Units['days'] )
        when "noleap", "365_day"
          since_yday = since - DateTime.new(since.year,1,1) # day number of year (0..364)
          since_yday = since_yday - 1 if( since.leap? && since.mon > 2 )
          days = since_yday + tun.convert( time, Units['days'] )
          year = since.year + (days/365).to_i
          date_yday = days%365 # day number of year (0..364)
          datetime = DateTime.new(year,1,1) + date_yday
          datetime = datetime + 1 if( datetime.leap? && date_yday >= 59 )
        when "360_day" # does not work perfectly
          since_day = since - DateTime.new(since.year,since.mon,1)
          days = (since.mon-1)*30 + since_day + tun.convert( time, Units['days'] )
          year = since.year + (days/360).to_i
          mon = ((days%360)/30).to_i + 1
          datetime = DateTime.new(year,mon,1) + days%30 # Feb29->Mar1,Feb30->Mar2
          #datetime = DateTime.new(year,mon,days%30 + 1) # stops if Feb29,Feb30
          if datetime.mon != mon # Feb29,Feb30
            $stderr.print("cannot convert #{year}-#{mon}-#{(days%30+1).to_i} to DateTime instance\n")
            return nil
          end
        else
          #raise("Unrecognized calendar: #{calendar}")
          return nil
        end
      else
        #raise("Unrecognized time units #{tun.to_s}")
        return nil
      end
      if eps_sec != 0.0
        datetime = datetime + eps_sec/8.64e4  
      end
      datetime
    end

    def coerce(other)
      case
      when Numeric
	c_other = UNumeric.new( other, Units.new("1") )
      when Array
	c_other = VArray.new( NArray.to_na(other) )
      when NArray
	c_other = VArray.new( other )
      else
	raise "#{self.class}: cannot coerce #{other.class}"
      end
      [ c_other, self ]
    end

    def *(other)
      case other
      when UNumeric
	UNumeric.new( val * other.val , units * other.units )
      when Numeric
	# assumed to be non-dimensional
	UNumeric.new( val * other, units )
      when VArray, GPhys
	result = other * val
	result.units = units * other.units
	result
      else
	s, o = other.coerce( self )
	s * o
      end
    end

    def +(other)
      case other
      when UNumeric
	v = val + other.convert2( units ).val
	UNumeric.new( v , units )
      when Numeric
	v = val + other
	$stderr.print("WARNING: raw Numeric added to #{inspect}\n") #if $VERBOSE
	UNumeric.new( v, units )
      when VArray, GPhys
	ans = other.units.convert2(other, units) + val
	ans.units = units     # units are taken from the lhs
	ans
      else
	s, o = other.coerce( self )
	s + o
      end
    end
    
    def **(other)
      UNumeric.new( val**other, units**other )
    end

    def abs
      UNumeric.new( val.abs, units )
    end

    def -@
      UNumeric.new( -val, units )
    end

    def +@
      self
    end

    def -(other)
      self + (-other)   # not efficient  --> Rewrite later!
    end

    def /(other)
      self * (other**(-1))   # not efficient  --> Rewrite later!
    end

    LogicalOps = [">",">=","<","<=","==","==="]
    LogicalOps.each { |op|
      eval <<-EOS, nil, __FILE__, __LINE__+1
        def #{op}(other)
          case other
	  when UNumeric
	    val #{op} other.convert2( units ).val
	  when Numeric
	    $stderr.print("WARNING: raw Numeric added to #{inspect}\n") #\
                # if $VERBOSE   # warn in Ruby 1.8
	    val #{op} other
	  when VArray, GPhys
	    val #{op} other.units.convert2(other, units)
	  else
	    s, o = other.coerce( self )
	    s #{op} o
	  end
	end
      EOS
    }

    Math_funcs_nondim = ["exp","log","log10","log2","sin","cos","tan",
	    "sinh","cosh","tanh","asinh","acosh",
	    "atanh","csc","sec","cot","csch","sech","coth",
	    "acsch","asech","acoth"]
    Math_funcs_nondim.each{ |f|
      eval <<-EOS, nil, __FILE__, __LINE__+1
        def #{f}
          UNumeric.new( Math.#{f}(val), Units.new('1') )
        end
      EOS
    }
    Math_funcs_radian = ["asin","acos","atan","acsc","asec","acot"]
    Math_funcs_radian.each{ |f|
      eval <<-EOS, nil, __FILE__, __LINE__+1
        def #{f}
          UNumeric.new( Math.#{f}(val), Units.new('rad') )
        end
      EOS
    }

    def atan2(other)
      case other
      when Numeric
	UNumeric.new( Math.atan2(val, other), Units.new('rad') )
      when UNumeric
	UNumeric.new( Math.atan2(val, other.val), Units.new('rad') )
      else
	c_me, c_other = other.coerce(self)
	c_me.atan2(c_other)
      end
    end

    def sqrt
      UNumeric.new( Math.sqrt(val), units**Rational(1,2) )
    end

  end   # class UNumeric
end   # module NumRu

######################################
if $0 == __FILE__

  require "narray"

  include NumRu
  a = UNumeric[ 10.0, Units['m/s'] ]
  b = UNumeric[ 2.0, Units['m/s'] ]
  c = UNumeric[ 5.0, Units['m'] ]

  print "\n** Section 1 **\n"
  p a
  p a*b
  p a+b
  p a+c
  p a+7
  p a*7
  p -a
  p a-b, a-1000, a/100
  p a.log, a.sin
  p UNumeric[1.0,Units['1']].atan2( UNumeric[1.0,Units['1']] )

  print "\n** Section 2 **\n"
  p a > 1
  p 1 > a

  print "\n** Section 3 **\n"

  require "numru/gphys/varray"

  na = NArray.float(4).indgen
  va = VArray.new( na )
  vb = a + va
  p vb, vb.units, vb.att_names

  a = UNumeric[ 3721.0, Units['seconds since 2008-01-01'] ]
  p a.to_datetime.to_s, a.strftime('%Y-%m-%d %H:%M:%S')
  b = UNumeric[ 3.0, Units['months since 2008-01-01'] ]
  p b.strftime('%Y-%m-%d %H:%M:%S')
  p (UNumeric::from_date(DateTime.parse('2008-01-01 00:00-0200'), 
                         'seconds since 2008-01-01')).to_s
  p (UNumeric::from_date(DateTime.parse('2008-6-01'), 
                         'months since 2008-01-01')).to_s
end
