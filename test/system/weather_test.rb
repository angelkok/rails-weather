require "application_system_test_case"
require "pry"
require "webdrivers"
require 'minitest/mock'

class WeatherTest < ApplicationSystemTestCase
  setup do
    @weather_data = JSON.parse(File.read(Rails.root.join('spec/fixtures/forecast_response.json')))
    @high_low_data = JSON.parse(File.read(Rails.root.join('spec/fixtures/high_and_low_data.json')))
    @high_and_low_data = {}
    @high_low_data.each do |k, val|
      @high_and_low_data[k] = {
        weather: val['weather'],
        wind: val['wind'],
        low: val['low'],
        high: val['high'],
      }
    end

  end

  test "visiting the index" do
    visit root_url
  
    assert_selector "h1", text: "Weather"
  end

  test "submitting the weather form" do
    weather_service_mock = Minitest::Mock.new
    weather_service_mock.expect :fetch, @weather_data
    weather_service_mock.expect :extract_with_highs_and_lows, @high_and_low_data, [@weather_data]

    WeatherService.stub :new, weather_service_mock do
      visit root_url

      fill_in 'Street', with: '1 Apple Park Way'
      fill_in 'City', with: 'Cupertino'
      fill_in 'State', with: 'CA'
      fill_in 'Zip', with: '95014'

      click_on 'Get Weather'

      assert_current_path weather_show_path

      @high_and_low_data.each do |date, temps|
        assert_text date
        assert_text "#{temps[:weather].first["description"]}"
        assert_text "#{temps[:wind]["speed"]}"
        assert_text "#{temps[:low]}"
        assert_text "#{temps[:high]}"
      end
    end

  end
end
