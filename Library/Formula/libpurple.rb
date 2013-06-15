require 'formula'

class Libpurple < Formula
  head 'http://hg.adium.im/libpurple/', :using => :hg, :revision => 'c8e809dffa1d'
  url 'http://hg.adium.im/libpurple/archive/c8e809dffa1d.tar.gz'
  sha1 '7d9e8fed659d648faf9c51aeec088809a3b66822'
  homepage 'http://pidgin.im/'
  version '2.10.7rc8e809dffa1d'

  option :universal

  depends_on 'pkg-config' => :build
  depends_on 'libtool' => :build
  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'gettext'
  depends_on 'glib'
  depends_on 'intltool'
  depends_on 'meanwhile'


  def options
    [["--debug", "Build with debugging symbols."]]
  end

  def install
    ENV.universal_binary if build.universal?

    ENV.append_to_cflags(" -DHAVE_SSL -DHAVE_OPENSSL -fno-common -DHAVE_ZLIB")
    ENV.append_to_cflags(" -g") if ARGV.include? '--debug'
    ENV['LDFLAGS'] += " -lsasl2 -lz"

    ENV.macosxsdk "10.8"
    ENV.remove_from_cflags(/ ?-mmacosx-version-min=10\.\d/)
    ENV['MACOSX_DEPLOYMENT_TARGET'] = "10.6"
    ENV.append_to_cflags("-mmacosx-version-min=10.6")

    ENV.append_to_cflags("-D_FORTIFY_SOURCE=2")
    ENV.append_to_cflags("-fstack-protector-all")

    ohai "CFLAGS: #{ENV['CFLAGS']}"

    args = %W[
        --disable-dependency-tracking
        --disable-gtkui
        --disable-consoleui
        --disable-perl
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

    if ARGV.include? '--debug' then
      ohai "Debug symbols are on"
      args << "--enable-debug"
    else
      ohai "Debug symbols are off"
      args << "--disable-debug"
    end

    system "./autogen.sh", *args
    
    ohai "Updating po files"

    Dir.chdir "po"

    system "make update-po"

    Dir.chdir ".."

    system "make install"

    ohai "Adding libpurple internal headers"

    internals = ["libpurple/protocols/oscar/oscar.h",
      "libpurple/protocols/oscar/snactypes.h",
      "libpurple/protocols/oscar/peer.h",
      "libpurple/cmds.h",
      "libpurple/internal.h",
      "libpurple/protocols/msn/*.h",
      "libpurple/protocols/yahoo/*.h",
      "libpurple/protocols/gg/buddylist.h",
      "libpurple/protocols/gg/gg.h",
      "libpurple/protocols/gg/search.h",
      "libpurple/protocols/jabber/auth.h",
      "libpurple/protocols/jabber/bosh.h",
      "libpurple/protocols/jabber/buddy.h",
      "libpurple/protocols/jabber/caps.h",
      "libpurple/protocols/jabber/chat.h",
      "libpurple/protocols/jabber/jutil.h",
      "libpurple/protocols/jabber/presence.h",
      "libpurple/protocols/jabber/si.h",
      "libpurple/protocols/jabber/jabber.h",
      "libpurple/protocols/jabber/iq.h",
      "libpurple/protocols/jabber/namespaces.h",
      "libpurple/protocols/irc/irc.h",
      "libpurple/protocols/gg/lib/libgadu.h"]

    internals.each {|internal|
      (include/"libpurple").install Dir[internal]
    }
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
