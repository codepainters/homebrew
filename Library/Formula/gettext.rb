require 'formula'

class Gettext < Formula
  homepage 'http://www.gnu.org/software/gettext/'
  url 'http://ftpmirror.gnu.org/gettext/gettext-0.18.3.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/gettext/gettext-0.18.3.tar.gz'
  sha256 '36f3c1043df803565d4977c1efbd41e1ec0f0301acf5f057984406c34cb9f948'

  bottle do
    revision 1
    sha1 '392d49de19c44238cb3d25cc43ab5884c3558fe8' => :mountain_lion
    sha1 '71b16d1305a221ea5ea15e1bb8d2819e4b62a045' => :lion
    sha1 'bdfe4889e7da5e25f4cf7c42a4d591794afc4e43' => :snow_leopard
  end

  keg_only "OS X provides the BSD gettext library and some software gets confused if both are in the library path."

  option :universal
  option 'with-examples', 'Keep example files'

  def patches
    # Patch to allow building with Xcode 4; safe for any compiler.
    p = {:p0 => ['https://trac.macports.org/export/79617/trunk/dports/devel/gettext/files/stpncpy.patch',
                 HOMEBREW_PREFIX/"../patches/gettext-Makefile.in.diff",
                 'https://trac.macports.org/export/102008/trunk/dports/devel/gettext/files/patch-gettext-tools-Makefile.in']}
  end

  def install
    ENV.libxml2
    ENV.universal_binary if build.universal?

    ENV.macosxsdk "10.8"
    ENV.remove_from_cflags(/ ?-mmacosx-version-min=10\.\d/)
    ENV['MACOSX_DEPLOYMENT_TARGET'] = "10.6"
    ENV.append_to_cflags("-mmacosx-version-min=10.6")

    ENV.append_to_cflags("-D_FORTIFY_SOURCE=2")
    ENV.append_to_cflags("-fstack-protector-all")

    system "./configure", "--disable-dependency-tracking",
                          "--disable-debug",
                          "--prefix=#{prefix}",
                          "--without-included-gettext",
                          "--without-included-glib",
                          "--without-included-libcroco",
                          "--without-included-libxml",
                          "--without-emacs",
                          "--disable-java",
                          # Don't use VCS systems to create these archives
                          "--without-git",
                          "--without-cvs"
    system "make"
    ENV.deparallelize # install doesn't support multiple make jobs
    system "make install"
  end
end
