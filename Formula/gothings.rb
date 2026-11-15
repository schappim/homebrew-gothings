class Gothings < Formula
  desc "MCP server giving ChatGPT, Claude and Claude Code full access to Things 3"
  homepage "https://github.com/schappim/gothings"
  url "https://github.com/schappim/gothings/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "329f3e439d1df36e213aef329717c30cdcf6948951747b1cae27a8b2222c7f6c"
  license "MIT"
  head "https://github.com/schappim/gothings.git", branch: "main"

  depends_on "go" => :build
  depends_on :macos

  def install
    ENV["CGO_ENABLED"] = "0"
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=#{version}"), "./cmd/gothings"
    generate_completions_from_executable(bin/"gothings", "completion")
    pkgshare.install "skills"
  end

  def caveats
    <<~EOS
      In Things, turn on Settings → General → Enable Things URLs, then:
        gothings doctor              # check database, URL token and AppleScript access
        gothings agent install       # background server on http://127.0.0.1:47865/mcp
        gothings install all         # Claude Desktop, Claude Code and ChatGPT

      macOS asks to let gothings read Things' data and control Things: allow both.

      An Agent Skill for CLI agents is in:
        #{opt_pkgshare}/skills/gothings
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gothings --version")
    assert_match "create_todo", shell_output("#{bin}/gothings tools")
    # MCP over stdio against an empty database path fails cleanly rather than hanging.
    ENV["THINGS_DB"] = testpath/"missing.sqlite"
    assert_match "Things database", shell_output("#{bin}/gothings doctor 2>&1", 1)
  end
end
