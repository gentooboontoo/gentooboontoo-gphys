## from [dennou-ruby:002687] by koshiro
## simultaneous map-fitting and axes-drawing when itr=10

require 'numru/ggraph'
include NumRu

wsn = ( ARGV[0] ? ARGV[0].to_i : 1 )

path = '../testdata/T.jan.nc'
var = 'T'
gp = GPhys::IO.open(path,var)

DCL.swpset('ldump',true) if wsn == 4
DCL.gropn(wsn)
DCL.sldiv('t',3,2)
DCL.uzfact(0.8)
DCL.sgpset('lcntl',false)

GGraph.set_map('coast_world'=>true)

gpjpn = gp.cut(110..160,10..70,false)

itr = 10

# contour
GGraph.next_fig('itr'=>itr)
GGraph.contour(gp,true,'title'=>'map_fit=T, map_axes=F (default)')

GGraph.next_fig('itr'=>itr)
GGraph.contour(gp, true,'map_axes'=>true,'title'=>'map_fit=T map_axes=T')

GGraph.next_fig('itr'=>itr,'map_fit'=>false)
GGraph.contour(gp,true,'map_axes'=>false,'title'=>'map_fit=F map_axes=F' )

GGraph.next_fig('itr'=>itr,'map_fit'=>false)
GGraph.contour(gp,true,'map_axes'=>true,'title'=>'map_fit=F map_axes=T')

GGraph.next_fig('itr'=>itr,'map_fit'=>false,'map_axis'=>[0,0,0],'map_window'=>[-120,120,-60,60])
GGraph.contour(gp,true,'map_axes'=>false,'title'=>'map_fit=F map_axes=F map_axis & map_window' )

GGraph.next_fig('itr'=>itr,'map_fit'=>false,'map_axis'=>[0,0,0],'map_window'=>[-120,120,-60,60])
GGraph.contour(gp,true,'map_axes'=>true,'title'=>'map_fit=F map_axes=T map_axis & map_window')


# tone
GGraph.next_fig('itr'=>itr)
GGraph.tone(gp,true,'title'=>'map_fit=T, map_axes=F (default)')

GGraph.next_fig('itr'=>itr)
GGraph.tone(gp, true,'map_axes'=>true,'title'=>'map_fit=T map_axes=T')

GGraph.next_fig('itr'=>itr,'map_fit'=>false)
GGraph.tone(gp,true,'map_axes'=>false,'title'=>'map_fit=F map_axes=F' )

GGraph.next_fig('itr'=>itr,'map_fit'=>false)
GGraph.tone(gp,true,'map_axes'=>true,'title'=>'map_fit=F map_axes=T')

GGraph.next_fig('itr'=>itr,'map_fit'=>false,'map_axis'=>[0,0,0],'map_window'=>[-120,120,-60,60])
GGraph.tone(gp,true,'map_axes'=>false,'title'=>'map_fit=F map_axes=F map_axis & map_window' )

GGraph.next_fig('itr'=>itr,'map_fit'=>false,'map_axis'=>[0,0,0],'map_window'=>[-120,120,-60,60])
GGraph.tone(gp,true,'map_axes'=>true,'title'=>'map_fit=F map_axes=T map_axis & map_window')


# tone & contour
GGraph.next_fig('itr'=>itr)
GGraph.tone(gpjpn,true,'title'=>'map_fit=T, map_axes=F (default)')
GGraph.contour( gpjpn, false )

GGraph.next_fig('itr'=>itr)
GGraph.tone(gpjpn, true,'map_axes'=>true,'title'=>'map_fit=T map_axes=T')
GGraph.contour( gpjpn, false )

GGraph.next_fig('itr'=>itr,'map_fit'=>false)
GGraph.tone(gpjpn,true,'map_axes'=>false,'title'=>'map_fit=F map_axes=F' )
GGraph.contour( gpjpn, false )

GGraph.next_fig('itr'=>itr,'map_fit'=>false)
GGraph.tone(gpjpn,true,'map_axes'=>true,'title'=>'map_fit=F map_axes=T')
GGraph.contour( gpjpn, false )

