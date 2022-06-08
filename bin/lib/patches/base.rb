module Patches
  class Base
    class << self
      def call
        start_time = Time.now
        puts "\n////// #{name.split('::').last.underscore.gsub('_', ' ').titleize} //////\n\n" if leaf?

        Instance.reload
        apply if needed?

        puts "\ntook #{(Time.now - start_time).round(2)}s" if leaf?
      end

      def leaf?
        true
      end

      def needed?
        true
      end

      def apply
        raise 'implement apply'
      end

      def pry
        binding.pry
      end
    end
  end
end
