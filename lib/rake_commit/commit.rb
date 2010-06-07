require 'rexml/document'

module RakeCommit
  class Commit
    def git?
      Shell.pure_backtick("git symbolic-ref HEAD 2>/dev/null")
      $?.success?
    end

    def git_svn?
      Shell.pure_backtick("git svn info 2> /dev/null")
      $?.success?
    end

    def commit
      if git_svn?
        GitSvn.new.commit
      elsif git?
        Git.new.commit
      else
        Svn.new.commit
      end
    end
  end
end