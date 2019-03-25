require 'spec_helper'

RSpec.describe Emittance::Sidekiq do
  it 'has a version number' do
    expect(Emittance::Sidekiq::VERSION).not_to be nil
  end
end
