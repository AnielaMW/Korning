class FullInvoice
  attr_accessor :employee_info, :customer_info, :p_name,
  :sale_date, :sale_amount, :units_sold, :invoice_no,
  :invoice_frequency

  def initialize(full_invoice)
    @employee_info = full_invoice[0]
    @customer_info = full_invoice[1]
    @p_name = full_invoice[2]
    @sale_date = full_invoice[3]
    @sale_amount = full_invoice[4]
    @units_sold = full_invoice[5]
    @invoice_no = full_invoice[6]
    @invoice_frequency = full_invoice[7]
  end

  def e_name
    @employee_info.split(' (')[0]
  end

  def email
    @employee_info.split(' (')[1].chop
  end

  def c_name
    @customer_info.split(' (')[0]
  end

  def account_no
    @customer_info.split(' (')[1].chop
  end
end
