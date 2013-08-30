# A ftp-like client of GPhys directory services
#
# Usage
#  % irb --noinspect -r numru/gphys_connect_ftp-like
# You will be prompted to type URI, which will be determined by the server.

require "drb/drb"
require "numru/gdir"
require "numru/ggraph"
include NumRu
include GGraph   # so you can use methods like "contour" without any prefix

def help
msg = <<EOS
=begin
= irb start-up program numru/gdir_connect_ftp-like

A ftp-like client of GPhys directory services (e.g., gdir_server.rb).
Connection is based on dRuby.

== Usage
    At command line,
     % irb --noinspect -r numru/gphys_connect_ftp-like
    then type in the URI of the server.

== Available Methods
    Native methods:
      help  help_more  ls  dir  pwd  cd(path)  open(name)  readtext(name)
      start_dcl(iws=1, iwidth=500, iheight=500, uzfact=1.0)

    All GGraph methods:
      contour(gphys)  line(gphys)  etc.etc.

=end
Type in
  help_more
For more info.
EOS
print msg.sub(/^=begin$/,'').sub(/^=end$/,'')
end

def help_more
msg = <<EOS
=begin
== Methods
---help
    Show a help message
---help_more
    Show a further help message
---ls
    List the directory.
---dir
---ls_l
    Like ls but with a long descriptive format
---pwd
    Prints the path of the current directory.
---open(name)
    opens a GPhys, where name is a variable name in the current directory
    (shown by ls without trailing "/").
---readtext(name)
    prints the contents of the text file in the current directory
    (shown by ls with remarks as such).
---start_dcl(iws=1, iwidth=500, iheight=500, uzfact=1.0)
    To start RubyDCL (Calls DCL.gropn(iws)).
    Call this before using GGraph module functions such as contour.
---contour
---line
      GGraph methods
=end
EOS
print msg.sub(/^=begin$/,'').sub(/^=end$/,'')
end

def pwd
  print $cwd.path,"\n"
end
def cd(path)
  $cwd = $cwd.dir(path)
  pwd
end
def ls(path=nil)
  print $cwd.list_all(path)
end
def dir(path=nil)
  print $cwd.list_all_v(path)
end
alias ls_l dir
def open(name)
  $cwd.data(name)
end
def readtext(name)
  print $cwd.text(name).readlines
end

def start_dcl(iws=1, iwidth=500, iheight=500, uzfact=1.0)
  DCL.swpset('iwidth',iwidth)
  DCL.swpset('iheight',iheight)
  DCL.swpset('lwait',false)
  DCL.gropn(iws)
  #DCL.sgpset('lcntl', false)
  DCL.sgpset('isub', 96)    # control character of subscription: '_' --> '`'
  DCL.glpset('lmiss',true)
  DCL.uzfact(uzfact)
end

class NArray
  def self._load(o); to_na(*Marshal::load(o)).ntoh; end
  def _dump(limit); Marshal::dump([hton.to_s, typecode, *shape]); end
end

# < start the client >

DRb.start_service  && nil
print "** A GPhys service client. To conetct, type in server's URI(return)\n",
      "   (format: druby://host:port). Type in help to see usage.\n","URI>> "
uri = gets.strip
if /^help/ =~ uri
  help
  print "\nMore info? (y or else)>> "; ans=gets
  help_more if /^y/ =~ ans
  print "\nNeed a connection first. Input the uri of the server:\nURI>> "
  uri = gets.chomp
end
rootdir = DRbObject.new(nil, uri)
$cwd = rootdir

# < greeting >

print <<EOS
***************************************************************
*                          WELCOME!
*
*  You logged in #{uri} 
*  with #{__FILE__}: 
*  an irb-based ftp-like client of a gphys service (such as gdir_server.rb).
*
*  This client is to be started as
*
*    % irb --noinspect -r "numru/gphys_connect_ftp-like"
*
*  if you are running on a interactive ruby shell such as irb,
*  quit and start again like this.
***************************************************************

Type in
  help
for available methods 

EOS
