#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby -W0
# -*- coding: utf-8 -*-

require 'extend/pathname'
require 'formula_installer'

f = Formula.factory("rtool")

if not f.installed? then
	ohai "Installing rtool first"
	installer = FormulaInstaller.new(f)
	installer.install
end

frameworks = HOMEBREW_PREFIX+"Frameworks"

frameworks.mkpath

libraries = { "libpurple" => ["libpurple.0.dylib"],
	          "glib" => ["libglib-2.0.0.dylib", "libgmodule-2.0.0.dylib", "libgobject-2.0.0.dylib", "libgthread-2.0.0.dylib"],
	          "meanwhile" => ["libmeanwhile.1.0.2.dylib"],
	          "gettext" => ["libintl.8.dylib"]
			}

libraries.each { | name, libs |
	f = Formula.factory(name)

	if not f.installed? then
		ohai "Installing #{name} first"
		installer = FormulaInstaller.new(f)
		installer.install
	end
}

libs_to_convert = []
framework_paths = []

libraries.each { | name, libs |
	f = Formula.factory(name)

	libs.each { | lib |
		libname = lib.gsub(/dylib$/, '').gsub(/[^A-Za-z]/, '')
		cellar_path = (f.lib + lib).realpath
		prefix_path = HOMEBREW_PREFIX+"lib"+lib
		executable_path = "@executable_path/../Frameworks/" + libname + ".framework/Versions/" + f.version + "/" + libname

		libs_to_convert << cellar_path << prefix_path
		framework_paths << executable_path << executable_path
	}
}

rlinks = "--rlinks_framework=[" + libs_to_convert.join(" ") + "]:[" + framework_paths.join(" ") + "]"

libraries.each { | name, libs |
	f = Formula.factory(name)

	libs.each {|lib|
		libname = lib.gsub(/dylib$/, '').gsub(/[^A-Za-z]/, '')
		ohai "Frameworkerizing #{lib}"
		system "rtool",
				"--framework_root=@executable_path/../Frameworks",
				"--framework_name=#{libname}",
				"--framework_version=#{f.version}",
				"--library=#{(f.lib + lib).realpath}",
				"--builddir=#{frameworks}",
				"--headers=#{f.include}",
				"--headers_no_root",
				"#{rlinks}"
	}
}

ohai "Copying libpurple po files"
libpurple = Formula.factory "libpurple"
Dir[libpurple.share / "locale" / "*"].each { | locale |
	FileUtils.cp_r(locale, frameworks / "libpurple.subproj" / "libpurple.framework" / "Resources")
}