RequireSupportFiles File.dirname(__FILE__) + "/../../../edit_view/features/"
require 'fileutils'

def reset_project_fixtures
  fixtures_path = File.expand_path(File.dirname(__FILE__) + "/../fixtures")
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
