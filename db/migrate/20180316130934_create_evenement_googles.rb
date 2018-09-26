class CreateEvenementGoogles < ActiveRecord::Migration[5.1]
  def change
    create_table :evenement_googles do |t|
      t.string :site
      t.string :heure
      t.string :titre
      t.string :date
      t.string :lieu
      t.string :map
      t.string :description

      t.timestamps
    end
  end
end
