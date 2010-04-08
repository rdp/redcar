RequireSupportFiles File.dirname(__FILE__) + "/../../../edit_view/features/"
require 'fileutils'
require 'drb'

def reset_project_fixtures
  if @put_myproject_fixture_back
    @put_myproject_fixture_back = nil
    FileUtils.mv("plugins/project/spec/fixtures/myproject.bak",
                 "plugins/project/spec/fixtures/myproject")
  end
  fixtures_path = File.expand_path(File.dirname(__FILE__) + "/../../spec/fixtures")
  File.open(fixtures_path + "/winter.txt", "w") {|f| f.print "Wintersmith" }
  FileUtils.rm_rf(fixtures_path + "/winter2.txt")
end

def save_cached_settings
  FileUtils.rm_rf(File.expand_path('~/.redcar_saved'))
  FileUtils.mv(File.expand_path('~/.redcar'), File.expand_path('~/.redcar_saved'))
end

def restore_cached_settings
  FileUtils.mv(File.expand_path('~/.redcar_saved'), File.expand_path('~/.redcar'))
end

Before do
  reset_project_fixtures
  save_cached_settings
end

After do
  reset_project_fixtures
  restore_cached_settings
end
