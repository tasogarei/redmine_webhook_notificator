class CreateWebhooks < ActiveRecord::Migration[5.2]
  def change
    create_table :webhooks do |t|
      t.integer :project_id, null: false
      t.string :url, null: false
    end
  end
end
