module ElasticWhenever
  class Task
    attr_reader :name
    attr_reader :commands
    attr_reader :expression

    def initialize(environment, bundle_command, expression, name)
      @environment = environment
      @bundle_command = bundle_command.split(" ")
      @expression = expression
      @commands = []
      @name = name
    end

    def command(task, id = nil)
      @commands << {
        id: id,
        command: task.split(" "),
      }
    end

    def rake(task, id = nil)
      @commands << {
        id: id,
        command: [@bundle_command, "rake", task, "--silent"].flatten,
      }
    end

    def runner(src, id = nil)
      @commands << {
        id: id,
        command: [@bundle_command, "bin/rails", "runner", "-e", @environment, src].flatten,
      }
    end

    def script(script, id = nil)
      @commands << {
        id: id,
        command: [@bundle_command, "script/#{script}"].flatten,
      }
    end

    def method_missing(name, *args)
      Logger.instance.warn("Skipping unsupported method: #{name}")
    end
  end
end
