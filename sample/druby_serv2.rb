=begin
=druby_serv2.rb

a sample dRuby server. The difference from druby_serv1.rb is that
a couple of methods are added to NArray, which enables us to serialize
NArray with Marshal.dump. Therefore, a GPhys object can be transferred by 
value (not by reference) if all the VArray in it is based on NArray.
This can be done with the copy method of GPhys. See druby_cli2.rb
for an example.

==USAGE

To start the server:

     % ruby druby_serv2.rb [port]

This will print the address of the server such as
druby://[hostname]:[port] (For exaple druby://horihost:39391

Then run the client as (if the address is druby://horihost:39391):

     % ruby druby_cli2.rb druby://horihost:39391
=end

require "drb/drb"
require "numru/gphys"
include NumRu

def usage
  print <<-EOS

  USAGE:
    % ruby #{$0} [port]

    Here, port (optional) is the port number to assign.
  EOS
  raise RuntimeError
end

port = ARGV.shift
usage if port && port.to_i.to_s != port
usage if ARGV.length > 0

file = NetCDF.open("../testdata/T.jan.nc")
gp = GPhys::NetCDF_IO.open(file,"T")

uri_seed = ( port ? 'druby://:'+port : nil )   # 'druby://:'+port, or nil
DRb.start_service(uri_seed, gp)
puts 'URI: '+DRb.uri
puts '[return] to exit'
gets
