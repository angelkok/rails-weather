class WeatherService
    include HTTParty
    attr_accessor :address
    attr_reader :errors, :parsed_response

    def initialize(address)
        @address = address
        @errors = []
    end

    def fetch()
        zip = @address.zip
        api_key = ENV['OPENWEATHER_API_KEY']
        # 5 day forecast: https://openweathermap.org/forecast5
        url = "https://api.openweathermap.org/data/2.5/forecast?zip=#{zip},us&appid=#{api_key}"
        response = HTTParty.get(url)

        if response.success?
            @parsed_response = response.parsed_response
            # extract_with_highs_and_lows(parsed_response)
        else
            @errors << response["message"]
            nil
        end
    end

	def extract_with_highs_and_lows(weather_data)
		forecast = {}

		weather_data['list'].each do |entry|
			date = Date.parse(entry['dt_txt']).to_s
			temp_min = entry['main']['temp_min']
			temp_max = entry['main']['temp_max']
            weather  = entry['weather']
            wind     = entry['wind']

			if forecast[date]
                forecast[date][:weather] = weather
                forecast[date][:wind]    = wind
				forecast[date][:low]     = [forecast[date][:low], temp_min].min
				forecast[date][:high]    = [forecast[date][:high], temp_max].max
			else
				forecast[date] = {
                    low: temp_min,
                    high: temp_max,
                    weather: weather,
                    wind: wind
                }
			end
		end

		forecast
	end
end