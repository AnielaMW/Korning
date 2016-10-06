# Use this file to import the sales information into the
# the database.

#  Clancy Wiggum (clancy.wiggum@korning.com),Motorola (MT928534),Chimp Glass,11/13/2012,$795219.34,956306,82547,Monthly

require "pg"
require "csv"
require "pry"
require_relative "models/invoice"

system "psql korning < schema.sql"

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

@full_invoices = CSV.foreach('sales.csv', headers: true)

@full_invoices.each do |full_invoice|
  new_invoice = FullInvoice.new(full_invoice)
end
