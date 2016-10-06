class FullInvoice
  attr_accessor :employee_info, :customer_info, :product_name,
  :sale_date, :sale_amount, :units_sold, :invoice_no,
  :invoice_frequency

  def initialize(full_invoice)
    @employee_info = full_invoice[0]
    @customer_info = full_invoice[1]
    @product_name = full_invoice[2]
    @sale_date = full_invoice[3]
    @sale_amount = full_invoice[4]
    @units_sold = full_invoice[5]
    @invoice_no = full_invoice[6]
    @invoice_frequency = full_invoice[7]
  end

  def employee_name
    @employee_info.split(' (')[0]
  end

  def employee_email
    @employee_info.split(' (')[1].chop
  end

  def customer_name
    @customer_info.split(' (')[0]
  end

  def customer_account_no
    @customer_info.split(' (')[1].chop
  end
end
