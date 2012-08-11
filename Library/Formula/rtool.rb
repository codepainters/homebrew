require 'formula'

class Rtool < Formula
  homepage ''
  url 'http://hg.adium.im/adium/raw-file/c346a138fd5a/Dependencies/rtool/rtool'
  sha1 'f60e03c987a6034c46e448ff4d0c717008a64328'
  version '1.2.5'

  def install
    system "chmod +x rtool"
    bin.install "rtool"
  end

  def test
    system "rtool"
  end
end
