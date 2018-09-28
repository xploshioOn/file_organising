require 'rails_helper'

RSpec.describe Tag, type: :model do
  # Association test
  it { should have_many(:documents) }
  it { should have_many(:document_tags).dependent(:destroy) }

  # Validation tests
  it { should validate_presence_of(:name) }
end
