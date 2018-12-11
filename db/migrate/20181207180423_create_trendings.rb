class CreateTrendings < ActiveRecord::Migration[5.2]
  def change
    create_table :trendings do |t|
      t.jsonb :hashtags

      t.timestamps
    end
  end
end
