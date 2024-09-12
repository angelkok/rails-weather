class WeatherController < ApplicationController
    def index
    end

    def show
        address_data = {
            street: params[:street],
            city: params[:city],
            state: params[:state],
            zip: params[:zip],
        }
        address = Address.new(**address_data)

        if address.zip
            @cached = true
            @weather_data = Rails.cache.read("weather_#{address.zip}")
            weather = WeatherService.new(address)
            
            unless @weather_data
                @cached = false
                @weather_data = weather.fetch
                Rails.cache.write("weather_#{address.zip}", @weather_data, expires_in: 30.minutes)
            end
            
            if @weather_data
                @address = address
                @highs_and_lows = weather.extract_with_highs_and_lows(@weather_data)
                render :show
            else
                flash[:error] = "Weather data could not be retrieved."
                redirect_to root_path
            end
        else
            flash[:error] = "Invalid address. Please try again."
            redirect_to root_path
        end
    end

    private

end