GGraph.next_fig('itr'=>itr,'map_fit'=>false,'map_axis'=>[0,0,0],'map_window'=>[90,180,0,90])
GGraph.tone(gpjpn,true,'map_axes'=>false,'title'=>'map_fit=F map_axes=F map_axis & map_window' )
GGraph.contour( gpjpn, false )

GGraph.next_fig('itr'=>itr,'map_fit'=>false,'map_axis'=>[0,0,0],'map_window'=>[90,180,0,90])
GGraph.tone(gpjpn,true,'map_axes'=>true,'title'=>'map_fit=F map_axes=T map_axis & map_window')
GGraph.contour( gpjpn, false )


# vector ('flow_vect'=>false)
GGraph.next_fig('itr'=>itr)
GGraph.vector(gpjpn,gpjpn,true,'title'=>'map_fit=T, map_axes=F (default)','flow_vect'=>false,'unit_vect'=>true)

GGraph.next_fig('itr'=>itr)
GGraph.vector(gpjpn,gpjpn, true,'map_axes'=>true,'title'=>'map_fit=T map_axes=T','flow_vect'=>false,'unit_vect'=>true)

GGraph.next_fig('itr'=>itr,'map_fit'=>false)
GGraph.vector(gpjpn,gpjpn,true,'map_axes'=>false,'title'=>'map_fit=F map_axes=F' ,'flow_vect'=>false,'unit_vect'=>true)

GGraph.next_fig('itr'=>itr,'map_fit'=>false)
GGraph.vector(gpjpn,gpjpn,true,'map_axes'=>true,'title'=>'map_fit=F map_axes=T','unit_vect'=>true,'flow_vect'=>false,'unit_vect'=>true)

GGraph.next_fig('itr'=>itr,'map_fit'=>false,'map_axis'=>[0,0,0],'map_window'=>[90,180,0,90])
GGraph.vector(gpjpn,gpjpn,true,'map_axes'=>false,'title'=>'map_fit=F map_axes=F map_axis & map_window','flow_vect'=>false,'unit_vect'=>true)

GGraph.next_fig('itr'=>itr,'map_fit'=>false,'map_axis'=>[0,0,0],'map_window'=>[90,180,0,90])
GGraph.vector(gpjpn,gpjpn,true,'map_axes'=>true,'title'=>'map_fit=F map_axes=T map_axis & map_window','flow_vect'=>false,'unit_vect'=>true)


# vector ('flow_vect'=>true)
GGraph.next_fig('itr'=>itr)
GGraph.vector(gpjpn,gpjpn,true,'title'=>'map_fit=T, map_axes=F (default)','unit_vect'=>true)

GGraph.next_fig('itr'=>itr)
GGraph.vector(gpjpn,gpjpn, true,'map_axes'=>true,'title'=>'map_fit=T map_axes=T','unit_vect'=>true)

GGraph.next_fig('itr'=>itr,'map_fit'=>false)
GGraph.vector(gpjpn,gpjpn,true,'map_axes'=>false,'title'=>'map_fit=F map_axes=F','unit_vect'=>true)

GGraph.next_fig('itr'=>itr,'map_fit'=>false)
GGraph.vector(gpjpn,gpjpn,true,'map_axes'=>true,'title'=>'map_fit=F map_axes=T','unit_vect'=>true,'unit_vect'=>true)

GGraph.next_fig('itr'=>itr,'map_fit'=>false,'map_axis'=>[0,0,0],'map_window'=>[90,180,0,90])
GGraph.vector(gpjpn,gpjpn,true,'map_axes'=>false,'title'=>'map_fit=F map_axes=F map_axis & map_window','unit_vect'=>true)

GGraph.next_fig('itr'=>itr,'map_fit'=>false,'map_axis'=>[0,0,0],'map_window'=>[90,180,0,90])
GGraph.vector(gpjpn,gpjpn,true,'map_axes'=>true,'title'=>'map_fit=F map_axes=T map_axis & map_window','unit_vect'=>true)


DCL.grcls
