class CreateDocumentTags < ActiveRecord::Migration[5.2]
  def change
    create_table :document_tags do |t|
      t.references :document, foreign_key: true
      t.references :tag, foreign_key: true

      t.timestamps
    end
  end
end
