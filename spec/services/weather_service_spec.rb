require 'rails_helper'
require 'webmock/rspec'
require 'pry'

RSpec.describe WeatherService, type: :model do

  let(:address_data) do {
        street: "1 Apple Park Way",
        city: "Cupertino",
        state: "CA",
        zip: "95014"
    }
  end

  describe '#fetch' do
    let(:address)   { Address.new(**address_data) }
    let(:weather_data) {JSON.parse(File.read(Rails.root.join('spec/fixtures/forecast_response.json')))}

    context 'with a valid address' do
      before do
        # Mock the successful API response
        stub_request(:get, /api.openweathermap.org/)
          .to_return(
            status: 200,
            body: weather_data.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns a weather data' do
        weather = WeatherService.new(address)
        result = weather.fetch
        expect(result["cod"]).to eq "200"
      end
    end

    context 'with an invalid address' do
      let(:address) { Address.new(**address_data.merge(zip: nil)) }
      let(:expected_message) { "city not found" }

      before do

        # Mock the 404 API response
        stub_request(:get, /api.openweathermap.org/)
          .to_return(
            status: 404,
            body: {
              message: expected_message,
              cod: 404
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns a 404 response' do
        weather = WeatherService.new(address)
        result = weather.fetch
        expect(result).to eq nil
        expect(weather.errors).to eq [expected_message]
      end
    end

  end

  describe '#extract_with_highs_and_lows' do
    let(:address)   { Address.new(**address_data) }
    let(:weather_data) {JSON.parse(File.read(Rails.root.join('spec/fixtures/forecast_response.json')))}

    context 'given an openweather forecast response' do
      before do
        # Mock the successful API response
        stub_request(:get, /api.openweathermap.org/)
          .to_return(
            status: 200,
            body: weather_data.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'includes highs and lows for 6 (day-of + 5) days' do
        weather = WeatherService.new(address)
        data = weather.fetch
        forecast = weather.extract_with_highs_and_lows(data)

        expect(forecast.keys.count).to eq 6
        forecast.each do |key, day|
          expect(day.keys).to eq [:low, :high, :weather, :wind]
        end
      end
    end

  end

end
