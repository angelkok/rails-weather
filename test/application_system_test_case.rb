require "test_helper"

WINDOWS_HOST = `cat /etc/resolv.conf | grep nameserver | awk '{print $2}'`.strip
CHROMEDRIVER_PORT = '40000'
CHROMEDRIVER_URL = "http://#{WINDOWS_HOST}:#{CHROMEDRIVER_PORT}/"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium_remote_chrome

  Capybara.register_driver :selenium_remote_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless') # use --start-maximized to observe tests
                                       # other options: --no-sandbox, --disable-gpu, etc.

    Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: CHROMEDRIVER_URL,
      options: options
    )
  end

  Capybara.configure do |config|
    config.server_host = 'localhost'
    config.server_port = '3000'
  end

  driven_by :selenium_remote_chrome
end
