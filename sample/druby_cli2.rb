# druby_cli2.rb -- a sample dRuby client
#
# USAGE
#   See ./druby_serv2.rb

require "drb/drb"
require "numru/ggraph"
include NumRu

DRb.start_service
uri = ARGV.shift || raise("Usage: % #{$0} uri")
gp = DRbObject.new(nil, uri)

p gp.class, gp.name, gp.rank, gp.length
p gp.grid.axis(0).pos.name

gpmean = gp.mean(0)
p gpmean.class, gpmean.name, gpmean.rank

p ( gpmean_copy = gpmean.copy )
DCL.gropn(1)
DCL.sgpset('lfull',true)
DCL.sgpset('lcntl',false)
DCL.uzfact(0.7)
GGraph.set_fig('viewport'=>[0.25,0.7,0.15,0.6], 'itr'=>2 )
GGraph.contour( gpmean_copy )
DCL.grcls

