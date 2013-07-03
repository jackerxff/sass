require 'sass/script/functions'

module Sass::Script::Tree
  # A SassScript parse node representing an inline if function.
  class IfFunction < Node

    # Create the IfFunction node
    #
    # @param args [Array<Node>] The arguments passed to the function.
    # @param keywords [{String => Node}] The keyword arguments passed to the function.
    # @raise ArgumentError when the three required arguments (condition, if_true, if_false) are not present.
    def initialize(args, keywords)
      condition, true_expression, false_expression = args
      condition ||= keywords.delete("condition")
      true_expression ||= keywords.delete("if_true")
      false_expression ||= keywords.delete("if_false")
      if keywords.any?
        raise ArgumentError.new("The $#{keywords.keys.first} is not allowed as an argument to if")
      end
      self.condition = condition
      self.true_statement = true_expression
      self.false_statement = false_expression
    end

    # An expression that determines which branch to execute
    # @return [Node]
    attr_accessor :condition

    # The statement that runs if the condition is true
    # @return [Node]
    attr_accessor :true_statement

    # The statement that runs if the condition is false
    # @return [Node]
    attr_accessor :false_statement

    # @see Node#children
    def children
      [condition, true_statement, false_statement]
    end

    # @see Node#to_sass
    def to_sass(opts = {})
      "if(#{condition.to_sass(opts)}, #{true_statement.to_sass(opts)}, #{false_statement.to_sass(opts)})"
    end

    # @see Node#deep_copy
    def deep_copy
      node = dup
      node.instance_variable_set('@condition', condition.deep_copy)
      node.instance_variable_set('@true_statement', true_statement.deep_copy)
      node.instance_variable_set('@false_statement', false_statement.deep_copy)
      node
    end

    # @see Node#inspect
    def inspect
      "if(#{condition.inspect}, #{true_statement.inspect}, #{false_statement.inspect})"
    end

    protected

    # Evaluates the if function.
    #
    # @see Node#_perform
    def _perform(environment)
      if condition.perform(environment).to_bool
        true_statement.perform(environment)
      else
        false_statement.perform(environment)
      end
    end

  end
end
