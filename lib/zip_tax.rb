require "zip_tax/version"
require 'net/http'
require 'json'

module ZipTax
  def self.key=(key)
    @key = key
  end

  def self.key
    @key
  end

  def self.host
    'api.zip-tax.com'
  end

  def self.request(zip)
    raise ArgumentError, "Zip-Tax API key must be set using ZipTax.key=" if key.nil?
    path = "/request/v20?key=#{key}&postalcode=#{zip}"
    response = JSON.parse(Net::HTTP.get(host, path))
    raise StandardError, "Zip-Tax returned an empty response using the zip code #{zip}" if response["results"].empty?
    return response
  end

  def self.rate(zip, state = nil)
    response = request(zip)
    state.nil? || state.upcase == response['results'][0]['geoState'] ? response['results'][0]['taxSales'] : 0.0
  end

  def self.info(zip)
    response = request(zip)
    return response['results'][0]
  end
end
