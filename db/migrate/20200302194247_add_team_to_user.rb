class AddTeamToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :team, :string, :null => true
  end
end
