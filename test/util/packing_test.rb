# encoding: ASCII-8BIT
require 'test_helper'
require 'pwnlib/util/packing'

class PackingTest < MiniTest::Test
  include Pwnlib::Util::Packing

  def test_pack
    assert_equal('ABC', pack(0x414243, 24, 'big', true))
    assert_equal('CBA', pack(0x414243, 24, 'little', true))

    assert_equal("\x81BC", pack(0x814243, 24, 'big', false))
    err = assert_raises(ArgumentError) { pack(0x814243, 23, 'big', false) }
    assert_match(/does not fit/, err.message)

    assert_equal("\x00\x81BC", pack(0x814243, 25, 'big', true))
    err = assert_raises(ArgumentError) { pack(0x814243, 24, 'big', true) }
    assert_match(/does not fit/, err.message)

    assert_equal("\xff", pack(-1, 'all', 'little', true))
    assert_equal("\xff\x00", pack(-256, 'all', 'big', true))
    assert_equal("\xde\xad\xbe\xef", pack(0xdeadbeef, 'all', 'big', false))
    assert_equal("\x05\x04\x03\x02\x01", pack(0x0102030405, 'all', 'little', true))
    assert_equal("\x00\x00\x00\x80\x00", pack(0x80000000, 'all', 'little', true))

    err = assert_raises(ArgumentError) { pack('shik') }
    assert_match(/must be an integer/, err.message)

    assert_equal('ABC', pack(0x414243, bits: 24, endian: 'big'))

    err = assert_raises(ArgumentError) { pack(-514, bits: 'all', signed: 'unsigned') }
    assert_match(/Can't pack negative number/, err.message)
  end

  def test_unpack
    assert_equal(0x55aa, unpack("\xaa\x55", 16, 'little', false))
    assert_equal(0xaa55, unpack("\xaa\x55", 16, 'big', false))
    assert_equal(-0x55ab, unpack("\xaa\x55", 16, 'big', true))
    assert_equal(0x2a55, unpack("\xaa\x55", 15, 'big', true))
    assert_equal(0x0302ff, unpack("\xff\x02\x03", 'all', 'little', true))
    assert_equal(-0xfdfd, unpack("\xff\x02\x03", 'all', 'big', true))
    assert_equal(0x80000000, unpack("\x00\x00\x00\x80\x00", 'all', 'little', true))

    err = assert_raises(ArgumentError) { unpack("\xff\xff", 8, 'big', false) }
    assert_match(/does not match/, err.message)

    assert_equal(0x414243, unpack('ABC', bits: 'all', endian: 'big', signed: false))
  end

  def test_unpack_many
    assert_equal([0x55aa, 0x33cc], unpack_many("\xaa\x55\xcc\x33", 16, 'little', false))
    assert_equal([0xaa55, 0xcc33], unpack_many("\xaa\x55\xcc\x33", 16, 'big', false))
    assert_equal([-0x55ab, -0x33cd], unpack_many("\xaa\x55\xcc\x33", 16, 'big', true))
    assert_equal([0x0302ff], unpack_many("\xff\x02\x03", 'all', 'little', true))
    assert_equal([-0xfdfd], unpack_many("\xff\x02\x03", 'all', 'big', true))

    err = assert_raises(ArgumentError) { unpack_many('ABCD', 12) }
    assert_match(/bits must be a multiple of 8/, err.message)

    err = assert_raises(ArgumentError) { unpack_many('ABC', 16) }
    assert_match(/must be a multiple of bytes/, err.message)

    assert_equal([0x41, 0x42, 0x43, 0x44], unpack_many('ABCD', bits: 8))
    assert_equal([0x4142, 0x4344], unpack_many('ABCD', bits: 16, endian: 'big', signed: 'signed'))
    assert_equal([-2, -1], unpack_many("\xff\xfe\xff\xff", bits: 16, endian: 'big', signed: 'signed'))
  end
end
