require 'formula'

class Gettext < Formula
  homepage 'http://www.gnu.org/software/gettext/'
  url 'http://ftpmirror.gnu.org/gettext/gettext-0.18.1.1.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/gettext/gettext-0.18.1.1.tar.gz'
  sha1 '5009deb02f67fc3c59c8ce6b82408d1d35d4e38f'

  keg_only "OS X provides the BSD gettext library and some software gets confused if both are in the library path."

  bottle do
    sha1 'd1ad5ad15bfe8fe813ee37e5d6b514fc79924b9a' => :mountainlion
    sha1 'c75fdb192f1b49c9e7e2039c66e24f60f26bc027' => :lion
    sha1 'b8958544542fc160b4c74db5d83cb441d12741c7' => :snowleopard
  end

  option :universal
  option 'with-examples', 'Keep example files'

  def patches
    # Patch to allow building with Xcode 4; safe for any compiler.
    p = {:p0 => ['https://trac.macports.org/export/79617/trunk/dports/devel/gettext/files/stpncpy.patch',
                 HOMEBREW_PREFIX/"../patches/gettext-Makefile.in.diff"]}

    return p
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

    system "./configure", "--disable-dependency-tracking", "--disable-debug",
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
