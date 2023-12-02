class Libdpp < Formula
  desc "C++ Discord API Bot Library"
  homepage "https://github.com/brainboxdotcc/DPP"
  url "https://github.com/brainboxdotcc/DPP/releases/download/v10.0.28/DPP-10.0.28.tar.gz"
  sha256 "aa0c16a1583f649f28ec7739c941e9f2bf9c891c0b87ef8278420618f8bacd46"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any, arm64_sonoma: "9f05a962b1a82a872ffff8ac3ab084f762ce85b1bd076412164efa98f0d452c8"
    sha256 cellar: :any, sonoma:       "6d3235f0f8c9bfd0ec3ed8be0266021e3c30b25c6414014d4eacd5781dfd1187"
  end

  depends_on "cmake" => :build
  depends_on xcode: ["12.0", :build]
  depends_on "libsodium"
  depends_on "openssl@3"
  depends_on "opus"
  depends_on "pkg-config"

  uses_from_macos "zlib"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <dpp/dpp.h>

      int main() {
        dpp::cluster bot("invalid_token");

        bot.on_log(dpp::utility::cout_logger());

        try {
          bot.start(dpp::st_wait);
        }
        catch(dpp::invalid_token_exception& e) {
          std::cout << "Invalid token." << std::endl;
          return 0;
        }
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++17", "-L#{lib}", "-I#{include}", "test.cpp", "-o", "test", "-ldpp"
    assert_equal "Invalid token.", shell_output("./test").strip
  end
end