class Tag < ApplicationRecord

  has_many :document_tags, dependent: :destroy
  has_many :documents, through: :document_tags

  scope :by_documents, -> (documents) { joins(:documents).where(documents: {id: documents}) }
  scope :exclude, -> (tags) { where.not(name: tags) }
  scope :count_by_name, -> { group(:name).count }

  validates :name, presence: true, uniqueness: true, format: {without: /[\s+-]/, message: "Invalid characters (+, -, white space)"}

end
