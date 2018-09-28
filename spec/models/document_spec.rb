require 'rails_helper'

RSpec.describe Document, type: :model do
  # Association test
  it { should have_many(:tags) }
  it { should have_many(:document_tags).dependent(:destroy) }

  # Validation tests
  it { should validate_presence_of(:name) }
end
