module Patches
  class InstallAsdfTools < Base
    class << self
      def needed?
        tool_versions.each do |t, v|
          return true unless Utils.nofail { Cmd.remote("#{Const.asdf} list #{t}").include?(v) }
        end

        false
      end

      def apply
        tool_versions.each do |t, v|
          Cmd.remote("#{Const.yay} -S jemalloc", bool: true)
          Cmd.remote('mkdir -p ~/tmp')
          Cmd.remote("#{Const.asdf} plugin add #{t}", bool: true)
          Cmd.remote("export TMPDIR=~/tmp; export RUBY_CONFIGURE_OPTS='--with-jemalloc'; #{Const.asdf} install #{t} #{v}")
          Cmd.remote("#{Const.asdf} global #{t} #{v}")
          Cmd.remote('rm -rf ~/tmp')
        end
      end

      private

      def tool_versions
        [Const.local_root, Const.remote_root]
          .find { |x| Dir.exist?(x) }
          .then { |x| File.join(x, '.tool-versions') }
          .then { |x| File.readlines(x) }
          .map(&:split)
          .to_h
      end
    end
  end
end
