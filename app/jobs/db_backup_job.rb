class DbBackupJob < ApplicationJob
  schedule '11 11 11 * * *'

  def call
    # vars
    user = `whoami`.chomp
    bucket = 'databases-a59ffa28'
    tmp_path = Rails.root.join('tmp/db_copy.sql').to_s
    db_name = Rails.configuration.database_configuration.dig(Rails.env, "database")
    key_name = "#{db_name}_#{Time.zone.now.to_i}.sql"
    pg_dump = `which pg_dump`.chomp
    s3 = Aws::S3::Client.new(
      access_key_id: Rails.application.secrets.s3_id,
      secret_access_key: Rails.application.secrets.s3_secret,
      region: 'us-west-002',
      endpoint: 'https://s3.us-west-002.backblazeb2.com',
    )

    # upload db
    `#{pg_dump} -U #{user} --clean #{db_name} > #{tmp_path}`
    File.open(tmp_path, 'rb') do |file|
      s3.put_object(bucket: bucket, key: key_name, body: file)
    end

    # remove_old_dbs
    s3.list_objects(bucket: bucket).contents.each do |x|
      next unless x.key.start_with?(db_name)
      next unless x.last_modified < 30.days.ago

      s3.delete_object(bucket: bucket, key: x.key)
    end

    # suppress output
    nil
  end
end
