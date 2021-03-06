# encoding: ASCII-8BIT
# frozen_string_literal: true

require 'pwnlib/ext/helper'
require 'pwnlib/util/fiddling'
require 'pwnlib/util/packing'

module Pwnlib
  module Ext
    module String
      # Methods to be mixed into String.
      module InstanceMethods
        extend ::Pwnlib::Ext::Helper

        def_proxy_method ::Pwnlib::Util::Packing, %w(unpack unpack_many u8 u16 u32 u64)
        def_proxy_method ::Pwnlib::Util::Fiddling, %w(
          enhex unhex urlencode urldecode bits bits_str unbits bitswap b64e b64d xor
        )
      end
    end
  end
end

::String.include ::Pwnlib::Ext::String::InstanceMethods
