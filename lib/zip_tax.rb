# frozen_string_literal: true

require "zip_tax/version"
require 'net/http'
require 'json'

module ZipTax
  class << self
    attr_accessor :key

    def host
      'api.zip-tax.com'
    end

    def request(zip)
      raise ArgumentError, "Zip-Tax API key must be set using ZipTax.key=" if key.nil?
      path = "/request/v20?key=#{key}&postalcode=#{zip}"
      response = JSON.parse(Net::HTTP.get(host, path))
      raise StandardError, "Zip-Tax returned an empty response using the zip code #{zip}" if response["results"].empty?
      response
    end

    def rate(zip, state = nil)
      response = request(zip)

      if state.nil? || state.upcase == response.dig('results', 0, 'geoState')
        response.dig('results', 0, 'taxSales')
      else
        0.0
      end
    end

    def info(zip)
      request(zip).dig('results', 0)
    end
  end
end
