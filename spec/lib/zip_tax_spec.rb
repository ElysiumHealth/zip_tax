# frozen_string_literal: true

require 'spec_helper'

describe ZipTax do
  describe '.request' do
    subject(:request) do
      described_class.request(zip)
    end

    let(:zip) { '10801' }

    context 'when a key is not set' do
      before do
        allow(described_class).to receive(:key).and_return(nil)
      end

      it 'raises an error' do
        expect { request }.to raise_error(
          ArgumentError,
          'Zip-Tax API key must be set using ZipTax.key='
        )
      end
    end

    context 'when a key is set' do
      let(:key) { '1234' }

      let(:fake_response_body) do
        File.read('spec/support/fixtures/valid-zip-tax-response.json')
      end

      before do
        allow(described_class).to receive(:key).and_return(key)

        stub_request(:get, 'api.zip-tax.com/request/v20')
          .with(query: { key: key, postalcode: zip })
          .to_return(
            status: 200,
            body: fake_response_body,
            headers: {}
          )
      end

      it { is_expected.to eq JSON.parse(fake_response_body) }

      it 'makes a request to zip tax' do
        request
        expect(a_request(:get, 'http://api.zip-tax.com/request/v20?key=1234&postalcode=10801'))
          .to have_been_made
      end
    end
  end

  describe '.rate', 'without a state' do
    subject(:rate) do
      described_class.rate(zip)
    end

    let(:zip) { '10801' }

    before do
      allow(described_class).to receive(:request).and_return(
        JSON.parse(File.read('spec/support/fixtures/valid-zip-tax-response.json'))
      )
    end

    it 'makes a request for the zip' do
      rate
      expect(described_class).to have_received(:request).with(zip)
    end

    it { is_expected.to eq 0.083750002086163 }
  end

  describe '.rate', 'with a state' do
    subject(:rate) do
      described_class.rate(zip, state)
    end

    let(:zip) { '10801' }

    before do
      allow(described_class).to receive(:request).and_return(
        JSON.parse(File.read('spec/support/fixtures/valid-zip-tax-response.json'))
      )
    end

    context 'when state matches response' do
      let(:state) { 'nY' }

      it 'makes a request for the zip' do
        rate
        expect(described_class).to have_received(:request).with(zip)
      end

      it { is_expected.to eq 0.083750002086163 }
    end

    context 'when state does not match response' do
      let(:state) { 'CA' }

      it 'makes a request for the zip' do
        rate
        expect(described_class).to have_received(:request).with(zip)
      end

      it { is_expected.to eq 0.0 }
    end
  end

  describe '.info' do
    subject(:rate) do
      described_class.info(zip)
    end

    let(:zip) { '10801' }

    let(:response_hash) do
      JSON.parse(File.read('spec/support/fixtures/valid-zip-tax-response.json'))
    end

    before do
      allow(described_class).to receive(:request).and_return(response_hash)
    end

    it 'makes a request for the zip' do
      rate
      expect(described_class).to have_received(:request).with(zip)
    end

    it { is_expected.to eq response_hash.dig('results', 0) }
  end
end
