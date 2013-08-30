=begin
=class NumRu::GDir::HtDir
A class to treat the URL of a "directory" as a directory, with a special
interpretation for DODS if requested (not by default. You must turn it on
explicitly by GDir::HtDir.dods_interpret=true).

==Class Methods
---GDir::HtDir.new(url, proxy=nil)
   ARGUMENTS
   url (String) url of a "directory"
   proxy (String) proxy address and port such as 'proxy.org:8080'
---GDir::HtDir.proxy=(proxy)
---GDir::HtDir.dods_interpret=(t_or_f)

==Instance Methods
---each
    Iterator for each "file" in the directory. Arguments
    of the block will be String (as in Dir#each)
---collect
---each_dir
    Like ((<each>)) but limited to iterate over subdirectories.
---each_file
    Like ((<each>)) but limited to iterate over files.
---close
    close the http connection.
---rewind
    Dummy for compatibilty with Dir.
---body
    Body of the http response.
=end

require 'net/http'
Net::HTTP.version_1_2

module NumRu
  class GDir
    class HtDir

      Regexp_URL = /^(http:\/\/)?([\w\-\.]+)(:(\d+))?(\/[\w\-\.\/_~]*)?/
      Regexp_File = /<img.*alt=\"\[(.*)\]\".*href=\"([^\"]+)\"[^>]*>([^<]*)/i
      File_Type = {'DIR'=>'directory','TXT'=>'text'}

      @@proxy_host = @@proxy_port = nil
      @@dods_interpret = false

      class << self

	def dods_interpret; @@dods_interpret; end
	def dods_interpret=(t_or_f)
	  @@dods_interpret=t_or_f
	end

	def proxy_port; @@proxy_port; end
	def proxy_host; @@proxy_host; end
	def proxy=(proxy)
	  if Regexp_URL =~ proxy
	    @@proxy_host = $2
	    @@proxy_port = ( $4 ? $4.to_i : 8080 )
	  else
	    raise "Invalid Proxy URL: "+proxy
	  end
	end
      end

      def initialize(url, proxy=nil)
	url += '/' if /\/$/ !~ url    # treat URLs that always end with '/'
        @url = url
	if Regexp_URL =~ @url
	  @host = $2
	  @port = ( $4 ? $4.to_i : 80 )
	  @path = $5
	else
	  raise "Invalid URL: "+url
	end
	if proxy
	  if Regexp_URL =~ proxy
	    @proxy_host = $2
	    @proxy_port = ( $4 ? $4.to_i : 8080 )
	  else
	    raise "Invalid Proxy URL: "+proxy
	  end
	else
	  @proxy_host = @@proxy_host
	  @proxy_port = @@proxy_port
	end
	@http = Net::HTTP.new(@host, @port, @proxy_host, @proxy_port)
	res = @http.get(@path)
	@body = res.body
	@files = Array.new
	@body.each do |line|
	  if Regexp_File =~ line
	    fltyp = File_Type[$1]
	    url = $2
	    label = $3
	    if @@dods_interpret
	      if /Parent Directory/ =~ label
		url = '..'
	      else
		url = File.basename( url.sub(/http:\//,'') )
	      end
	      if ( fltyp != 'text' and /\.(\w+)\.html$/ =~ url and
		   /#{$1}$/ =~ label )
		# It must be a dods file url with a '.html' suffix
		url.sub!(/\.html$/,'')
	      end
	    end
	    @files.push( {:file_type=>fltyp, :url=>url} )
	  end
	end
      end

      def body
	@body
      end

      def each
	@files.each do |fl|
	  yield(fl[:url])
	end
      end

      def collect
	ary = Array.new
	@files.each do |fl|
	  ary.push( yield(fl[:url]) )
	end
	ary
      end

      def each_dir
	@files.each do |fl|
	  yield(fl[:url]) if fl[:file_type] == 'directory'
	end
      end

      def each_file
	@files.each do |fl|
	  yield(fl[:url]) if fl[:file_type] != 'directory'
	end
      end

      def close
	@http.finish if @http.active?
      end

      def rewind
	# do nothing
      end

    end  # HtDir
  end  # GDir
end  # NumRu

if $0 == __FILE__
  include NumRu
  ## GDir::HtDir.proxy='proxy.kuins.net:8080'
  GDir::HtDir.dods_interpret = true

  htdir = GDir::HtDir.new('http://davis-dods.rish.kyoto-u.ac.jp/cgi-bin/nph-dods/jmadata/gpv/latest/gpv/latest/')
  print htdir.body
  htdir.each{|sub| p sub}
  htdir = GDir::HtDir.new('http://davis-dods.rish.kyoto-u.ac.jp/cgi-bin/nph-dods/jmadata/gpv/latest/gpv/')
  print htdir.body
  p htdir.collect{|x| x}
  htdir.each{|sub| p sub}
  htdir = GDir::HtDir.new('http://www.gfd-dennou.org/arch/')
  print htdir.body
  htdir.each_dir{|sub| p sub}
  htdir.each_file{|sub| p sub}
end
