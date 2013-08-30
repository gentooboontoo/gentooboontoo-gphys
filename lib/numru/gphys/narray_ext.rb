require "narray"

class NArray

  @@dump_size_limit = -1  # max len to allow dump / no limit if negative
  def self.dump_size_limit=(lmt)
    @@dump_size_limit = lmt
  end
  def self.dump_size_limit
    @@dump_size_limit
  end

  def self.endian
    NArray[1].to_s[1] == 1 ? :little : :big
  end

  def _dump(limit)
    if (@@dump_size_limit <= 0) || (size <= @@dump_size_limit)
      Marshal.dump([typecode, shape, NArray.endian, to_s])
    else
      raise "size of the NArray (#{size}) is too large to dump "+
            "(limit: #{DUMP_SIZE_LIMIT})"
    end
  end

  def self._load(str)
    ary = Marshal.load(str)
    typecode, shape, endian, str = ary
    na = NArray.to_na(str, typecode, *shape)
    na = na.swap_byte unless endian == NArray.endian
    return na
  end

end
