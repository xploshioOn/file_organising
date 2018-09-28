require 'rails_helper'

RSpec.describe DocumentTag, type: :model do
  # Association test
  it { should belong_to(:document) }
  it { should belong_to(:tag) }

  # Validation tests
  it { should validate_presence_of(:tag_id) }
end
