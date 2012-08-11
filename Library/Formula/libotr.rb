require 'formula'

class Libotr < Formula
  url 'http://www.cypherpunks.ca/otr/libotr-3.2.0.tar.gz'
  homepage 'http://www.cypherpunks.ca/otr/'
  md5 'faba02e60f64e492838929be2272f839'

  depends_on 'libgcrypt'

  def install
    ENV.universal_binary if build.universal?

    ENV.macosxsdk "10.8"
    ENV.remove_from_cflags(/ ?-mmacosx-version-min=10\.\d/)
    ENV['MACOSX_DEPLOYMENT_TARGET'] = "10.6"
    ENV.append_to_cflags("-mmacosx-version-min=10.6")
    
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking", "--mandir=#{man}"
    system "make install"
  end
end
