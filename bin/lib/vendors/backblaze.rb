module Vendors
  class Backblaze
    def upload(path)
      [
        'curl -s',
        "-H 'Authorization: #{upload_config.dig(:authorizationToken)}'",
        "-H 'X-Bz-File-Name: #{File.basename(path)}'",
        "-H 'Content-Type: binary/octet-stream'",
        "-H 'X-Bz-Content-Sha1: #{Cmd.remote("sha1sum #{path}").split.first}'",
        "-H 'X-Bz-Info-Author: #{Const.project}'",
        "-H 'X-Bz-Server-Side-Encryption: AES256'",
        "--data-binary \"@#{path}\"",
        upload_config.dig(:uploadUrl),
      ]
        .join(' ')
        .then { |x| Cmd.remote(x) }
    end

    def download(key, path)
      [
        'curl -s',
        "-H 'Authorization: #{auth.dig(:authorizationToken)}'",
        "#{auth.dig(:apiUrl)}/file/#{bucket_name}/#{key}",
        "--output #{path}"
      ]
        .join(' ')
        .then { |x| Cmd.remote(x, quiet: true) }
    end

    def delete(key)
      backups.select { |x| x.dig(:fileName) == key }.each do |x|
        [
          'curl -s',
          "-H 'Authorization: #{auth.dig(:authorizationToken)}'",
          "-d '#{{ fileName: x.dig(:fileName), fileId: x.dig(:fileId), }.to_json}'",
          "#{auth.dig(:apiUrl)}/b2api/v2/b2_delete_file_version",
        ]
          .join(' ')
          .then { |x| Cmd.remote(x) }
      end
    end

    # ---

    def auth
      @auth ||= [
        'curl -s',
        "-u \"#{Secrets.backup_bucket.dig('access_key_id')}:#{Secrets.backup_bucket.dig('secret_access_key')}\"",
        "https://api.backblazeb2.com/b2api/v2/b2_authorize_account",
      ]
        .join(' ')
        .then { |x| Cmd.remote(x, quiet: true) }
        .then { |x| JSON.parse(x, symbolize_names: true) }
    end

    def account_id
      @account_id ||= auth.dig(:accountId)
    end

    def bucket_name
      @bucket_name ||= Secrets.backup_bucket.dig('bucket')
    end

    def bucket_id
      @bucket_id ||= [
        'curl -s',
        "-H 'Authorization: #{auth.dig(:authorizationToken)}'",
        "-d '#{{ accountId: account_id }.to_json}'",
        "#{auth.dig(:apiUrl)}/b2api/v2/b2_list_buckets",
      ]
        .join(' ')
        .then { |x| Cmd.remote(x, quiet: true) }
        .then { |x| JSON.parse(x, symbolize_names: true) }
        .dig(:buckets)
        .find { |x| x.dig(:bucketName) == bucket_name }
        .dig(:bucketId)
    end

    def upload_config
      @upload_config ||= [
        'curl -s',
        "-H 'Authorization: #{auth.dig(:authorizationToken)}'",
        "-d '#{{ bucketId: bucket_id }.to_json}'",
        "#{auth.dig(:apiUrl)}/b2api/v2/b2_get_upload_url",
      ]
        .join(' ')
        .then { |x| Cmd.remote(x, quiet: true) }
        .then { |x| JSON.parse(x, symbolize_names: true) }
    end

    def latest_backup_key
      @latest_backup_key ||= backup_names
        .sort_by { |x| x.gsub('.sql', '').split('_').last }
        .reverse
        .first
    end

    def backup_names
      @backup_names ||= backups.map { |x| x.dig(:fileName) }
    end

    def backups
      @backups ||= begin
        keys = []
        pos = ""

        loop do
          res = [
              'curl -s',
              "-H 'Authorization: #{auth.dig(:authorizationToken)}'",
              "-d '#{{ bucketId: bucket_id, startFileName: pos, prefix: Const.db_name }.to_json}'",
              "#{auth.dig(:apiUrl)}/b2api/v2/b2_list_file_names",
            ]
              .join(' ')
              .then { |x| Cmd.remote(x, quiet: true) }
              .then { |x| JSON.parse(x, symbolize_names: true) }

          keys += res.dig(:files)
          pos = res.dig(:nextFileName)

          break if pos.blank?
        end

        keys.select { |x| x.dig(:fileName).start_with?(Const.db_name) }
      end
    end
  end
end
