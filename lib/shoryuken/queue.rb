module Shoryuken
  class Queue
    # From: https://github.com/aws/aws-sdk-ruby/blob/v2.0.21/aws-sdk-resources/lib/aws-sdk-resources/services/sqs/queue.rb
    # until they replace the sqs resource classes with new versions.

    class << self
      private

      def queue_str_attr(method_name, options = {})
        name = options[:name] || attr_name(method_name)
        define_method(method_name) do
          attributes[name]
        end
      end

      def queue_int_attr(method_name, options = {})
        name = options[:name] || attr_name(method_name)
        define_method(method_name) do
          if value = attributes[name]
            value.to_i
          end
        end
      end

      def queue_time_attr(method_name, options = {})
        name = options[:name] || attr_name(method_name)
        define_method(method_name) do
          if value = attributes[name]
            Time.at(value.to_i)
          end
        end
      end

      def attr_name(method_name)
        method_name.to_s.split('_').map { |s| s[0].upcase + s[1..-1] }.join
      end
    end

    # @group Queue Attributes
    # @return [String] the queue's policy.
    queue_str_attr :policy

    # @group Queue Attributes
    # @return [Integer] the visibility timeout for the queue. For more information about visibility timeout, see [Visibility Timeout](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/AboutVT.html) in the Amazon SQS Developer Guide.
    queue_int_attr :visibility_timeout

    # @group Queue Attributes
    # @return [Integer] the limit of how many bytes a message can contain before
    #   Amazon SQS rejects it.
    queue_int_attr :maximum_message_size

    # @group Queue Attributes
    # @return [Integer] the number of seconds Amazon SQS retains a message.
    queue_int_attr :message_retention_period

    # @group Queue Attributes
    # @return [Integer] the approximate number of visible messages in a queue.
    #   For more information, see [Resources Required to Process Messages](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/ApproximateNumber.html) in the Amazon SQS Developer Guide.
    queue_int_attr :approximate_number_of_messages

    # @group Queue Attributes
    # @return [Integer] returns the approximate number of messages that are not timed-out and not deleted. For more information, see [Resources Required to Process Messages](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/ApproximateNumber.html) in the Amazon SQS Developer Guide.
    queue_int_attr :approximate_number_of_messages_not_visible

    # @group Queue Attributes
    # @return [Time] the time when the queue was created.
    queue_time_attr :created_timestamp

    # @group Queue Attributes
    # @return [Time] the time when the queue was last changed.
    queue_time_attr :last_modified_timestamp

    # @group Queue Attributes
    # @return [String] the queue's Amazon resource name (ARN).
    queue_str_attr :arn, name: 'QueueArn'

    alias queue_arn arn

    # @group Queue Attributes
    # @return [Integer] returns the approximate number of messages that
    #   are pending to be added to the queue.
    queue_int_attr :approximate_number_of_messages_delayed

    # @group Queue Attributes
    # @return [Integer] the default delay on the queue in seconds.
    queue_int_attr :delay_seconds

    # @group Queue Attributes
    # @return [Integer] the time for which a {Client#receive_message} call
    #   will wait for a message to arrive.
    queue_int_attr :receive_message_wait_time_seconds

    # @group Queue Attributes
    # @return [String] the parameters for dead letter queue functionality of
    #   the source queue. For more information about RedrivePolicy and dead
    #   letter queues, see [Using Amazon SQS Dead Letter Queues](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/SQSDeadLetterQueue.html)
    #   in the Amazon SQS Developer Guide.
    queue_str_attr :redrive_policy

    def initialize queue_url, client
      @queue_url = queue_url
      @client = client
    end

    def attributes
      @attributes ||= @client.get_queue_attributes(queue_url: @queue_url, attribute_names: %w(All))[:attributes]
    end

    def delete_messages(params)
      @client.delete_message_batch(params.merge(queue_url: @queue_url))
    end

    def receive_messages(params = {})
      @client.receive_message(params.merge(queue_url: @queue_url)).messages.map do |attrs|
        Message.new(attrs, self, @client)
      end
    end

    def set_attributes(params)
      @client.set_queue_attributes(params.merge(queue_url: @queue_url))
    end

    def url
      @queue_url
    end
  end
end
