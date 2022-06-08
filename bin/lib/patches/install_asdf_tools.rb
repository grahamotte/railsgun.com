module Patches
  class InstallAsdfTools < Base
    class << self
      def needed?
        tool_versions.each do |t, v|
          return true unless Utils.nofail { Cmd.remote("#{asdf_prefix} list #{t}").include?(v) }
        end

        false
      end

      def apply
        tool_versions.each do |t, v|
          Cmd.remote("#{yay_prefix} -S jemalloc", bool: true)
          Cmd.remote('mkdir -p ~/tmp')
          Cmd.remote("#{asdf_prefix} plugin add #{t}", bool: true)
          Cmd.remote("export TMPDIR=~/tmp; export RUBY_CONFIGURE_OPTS='--with-jemalloc'; #{asdf_prefix} install #{t} #{v}")
          Cmd.remote("#{asdf_prefix} global #{t} #{v}")
          Cmd.remote('rm -rf ~/tmp')
        end
      end
    end
  end
end
