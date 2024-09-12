# spec/models/address_spec.rb
require 'rails_helper'
require 'pry'

RSpec.describe Address, type: :model do

  let(:address_data) do {
        street: "1 Apple Park Way",
        city: "Cupertino",
        state: "CA",
        zip: "95014"
    }
  end

  let(:messages) do {
        street: "Street is required.",
        city: "City is required.",
        state: "State must be 2 characters long.",
        zip: "Zip must be a valid US zip code."
    }
  end

  describe '#valid?' do
    context 'a valid address' do
      it 'is valid' do
        address = Address.new(**address_data)
        expect(address.valid?).to be true
        expect(address.errors).to be_empty
      end
    end

    context 'a missing street' do
      it 'is invalid if street is empty' do
        address = Address.new(**address_data.merge(street: nil))
        expect(address.valid?).to be false
        expect(address.errors).to include(messages[:street])
      end
    end

    context 'a city missing' do
      it 'is invalid if city is empty' do
        address = Address.new(**address_data.merge(city: nil))
        expect(address.valid?).to be false
        expect(address.errors).to include(messages[:city])
      end
    end

    context 'a state is missing' do
      it 'is invalid if state is invalid' do
        address = Address.new(**address_data.merge(state: nil))
        expect(address.valid?).to be false
        expect(address.errors).to include(messages[:state])
      end
    end

    context 'a zip is invalid' do
      it 'is invalid if zip does not match 12345 or 12345-1234 format' do
        address = Address.new(**address_data.merge(zip: "123"))
        expect(address.valid?).to be false
        expect(address.errors).to include(messages[:zip])
      end
    end

  end

end
