require 'fileutils'

module RakeCommit
  class Svn
    def commit
      if files_to_check_in?
        message = CommitMessage.new.joined_message
        add
        delete
        up
        Shell.system "rake"

        if RakeCommit.ok_to_check_in?
          output = Shell.backtick "#{commit_command(message)}"
          puts output
          revision = output.match(/Committed revision (\d+)\./)[1]
          merge_to_trunk(revision) if Shell.backtick("svn info").include?("branches") && self.class.const_defined?(:PATH_TO_TRUNK_WORKING_COPY)
        end
      else
        puts "Nothing to commit"
      end
    end

    def commit_command(message)
      "svn ci -m #{message.inspect}"
    end

    def files_to_check_in?
      Shell.backtick("svn st --ignore-externals").split("\n").reject {|line| line[0,1] == "X"}.any?
    end

    def status
      Shell.system "svn st"
    end

    def up
      output = Shell.backtick "svn up"
      puts output
      output.each do |line|
        raise "SVN conflict detected. Please resolve conflicts before proceeding." if line[0,1] == "C"
      end
    end

    def add
      Shell.backtick("svn st").split("\n").each do |line|
        if new_file?(line) && !svn_conflict_file?(line)
          file = line[7..-1].strip
          Shell.system "svn add #{file.inspect}"
        end
      end
    end

    def new_file?(line)
      line[0,1] == "?"
    end

    def svn_conflict_file?(line)
      line =~ /\.r\d+$/ || line =~ /\.mine$/
    end

    def delete
      Shell.backtick("svn st").split("\n").each do |line|
        if line[0,1] == "!"
          file = line[7..-1].strip
          Shell.backtick "svn up #{file.inspect} && svn rm #{file.inspect}"
          puts %[removed #{file}]
        end
      end
    end

    def revert_all
      Shell.system "svn revert -R ."
      Shell.backtick("svn st").split("\n").each do |line|
        next unless line[0,1] == '?'
        filename = line[1..-1].strip
        puts "removed #{filename}"
        FileUtils.rm_r filename
      end
    end

    def merge_to_trunk(revision)
      puts "Merging changes into trunk.  Don't forget to check these in."
      Shell.system "svn up #{PATH_TO_TRUNK_WORKING_COPY.inspect}"
      Shell.system "svn merge -c #{revision} . #{PATH_TO_TRUNK_WORKING_COPY.inspect}"
    end
  end
end