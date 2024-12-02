module Chewy
  # Replacement for Chewy.client
  class OpenSearchClient
    def self.build_os_client(configuration = Chewy.configuration)
      client_configuration = configuration.deep_dup
      client_configuration.delete(:prefix) # used by Chewy, not relevant to OpenSearch::Client
      block = client_configuration[:transport_options].try(:delete, :proc)
      ::OpenSearch::Client.new(client_configuration, &block)
    end

    def initialize(open_search_client = self.class.build_os_client)
      @open_search_client = open_search_client
    end

  private

    def method_missing(name, *args, **kwargs, &block)
      inspect_payload(name, args, kwargs)

      @open_search_client.__send__(name, *args, **kwargs, &block)
    end

    def respond_to_missing?(name, _include_private = false)
      @open_search_client.respond_to?(name) || super
    end

    def inspect_payload(name, args, kwargs)
      Chewy.config.before_es_request_filter&.call(name, args, kwargs)
    end
  end
end
