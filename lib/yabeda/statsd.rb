# frozen_string_literal: true

require "yabeda/statsd/version"

module Yabeda
  # Namespace for Statsd adapter
  module Statsd
    class << self
      def configure(&block)
        class_exec(&block)
      end

      def config
        Yabeda::Statsd::Config.config
      end

      def global_label(label_name, value:)
        global_labels[label_name] = value
      end

      def global_labels
        @global_labels ||= Concurrent::Hash.new
      end

      def start(logger: nil)
        adapter = Yabeda::Statsd::Adapter.new(logger: logger)
        Yabeda.register_adapter(:statsd, adapter)
        adapter
      end

      # Start collection metrics from Yabeda collectors
      def start_exporter
        Thread.new do
          loop do
            Yabeda.collectors.each(&:call)
            sleep(config.collect_interval)
          end
        end
      end
    end
  end
end
