class BackupJob < ApplicationJob
  schedule '11 11 11 * * *'

  def call
    `source /opt/asdf-vm/asdf.sh; cd #{Rails.root}; asdf exec bundle exec bin/prod db backup`
  end
end
