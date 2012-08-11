require 'formula'

class Libpurple < Formula
  head 'http://hg.adium.im/libpurple/', :using => :hg
  homepage 'http://pidgin.im/'

  option :universal

  depends_on 'pkg-config' => :build
  depends_on 'libtool' => :build
  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'gettext'
  depends_on 'glib'
  depends_on 'intltool'
  depends_on 'meanwhile'

  def install
    ENV.universal_binary if build.universal?

    ENV.append_to_cflags(" -DHAVE_SSL -DHAVE_OPENSSL -fno-common -DHAVE_ZLIB")
    ENV['LDFLAGS'] += " -lsasl2 -lz"

    ENV.macosxsdk "10.8"
    ENV.remove_from_cflags(/ ?-mmacosx-version-min=10\.\d/)
    ENV['MACOSX_DEPLOYMENT_TARGET'] = "10.6"
    ENV.append_to_cflags("-mmacosx-version-min=10.6")

    args = %W[
        --disable-dependency-tracking
        --disable-gtkui
        --disable-consoleui
        --disable-perl
        --enable-debug
        --disable-static
        --enable-shared
        --enable-cyrus-sasl
        --with-static-prpls=gg,irc,jabber,msn,myspace,novell,oscar,sametime,simple,yahoo,zephyr
        --disable-plugins
        --disable-avahi
        --disable-dbus
        --enable-gnutls=no
        --enable-nss=no
        --enable-vv=no
        --disable-gstreamer
        --disable-idn
        --disable-debug
        --prefix=#{prefix}
    ]

    system "./autogen.sh", *args

    system "make install"
  end
end
