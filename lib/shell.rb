class Shell
  def self.system(cmd)
    Kernel.system(cmd) or raise
  end

  def self.pure_backtick(cmd)
    `#{cmd}`
  end

  def self.backtick(cmd)
    output = `#{cmd}`
    raise "Command failed: #{cmd.inspect}" unless $?.success?
    output
  end
end
