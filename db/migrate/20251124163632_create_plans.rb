class CreatePlans < ActiveRecord::Migration[7.1]
  def change
    create_table :plans do |t|
      t.string :title
      t.string :theme
      t.string :pricing
      t.references :user, null: false, foreign_key: true
      t.text :roadmap
      t.integer :number_persons
      t.string :city
      t.string :context
      t.integer :lenght_event

      t.timestamps
    end
  end
end
