class SendMailMailer < ApplicationMailer
  default from: 'sistemasfgfc@gmail.com'
  layout 'mailer'

  def send_email(email, name, subject, title, content)
    @email_name = name
    @content = content
    @title = title
    mail(to: email, subject: subject)
  end

  def send_mail_credit(email, name,subject, title,file, content)
    @email_name = name
    @content = content
    @title = title
    attachments["document.pdf"] = File.read("#{file}", mode: "rb") {|io| a = a + io.read}
    mail(to: email, subject: subject)
  end

  def send_mail_committee(email, name, subject, title, content)
    @email_name = name
    @content = content
    @title = title
    mail(to: email, subject: subject)
  end

  def committee(email, name, subject, title, content)
    @email_name = name
    @content = content
    @title = title
    mail(to: email, subject: subject)
  end

  def analyst1(email, name, subject, title, content)
    @email_name = name
    @content = content
    @title = title
    mail(to: email, subject: subject)
  end  
  
  def customer_nip(email, name, subject, title, content)
    @email_name = name
    @content = content
    @title = title
    mail(to: email, subject: subject)
  end

  def send_email_account_status(email, name, subject, title, content)
    # wb = xlsx_package.workbook
    # wb.styles do |s|
    #     header_cell = s.add_style bg_color: "EFEFEF", 
    #         fg_color: "00", 
    #         sz: 14,
    #         alignment: { horizontal: :center }
    #     wb.add_worksheet(name: "Estado de cuenta") do |sheet|
    #         sheet.add_row ["Número de pago", "Monto", "Deuda actual", "Deuda restante", "Fecha de pago", "Estatus"], 
    #             :style => [header_cell, header_cell, header_cell, header_cell]
    #         content.each do |t|
    #             sheet.add_row [t[:pay_number], 
    #                 t[:payment], 
    #                 t[:current_debt], 
    #                 t[:remaining_debt],
    #                 t[:payment_date],
    #                 t[:status]]
    #         end
    #     end
    # end
    # attachments["estado de cuenta.xlsx"] = wb
    @email_name = name
    @content = content
    @title = title
    mail(to: email, subject: subject)
  end

  def send_email_request(email, name, subject, supplier, company, invoices, signatories, request, create_user, max_days, limit_days, year_base_days, final_rate)
    @create_user = create_user
    @email_name = name
    @invoices = invoices
    @signatories = signatories
    @supplier = supplier
    @company = company
    @request = request
    @max_days = max_days
    @limit_days = limit_days
    @year_base_days = year_base_days
    @final_rate = final_rate
    mail(to: email, subject: subject)
  end

  def send_email_funding_request(email, name, subject, funding_resume, funding_detail)
    @email_name = name
    @funding_resume = funding_resume
    @total_invoices_mailer = 0
    @total_importe_mailer = 0
    funding_resume.each do |funding_resume_row|          
      @total_invoices_mailer = @total_invoices_mailer + funding_resume_row['sum_invoices'].to_i
      @total_importe_mailer = @total_importe_mailer + funding_resume_row['funding_invoice_sum'].to_f
    end
    @funding_detail = funding_detail
    mail(to: email, subject: subject)
  end
end
