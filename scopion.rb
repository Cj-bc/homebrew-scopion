class Scopion < Formula
	desc "a statically-typed functional programming language with powerful objective syntax"
	homepage "https://scopion.coord-e.com/"
	version "0.0.3.1"
	url "https://github.com/coord-e/scopion/releases/tag/v#{version}"
	head "https://github.com/coord-e/scopion.git"
	sha256 ""

	SupportedOSLeast = "10.12"
	CPUNumbers = `sysctl -n hw.ncpu`

	depends_on "cmake" => :build
	depends_on "wget" 
	depends_on "unzip"
	depends_on "ctags"
	depends_on "boost"
	depends_on "llvm"
	depends_on "bdw-gc"

	def preCheck
		# test architecture. x86_64 is needed
		if Hardware::CPU.is_32_bit? then
			odie "Architecture x86_64 is needed.Yours is #{arch}." # odie --> display error messages and exist.
		end

		# I don't treat with Linux yet. I'll do it later,sorry :(
		if OS.linux? then
			odie "Linuxbrew isn't supported yet. We're commiting now,sorry ;("
		end

		# Check wether used mac version is supported
		if `sw_vers -productVersion` <= SupportedOSLeast then
			odie "Unsaopported macOS version.You need #{SupportedOSLeast} or later"
		end
	end


	def install
  
		preCheck # check architecture,OS,macOS version

		ohai "debug:", `pwd`, "list:", `ls examples`
		prefix.install "#{buildpath}/examples/hello_world.scc" # install example program for homebrew test

		mkdir("build")
		cd("build")
		system "cmake", "-DCMAKE_BUILD_TYPE=RELEASE", "-DFORMAT_BEFORE_BUILD=OFF", "-DCMAKE_INSTALL_PREFIX=#{prefix}", ".."
		system "make" #, "-j", "#{CPUNumbers}" #  I Coudn't understand how to use -j command(it occure error)...Left here
		system "make install" # install
	end

	test do

		# --------------------- unit test
.		ohai "running unit test..."
		system "make", "test" # run unit test (i.e. whether perser is avilable..)
		if $? == 0 then
			ohai "unit test end successfully"
		else
			odie "unit test failed. OMG, something wrong..Please issue this"
		end


		# -------------------- compile test
		ohai "running compiling test..."
		system "scopc", "#{prefix}/hello_world.scc", "-o", "hello"
		system "./hello"
		if $? == 0 then
			ohai "scopc compiled test script successfully ;)"
		else
			odie "scopc couldn't compile test script... what's wrong!?"
		end
	end
end
