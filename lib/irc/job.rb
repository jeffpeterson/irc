require 'thread'

module IRC
  class Job
    def initialize *args, &block
      @args, @block = args, block
    end

    def call
      @block.call(*@args)
    end

    class << self
      attr_accessor :safe_mode
      def schedule *args, &block
        run!
        jobs << new(*args, &block)
      end

      def size
        @size ||= 1
      end

      def size= _size
        _size = _size.to_i
        _size = 1 if _size < 1

        @size = _size
      end

      def jobs
        @jobs ||= Queue.new
      end

      def run!
        @pool ||= Array.new(size) do |i|
          Thread.new do
            catch :exit do
              loop do
                jobs.pop.call
              end
            end
          end
        end
      end # def run!

      def shutdown
        size.times do
          schedule { throw :exit }
        end
      end # def shutdown
    end # class << Job
    at_exit { shutdown }
  end # class Job
end # module IRC
