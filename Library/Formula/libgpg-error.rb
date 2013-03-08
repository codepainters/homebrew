require 'formula'

class LibgpgError < Formula
  homepage 'http://www.gnupg.org/'
  url 'ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.11.tar.bz2'
  sha1 'be209b013652add5c7e2c473ea114f58203cc6cd'

  option :universal

  def install
    ENV.universal_binary if build.universal?

    ENV.macosxsdk "10.8"
    ENV.remove_from_cflags(/ ?-mmacosx-version-min=10\.\d/)
    ENV['MACOSX_DEPLOYMENT_TARGET'] = "10.6"
    ENV.append_to_cflags("-mmacosx-version-min=10.6")

    ENV.append_to_cflags("-D_FORTIFY_SOURCE=2")
    ENV.append_to_cflags("-fstack-protector-all")

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
