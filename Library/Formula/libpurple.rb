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

    ohai "Updating po files"

    Dir.chdir "po"

    system "make update-po"
    system "make all"
    system "make install"
  end

  def test
    unless Formula.factory("pkg-config").installed?
      puts "pkg-config is required to run this test, but is not installed"
      exit 1
    end

    mktemp do
      (Pathname.pwd/'test.c').write <<-EOS.undent
        #include <string.h>
        #include <libpurple/eventloop.h>

        guint add_timeout(guint interval, GSourceFunc function, gpointer data)
        {
          return 0;
        }

        guint input_add(gint fd, PurpleInputCondition condition, PurpleInputFunction func, gpointer user_data)
        {
          return 0;
        }


        static PurpleEventLoopUiOps eventLoopUiOps = {
            add_timeout,
            NULL,
            input_add,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL
        };

        int main(void)
        {
            purple_eventloop_set_ui_ops(&eventLoopUiOps);
            return purple_core_init("test") ? 0 : 1;
        }
        EOS

      ENV.macosxsdk "10.8"
      ENV.remove_from_cflags(/ ?-mmacosx-version-min=10\.\d/)
      ENV['MACOSX_DEPLOYMENT_TARGET'] = "10.6"
      ENV.append_to_cflags("-mmacosx-version-min=10.6")

      flags = *`pkg-config --cflags --libs purple`.split
      flags += ENV.cflags.split
      flags.delete("-arch=x86")
      flags << "-arch x86_64"
      system ENV.cc, "-o", "test", "test.c", *flags
      system "./test"

      flags.delete("-arch=x86")
      flags << "-arch i386"
      system ENV.cc, "-o", "test", "test.c", *flags

      system "./test"
    end
  end
end
