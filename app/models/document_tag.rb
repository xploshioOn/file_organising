class DocumentTag < ApplicationRecord
  belongs_to :document
  belongs_to :tag

  validates_presence_of :tag_id
end
