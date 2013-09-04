require "numru/dcl"
require "numru/misc"
require "date"      # needs ruby >= 1.8 for DateTime class


module NumRu
  module DCLExt

    module_function

    @@datetime_ax_options = Misc::KeywordOptAutoHelp.new(
      ['yax', false, 'true => y-axis, false => x-axis'],
      ['cside', nil, '"b", "t", "l", "r", nil (=>left/bottom), or false (=>right/top)'],
      ['dtick1', 1, 'small tick interval in hours'],
      ['dtick2', nil, 'large tick (with hour labels) interval in hours'],
      ['year', false, 'true => add year to date label'],
      ['month', true, 'true => add month to date label']
    )

    def datetime_ax(date_from, date_to, options=nil)
      # date_from [a DateTime] : start on this date&time
      # date_to [a DateTime]   : end on this date&time

      opt = @@datetime_ax_options.interpret(options)

      yax = opt['yax']
      xax = !yax
      if xax
	xy='x'
      else
	xy='y'
      end

      if opt['cside']
	cside = opt['cside']
      elsif opt['cside'].nil?
	if xax
	  cside='b'
	else
	  cside='l'
	end
      else
	if xax
	  cside='t'
	else
	  cside='r'
	end
      end

      if opt['year']
	datefmt = '%Y/%m/%d'
      elsif opt['month']
	datefmt = '%m/%d'
      else
	datefmt = '%d'
      end

      # < window parameters >

      ux1,ux2,uy1,uy2 = DCL.sgqwnd
      if xax
	u1, u2 = ux1, ux2
      else
	u1, u2 = uy1, uy2
      end

      loffset_save = DCL.uzpget('loffset')
      xyfact_save = DCL.uzpget(xy+'fact')
      xyoffset_save = DCL.uzpget(xy+'offset')

      tu1 = date_from.day_fraction.to_f
      range_day = date_to - date_from    # time btwn start and end (in days)
      tu2 = tu1 + range_day

      # < axis in hours >

      DCL.uzpset('loffset',true)

      DCL.uzpset(xy+'fact',24.0)
      DCL.uzpset(xy+'offset',(tu1-u1)*24)

      dtick1 = opt['dtick1']
      if opt['dtick2']
	dtick2 = opt['dtick2']
      else
	if range_day >= 4
	  dtick2 = 24
	elsif range_day >= 2
	  dtick2 = 12
	elsif range_day >= 1
	  dtick2 = 6
	elsif range_day >= 0.5
	  dtick2 = 3
	elsif range_day >= 0.25
	  dtick2 = 2
	else
	  dtick2 = 1
	end
      end

      str_hour = (tu1*24).ceil
      end_hour = (tu2*24).floor
      tick1=Array.new
      tick2=Array.new
      labels=Array.new
      h1 = str_hour + (-str_hour % dtick1)
      (h1..end_hour).step(dtick1){|i| tick1.push(i)}
      h2 = str_hour + (-str_hour % dtick2)
      (h2..end_hour).step(dtick2) do |i|
	tick2.push(i)
	labels.push((i%24).to_s)
      end
      if xax
	DCL.uxaxlb(cside, tick1, tick2, labels, 2)
      else
	irotl_save = DCL.uzpget('irotly'+cside)
	icent_save = DCL.uzpget('icenty'+cside)
	DCL.uzpset('irotly'+cside,1)
	DCL.uzpset('icenty'+cside,0)
	DCL.uyaxlb(cside, tick1, tick2, labels, 2)
      end

      # < labels in days >

      if DCL.uzpget('label'+xy+cside)
	DCL.uzpset(xy+'fact',1.0)
	DCL.uzpset(xy+'offset',0.0)

	str_day = tu1.floor
	end_day = tu2.floor
	pos=Array.new
	labels=Array.new
	(str_day..end_day).step(1) do |i|
	  u = i.to_f + 0.5 + (u1- tu1)
	  u = (u1+u+0.5)/2 if u < u1
	  u = (u2+u-0.5)/2 if u > u2
	  pos.push(u)
	  str = (date_from+i).strftime(datefmt)
	  str.sub!(/^0/,'') if !opt['year'] && opt['month']
	  labels.push(str)
	end

        if xax
	  DCL.uxsaxz(cside,DCL.uzpget('roffx'+cside))
	  DCL.uxplbl(cside,1,pos,labels,10)
	else
	  DCL.uysaxz(cside,DCL.uzpget('roffy'+cside))
	  DCL.uyplbl(cside,1,pos,labels,10)
	#  DCL.uzpset('irotly'+cside,irotl_save)
	#  DCL.uzpset('icenty'+cside,icent_save)
	end

      end

      if xax
      else
	DCL.uzpset('irotly'+cside,irotl_save)
	DCL.uzpset('icenty'+cside,icent_save)
      end

      # < to finish >

      DCL.uzpset('loffset',loffset_save)
      DCL.uzpset(xy+'fact',xyfact_save)
      DCL.uzpset(xy+'offset',xyoffset_save)

    end
  end
end


######## test program ######

if $0 == __FILE__
  
  include NumRu

  iws = (ARGV[0] || (puts ' WORKSTATION ID (I)  ? ;'; DCL.sgpwsn; gets)).to_i
  DCL.swpset('ldump',true) if iws==4
  DCL.gropn iws
  DCL.sldiv('y',2,1)
  
  date_from = DateTime.parse('2005-06-30 17:00')
  date_to = DateTime.parse('2005-07-01 5:00')
  date_from2 = DateTime.parse('2005-06-29 17:00')
  date_to2 = DateTime.parse('2005-07-02 5:00')

  any_offst = 10

  DCL.grfrm
  DCL.grswnd(0.0, date_to-date_from, any_offst, date_to2-date_from2+any_offst)
  DCL.grsvpt(0.2, 0.8, 0.2, 0.8)
  DCL.grstrn(1)
  DCL.grstrf
  DCLExt.datetime_ax(date_from,  date_to,                 'year'=>true)
  DCLExt.datetime_ax(date_from,  date_to, 'cside'=>'t',   'year'=>true)
  DCLExt.datetime_ax(date_from2, date_to2, 'yax'=>true)
  DCLExt.datetime_ax(date_from2, date_to2, 'yax'=>true, 'cside'=>'r')
  DCL.uxsttl('b','TIME AND DATE',0.0)
  DCL.uysttl('l','TIME AND DATE',0.0)

  DCL.grfrm
  DCL.grswnd(0.0, date_to-date_from, 0, date_to2-date_from2)
  DCL.grsvpt(0.2, 0.8, 0.2, 0.8)
  DCL.grstrn(1)
  DCL.grstrf
  DCL.uzpset('inner',-1)
  DCLExt.datetime_ax(date_from,  date_to,               'dtick2'=>2)
  DCLExt.datetime_ax(date_from,  date_to, 'cside'=>'t', 'dtick2'=>2)
  DCL.uzpset('inner',1)
  DCLExt.datetime_ax(date_from2, date_to2, 'yax'=>true, 
                     'dtick1'=>2, 'dtick2'=>24)
  DCLExt.datetime_ax(date_from2, date_to2, 'yax'=>true, 'cside'=>'r',
                     'dtick1'=>2, 'dtick2'=>24)
  DCL.uxsttl('b','TIME AND DATE',0.0)
  DCL.uysttl('l','TIME AND DATE',0.0)

  DCL.grcls

end
