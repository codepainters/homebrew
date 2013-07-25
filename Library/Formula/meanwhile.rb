require 'formula'

class Meanwhile < Formula
  homepage ''
  url 'http://downloads.sourceforge.net/project/meanwhile/meanwhile/1.0.2/meanwhile-1.0.2.tar.gz'
  sha1 'e0e9836581da3c4a569135cb238eaa566c324540'

  option :universal

  depends_on 'pkg-config' => :build
  depends_on 'glib'

  def patches
    mp = HOMEBREW_PREFIX/"../patches/"
    {
      :p0 => [
        mp+"Meanwhile-srvc_ft.c.diff",
        mp+"Meanwhile-common.c.diff",
        mp+"Meanwhile-st_list.c.diff",
        mp+"Meanwhile-ltmain.sh.diff",
        mp+"Meanwhile-srvc_place.c.diff",
        mp+"Meanwhile-session.c.diff"
      ],
      :p1 => [
        mp+"Meanwhile-glib_headers.diff"
      ]
    }
  end

  def install
    ENV.universal_binary if build.universal?
    ENV.j1

    ENV.macosxsdk "10.8"
    ENV.remove_from_cflags(/ ?-mmacosx-version-min=10\.\d/)
    ENV['MACOSX_DEPLOYMENT_TARGET'] = "10.6"
    ENV.append_to_cflags("-mmacosx-version-min=10.6")

    ENV.append_to_cflags("-D_FORTIFY_SOURCE=2")
    ENV.append_to_cflags("-fstack-protector-all")

    ENV['CC'] = 'gcc'

    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--disable-doxygen",
                          "-disable-mailme", "--disable-static"
    system "make install"
  end

  def test
    system "false"
  end
end
