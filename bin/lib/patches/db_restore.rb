module Patches
  class DbRestore < Base
    class << self
      def apply
        return(puts('does not exist.')) unless Instance.exists?

        latest_backup_name = nil

        latest_backup_name = Cmd.remote('ls /mnt/dbs')
          .split
          .compact
          .select { |x| x.start_with?("#{Const.project}_production") }
          .max_by { |x| x.split('_').last.split('.').first.to_i }

        raise 'no version found' unless latest_backup_name

        Cmd.remote("psql #{Const.project}_production < /mnt/dbs/#{latest_backup_name}")
      end
    end
  end
end
