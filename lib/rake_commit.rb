Dir.glob(File.expand_path(File.dirname(__FILE__) + '/rake_commit/*.rb')) do |file|
  require file
end

module RakeCommit
  def self.ok_to_check_in?
    return true unless self.const_defined?(:CCRB_RSS)
    cruise_status = CruiseStatus.new(CCRB_RSS)
    cruise_status.pass? ? true : are_you_sure?( "Build FAILURES: #{cruise_status.failures.join(', ')}" )
  end

  def self.are_you_sure?(message)
    puts "\n", message
    input = ""
    while (input.strip.empty?)
      input = Readline.readline("Are you sure you want to check in? (y/n): ")
    end
    return input.strip.downcase[0,1] == "y"
  end
end