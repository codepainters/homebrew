require 'formula'

class Libotr < Formula
  homepage 'http://www.cypherpunks.ca/otr/'
  url 'http://www.cypherpunks.ca/otr/libotr-3.2.1.tar.gz'
  sha1 '898bf00d019f49ca34cd0116dd2e22685c67c394'

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
