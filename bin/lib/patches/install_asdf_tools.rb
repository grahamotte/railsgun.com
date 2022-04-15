module Patches
  class InstallAsdfTools < Base
    class << self
      def needed?
        tool_versions.each do |t, v|
          return true unless nofail { run_remote("#{asdf_prefix} list #{t}").include?(v) }
        end

        false
      end

      def apply
        tool_versions.each do |t, v|
          subsection("working on #{t} #{v}") do
            run_remote("#{yay_prefix} -S jemalloc", just_status: true)
            run_remote('mkdir -p ~/tmp')
            run_remote("#{asdf_prefix} plugin add #{t}", just_status: true)
            run_remote("export TMPDIR=~/tmp; export RUBY_CONFIGURE_OPTS='--with-jemalloc'; #{asdf_prefix} install #{t} #{v}")
            run_remote("#{asdf_prefix} global #{t} #{v}")
            run_remote('rm -rf ~/tmp')
          end
        end
      end
    end
  end
end
