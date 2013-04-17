require 'formula'

class Libotr < Formula
  url 'http://www.cypherpunks.ca/otr/libotr-4.0.0.tar.gz'
  homepage 'http://www.cypherpunks.ca/otr/'
  sha1 '8865e9011b8674290837afcf7caf90c492ae09cc'

  depends_on 'libgcrypt'

  def install
    ENV.universal_binary if build.universal?

    ENV.macosxsdk "10.8"
    ENV.remove_from_cflags(/ ?-mmacosx-version-min=10\.\d/)
    ENV['MACOSX_DEPLOYMENT_TARGET'] = "10.6"
    ENV.append_to_cflags("-mmacosx-version-min=10.6")

    ENV.append_to_cflags("-D_FORTIFY_SOURCE=2")
    ENV.append_to_cflags("-fstack-protector-all")
    
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking", "--mandir=#{man}"
    system "make install"
  end
end
