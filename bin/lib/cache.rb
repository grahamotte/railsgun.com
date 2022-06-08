class Cache
  class << self
    def all
      File.write(cf, Marshal.dump({})) unless File.exists?(cf)
      Marshal.load(File.read(cf))
    end

    def read(k)
      res = all.dig(k.to_sym)
      return if res.blank?
      return if (res[:t] + res[:x]) < Time.now

      res[:v]
    end

    def write(k, v, x)
      all
        .merge(k.to_sym => { v: v, t: Time.now, x: x })
        .then { |x| Marshal.dump(x) }
        .then { |x| File.write(cf, x) }
    end

    private

    def cf
      File.join(Const.local_root, 'tmp/depcache')
    end
  end
end
