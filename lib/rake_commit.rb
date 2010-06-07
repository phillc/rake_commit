Dir.glob(File.expand_path(File.dirname(__FILE__) + '/rake_commit/*.rb')) do |file|
  require file
end

module RakeCommit  
  def self.ok_to_check_in?
    return true unless self.class.const_defined?(:CCRB_RSS)
    cruise_status = CruiseStatus.new(CCRB_RSS)
    cruise_status.pass? ? true : are_you_sure?( "Build FAILURES: #{cruise_status.failures.join(', ')}" )
  end

  def git_commit_with_message
    commit_message = CommitMessage.new
    sh_with_output("git config user.name #{commit_message.pair.inspect}")
    message = "#{commit_message.feature} - #{commit_message.message}"
    sh_with_output("git commit -m #{message.inspect}")
  end

  def are_you_sure?(message)
    puts "\n", message
    input = ""
    while (input.strip.empty?)
      input = Readline.readline("Are you sure you want to check in? (y/n): ")
    end
    return input.strip.downcase[0,1] == "y"
  end

  def sh_with_output(command)
    puts command
    output = `#{command}`
    puts output
    raise unless $?.success?
    output
  end
end