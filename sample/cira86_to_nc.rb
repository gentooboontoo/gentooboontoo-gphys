=begin
=cira86_to_nc.rb

Read the CIRA86 data file, make corresponding GPhys objects, 
and write into a NetCDF file.

==Usage

The following will create a NetCDF file 'cira86.nc' under the current 
directory.

   % ruby cira86_to_nc.rb
=end

require 'numru/gphys'

#<< read CIRA data >>

file = File.open('../testdata/cira86.dat')

nlat = 17
nht = 36
nmon = 12
cira_miss_val = 999.0

lat, lat_units  = NArray.sfloat(nlat), 'degrees'      # latitude
ht,  ht_units   = NArray.sfloat(nht), 'km'            # height
mon, mon_units  = NArray.sfloat(nmon), 'month'        # month
prs, prs_units  = NArray.sfloat(nht), 'hPa'           # pressure
temp,temp_units = NArray.sfloat(nht,nlat,nmon), 'K'   # temperature
gph, gph_units  = NArray.sfloat(nht,nlat,nmon), 'km'  # geopot. height
west,west_units = NArray.sfloat(nht,nlat,nmon),'m/s'  #eastward(westerly) wind

mon.indgen!.add!(1)      # => 1..12
lat=(lat.indgen!-8)*10   # => -80,-70,...,80

print "Reading the CIRA86 data file...\n"
for imon in 0...nmon
  dummy = file.gets
  for iht in 0...nht
    data = file.gets.strip.split(/ +/).collect{|v| v.to_f}
    ht[iht] = data.shift
    prs[iht] = data.shift
    temp[iht,true,imon] = data
  end
  dummy = file.gets
  for iht in 0...nht
    data = file.gets.strip.split(/ +/).collect{|v| v.to_f}
    gph[iht,true,imon] = data[2..-1]
  end
  dummy = file.gets
  for iht in 0...nht
    data = file.gets.strip.split(/ +/).collect{|v| v.to_f}
    west[iht,true,imon] = data[2..-1]
  end
end

temp = temp.transpose(1,0,2)     # => [lat,ht,mon]
gph  = gph.transpose(1,0,2)      # => [lat,ht,mon]
west = west.transpose(1,0,2)     # => [lat,ht,mon]

#<< change missing value to a large value >>

gp_miss_val = 2e30
valid_max = 1e30
temp[temp.eq(cira_miss_val)] = gp_miss_val
gph[gph.eq(cira_miss_val)] = gp_miss_val
west[west.eq(cira_miss_val)] = gp_miss_val

#<< into GPhys >>

include NumRu

lat_ax = Axis.new.set_pos(
  VArray.new(lat,nil,'lat').set_att('units',lat_units).
			    set_att('long_name','latitude')
)
ht_ax = Axis.new.set_pos(
  VArray.new(ht,nil,'ht').set_att('units',ht_units).
			    set_att('long_name','height')
)
ht_ax.set_aux('pressure',
  VArray.new(prs,nil,'prs').set_att('units',prs_units).
			    set_att('long_name','pressure')
)
mon_ax = Axis.new.set_pos(
  VArray.new(mon,nil,'mon').set_att('units',mon_units).
			    set_att('long_name','calendar month')
)

grid = Grid.new(lat_ax, ht_ax, mon_ax)

gp_miss_val = NArray.sfloat(1).fill!(gp_miss_val)
valid_max = NArray.sfloat(1).fill!(valid_max)

temp_gp = GPhys.new( grid,
  VArray.new(temp,nil,'temp').set_att('units',temp_units).
         set_att('long_name','temperature').
         set_att('valid_max',valid_max).set_att('missing_value',gp_miss_val)
)
gph_gp = GPhys.new( grid,
  VArray.new(gph,nil,'gph').set_att('units',gph_units).
	 set_att('long_name','geoptential height').
         set_att('valid_max',valid_max).set_att('missing_value',gp_miss_val)
)
west_gp = GPhys.new( grid,
  VArray.new(west,nil,'west').set_att('units',west_units).
         set_att('long_name','westerly wind').
         set_att('valid_max',valid_max).set_att('missing_value',gp_miss_val)
)
print "...GPhys created: #{temp_gp.name}, #{gph_gp.name}, #{west_gp.name}\n"

#<<into a NetCDF file>>

ofilename = 'cira86.nc'
print "Writing into #{ofilename}...\n"
file = NetCDF.create(ofilename)
GPhys::NetCDF_IO.write(file,temp_gp)
GPhys::NetCDF_IO.write(file,gph_gp)
GPhys::NetCDF_IO.write(file,west_gp)
file.close
print "...done\n"
