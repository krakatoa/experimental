#require "cinruby/version"

require 'ffi'

class Msg < FFI::Struct
  layout  :version, :int,
          :kind, :int
end

module Cinruby
  # Your code goes here...
  extend FFI::Library
  
  #ffi_lib 'c'
  ffi_lib ['pmodparser', File.join(File.dirname(__FILE__), 'pmodparser.so')]
  
  attach_function :testing, [], Msg.by_value
  attach_function :devuelve_inc, [:int], :int
  # attach_function :static_estatica, [], :int
end

