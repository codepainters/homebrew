require 'formula'

class Libotr < Formula
  url 'http://www.cypherpunks.ca/otr/libotr-3.2.1.tar.gz'
  homepage 'http://www.cypherpunks.ca/otr/'
  md5 '974acf937d2ce0ee89b27a9815c17a3f'

  depends_on 'libgcrypt'

  def install
    ENV.universal_binary

    ENV.macosxsdk "10.8"
    ENV.remove_from_cflags(/ ?-mmacosx-version-min=10\.\d/)
    ENV['MACOSX_DEPLOYMENT_TARGET'] = "10.6"
    ENV.append_to_cflags("-mmacosx-version-min=10.6")

    ENV.append_to_cflags("-D_FORTIFY_SOURCE=2")
    ENV.append_to_cflags("-fstack-protector-all")
    
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make install"
  end
end
