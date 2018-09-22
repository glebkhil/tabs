require_relative 'requires'
require 'hashids'
hashids = Hashids.new(TOKEN_SALT, 40, TOKEN_ALPHABET)
hash = hashids.encode(2, 389283749234, 111)
puts hash


