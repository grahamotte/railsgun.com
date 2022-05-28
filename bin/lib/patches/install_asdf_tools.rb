module Patches
  class InstallAsdfTools < Base
    class << self
      def needed?
        tool_versions.each do |t, v|
          return true unless Utils.nofail { Utils.run_remote("#{asdf_prefix} list #{t}").include?(v) }
        end

        false
      end

      def apply
        tool_versions.each do |t, v|
          Utils.run_remote("#{yay_prefix} -S jemalloc", bool: true)
          Utils.run_remote('mkdir -p ~/tmp')
          Utils.run_remote("#{asdf_prefix} plugin add #{t}", bool: true)
          Utils.run_remote("export TMPDIR=~/tmp; export RUBY_CONFIGURE_OPTS='--with-jemalloc'; #{asdf_prefix} install #{t} #{v}")
          Utils.run_remote("#{asdf_prefix} global #{t} #{v}")
          Utils.run_remote('rm -rf ~/tmp')
        end
      end
    end
  end
end
