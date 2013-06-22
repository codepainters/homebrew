#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby -W0
# -*- coding: utf-8 -*-

require 'extend/pathname'
require 'formula_installer'

frameworks = HOMEBREW_PREFIX/"Frameworks"

Dir[frameworks].each {|fr|
	FileUtils.rm_r fr
}

frameworks.mkpath

libraries = [ { "name" => "gettext", "libs" => ["libintl.8.dylib"] },
			  { "name" => "glib", "libs" => ["libglib-2.0.0.dylib", "libgmodule-2.0.0.dylib", "libgobject-2.0.0.dylib", "libgthread-2.0.0.dylib"] },
	          { "name" => "meanwhile", "libs" => ["libmeanwhile.1.0.2.dylib"] },
	          { "name" => "libgcrypt", "libs" => ["libgcrypt.11.dylib"] },
	          { "name" => "libgpg-error", "libs" => ["libgpg-error.0.dylib"] },
	          { "name" => "libotr", "libs" => ["libotr.dylib"] },
	          { "name" => "libidn", "libs" => ["libidn.11.dylib"] },
	          { "name" => "libpurple", "libs" => ["libpurple.0.dylib"] }
			]

libs_to_convert = []
framework_paths = []

libraries.each { | l |
	name = l["name"]
	libs = l["libs"]
	f = Formula.factory(name)
	cellar = f.prefix.parent

	if not cellar.directory? or not f.installed? then
		ohai "Installing #{name} #{f.version} first"
		installer = FormulaInstaller.new(f)
		installer.install
		installer.finish
	end

	ohai "Linking version #{f.version} of #{name}"

	cellar.children.select {|pn| pn.directory? }.each {|v|
		keg = Keg.new(v)
		keg.unlink
	}

	keg = Keg.new(cellar+f.version)
	keg.link

	libs.each { | lib |
		libname = lib.gsub(/dylib$/, '').gsub(/[^A-Za-z]/, '')
		cellar_path = (f.lib + lib).realpath
		prefix_path = HOMEBREW_PREFIX/"lib"/lib
		opt_prefix_path = HOMEBREW_PREFIX/"opt"/name/"lib"/lib
		executable_path = "@executable_path/../Frameworks/" + libname + ".framework/Versions/" + f.version + "/" + libname

		libs_to_convert << cellar_path << prefix_path << opt_prefix_path
		framework_paths << executable_path << executable_path << executable_path
	}
}

rlinks = "--rlinks_framework=[" + libs_to_convert.join(" ") + "]:[" + framework_paths.join(" ") + "]"

libraries.each { | l |
	name = l["name"]
	libs = l["libs"]
	f = Formula.factory(name)

	libs.each {|lib|
		libname = lib.gsub(/dylib$/, '').gsub(/[^A-Za-z]/, '')
		ohai "Frameworkerizing #{lib}"
		
		headers = []

		Dir[f.include / '*'].each { |header_path|
			if not File.file? header_path then 
				headers << header_path
			end
		}

		Dir[f.lib / '*' / "include"].each { |header_path|
			headers << header_path
		}

		headers << f.include if headers.length == 0

		system HOMEBREW_PREFIX/"../rtool/rtool",
				"--framework_root=@executable_path/../Frameworks",
				"--framework_name=#{libname}",
				"--framework_version=#{f.version}",
				"--library=#{(f.lib + lib).realpath}",
				"--builddir=#{frameworks}",
				"--headers=#{headers.join(' ')}",
				"--headers_no_root",
				"#{rlinks}"
		system "otool -L #{frameworks}/#{libname}.subproj/#{libname}.framework/#{libname} | tail -n +2 | grep -E --invert-match \"^[[:space:]](/System|/usr|@executable_path)\""
		if $? == 0 then
			ohai "Something is wrong with #{libname}! Check 'otool -L #{frameworks}/#{libname}.subproj/#{libname}.framework/#{libname}'"
			exit
		end
		system "file #{frameworks}/#{libname}.subproj/#{libname}.framework/Versions/#{f.version}/#{libname} | grep -E --invert-match \"Mach-O fat file with 2 architectures\""
		if $? == 0 then
			ohai "Something is wrong with #{libname}! Check 'file -L #{frameworks}/#{libname}.subproj/#{libname}.framework/Versions/#{f.version}/#{libname}'"
			exit
		end
	}
}

ohai "Copying libpurple po files"
libpurple = Formula.factory "libpurple"
Dir[libpurple.share / "locale" / "*"].each { | locale |
	FileUtils.cp_r(locale, frameworks / "libpurple.subproj" / "libpurple.framework" / "Resources")
}

ohai "Adding libpurple.h and Info.plist"

FileUtils.cp HOMEBREW_PREFIX/"../libpurple-full.h", frameworks / "libpurple.subproj/libpurple.framework/Headers/libpurple.h"
FileUtils.cp HOMEBREW_PREFIX/"../Libpurple-Info.plist", frameworks / "libpurple.subproj/libpurple.framework/Resources/Info.plist"


FileUtils.cp HOMEBREW_PREFIX/"../Libotr-Info.plist", frameworks / "libotr.subproj/libotr.framework/Resources/Info.plist"

ohai "Done!"