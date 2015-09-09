class AddCallDateColumnToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :call_date, :date
  end
end
