=begin
=map_projection.rb
==USAGE
  % ruby map_projection.rb [wsn]
where wsn is 1,2,3,or 4.
PNG files will be dumped if wsn==4.
=end

require 'numru/ggraph'
include NumRu

wsn = ( ARGV[0] ? ARGV[0].to_i : 1 )

path = '../testdata/T.jan.nc'
var = 'T'
gp = GPhys::IO.open(path,var)

DCL.swpset('ldump',true) if wsn == 4
DCL.gropn(wsn)
DCL.sldiv('t',3,2)
DCL.uzfact(1.1)
DCL.sgpset('lcntl',false)

# < defalut: itr==1 >
GGraph.set_fig('viewport'=>[0.2,0.8,0.21,0.81])
GGraph.tone( gp )
DCL.grfrm

# < map projection >

GGraph.set_map('vpt_boundary'=>true, 'coast_world'=>true)

itr=11
GGraph.set_fig('itr'=>itr)
[ [180.0,0.0,0.0],  [180.0,0.0,180.0] ].each do |axis|
  GGraph.next_fig('map_axis'=>axis)
  GGraph.tone( gp.cut('lat'=>-70.0..-20.0) )
  DCL::sgtxzr(0.5, 0.15, DCL::sgtrnl(itr).strip+"  map_axis=#{axis.inspect}", 
	      0.03, 0, 0, 3)

  GGraph.next_fig('map_axis'=>axis, 'map_window'=>[-180.0,180.0,-70.0,-20.0])
  GGraph.tone( gp.cut('lat'=>-70.0..-20.0) )
  DCL::sgtxzr(0.5, 0.15, DCL::sgtrnl(itr).strip+"  map_axis=#{axis.inspect}",
	      0.03, 0, 0, 3)
end

[  [180.0,0.0,90.0], [180.0,0.0,60.0] ].each do |axis|
  GGraph.next_fig('map_axis'=>axis)
  GGraph.tone( gp.cut('lat'=>-70.0..-20.0) )
  DCL::sgtxzr(0.5, 0.15, DCL::sgtrnl(itr).strip+"  map_axis=#{axis.inspect}",
	      0.03, 0, 0, 3)
end

GGraph.set_map('vpt_boundary'=>false)

[10,11,12,13,14,15].each do |itr|
  GGraph.next_fig('itr'=>itr)
  GGraph.tone( gp )
  DCL::sgtxzr(0.5, 0.15, DCL::sgtrnl(itr), 0.03, 0, 0, 3)
end

[20,21,22,23,30,31,32,33].each do |itr|
  GGraph.next_fig('itr'=>itr)
  if itr==31  # polar stereo
    GGraph.next_map('vpt_boundary'=>3) 
    DCL::sgpset('lclip', true)
  else
    DCL::sgpset('lclip', false)
  end
  GGraph.tone( gp )
  DCL::sgtxzr(0.5, 0.15, DCL::sgtrnl(itr), 0.03, 0, 0, 3)

  axis = [135,60,0]
  GGraph.next_fig('itr'=>itr,'map_axis'=>axis,'map_radius'=>60.0)
  GGraph.next_map('vpt_boundary'=>3) if itr==31  # polar stereo
  GGraph.tone( gp.cut('lat'=>0..90) )
  DCL::sgtxzr(0.5, 0.15, DCL::sgtrnl(itr).strip+"  map_axis=#{axis.inspect}",
	      0.03, 0, 0, 3)
end

# < cylindrical and mercator; effects of 'map_fit' >

gpjpn = gp.cut(110..160,10..70,false)

itr = 10
GGraph.next_fig('itr'=>itr)
GGraph.tone( gpjpn )
DCL::sgtxzr(0.5, 0.15, DCL::sgtrnl(itr).strip+'  defaut', 0.03, 0, 0, 3)

itr = 10
GGraph.next_fig('itr'=>itr, 'map_fit'=>false )
GGraph.tone( gpjpn )
DCL::sgtxzr(0.5, 0.15, DCL::sgtrnl(itr).strip+"  'map_fit'=>false", 0.03, 0, 0, 3)

itr=11
GGraph.next_fig('itr'=>itr)
GGraph.tone( gpjpn )
DCL::sgtxzr(0.5, 0.15, DCL::sgtrnl(itr).strip+'  defaut', 0.03, 0, 0, 3)

GGraph.next_fig('itr'=>itr, 'map_fit'=>true)
GGraph.tone( gpjpn)
DCL::sgtxzr(0.5, 0.15, DCL::sgtrnl(itr).strip+"  'map_fit'=>true", 0.03, 0, 0, 3)

itr = 10
GGraph.next_fig('itr'=>itr)
GGraph.tone( gpjpn, true, 'map_axes'=>true, 'title'=>'itr=10 & map_axes=true' )
GGraph.contour( gpjpn, false, 'map_axes'=>true, 'title'=>'itr=10 & map_axes=true' )

gpjpn2 = gp.cut(110..180,10..70,false)

itr = 10
GGraph.next_fig('itr'=>itr)
GGraph.contour( gpjpn2, true, 'map_axes'=>true, 'title'=>'itr=10 & map_axes=true' )

#itr = 10
#GGraph.next_fig('itr'=>itr)
#GGraph.vector( gpjpn, gpjpn, true, 'map'=>true, 'title'=>'itr=10 & map_axes=true', 'unit_vect'=>true )


DCL.grcls

