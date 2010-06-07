require File.dirname(__FILE__) + "/../test_helper"

class CommitTest < Test::Unit::TestCase  
  def test_delegates_to_git_svn
    GitSvn.stubs(:new).returns(stub{expects(:commit)})
    Git.stubs(:new).returns(stub{expects(:commit).never})
    Svn.stubs(:new).returns(stub{expects(:commit).never})
    
    commit = Commit.new
    commit.expects("git_svn?").returns(true)
    commit.commit
  end
  
  def test_delegates_to_git
    GitSvn.stubs(:new).returns(stub{expects(:commit).never})
    Git.stubs(:new).returns(stub{expects(:commit)})
    Svn.stubs(:new).returns(stub{expects(:commit).never})
    
    commit = Commit.new
    commit.expects("git_svn?").returns(false)
    commit.expects("git?").returns(true)
    commit.commit
  end
  
  def test_delegates_to_svn
    GitSvn.stubs(:new).returns(stub{expects(:commit).never})
    Git.stubs(:new).returns(stub{expects(:commit).never})
    Svn.stubs(:new).returns(stub{expects(:commit)})
    
    commit = Commit.new
    commit.expects("git_svn?").returns(false)
    commit.expects("git?").returns(false)
    commit.commit
  end
end