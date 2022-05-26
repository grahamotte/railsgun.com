module Patches
  class DbRestore < Base
    class << self
      def always_needed?
        true
      end

      def apply
        return(puts('does not exist.')) unless Instance.exists?

        latest_backup_name = nil

        subsection('finding latest version') do
          latest_backup_name = run_remote('ls /mnt/dbs')
            .split
            .compact
            .select { |x| x.start_with?("#{project}_production") }
            .max_by { |x| x.split('_').last.split('.').first.to_i }
        end

        raise 'no version found' unless latest_backup_name

        subsection("restoring to version #{@latest_backup_name}") do
          run_remote("psql #{project}_production < /mnt/dbs/#{latest_backup_name}")
        end
      end
    end
  end
end
