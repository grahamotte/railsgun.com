class AddUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :uid, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.timestamp :confirmed_at, null: true
    end

    add_index :users, :email, unique: true
  end
end
