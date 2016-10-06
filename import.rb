# Use this file to import the sales information into the
# the database.

require "pg"
require "csv"
require "pry"
require_relative "models/invoice"

# system "psql korning < schema.sql"

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

def employee_check(new_ename, new_email)
  db_connection do |conn|
    db_employee = conn.exec("SELECT name FROM employee;").to_a
    employee_array = db_employee.map { |ehash| ehash["name"] }

    unless employee_array.include?(new_ename)
      conn.exec_params("INSERT INTO employee (name, email) VALUES ($1, $2);",
      [new_ename, new_email])
    end

    conn.exec("SELECT id FROM employee WHERE employee.name =
    '#{new_ename}';").to_a[0]["id"].to_i
  end
end

def customer_check(new_cname, new_account_no)
  db_connection do |conn|
    db_customer = conn.exec("SELECT account_no FROM customer;").to_a
    customer_array = db_customer.map { |chash| chash["account_no"] }

    unless customer_array.include?(new_account_no)
      conn.exec_params("INSERT INTO customer (name, account_no)
      VALUES ($1, $2);", [new_cname, new_account_no])
    end

    conn.exec("SELECT id FROM customer WHERE customer.account_no =
    '#{new_account_no}';").to_a[0]["id"].to_i
  end
end

def product_check(new_pname)
  db_connection do |conn|
    db_product = conn.exec("SELECT name FROM product;").to_a
    product_array = db_product.map { |phash| phash["name"] }

    unless product_array.include?(new_pname)
      conn.exec_params("INSERT INTO product (name) VALUES ($1);", [new_pname])
    end

    conn.exec("SELECT id FROM product WHERE product.name =
    '#{new_pname}';").to_a[0]["id"].to_i
  end
end

def frequency_check(new_frequency)
  db_connection do |conn|
    db_frequency = conn.exec("SELECT frequency FROM frequency;").to_a
    frequency_array = db_frequency.map { |fhash| fhash["frequency"] }

    unless frequency_array.include?(new_frequency)
      conn.exec_params("INSERT INTO frequency (frequency) VALUES ($1);",
      [new_frequency])
    end

    conn.exec("SELECT id FROM frequency WHERE frequency.frequency =
    '#{new_frequency}';").to_a[0]["id"].to_i
  end
end

def invoice_check(new_invoice_no)
  db_connection do |conn|
    db_invoice = conn.exec("SELECT invoice_no FROM invoice;").to_a
    invoice_array = db_invoice.map { |ihash| ihash["invoice_no"] }

    invoice_array.include?(new_invoice_no)
  end
end

@full_invoices = CSV.foreach('sales.csv', headers: true)

db_connection do |conn|
  @full_invoices.each do |full_invoice|
    @new_invoice = FullInvoice.new(full_invoice)

    @employee_id = employee_check(@new_invoice.employee_name,
      @new_invoice.employee_email
    )
    @customer_id = customer_check(@new_invoice.customer_name,
      @new_invoice.customer_account_no
    )
    @product_id = product_check(@new_invoice.product_name)
    @frequency_id = frequency_check(@new_invoice.invoice_frequency)

    unless invoice_check(@new_invoice.invoice_no) == true
      conn.exec_params("INSERT INTO invoice (
        employee_id,
        customer_id,
        product_id,
        sale_date,
        sale_amount,
        units_sold,
        invoice_no,
        invoice_frequency
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8);",
      [@employee_id,
        @customer_id,
        @product_id,
        @new_invoice.sale_date,
        @new_invoice.sale_amount,
        @new_invoice.units_sold,
        @new_invoice.invoice_no,
        @frequency_id
      ])
    end
  end
end
