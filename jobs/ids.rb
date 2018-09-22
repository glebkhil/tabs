require_relative 'requires'
require 'hashids'
puts "ENCODED: #{enc = Tsc.create_tscx_code(20)}"
puts "DECODED:"
puts "#{Tsc.verify_tscx_code(enc)}"