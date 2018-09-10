module ElasticWhenever
  class Task
    class Rule
      attr_reader :name
      attr_reader :expression

      class UnsupportedOptionException < StandardError; end

      def self.fetch(option)
        client = Aws::CloudWatchEvents::Client.new(option.aws_config)
        client.list_rules(name_prefix: option.identifier).rules.map do |rule|
          self.new(
            option,
            name: rule.name,
            expression: rule.schedule_expression,
          )
        end
      end

      def self.convert(option, task)
        self.new(
          option,
          name: task.name || rule_name(option.identifier, task.commands),
          expression: task.expression
        )
      end

      def initialize(option, name:, expression:)
        @name = name
        @expression = expression
        @client = Aws::CloudWatchEvents::Client.new(option.aws_config)
      end

      def create
        client.put_rule(
          name: name,
          schedule_expression: expression,
          state: "ENABLED",
        )
      end

      def delete
        targets = client.list_targets_by_rule(rule: name).targets
        client.remove_targets(rule: name, ids: targets.map(&:id)) unless targets.empty?
        client.delete_rule(name: name)
      end

      private

      def self.rule_name(identifier, commands)
        "#{identifier}_#{Digest::SHA1.hexdigest(commands.map { |command| command.join("-") }.join("-"))}"
      end

      attr_reader :client
    end
  end
end
