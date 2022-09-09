# frozen_string_literal: true

module Gem
  def self.ruby=(ruby)
    @ruby = ruby
  end

  if ENV["RUBY"]
    Gem.ruby = ENV["RUBY"]
  end

  if ENV["BUNDLER_GEM_DEFAULT_DIR"]
    @default_dir = ENV["BUNDLER_GEM_DEFAULT_DIR"]
    @default_specifications_dir = nil
  end

  if ENV["BUNDLER_SPEC_WINDOWS"]
    @@win_platform = true # rubocop:disable Style/ClassVars
  end

  if ENV["BUNDLER_SPEC_PLATFORM"]
    class Platform
      @local = new(ENV["BUNDLER_SPEC_PLATFORM"])
    end
    @platforms = [Gem::Platform::RUBY, Gem::Platform.local]
  end

  if ENV["BUNDLER_SPEC_GEM_SOURCES"]
    self.sources = [ENV["BUNDLER_SPEC_GEM_SOURCES"]]
  end

  if ENV["BUNDLER_SPEC_READ_ONLY"]
    module ReadOnly
      def open(file, mode)
        if file != IO::NULL && mode == "wb"
          raise Errno::EROFS
        else
          super
        end
      end
    end

    File.singleton_class.prepend ReadOnly
  end

  # We only need this hack for rubygems versions without the BundlerVersionFinder
  if Gem.rubygems_version < Gem::Version.new("2.7.0")
    @path_to_default_spec_map.delete_if do |_path, spec|
      spec.name == "bundler"
    end
  end
end
