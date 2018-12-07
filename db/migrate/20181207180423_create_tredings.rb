class CreateTredings < ActiveRecord::Migration[5.2]
  def change
    create_table :tredings do |t|
      t.jsonb :hashtags

      t.timestamps
    end
  end
end
