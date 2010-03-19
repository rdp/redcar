
require 'java'
require 'fileutils'

require "core/logger"
require "core/reentry_helpers"
require "core/controller"
require "core/gui"
require "core/interface"
require "core/model"
require "core/observable"
require "core/observable_struct"
require "core/persistent_cache"
require "core/plugin"
require "core/plugin/storage"

module Redcar
  def self.tmp_dir
    path = File.join(Redcar.user_dir, "tmp")
    unless File.exists?(path)
      FileUtils.mkdir(path)
    end
    path
  end
    
  class Core
    include HasLogger
    
    def self.loaded
      Core::Logger.init
      unless File.exist?(Redcar.user_dir)
        FileUtils.mkdir(Redcar.user_dir)
      end
      PersistentCache.storage_dir = File.join(Redcar.user_dir, "cache")
    end
  end
end
