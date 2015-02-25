module Shoryuken
  class Message
    def initialize attrs, queue, client
      @attrs = attrs
      @queue = queue
      @client = client
    end

    def message_id
      @attrs[:message_id]
    end

    def receipt_handle
      @attrs[:receipt_handle]
    end

    def md5_of_body
      @attrs[:md5_of_body]
    end

    def body
      @attrs[:body]
    end

    def attributes
      @attrs[:attributes]
    end

    def message_attributes
      @attrs[:message_attributes]
    end

    def md5_of_message_attributes
      @attrs[:md5_of_message_attributes]
    end

    def change_visibility(params)
      @client.change_message_visibility(
        params.merge(
          queue_url: @queue.url,
          receipt_handle: receipt_handle))
    end
  end
end
