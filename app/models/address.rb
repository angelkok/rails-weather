class Address
    attr_accessor :street, :city, :state, :zip
    attr_reader :errors

  def initialize(street:, city:, state:, zip:)
    @street = street
    @city = city
    @state = state
    @zip = zip
    @errors = []
  end

  def valid?
    @errors = []
    validate_street
    validate_city
    validate_state
    validate_zip
    errors.empty?
  end

  def validate_street
    if street.nil? || street.empty?
      @errors << "Street is required."
    end
  end

  def validate_city
    if city.nil? || city.empty?
      @errors << "City is required."
    end
  end

  def validate_state
    if state.nil? || state.length != 2
      @errors << "State must be 2 characters long."
    end
  end

  def validate_zip
    if zip.nil? || !zip.match?(/\A\d{5}(-\d{4})?\z/)
      @errors << "Zip must be a valid US zip code."
    end
  end

end