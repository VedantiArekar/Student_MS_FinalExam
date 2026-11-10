class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students do |t|
      t.string  :full_name, null: false
      t.string  :email,     null: false
      t.string  :course,    null: false
      t.integer :semester,  null: false

      # created_at and updated_at (filled in automatically by Rails)
      t.timestamps
    end

    # The database itself also guarantees that an email is used only once.
    add_index :students, :email, unique: true
  end
end
