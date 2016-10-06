# Use this file to import the sales information into the
# the database.

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

def duplicate_entry?(sub_info)
  db_connection do |conn|
    db_find = conn.exec("SELECT #{sub_info[:column_lable]}
    FROM #{sub_info[:table]};").to_a
    array = db_find.map { |find_hash| find_hash["#{sub_info[:column_lable]}"] }
    array.include?(sub_info[:identifier])
  end
end

def insert_sub_record(sub_info)
  db_connection do |conn|
    unless duplicate_entry?(sub_info)
      conn.exec_params("INSERT INTO #{sub_info[:table]}
      (#{sub_info[:columns]})
      VALUES (#{sub_info[:values]});", sub_info[:hash])
    end
  end
end

def find_id(table, column, identifier)
  db_connection do |conn|
    conn.exec("SELECT id FROM #{table} WHERE #{column} =
    '#{identifier}';").to_a[0]["id"].to_i
  end
end

def employee_check(new_ename, new_email)
  e_info = {column_lable: "name",
    table: "employee",
    identifier: new_ename,
    columns: "name, email",
    values: "$1, $2",
    hash: [new_ename, new_email]
  }
  insert_sub_record(e_info)
  find_id("employee", "employee.name", new_ename)
end

def customer_check(new_cname, new_account_no)
  c_info = {column_lable: "account_no",
    table: "customer",
    identifier: new_account_no,
    columns: "name, account_no",
    values: "$1, $2",
    hash: [new_cname, new_account_no]
  }
  insert_sub_record(c_info)
  find_id("customer", "customer.account_no", new_account_no)
end

def product_check(new_pname)
  p_info = {column_lable: "name",
    table: "product",
    identifier: new_pname,
    columns: "name",
    values: "$1",
    hash: [new_pname]
  }
  insert_sub_record(p_info)
  find_id("product", "product.name", new_pname)
end

def frequency_check(new_frequency)
  f_info = {column_lable: "frequency",
    table: "frequency",
    identifier: new_frequency,
    columns: "frequency",
    values: "$1",
    hash: [new_frequency]
  }
  insert_sub_record(f_info)
  find_id("frequency", "frequency.frequency", new_frequency)
end

def invoice_check(new_invoice_no)
  i_info = {column_lable: "invoice_no",
    table: "invoice",
    identifier: new_invoice_no,
  }
  duplicate_entry?(i_info)
end

@full_invoices = CSV.foreach('sales.csv', headers: true)

db_connection do |conn|
  @full_invoices.each do |full_invoice|
    @new = FullInvoice.new(full_invoice)

    @employee_id = employee_check(@new.e_name, @new.email)
    @customer_id = customer_check(@new.c_name, @new.account_no)
    @product_id = product_check(@new.p_name)
    @frequency_id = frequency_check(@new.invoice_frequency)

    unless invoice_check(@new.invoice_no) == true
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
        @new.sale_date,
        @new.sale_amount,
        @new.units_sold,
        @new.invoice_no,
        @frequency_id
      ])
    end
  end
end
