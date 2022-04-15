# frozen_string_literal: true

class Profiler
  class << self
    def call
      FileUtils.mkdir_p(Rails.root.join('tmp/prof'))
      flamegraph_pl_path = Rails.root.join('tmp/prof/FlameGraph/flamegraph.pl')
      run_path = Rails.root.join("tmp/prof/#{Time.zone.now.to_i}")
      `git clone https://github.com/brendangregg/FlameGraph.git #{File.dirname(flamegraph_pl_path)}` unless File.exist?(flamegraph_pl_path)
      result = RubyProf.profile { yield }
      printer = RubyProf::FlameGraphPrinter.new(result)
      File.open("#{run_path}.txt", 'w') { |file| printer.print(file) }
      `cat #{run_path}.txt | #{flamegraph_pl_path} > #{run_path}.svg`
      Launchy.open("#{run_path}.svg")
    end
  end
end
