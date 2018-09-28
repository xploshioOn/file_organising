class Document < ApplicationRecord
  validate :tag_count_validation

  has_many :document_tags, dependent: :destroy
  has_many :tags, through: :document_tags

  before_save :set_uuid

  scope :join_tags, ->(tags) { joins(:tags).where(tags: {name: tags}) }
  scope :with_all_specified_tags, ->(tags) { join_tags(tags).group('documents.id').having('count(*) = ?', tags.size) }
  scope :without_tags, ->(tags) { where.not(id: Document.join_tags(tags).pluck(:id)) }
  scope :paginate, -> (page) { limit(10).offset((page-1)*10) }

  validates :name, presence: true

  accepts_nested_attributes_for :tags
  accepts_nested_attributes_for :document_tags

  private

  # we set the uuid for the file automatically
  def set_uuid
    self.uuid = SecureRandom.uuid
  end

  # we don't let a user create a file without a tag
  # because the only way to search for a file is
  # by tag name
  def tag_count_validation
    if (self.tags.size < 1) && (self.document_tags.size < 1)
      errors.add(:base, "You have to specify at least one tag!")
    end
  end

end
