class Text
  class << self
    def eq?(a, b)
      a.to_s.split("\n").select(&:present?) == b.to_s.split("\n").select(&:present?)
    end

    def md5(str)
      Digest::MD5.hexdigest(str)
    end

    def remote_md5_eq?(path, str)
      Utils.nofail do
        md5local = md5(str + "\n")
        md5remote = Cmd.remote("sudo md5sum #{path}").split(' ').first

        return md5local == md5remote
      end
    end

    def with_local_tmp(str = "")
      path = File.expand_path(File.join(local_dir, 'tmp', SecureRandom.hex(16)))
      Cmd.local("touch #{path}")
      File.open(path, 'w+') { |f| f << str } if str.present?
      result = yield(path)
      Cmd.local("rm #{path}")
      result
    end

    def write_local(path, str)
      Cmd.local("rm -f #{path}")
      File.open(path, 'w+') { |f| f << str; f << "\n" }
    end

    def write_remote(path, str)
      # do nothing if the files are the same
      return if Text.remote_md5_eq?(path, str)

      # create remote dir if it doesn't exist
      unless Cmd.remote("sudo [ -d #{File.dirname(path)} ]", bool: true)
        Utils.nofail { Cmd.remote("mkdir -p #{File.dirname(path)}") } || Cmd.remote("sudo mkdir -p #{File.dirname(path)}")
      end

      # setup tmp files for copy
      local_tmp_file = File.expand_path(File.join(local_dir, 'tmp', 'file_to_upload'))
      remote_tmp_file = '/tmp/uploaded_file'

      # copy over file
      Text.write_local(local_tmp_file, str)
      Cmd.local("scp -i #{Secrets.id_rsa_path} #{local_tmp_file} #{Instance.username}@#{Instance.ipv4}:#{remote_tmp_file}")
      Cmd.remote("sudo cp #{remote_tmp_file} #{path}")
    end
  end
end
