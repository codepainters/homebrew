require 'formula'

class Libgcrypt < Formula
  homepage 'http://gnupg.org/'
  url 'ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.5.3.tar.bz2'
  sha1 '2c6553cc17f2a1616d512d6870fe95edf6b0e26e'

  depends_on 'libgpg-error'

  option :universal

  fails_with :clang do
    build 77
    cause "basic test fails"
  end

  def patches
    if ENV.compiler == :clang
      {:p0 =>
      "https://trac.macports.org/export/85232/trunk/dports/devel/libgcrypt/files/clang-asm.patch"}
    end
  end

  def cflags
    cflags = ENV.cflags.to_s
    cflags += ' -std=gnu89 -fheinous-gnu-extensions' if ENV.compiler == :clang
    cflags
  end

  def install
    ENV.universal_binary if build.universal?

    ENV.macosxsdk "10.8"
    ENV.remove_from_cflags(/ ?-mmacosx-version-min=10\.\d/)
    ENV['MACOSX_DEPLOYMENT_TARGET'] = "10.6"
    ENV.append_to_cflags("-mmacosx-version-min=10.6")

    ENV.append_to_cflags("-D_FORTIFY_SOURCE=2")
    ENV.append_to_cflags("-fstack-protector-all")
    ENV.append_to_cflags("-arch i386 -arch x86_64")

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-asm",
                          "--with-gpg-error-prefix=#{HOMEBREW_PREFIX}"

    if build.universal?
      system "curl 'https://trac.macports.org/export/56608/trunk/dports/devel/libgcrypt/files/config.h.ed' | ed - config.h"
    end

    # Parallel builds work, but only when run as separate steps
    if build.universal?
      system "curl 'https://trac.macports.org/export/56608/trunk/dports/devel/libgcrypt/files/config.h.ed' | ed - config.h"
    end

    system "make", "CFLAGS=#{cflags}"
    system "make check"
    system "make install"
  end

  test do
    (testpath/'test.c').write <<-EOS.undent
      #include <gcrypt.h>

      int main(void)
      {
          gcry_error_t err;

          if(!gcry_check_version(GCRYPT_VERSION)) {
            exit(2);
          }

          gcry_control (GCRYCTL_DISABLE_SECMEM, 0);

          gcry_control (GCRYCTL_INITIALIZATION_FINISHED, 0);

          gcry_sexp_t key, parms, privkey;
          static const char *parmstr = "(genkey (dsa (nbits 4:1024)))";

          err = gcry_sexp_new(&parms, parmstr, strlen(parmstr), 0);

          if (err) return err;

          err = gcry_pk_genkey(&key, parms);

          if (err) return err;

          gcry_sexp_release(parms);

          privkey = gcry_sexp_find_token(key, "private-key", 0);

          gcry_sexp_release(key);

          return 0;
      }
      EOS

    ENV.macosxsdk "10.8"
    ENV.remove_from_cflags(/ ?-mmacosx-version-min=10\.\d/)
    ENV['MACOSX_DEPLOYMENT_TARGET'] = "10.6"
    ENV.append_to_cflags("-mmacosx-version-min=10.6")

    flags = *`#{bin}/libgcrypt-config --cflags --libs`.split
    flags += ENV.cflags.split
    flags.delete("-arch=x86")
    flags.delete("-march=native")
    flags << "-arch x86_64"
    system ENV.cc, "-o", "test", "test.c", *flags
    system "./test"

    flags.delete("-arch x86_64")
    flags << "-arch i386"
    flags << "-m32"
    system ENV.cc, "-o", "test", "test.c", *flags

    system "arch", "-i386", "./test"
  end
end
