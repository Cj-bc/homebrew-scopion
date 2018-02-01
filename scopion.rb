# version 0.0.3.1

class Scopion < Formula
	desc "a statically-typed functional programming language with powerful objective syntax"
	homepage "https://scopion.coord-e.com/"
	url "https://github.com/coord-e/scopion/archive/v0.0.3.1.tar.gz"
	head "https://github.com/coord-e/scopion.git", :branch => "develop"
	sha256 "74f7cacbd6e4f7544f085f26d39efaf87f6916bc4e40dfc95daf802ae39949b8"

	SupportedOSLeast = "10.12"

	depends_on "cmake" => :build
	depends_on "wget" 
	depends_on "unzip"
	depends_on "ctags"
	depends_on "boost"
	depends_on "llvm"
	depends_on "bdw-gc"

	bottle do
	    rebuild 1
	        sha256 "ccb1dc58a8e9d999a288b3fa4a94907172ed1a364b952db039187f7f40e3e4ca" => :high_sierra
		  end

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

		mkdir("build")
		cd("build")
		system "cmake", "-DCMAKE_BUILD_TYPE=RELEASE", "-DFORMAT_BEFORE_BUILD=OFF", "-DCMAKE_INSTALL_PREFIX=#{prefix}", ".."
		system "make"
		
# --------------------- unit test
		ohai "running unit test..."
		system "make", "test" # run unit test (i.e. whether perser is avilable..)
		if $? == 0 then
			ohai "unit test end successfully"
		else
			odie "unit test failed. OMG, something wrong..Please issue this"
		end

		system "make", "install" # install
	end

	test do
		# create new script file for test.
		# this simply output "hello,world"
		hello_world_text = <<~EOS  # contents of hello_world. <<~ is heredocument
		(argc, argv){
		  io = @import#c:stdio.h;
		  io.printf("Hello, World!\n");
		  |> 0;
		}
		EOS
		open('.tmp.scc','w'){|f| # make a new file with hello_world_text
			f.puts hello_world_text 	
		}

		system "#{bin}/scopc", ".tmp.scc" # compile
		system "./a.out" # execute
	end
end
