# frozen_string_literal: true

class Api::V1::ReportsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::ReportsApi

  before_action :authenticate

  def role_not_options
    @options = Option.options_by_not_role(params[:role])
    render 'api/v1/reports/show_not_options'
  end

  def user_not_options
    @options = Option.options_by_not_user(params[:user])
    render 'api/v1/reports/show_not_options'
  end

  def daily_operations
    @query = "SELECT ab.*
    FROM((SELECT req.folio folio_solicitud, inv.invoice_folio folio_factura, sup.business_name proveedor, com.business_name deudor, req.used_date fecha_operacion, inv.due_date fecha_vencimiento, inv.due_date - req.used_date dias, TO_CHAR(rei.total_used, 'FM9,999,999,990.00') importe, inv.currency moneda, rei.ext_rate tasa_interbancaria, rei.int_rate sobre_tasa, rei.total_rate tasa_factor, TO_CHAR(rei.interests, 'FM9,999,999,990.00') intereses_factor, TO_CHAR(rei.total_used - rei.interests, 'FM9,999,999,990.00') importe_sin_intereses, TO_CHAR(req.total_used - req.interests, 'FM9,999,999,990.00') por_disposicion_solicitud, req.folio id_solicitud
      FROM invoices inv, requests req, request_invoices rei, suppliers sup, companies com
      WHERE inv.id = rei.invoice_id
      AND req.id = rei.request_id
      AND inv.supplier_id = sup.id
      AND inv.company_id = com.id
      AND inv.status = 'PENDIENTE'
      AND req.status = 'APROBADA'
      AND req.used_date = ':used_date'
       ) UNION ALL
       (SELECT null, inv.invoice_folio folio_factura, sup.business_name proveedor, com.business_name deudor, inv.used_date fecha_operacion, inv.due_date fecha_vencimiento, inv.due_date - inv.used_date dias, TO_CHAR(inv.total, 'FM9,999,999,990.00') importe, inv.currency moneda, '0.00' tasa_interbancaria, '0.00' sobre_tasa, '0.00' tasa_factor, '0.00' intereses_factor, TO_CHAR(inv.total, 'FM9,999,999,990.00') importe_sin_intereses, TO_CHAR(inv.total, 'FM9,999,999,990.00') por_dispocision_solicitud, null id_solicitud
      FROM invoices inv, suppliers sup, companies com
      WHERE inv.supplier_id = sup.id
      AND inv.company_id = com.id
      AND inv.id not in (SELECT invoice_id from request_invoices)
      AND inv.status IN ('PENDIENTE', 'PENDIENTE LIQUIDADA')
      AND inv.used_date = ':used_date'
       ) UNION ALL
       (SELECT req.folio folio_solicitud, inv.invoice_folio folio_factura, sup.business_name proveedor, com.business_name deudor, inv.used_date fecha_operacion, inv.due_date fecha_vencimiento, inv.due_date - inv.used_date dias, TO_CHAR(inv.total - inv.total_used, 'FM9,999,999,990.00') importe, inv.currency moneda, '0.00' tasa_interbancaria, '0.00' sobre_tasa, '0.00' tasa_factor, '0.00' intereses_factor, TO_CHAR(inv.total - inv.total_used, 'FM9,999,999,990.00') importe_sin_intereses, TO_CHAR(inv.total - inv.total_used, 'FM9,999,999,990.00') por_dispocision_solicitud, 'Saldo pendiente de solicitud: '||req.folio id_solicitud
      FROM invoices inv, requests req, request_invoices rei, suppliers sup, companies com
      WHERE inv.id = rei.invoice_id
      AND req.id = rei.request_id
      AND inv.supplier_id = sup.id
      AND inv.company_id = com.id
      AND inv.status IN ('CON SALDO', 'CON SALDO LIQUIDADA')
      AND inv.used_date = ':used_date'
       )
      ) ab;"
    @query = @query.gsub ':used_date', params[:used_date].to_s
    @daily_operations = execute_statement(@query)
    # @daily_operations.type_map = PG::TypeMapByColumn.new [nil, PG::TextDecoder::JSON.new]
    # render 'api/v1/reports/show_daily_operations'
    render json: @daily_operations
  end

  def layout_banorte
    @query_supplier = "SELECT ':pr_folio' payment_report_folio, ' '''||'04' oper, ab.*
    FROM((SELECT chr(9)||con.extra1 clave_id,
      (select chr(9)||' '''||value from general_parameters WHERE KEY = 'CUENTA_ORIGEN_BANORTE') cuenta_origen, 
        CASE
          WHEN con.bank = 'BANORTE'
          THEN chr(9)||' '''||con.account_number
          ELSE chr(9)||' '''||con.clabe
        END cuenta_destino,
        chr(9)||TO_CHAR(cuc.total_requested, 'FM9999999990.00') importe,
        chr(9)||cuc.credit_number referencia,
        chr(9)||'DISPERSION CREDITO: ' || cuc.credit_number descripcion,
        (select chr(9)||value from general_parameters WHERE KEY = 'RFC_FINANCIERA') rfc_ordenante,
        chr(9)||0 iva,
        chr(9)||to_char(cuc.start_date,'DDMMYYYY') fecha_aplicacion,
        (select chr(9)||value from general_parameters WHERE KEY = 'NOMBRE_FINANCIERA') instruccion_pago,
        chr(9)||0 clave_tipo_cambio
        FROM customer_credits cuc, customers cus, companies com, contributors con
        WHERE cuc.customer_id = cus.id
        AND cus.company_id = com.id
        AND cus.contributor_id = con.id
        AND cuc.status = 'VA'
                  AND cuc.start_date = ':start_date'
                ) 
                ) ab;"
    @query = @query_supplier
    t = Time.now
    @folio = t.to_i
    @pr_folio = "PR#{@folio}"
    @query = @query.gsub ':start_date', params[:start_date].to_s
    @query = @query.gsub ':pr_folio', @pr_folio
    @layout_banorte = execute_statement(@query)
    unless @layout_banorte.blank?
      @layout_banorte.each do |report_row|
          @customer_credit = CustomerCredit.where(id: report_row['id_customer_credit'].to_s)
          @customer_credit.update(extra1: report_row['payment_report_folio'].to_s)      
      end
    end
    render json: @layout_banorte
  end

  def layout_bancrea
    @query_resumen_supplier = "SELECT ':pr_folio' payment_report_folio, to_char(to_date(':used_date','YYYY-MM-DD'),'DDMMYYYY') fecha_registro, (select value from general_parameters WHERE KEY = 'CUENTA_ORIGEN_BANCREA') cuenta_origen, sum(TO_NUMBER(ab.importe, 'FM9999999990.00')) importe_total, count(ab.importe) total_registros
                      FROM((SELECT to_char(req.used_date,'DDMMYYYY') fecha_registro, to_char(req.used_date,'DDMMYYYY') fecha_aplicacion,
                        CASE
                        WHEN con.bank = 'BANCREA'
                          THEN 1
                        ELSE 2
                        END tipo_cuenta_abono,
                        CASE
                        WHEN con.bank = 'BANCREA'
                          THEN con.account_number
                        ELSE con.clabe
                        END cuenta_abono,
                        TO_CHAR(rei.total_used - rei.interests, 'FM9999999990.00') importe,
                        inv.invoice_folio referencia,
                        'PAGO ANTICIPADO DE FACTURAS A: ' || sup.business_name descripcion,
                        0 iva
                        FROM invoices inv, requests req, request_invoices rei, suppliers sup, companies com, contributors con
                        WHERE inv.id = rei.invoice_id
                        AND req.id = rei.request_id
                        AND inv.supplier_id = sup.id
                        AND inv.company_id = com.id
                        AND sup.contributor_id = con.id
                        AND inv.status = 'PENDIENTE'
                        AND req.status = 'APROBADA'
                        AND req.used_date = ':used_date'
                        ) UNION ALL
                        (SELECT to_char(inv.used_date,'DDMMYYYY') fecha_registro, to_char(inv.used_date,'DDMMYYYY') fecha_aplicacion,
                        CASE
                        WHEN con.bank = 'BANCREA'
                          THEN 1
                        ELSE 2
                        END tipo_cuenta_abono,
                        CASE
                        WHEN con.bank = 'BANCREA'
                          THEN con.account_number
                        ELSE con.clabe
                        END cuenta_abono,
                        TO_CHAR(inv.total, 'FM9999999990.00') importe,
                        inv.invoice_folio referencia,
                        'PAGO DE FACTURAS A: ' || sup.business_name,
                        0 iva
                        FROM invoices inv, suppliers sup, companies com, contributors con
                        WHERE inv.supplier_id = sup.id
                        AND inv.company_id = com.id
                        AND sup.contributor_id = con.id
                        AND inv.id not in (SELECT invoice_id from request_invoices)
                        AND inv.status IN ('PENDIENTE', 'PENDIENTE LIQUIDADA')
                        AND inv.used_date = ':used_date'
                        ) UNION ALL
                        (SELECT to_char(inv.used_date,'DDMMYYYY') fecha_registro, to_char(inv.used_date,'DDMMYYYY') fecha_aplicacion,
                        CASE
                        WHEN con.bank = 'BANCREA'
                          THEN 1
                        ELSE 2
                        END tipo_cuenta_abono,
                        CASE
                        WHEN con.bank = 'BANCREA'
                          THEN con.account_number
                        ELSE con.clabe
                        END cuenta_abono,
                        TO_CHAR(inv.total - inv.total_used, 'FM9999999990.00') importe,
                        inv.invoice_folio referencia,
                        'PAGO DE SALDO DE FACTURAS A: ' || sup.business_name,
                        0 iva
                        FROM invoices inv, suppliers sup, companies com, contributors con
                        WHERE inv.supplier_id = sup.id
                        AND inv.company_id = com.id
                        AND sup.contributor_id = con.id
                        AND inv.id in (SELECT invoice_id from request_invoices)
                        AND inv.status IN ('CON SALDO', 'CON SALDO LIQUIDADA')
                        AND inv.used_date = ':used_date'
                        )
                      ) ab;"

    @query_supplier = "SELECT ':pr_folio' payment_report_folio, ab.*
              FROM((SELECT to_char(req.used_date,'DDMMYYYY') fecha_registro, to_char(req.used_date,'DDMMYYYY') fecha_aplicacion,
                CASE
                WHEN con.bank = 'BANCREA'
                  THEN 1
                ELSE 2
                END tipo_cuenta_abono,
                CASE
                WHEN con.bank = 'BANCREA'
                  THEN con.account_number
                ELSE con.clabe
                END cuenta_abono,
                TO_CHAR(rei.total_used - rei.interests, 'FM9999999990.00') importe,
                inv.invoice_folio referencia,
                'PAGO ANTICIPADO DE FACTURAS A: ' || sup.business_name descripcion,
                0 iva
                FROM invoices inv, requests req, request_invoices rei, suppliers sup, companies com, contributors con
                WHERE inv.id = rei.invoice_id
                AND req.id = rei.request_id
                AND inv.supplier_id = sup.id
                AND inv.company_id = com.id
                AND sup.contributor_id = con.id
                AND inv.status = 'PENDIENTE'
                AND req.status = 'APROBADA'
                AND req.used_date = ':used_date'
                ) UNION ALL
                (SELECT to_char(inv.used_date,'DDMMYYYY') fecha_registro, to_char(inv.used_date,'DDMMYYYY') fecha_aplicacion,
                CASE
                WHEN con.bank = 'BANCREA'
                  THEN 1
                ELSE 2
                END tipo_cuenta_abono,
                CASE
                WHEN con.bank = 'BANCREA'
                  THEN con.account_number
                ELSE con.clabe
                END cuenta_abono,
                TO_CHAR(inv.total, 'FM9999999990.00') importe,
                inv.invoice_folio referencia,
                'PAGO DE FACTURAS A: ' || sup.business_name,
                0 iva
                FROM invoices inv, suppliers sup, companies com, contributors con
                WHERE inv.supplier_id = sup.id
                AND inv.company_id = com.id
                AND sup.contributor_id = con.id
                AND inv.id not in (SELECT invoice_id from request_invoices)
                AND inv.status IN ('PENDIENTE', 'PENDIENTE LIQUIDADA')
                AND inv.used_date = ':used_date'
                ) UNION ALL
                (SELECT to_char(inv.used_date,'DDMMYYYY') fecha_registro, to_char(inv.used_date,'DDMMYYYY') fecha_aplicacion,
                CASE
                WHEN con.bank = 'BANCREA'
                  THEN 1
                ELSE 2
                END tipo_cuenta_abono,
                CASE
                WHEN con.bank = 'BANCREA'
                  THEN con.account_number
                ELSE con.clabe
                END cuenta_abono,
                TO_CHAR(inv.total - inv.total_used, 'FM9999999990.00') importe,
                inv.invoice_folio referencia,
                'PAGO DE SALDO DE FACTURAS A: ' || sup.business_name,
                0 iva
                FROM invoices inv, suppliers sup, companies com, contributors con
                WHERE inv.supplier_id = sup.id
                AND inv.company_id = com.id
                AND sup.contributor_id = con.id
                AND inv.id in (SELECT invoice_id from request_invoices)
                AND inv.status IN ('CON SALDO', 'CON SALDO LIQUIDADA')
                AND inv.used_date = ':used_date'
                )
              ) ab;"

    @query_resumen_funder = "SELECT ':pr_folio' payment_report_folio, to_char(to_date(':used_date','YYYY-MM-DD'),'DDMMYYYY') fecha_registro, (select value from general_parameters WHERE KEY = 'CUENTA_ORIGEN_BANCREA') cuenta_origen, sum(TO_NUMBER(ab.importe, 'FM9999999990.00')) importe_total, count(ab.importe) total_registros
                          FROM((SELECT to_char(inv.used_date,'DDMMYYYY') fecha_registro, to_char(inv.used_date,'DDMMYYYY') fecha_aplicacion,
                                CASE
                                WHEN con.bank = 'BANCREA'
                                  THEN 1
                                ELSE 2
                                END tipo_cuenta_abono,
                                CASE
                                WHEN con.bank = 'BANCREA'
                                  THEN con.account_number
                                ELSE con.clabe
                                END cuenta_abono,
                                TO_CHAR(fri.total_used, 'FM9999999990.00') importe,
                                inv.invoice_folio referencia,
                                'PAGO DE REFACTORAJE DE FACTURAS A: ' || fun.name descripcion,
                                0 iva
                                FROM invoices inv, requests req, request_invoices rei, funding_requests fre, funding_request_invoices fri, funders fun, contributors con
                                WHERE fri.invoice_id = inv.id
                                  AND fre.id = fri.funding_request_id
                                  AND fre.funder_id = fun.id
                                  AND fun.contributor_id = con.id
                                  AND inv.id = rei.invoice_id
                                  AND req.id = rei.request_id
                                  AND inv.status IN ('LIQUIDADA', 'CON SALDO LIQUIDADA')
                                  AND fri.status = 'FONDEADA'
                                  AND req.used_date = ':used_date'
                                )
                                ) ab;"

    @query_funder = "SELECT ':pr_folio' payment_report_folio, ab.*
                FROM((SELECT to_char(inv.used_date,'DDMMYYYY') fecha_registro, to_char(inv.used_date,'DDMMYYYY') fecha_aplicacion,
                      CASE
                      WHEN con.bank = 'BANCREA'
                        THEN 1
                      ELSE 2
                      END tipo_cuenta_abono,
                      CASE
                      WHEN con.bank = 'BANCREA'
                        THEN con.account_number
                      ELSE con.clabe
                      END cuenta_abono,
                      TO_CHAR(fri.total_used, 'FM9999999990.00') importe,
                      inv.invoice_folio referencia,
                      'PAGO DE REFACTORAJE DE FACTURAS A: ' || fun.name descripcion,
                      0 iva
                      FROM invoices inv, requests req, request_invoices rei, funding_requests fre, funding_request_invoices fri, funders fun, contributors con
                      WHERE fri.invoice_id = inv.id
                        AND fre.id = fri.funding_request_id
                        AND fre.funder_id = fun.id
                        AND fun.contributor_id = con.id
                        AND inv.id = rei.invoice_id
                        AND req.id = rei.request_id
                        AND inv.status IN ('LIQUIDADA', 'CON SALDO LIQUIDADA')
                        AND fri.status = 'FONDEADA'
                        AND req.used_date = ':used_date'
                      )
                      ) ab;"

    if params[:type].blank?
      @query_resumen = @query_resumen_supplier
      @query = @query_supplier
    elsif params[:type] == 'funder'
      @query_resumen = @query_resumen_funder
      @query = @query_funder
    else
      @query_resumen = @query_resumen_supplier
      @query = @query_supplier
    end
    t = Time.now
    @folio = t.to_i
    @pr_folio = "PR#{@folio}"
    @query_resumen = @query_resumen.gsub ':used_date', params[:used_date].to_s
    @query_resumen = @query_resumen.gsub ':pr_folio', @pr_folio
    @layout_bancrea_resumen = execute_statement(@query_resumen)
    @query = @query.gsub ':used_date', params[:used_date].to_s
    @query = @query.gsub ':pr_folio', @pr_folio
    @layout_bancrea = execute_statement(@query)
    unless @layout_bancrea.blank?
      @layout_bancrea.each do |report_row|
        @invoice = Invoice.where(id: report_row['id_factura'].to_s)
        @invoice.update(payment_report_folio: report_row['payment_report_folio'].to_s)
      end
    end
    render json: { resumen: @layout_bancrea_resumen, detalles: @layout_bancrea }
  end

  def layout_banregio
    @query_supplier = "SELECT ':pr_folio' payment_report_folio, TO_CHAR(ROW_NUMBER () OVER (ORDER BY ab.cuenta_destino), '09') oper, ab.*
              FROM((SELECT 'S' tipo_transferencia,
                CASE
                  WHEN con.bank = 'BANREGIO'
                  THEN con.account_number
                  ELSE con.clabe
                END cuenta_destino,
                TO_CHAR(rei.total_used - rei.interests, 'FM9999999990.00') importe,
                0 iva,
                'PAGO ANTICIPADO DE FACTURAS A: ' || sup.business_name descripcion,
                inv.invoice_folio referencia
                FROM invoices inv, requests req, request_invoices rei, suppliers sup, companies com, contributors con
                WHERE inv.id = rei.invoice_id
                AND req.id = rei.request_id
                AND inv.supplier_id = sup.id
                AND inv.company_id = com.id
                AND sup.contributor_id = con.id
                AND inv.status = 'PENDIENTE'
                AND req.status = 'APROBADA'
                AND req.used_date = ':used_date'
                ) UNION ALL
                (SELECT 'S' tipo_transferencia,
                CASE
                  WHEN con.bank = 'BANREGIO'
                  THEN con.account_number
                  ELSE con.clabe
                END cuenta_destino,
                TO_CHAR(inv.total, 'FM9999999990.00') importe,
                0 iva,
                'PAGO DE FACTURAS A: ' || sup.business_name descripcion,
                inv.invoice_folio referencia
                FROM invoices inv, suppliers sup, companies com, contributors con
                WHERE inv.supplier_id = sup.id
                AND inv.company_id = com.id
                AND sup.contributor_id = con.id
                AND inv.id not in (SELECT invoice_id from request_invoices)
                AND inv.status IN ('PENDIENTE', 'PENDIENTE LIQUIDADA')
                AND inv.used_date = ':used_date'
                ) UNION ALL
                (SELECT 'S' tipo_transferencia,
                CASE
                  WHEN con.bank = 'BANREGIO'
                  THEN con.account_number
                  ELSE con.clabe
                END cuenta_destino,
                TO_CHAR(inv.total - inv.total_used, 'FM9999999990.00') importe,
                0 iva,
                'PAGO DE SALDO DE FACTURAS A: ' || sup.business_name descripcion,
                inv.invoice_folio referencia
                FROM invoices inv, suppliers sup, companies com, contributors con
                WHERE inv.supplier_id = sup.id
                AND inv.company_id = com.id
                AND sup.contributor_id = con.id
                AND inv.id in (SELECT invoice_id from request_invoices)
                AND inv.status IN ('CON SALDO', 'CON SALDO LIQUIDADA')
                AND inv.used_date = ':used_date'
                )
              ) ab;"

    @query_supplier = "SELECT ':pr_folio' payment_report_folio, TO_CHAR(ROW_NUMBER () OVER (ORDER BY ab.cuenta_destino), '09') oper, ab.*
                      FROM((SELECT 'S' tipo_transferencia,
                            CASE
                              WHEN con.bank = 'BANREGIO'
                              THEN con.account_number
                              ELSE con.clabe
                            END cuenta_destino,
                            TO_CHAR(fri.total_used, 'FM9999999990.00') importe,
                            0 iva,
                            'PAGO DE REFACTORAJE DE FACTURAS A: ' || fun.name descripcion,
                            inv.invoice_folio referencia
                            FROM invoices inv, requests req, request_invoices rei, funding_requests fre, funding_request_invoices fri, funders fun, contributors con
                            WHERE fri.invoice_id = inv.id
                              AND fre.id = fri.funding_request_id
                              AND fre.funder_id = fun.id
                              AND fun.contributor_id = con.id
                              AND inv.id = rei.invoice_id
                              AND req.id = rei.request_id
                              AND inv.status IN ('LIQUIDADA', 'CON SALDO LIQUIDADA')
                              AND fri.status = 'FONDEADA'
                              AND req.used_date = ':used_date'
                            )
                            ) ab;"
    @query = if params[:type].blank?
               @query_supplier
             elsif params[:type] == 'funder'
               @query_funder
             else
               @query_supplier
             end
    t = Time.now
    @folio = t.to_i
    @pr_folio = "PR#{@folio}"
    @query = @query.gsub ':used_date', params[:used_date].to_s
    @query = @query.gsub ':pr_folio', @pr_folio
    @layout_banregio = execute_statement(@query)
    unless @layout_banregio.blank?
      @layout_banregio.each do |report_row|
        @invoice = Invoice.where(id: report_row['id_factura'].to_s)
        @invoice.update(payment_report_folio: report_row['payment_report_folio'].to_s)
      end
    end
    render json: @layout_banregio
  end

  def layout_base
    @query_titulo_supplier = "SELECT TRIM(to_char(to_date(':start_date','YYYY-MM-DD'),'YYYYMMDD')|| TO_CHAR (count(ab.*), 'fm000')||'01'||'DP') titulo
    FROM(SELECT TO_CHAR(cuc.total_requested, 'FM9999999990.00') importe
      FROM customer_credits cuc, companies com, contributors con, customers cus
      WHERE cus.id = cuc.customer_id
      AND con.id = cus.contributor_id
      AND cuc.status ='VA'
      AND cuc.currency = ':currency'
      AND cuc.start_date = ':start_date'                      
    ) ab;"

  @query_supplier = "SELECT ':pr_folio' payment_report_folio, ab.*
  FROM((SELECT cuc.id id_customer_credit, '01' tipo_operacion, greatest((left(con.extra1, 30)),rpad(left(con.extra1, 30), 30)) destinatario,
    greatest(con.clabe, rpad(con.clabe, 48)) cuenta_destino, 
    replace(TO_CHAR(cuc.total_requested, 'FM000000000000.00'),'.','') importe,
    greatest(substr(cuc.credit_folio,1,7),lpad(substr(cuc.credit_folio,1,7), 30)) referencia_numerica,
    greatest(cuc.credit_folio,rpad(cuc.credit_folio, 30)) referencia_concepto,
    greatest(cuc.credit_folio,rpad(cuc.credit_folio, 30)) referencia, 
    CASE
    WHEN cuc.currency = 'PESOS'
    THEN 'MXP'
    WHEN cuc.currency = 'DOLARES'
    THEN 'USD'
    END divisa,
    replace(TO_CHAR(0, 'FM000000000000.00'),'.','') iva,
    CASE
    WHEN con.legal_entity_id IS NULL
    THEN greatest(peo.rfc,rpad(peo.rfc, 13))
    ELSE greatest(len.rfc,rpad(len.rfc, 13))
    END rfc_destinatario,
    greatest((select value from general_parameters WHERE KEY = 'CUENTA_ORIGEN_BASE'),rpad((select value from general_parameters WHERE KEY = 'CUENTA_ORIGEN_BASE'), 18)) cuenta_cargo
    FROM customer_credits cuc, customers cus, contributors con
    LEFT JOIN legal_entities len ON (len.id = con.legal_entity_id)
    LEFT JOIN people peo ON (peo.id = con.person_id)
    WHERE cus.id = cuc.customer_id
    AND con.id = cus.contributor_id
    AND cuc.status ='VA'
    AND cuc.currency = ':currency'
    AND cuc.start_date = ':start_date'
    ) 
  ) ab;"

 
    @query_titulo = @query_titulo_supplier
    @query = @query_supplier


  @query_titulo = @query_titulo.gsub ':start_date', params[:start_date].to_s
  @query_titulo = @query_titulo.gsub ':currency', params[:currency].to_s
  @base_titulo = execute_statement(@query_titulo)
  @pr_folio = @base_titulo[0]['titulo']
  @query = @query.gsub ':start_date', params[:start_date].to_s
  @query = @query.gsub ':pr_folio', @pr_folio
  @query = @query.gsub ':currency', params[:currency].to_s
  @layout_base = execute_statement(@query)
  unless @layout_base.blank?
    @layout_base.each do |report_row|
      @customer_credit = CustomerCredit.where(id: report_row['id_customer_credit'].to_s)
      puts report_row.inspect
      @customer_credit.update(extra1: report_row['payment_report_folio'].to_s)
    end
  end
  render json: @layout_base
end

  def layout_scotiabank # Este banco esta pendiente conforme a lo que vi en la conferencia con ellos Falta agregar lo de las facturas con saldo
    @query = "SELECT ':pr_folio' payment_report_folio, 'EE' tipo_archivo, 'DP' tipo_registro, '04' tipo_movimiento, ab.*
              FROM((SELECT con.extra1 clave_id,
                CASE
                  WHEN inv.currency = 'PESOS'
                  THEN '00'
                  WHEN inv.currency = 'DÓLARES'
                  THEN '01'
                  WHEN inv.currency = 'DOLARES'
                  THEN '01'
                  END cve_moneda_pago,
                TO_CHAR(rei.total_used - rei.interests, 'FM9999999990.00') importe,
                TO_CHAR(req.used_date,'YYYYMMDD') fecha_aplicacion,
                '03' servicio_concepto,
                con.extra1 cve_beneficiario,
                CASE
                    WHEN con.legal_entity_id IS NULL
                    THEN peo.rfc
                    ELSE len.rfc
                  END rfc_beneficiario,
                CASE
                    WHEN con.legal_entity_id IS NULL
                    THEN peo.first_name || ' ' || peo.last_name || ' ' || peo.second_last_name
                    ELSE len.business_name
                  END nombre_beneficiario,
                inv.invoice_folio referencia,
                  CASE
                    WHEN con.bank = 'SCOTIABANK'
                    THEN con.account_number
                    ELSE con.clabe
                  END cuenta_beneficiario,
                  '00000' plaza_pago,
                  '00000' sucursal_pago
                  FROM invoices inv, requests req, request_invoices rei, suppliers sup, companies com, contributors con
                  LEFT JOIN legal_entities len ON (len.id = con.legal_entity_id)
                    LEFT JOIN people peo ON (peo.id = con.person_id)
                  WHERE inv.id = rei.invoice_id
                  AND req.id = rei.request_id
                  AND inv.supplier_id = sup.id
                  AND inv.company_id = com.id
                  AND sup.contributor_id = con.id
                  AND inv.status = 'PENDIENTE'
                  AND req.status = 'APROBADA'
                  AND inv.currency = ':currency'
                  AND req.used_date = ':used_date'
                ) UNION ALL
                (SELECT con.extra1 clave_id,
                CASE
                  WHEN inv.currency = 'PESOS'
                  THEN '00'
                  WHEN inv.currency = 'DÓLARES'
                  THEN '01'
                  WHEN inv.currency = 'DOLARES'
                  THEN '01'
                  END cve_moneda_pago,
                TO_CHAR(inv.total, 'FM9999999990.00') importe,
                TO_CHAR(inv.used_date,'YYYYMMDD') fecha_aplicacion,
                '03' servicio_concepto,
                con.extra1 cve_beneficiario,
                CASE
                    WHEN con.legal_entity_id IS NULL
                    THEN peo.rfc
                    ELSE len.rfc
                  END rfc_beneficiario,
                CASE
                    WHEN con.legal_entity_id IS NULL
                    THEN peo.first_name || ' ' || peo.last_name || ' ' || peo.second_last_name
                    ELSE len.business_name
                  END nombre_beneficiario,
                inv.invoice_folio referencia,
                  CASE
                    WHEN con.bank = 'SCOTIABANK'
                    THEN con.account_number
                    ELSE con.clabe
                  END cuenta_beneficiario,
                  '00000' plaza_pago,
                  '00000' sucursal_pago
                  FROM invoices inv, suppliers sup, companies com, contributors con
                  LEFT JOIN legal_entities len ON (len.id = con.legal_entity_id)
                    LEFT JOIN people peo ON (peo.id = con.person_id)
                  WHERE inv.supplier_id = sup.id
                  AND inv.company_id = com.id
                  AND sup.contributor_id = con.id
                  AND inv.id not in (SELECT invoice_id from request_invoices)
                  AND inv.status IN ('PENDIENTE', 'PENDIENTE LIQUIDADA')
                  AND inv.currency = ':currency'
                  AND inv.used_date = ':used_date'
                )
                ) ab;"

    t = Time.now
    @folio = t.to_i
    @pr_folio = "PR#{@folio}"
    @query = @query.gsub ':used_date', params[:used_date].to_s
    @query = @query.gsub ':pr_folio', @pr_folio
    @query = @query.gsub ':currency', params[:currency].to_s
    @layout_scotiabank = execute_statement(@query)
    unless @layout_scotiabank.blank?
      @layout_scotiabank.each do |report_row|
        @customer_credit = Invoice.where(id: report_row['id_factura'].to_s)
        @invoice.update(payment_report_folio: report_row['payment_report_folio'].to_s)
      end
    end
    render json: @layout_scotiabank
  end

  def company_payments
    @query = "SELECT ':cr_folio' charge_report_folio, ab.*
              FROM((SELECT com.business_name cadena, inv.invoice_folio no_factura, sup.business_name proveedor, TO_CHAR(inv.total, 'FM9,999,999,990.00') importe, inv.currency moneda, req.used_date fecha_operacion, inv.due_date fecha_vencimiento, inv.entry_date fecha_carga, inv.due_date - inv.entry_date dias_transcurridos, req.folio folio_solicitud, inv.id id_factura
                  FROM invoices inv, requests req, request_invoices rei, suppliers sup, companies com
                  WHERE inv.id = rei.invoice_id
                  AND req.id = rei.request_id
                  AND inv.supplier_id = sup.id
                  AND inv.company_id = com.id
                  AND inv.status IN ('EJECUTADA','CON SALDO')
                  AND req.status = 'EJECUTADA'
                  AND inv.due_date = ':due_date'
                  AND com.id = :company_id
                ) UNION ALL
                (SELECT com.business_name cadena, inv.invoice_folio no_factura, sup.business_name proveedor, TO_CHAR(inv.total, 'FM9,999,999,990.00') importe, inv.currency moneda, inv.used_date fecha_operacion, inv.due_date fecha_vencimiento, inv.entry_date fecha_carga, inv.due_date - inv.entry_date dias_transcurridos, null folio_solicitud, inv.id id_factura
                  FROM invoices inv, suppliers sup, companies com
                  WHERE inv.supplier_id = sup.id
                  AND inv.company_id = com.id
                  AND inv.id not in (SELECT invoice_id from request_invoices)
                  AND inv.status = 'EJECUTADA'
                  AND inv.due_date = ':due_date'
                  AND com.id = :company_id
                )
                ) ab;"
    @due_date = params[:report_date].to_date
    @due_date += 1 until @due_date.strftime('%u').to_i == 5
    t = Time.now
    @folio = t.to_i
    @cr_folio = "CR#{@folio}"
    @query = @query.gsub ':due_date', @due_date.to_s
    @query = @query.gsub ':company_id', params[:company_id].to_s
    @query = @query.gsub ':cr_folio', @cr_folio
    @company_payments = execute_statement(@query)
    unless @company_payments.blank?
      @company_payments.each do |report_row|
        @invoice = Invoice.where(id: report_row['id_factura'].to_s)
        @invoice.update(charge_report_folio: report_row['charge_report_folio'].to_s)
      end
    end
    render json: @company_payments
  end

  def general_report_invoices
    @query = "SELECT
              inv.id id_factura,
              invoice_folio folio_factura,
              req.folio folio_solicitud,
              freq.folio folio_solicitud_fondeo,
              inv.uuid uuid_factura_descontada,
              sup.business_name emisor,
              com.business_name receptor,
              inv.currency moneda,
              inv.used_date fecha_operacion,
              inv.due_date fecha_vencimiento,
              inv.invoice_date fecha_emision,
              inv.entry_date fecha_carga,
              inv.status estatus,
              TO_CHAR(inv.total, 'FM9,999,999,990.00') total_factura,
              CASE
              WHEN req.capacity ISNULL
              THEN TO_CHAR(0.00, 'FM9,999,999,990.00')
              ELSE TO_CHAR(((inv.total_used * 100) / inv.total), 'FM9,999,999,990.00')
              END porcentaje_operado,
              TO_CHAR(inv.total_used, 'FM9,999,999,990.00') monto_operado,
              CASE
              WHEN rei.total_used ISNULL
              THEN '0.00'
              ELSE TO_CHAR(inv.total - rei.total_used, 'FM9,999,999,990.00')
              END disponible,
              CASE
              WHEN rei.interests ISNULL
              THEN '0.00'
              ELSE TO_CHAR(rei.interests, 'FM9,999,999,990.00')
              END intereses,
              rei.ext_rate tasa_interbancaria,
              rei.int_rate sobretasa,
              rei.total_rate tasa_total,
              rei.financial_cost costo_financiero,
              rei.discount_days dias_descuento,
              rei.net_amount monto_neto,
              CASE
              WHEN rei.interests ISNULL
              THEN TO_CHAR(0.00, 'FM9,999,999,990.00')
              ELSE  TO_CHAR(rei.interests * (cse.fee / 100), 'FM9,999,999,990.00')
              END comision_cadena,
              pay.payment_date dia_pago_cadena,
              TO_CHAR(pay.amount, 'FM9,999,999,990.00') monto_pago,
              CASE
              WHEN rei.total_used ISNULL
              THEN 0
              ELSE inv.due_date - req.used_date
              END dias_al_vencimiento
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN funding_request_invoices frei ON (inv.id = frei.invoice_id)
              LEFT JOIN funding_requests freq ON (frei.funding_request_id = freq.id)
              JOIN suppliers sup ON (inv.supplier_id = sup.id)
              JOIN companies com ON (inv.company_id = com.id)
              JOIN company_segments cse ON (com.id = cse.company_id)
              LEFT JOIN payments pay ON (inv.company_payment_id = pay.id);"
    @general_report_invoices = execute_statement(@query)
    render json: @general_report_invoices
  end

  def dashboard_admin
    @query = "SELECT TO_CHAR(SUM(pay.amount), 'FM9,999,999,990.00'), com.business_name cadena, con.extra2 numero_proveedores,
                    (SELECT COUNT(suppl.id) FROM companies compa, suppliers suppl, supplier_segments suseg
                    WHERE compa.id = suseg.company_id
                    AND suppl.id = suseg.supplier_id
                    AND compa.business_name = com.business_name) afiliados,
              TO_CHAR(SUM(rei.interests), 'FM9,999,999,990.00') total_intereses, count(inv.id) total_facturas, count(rei.invoice_id) total_facturas_en_descuento, (count(rei.invoice_id) * 100)/count(inv.id) porcentaje_descuento, TO_CHAR((SUM(rei.total_used - rei.interests) / ((extract(week from (SELECT MAX(pay.payment_date) FROM payments pay)::date) + 1)-extract(week from (SELECT MIN(pay.payment_date) FROM payments pay)::date))), 'FM9,999,999,990.00') promedio_operacion_semana, TO_CHAR(com.credit_limit, 'FM9,999,999,990.00') limite_credito, TO_CHAR(com.credit_available, 'FM9,999,999,990.00') credito_disponible, TO_CHAR(com.balance, 'FM9,999,999,990.00') saldo
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND inv.status not in ('CANCELADA')
              AND to_char(inv.entry_date, 'YYYY') = to_char(CURRENT_DATE, 'YYYY')
              GROUP BY com.business_name, com.credit_limit, com.credit_available, com.balance, con.extra2;"
    @dashboard_admin = execute_statement(@query)
    render json: @dashboard_admin
  end

  def dashboard_admin_invoices
    @query = "SELECT com.business_name cadena, sup.business_name proveedor, inv.status estatus, COUNT(inv.id) numero_facturas
              FROM invoices inv, companies com, suppliers sup
              WHERE inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND inv.status not in ('CANCELADA')
              AND to_char(inv.entry_date, 'YYYY') = to_char(CURRENT_DATE, 'YYYY')
              GROUP BY com.business_name, sup.business_name, inv.status
              ORDER BY com.business_name, sup.business_name, inv.status;"
    @dashboard_admin_invoices = execute_statement(@query)
    render json: @dashboard_admin_invoices
  end

  def dashboard_admin_requests
    @query = "SELECT com.business_name cadena, sup.business_name proveedor, COUNT(req.id) numero_solicitudes, TO_CHAR(SUM(req.total_used), 'FM9,999,999,990.00') suma_importe_solicitudes, TO_CHAR(sum(req.total_used) / COUNT(req.id), 'FM9,999,999,990.00') importe_promedio, TO_CHAR(SUM(req.interests), 'FM9,999,999,990.00') total_intereses, TO_CHAR(SUM(req.interests) / COUNT(req.id), 'FM9,999,999,990.00') promedio_intereses
              FROM requests req, companies com, suppliers sup
              WHERE req.company_id = com.id
              AND req.supplier_id = sup.id
              AND req.status not in ('CANCELADA')
              AND to_char(req.request_date, 'YYYY') = to_char(CURRENT_DATE, 'YYYY')
              GROUP BY com.business_name, sup.business_name
              ORDER BY com.business_name, sup.business_name;"
    @dashboard_admin_requests = execute_statement(@query)
    render json: @dashboard_admin_requests
  end

  def supplier_invoices
    @query = "SELECT inv.*
    FROM invoices inv
    JOIN suppliers sup ON (inv.supplier_id = sup.id)
    JOIN companies com ON (inv.company_id = com.id)
    WHERE inv.status = 'PENDIENTE'
    AND inv.id not in (SELECT invoice_id from request_invoices)
    AND sup.id = :supplier
    AND com.id = :company
    AND inv.currency = ':currency';"
    @query = @query.gsub ':supplier', params[:supplier_id].to_s
    @query = @query.gsub ':company', params[:company_id].to_s
    @query = @query.gsub ':currency', params[:currency].to_s
    @supplier_invoices = execute_statement(@query)
    render json: @supplier_invoices
  end

  def supplier_invoices_projects
    @query = "SELECT DISTINCT(pro.id), pro.key || '-' || pro.name proyecto
    FROM invoices inv
    JOIN suppliers sup ON (inv.supplier_id = sup.id)
    JOIN companies com ON (inv.company_id = com.id)
    LEFT JOIN company_projects pro ON (inv.company_project_id = pro.id)
    WHERE inv.status IN ('PENDIENTE', 'PENDIENTE LIQUIDADA')
    AND inv.id not in (SELECT invoice_id from request_invoices)
    AND sup.id = :supplier
    AND com.id = :company
    AND inv.currency = ':currency';"
    @query = @query.gsub ':supplier', params[:supplier_id].to_s
    @query = @query.gsub ':company', params[:company_id].to_s
    @query = @query.gsub ':currency', params[:currency].to_s
    @supplier_invoices_projects = execute_statement(@query)
    render json: @supplier_invoices_projects
  end

  def user_supplier
    @query = "SELECT com.id company_id, com.business_name cadena, sup.id supplier_id, sup.business_name proveedor
    FROM users usr, supplier_users sus, suppliers sup, companies com, supplier_segments sse
    WHERE usr.id = sus.user_id
    AND sus.supplier_id = sup.id
    AND sup.id = sse.supplier_id
    AND sse.company_id = com.id
    AND usr.id = :user_id;"
    # >>>>>>>>>>>>Pendiente agrear asociacion de cadena y proveedor por medio del segmento de dolares o de un proyecto
    @query = @query.gsub ':user_id', params[:user_id].to_s
    @user_supplier = execute_statement(@query)
    render json: @user_supplier
  end

  def customer_user_association
    @query = "SELECT * from customers cus 
    WHERE cus.user_id = ':user_id';"
    @query = @query.gsub ':user_id', params[:user_id].to_s
    @customer_user_association = execute_statement(@query)
    render json: @customer_user_association
  end

  def company_user_association
    @query = "SELECT cus.id supplier_user_id, cus.user_id, cus.company_id
    FROM users usr, company_users cus, companies com
    WHERE usr.id = cus.user_id
    AND cus.company_id = com.id
    AND usr.id = ':user_id';"
    @query = @query.gsub ':user_id', params[:user_id].to_s
    @company_user_association = execute_statement(@query)
    render json: @company_user_association
  end

  def user_company
    @query = "SELECT com.id company_uuid, com.business_name compañia, usr.id user_uuid  
    FROM  customers cus, companies com, users usr
    WHERE cus.company_id = com.id
    AND cus.user_id = usr.id
    AND cus.user_id = ':user_id';"
    @query = @query.gsub ':user_id', params[:user_id].to_s
    @user_company = execute_statement(@query)
    render json: @user_company
  end

  def supplier_signatories
    @query = "SELECT peo.first_name ||' '|| peo.last_name ||' '|| peo.second_last_name firmante
    FROM suppliers sup, contributors con, signatories sig, contributors con_sig, people peo
    WHERE sup.contributor_id = con.id
    AND sig.contributor_id = con.id
    AND sig.contributor_signatory_id = con_sig.id
    AND con_sig.person_id = peo.id
    AND sup.id = :supplier_id;"
    @query = @query.gsub ':supplier_id', params[:supplier_id].to_s
    @supplier_signatories = execute_statement(@query)
    render json: @supplier_signatories
  end

  def user_requests
    @query = "SELECT ab.*
              FROM((SELECT cuc.start_date fecha_inicio, cus.name empleado, cuc.capital, TO_CHAR(cuc.interests, 'FM9,999,999,990.00') intereses,
              cuc.rate,TO_CHAR(cuc.total_debt, 'FM9,999,999,990.00') adeudo_total, TO_CHAR(cuc.total_requested, 'FM9,999,999,990.00') pedido_total, cuc.fixed_payment pago_fijo,
              (select value from terms where id = cuc.term_id ) plazo, (select key from payment_periods where id = cuc.payment_period_id ), com.business_name compañia,  
              cuc.id credit_uuid, cuc.credit_folio, (select value from lists where key = cuc.status and domain = 'CREDIT_STATUS') estatus, cuc.currency moneda 
                       FROM customer_credits cuc, customers cus, companies com, users usr
                       WHERE cuc.customer_id = cus.id
                       AND cus.company_id = com.id
                       AND cuc.user_id = ':user_id'
                       AND cus.user_id = usr.id
                       AND cuc.status not in ('SO','RZ','RE','PA','PR')
                       AND ':user_id'<> (SELECT users.id FROM users WHERE email = (SELECT value FROM general_parameters WHERE key = 'USUARIO_ADMINISTRADOR'))
                       ) UNION ALL
                       (SELECT cuc.start_date fecha_inicio, cus.name empleado, cuc.capital, TO_CHAR(cuc.interests, 'FM9,999,999,990.00') intereses,
                       cuc.rate,TO_CHAR(cuc.total_debt, 'FM9,999,999,990.00') adeudo_total, TO_CHAR(cuc.total_requested, 'FM9,999,999,990.00') pedido_total, cuc.fixed_payment pago_fijo,
                       (select value from terms where id = cuc.term_id ) plazo, (select key from payment_periods where id = cuc.payment_period_id ), com.business_name compañia,  
                       cuc.id credit_uuid, cuc.credit_folio, (select value from lists where key = cuc.status and domain = 'CREDIT_STATUS') estatus,cuc.currency moneda 
                       FROM customer_credits cuc, customers cus, companies com, users usr
                       WHERE cuc.customer_id = cus.id
                       AND cus.company_id = com.id
                       AND cuc.user_id = usr.id
                       AND ':user_id' = (SELECT users.id FROM users WHERE email = (SELECT value FROM general_parameters WHERE key = 'USUARIO_ADMINISTRADOR'))
                       AND cuc.status not in ('SO','RZ','RE','PA','PR')
                       ) 
                       ) ab;"
    @query = @query.gsub ':user_id', params[:user_id].to_s
    @user_requests = execute_statement(@query)
    render json: @user_requests
  end

  def financial_workers
    @query = "SELECT id, name, email
    FROM users
    WHERE job IN (':job', 'CONTROL', 'TESORERÍA', 'ADMINISTRADOR')
    AND status = 'AC';"
    @query = @query.gsub ':job', params[:job].to_s
    @financial_workers = execute_statement(@query)
    render json: @financial_workers
  end

  def payment_companies
    @query = "SELECT
                com.id id_cadena,
                com.business_name nombre_cadena,
                con.id id_contribuyente,
                CASE
                WHEN con.contributor_type = 'PERSONA MORAL'
                  THEN len.business_email
                ELSE peo.email
                END email_contribuyente,
                (SELECT cont.id FROM legal_entities leen, contributors cont WHERE leen.id = cont.legal_entity_id AND leen.rfc = (select value from general_parameters WHERE KEY = 'RFC_FINANCIERA')) id_cont_finan,
                (SELECT leen.business_email FROM legal_entities leen, contributors cont WHERE leen.id = cont.legal_entity_id AND leen.rfc = (select value from general_parameters WHERE KEY = 'RFC_FINANCIERA')) email_finan
              FROM companies com
              JOIN contributors con ON (com.contributor_id = con.id)
              LEFT JOIN legal_entities len ON (len.id = con.legal_entity_id)
              LEFT JOIN people peo ON (peo.id = con.person_id);"
    @payment_companies = execute_statement(@query)
    render json: @payment_companies
  end

  def payment_suppliers
    @query = "SELECT
                sup.id id_proveedor,
                sup.business_name nombre_proveedor,
                con.id id_contribuyente,
                CASE
                WHEN con.contributor_type = 'PERSONA MORAL'
                  THEN len.business_email
                ELSE peo.email
                END email_contribuyente,
                (SELECT cont.id FROM legal_entities leen, contributors cont WHERE leen.id = cont.legal_entity_id AND leen.rfc = (select value from general_parameters WHERE KEY = 'RFC_FINANCIERA')) id_cont_finan,
                (SELECT leen.business_email FROM legal_entities leen, contributors cont WHERE leen.id = cont.legal_entity_id AND leen.rfc = (select value from general_parameters WHERE KEY = 'RFC_FINANCIERA')) email_finan
              FROM suppliers sup
              JOIN contributors con ON (sup.contributor_id = con.id)
              LEFT JOIN legal_entities len ON (len.id = con.legal_entity_id)
              LEFT JOIN people peo ON (peo.id = con.person_id);"
    @payment_suppliers = execute_statement(@query)
    render json: @payment_suppliers
  end

  def payment_funder_financial
    @query = "SELECT
              fun.id id_funder,
              fun.name nombre_fondeador,
              con.id id_contribuyente,
              CASE
              WHEN con.contributor_type = 'PERSONA MORAL'
                THEN len.business_email
              ELSE peo.email
              END email_contribuyente,
              (SELECT cont.id FROM legal_entities leen, contributors cont WHERE leen.id = cont.legal_entity_id AND leen.rfc = (select value from general_parameters WHERE KEY = 'RFC_FINANCIERA')) id_cont_finan,
              (SELECT leen.business_email FROM legal_entities leen, contributors cont WHERE leen.id = cont.legal_entity_id AND leen.rfc = (select value from general_parameters WHERE KEY = 'RFC_FINANCIERA')) email_finan
              FROM funders fun
              JOIN contributors con ON (fun.contributor_id = con.id)
              LEFT JOIN legal_entities len ON (len.id = con.legal_entity_id)
              LEFT JOIN people peo ON (peo.id = con.person_id);"
    @payment_funder_financial = execute_statement(@query)
    render json: @payment_funder_financial
  end

  def payment_supplier_invoices
    @query = "SELECT
              inv.payment_report_folio folio_reporte,
              inv.id id_factura,
              inv.invoice_folio folio_factura,
              inv.uuid uuid,
              req.folio folio_solicitud,
              sup.business_name emisor,
              com.business_name receptor,
              inv.currency moneda,
              CASE
              WHEN req.used_date ISNULL
              THEN inv.used_date
              WHEN inv.total != inv.total_used AND inv.status != 'PENDIENTE'
              THEN inv.used_date
              ELSE req.used_date
              END fecha_operacion,
              CASE
              WHEN req.capacity ISNULL
              THEN TO_CHAR(0.00, 'FM9,999,999,990.00')
              ELSE TO_CHAR(((inv.total_used * 100) / inv.total), 'FM9,999,999,990.00')
              END porcentaje_operado,
              CASE
              WHEN rei.total_used ISNULL
              THEN TO_CHAR(inv.total, 'FM9,999,999,990.00')
              WHEN inv.total != inv.total_used AND inv.status != 'PENDIENTE'
              THEN TO_CHAR(inv.total - inv.total_used, 'FM9,999,999,990.00')
              ELSE TO_CHAR(rei.total_used - rei.interests, 'FM9,999,999,990.00')
              END importe_neto,
              CASE
              WHEN req.due_date ISNULL
              THEN inv.due_date
              WHEN inv.total != inv.total_used AND inv.status != 'PENDIENTE'
              THEN inv.due_date
              ELSE req.due_date
              END fecha_vencimiento,
              inv.invoice_date fecha_emision,
              inv.entry_date fecha_carga,
              inv.status estatus
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id AND req.status IN ('APROBADA', 'LIQUIDADA'))
              JOIN suppliers sup ON (inv.supplier_id = sup.id)
              JOIN companies com ON (inv.company_id = com.id)
              JOIN company_segments cse ON (com.id = cse.company_id)
              AND sup.id = :supplier_id
              AND inv.status IN ('PENDIENTE', 'PENDIENTE LIQUIDADA', 'CON SALDO', 'CON SALDO LIQUIDADA')
              AND inv.currency = ':currency'
              AND inv.payment_report_folio IS NOT NULL
              AND inv.supplier_payment_id is NULL;"
    @query = @query.gsub ':supplier_id', params[:supplier_id].to_s
    @query = @query.gsub ':currency', params[:currency].to_s
    @payment_supplier_invoices = execute_statement(@query)
    render json: @payment_supplier_invoices
  end

  def payment_company_invoices
    @query = "SELECT
              inv.charge_report_folio folio_reporte,
              inv.id id_factura,
              inv.invoice_folio folio_factura,
              inv.uuid uuid,
              req.folio folio_solicitud,
              sup.business_name emisor,
              com.business_name receptor,
              inv.currency moneda,
              inv.used_date fecha_operacion,
              CASE
              WHEN req.capacity ISNULL
                THEN TO_CHAR(0.00, 'FM9,999,999,990.00')
              ELSE TO_CHAR(((inv.total_used * 100) / inv.total), 'FM9,999,999,990.00')
              END porcentaje_operado,
              TO_CHAR(inv.total, 'FM9,999,999,990.00') monto_total,
              CASE
              WHEN req.due_date ISNULL
              THEN inv.due_date
              ELSE req.due_date
              END fecha_vencimiento,
              inv.invoice_date fecha_emision,
              inv.entry_date fecha_carga,
              inv.status estatus
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id AND inv.status IN ('EJECUTADA', 'CON SALDO'))
              LEFT JOIN requests req ON (rei.request_id = req.id AND req.status = 'EJECUTADA')
              JOIN suppliers sup ON (inv.supplier_id = sup.id)
              JOIN companies com ON (inv.company_id = com.id)
              AND inv.status IN ('EJECUTADA', 'CON SALDO')
              AND com.id = :company_id
              AND inv.currency = ':currency'
              AND inv.charge_report_folio IS NOT NULL
              AND inv.company_payment_id is NULL;"
    @query = @query.gsub ':company_id', params[:company_id].to_s
    @query = @query.gsub ':currency', params[:currency].to_s
    @payment_company_invoices = execute_statement(@query)
    render json: @payment_company_invoices
  end

  def get_funding_invoices
    @query = "SELECT
    fri.funding_report_folio folio_reporte,
    inv.id id_factura,
    inv.invoice_folio folio_factura,
    inv.uuid uuid,
    req.folio folio_solicitud,
    sup.business_name emisor,
    com.business_name receptor,
    fre.currency moneda,
    fre.funding_request_date fecha_operacion,
    TO_CHAR(((fri.total_used * 100) / fri.total), 'FM9,999,999,990.00') porcentaje_operado,
    TO_CHAR(fri.total_used - fri.interests, 'FM9,999,999,990.00') importe_neto,
    inv.due_date fecha_vencimiento,
    inv.invoice_date fecha_emision,
    inv.entry_date fecha_carga,
    fri.status estatus
    FROM invoices inv
    JOIN funding_request_invoices fri ON (inv.id = fri.invoice_id)
    JOIN funding_requests fre ON (fri.funding_request_id = fre.id)
    JOIN request_invoices rei ON (inv.id = rei.invoice_id)
    JOIN requests req ON (rei.request_id = req.id AND req.status IN ('PENDIENTE', 'SOBREGIRO PROVEEDOR'))
    JOIN suppliers sup ON (inv.supplier_id = sup.id)
    JOIN companies com ON (inv.company_id = com.id)
    AND com.id = :company_id
    AND fri.status IN ('SOLICITADA')
    AND fre.currency = ':currency';"
    @query = @query.gsub ':company_id', params[:company_id].to_s
    @query = @query.gsub ':currency', params[:currency].to_s
    @get_funding_invoices = execute_statement(@query)
    render json: @get_funding_invoices
  end

  def payment_funding_invoices
    @query = "SELECT
    fri.payment_report_folio folio_reporte,
    inv.id id_factura,
    inv.invoice_folio folio_factura,
    inv.uuid uuid,
    req.folio folio_solicitud,
    sup.business_name emisor,
    com.business_name receptor,
    fre.currency moneda,
    fre.funding_request_date fecha_operacion,
    TO_CHAR(((fri.total_used * 100) / fri.total), 'FM9,999,999,990.00') porcentaje_operado,
    TO_CHAR(fri.total_used, 'FM9,999,999,990.00') importe_neto,
    inv.due_date fecha_vencimiento,
    inv.invoice_date fecha_emision,
    inv.entry_date fecha_carga,
    fri.status estatus
    FROM invoices inv
    JOIN funding_request_invoices fri ON (inv.id = fri.invoice_id)
    JOIN funding_requests fre ON (fri.funding_request_id = fre.id)
    JOIN request_invoices rei ON (inv.id = rei.invoice_id)
    JOIN requests req ON (rei.request_id = req.id AND req.status IN ('LIQUIDADA', 'CON SALDO LIQUIDADA'))
    JOIN suppliers sup ON (inv.supplier_id = sup.id)
    JOIN companies com ON (inv.company_id = com.id)
    AND com.id = :company_id
    AND fri.status IN ('FONDEADA')
    AND fre.currency = ':currency'
    AND fri.payment_report_folio IS NOT NULL;"
    @query = @query.gsub ':company_id', params[:company_id].to_s
    @query = @query.gsub ':currency', params[:currency].to_s
    @payment_funding_invoices = execute_statement(@query)
    render json: @payment_funding_invoices
  end

  def contributors_main
    @query = "SELECT
                    con.id id_contribuyente,
                    com.id id_cadena,
                    sup.id id_proveedor,
                    CASE
                    WHEN peo.id ISNULL
                      THEN len.rfc
                    ELSE peo.rfc
                    END rfc_contribuyente,
                    CASE
                    WHEN peo.id ISNULL
                      THEN len.business_name
                    ELSE peo.first_name || ' ' || peo.last_name || ' ' || peo.second_last_name
                    END nombre,
                    CASE
                    WHEN peo.id ISNULL
                      THEN len.phone
                    ELSE peo.phone
                    END telefono,
                    CASE
                    WHEN peo.id ISNULL
                      THEN len.mobile
                    ELSE peo.mobile
                    END celular,
                    CASE
                    WHEN peo.id ISNULL
                      THEN len.business_email
                    ELSE peo.email
                    END correo,
                    con.contributor_type tipo,
                    con.bank banco,
                    con.account_number numero_cuenta,
                    con.clabe clave_interbancaria,
                    con.extra1 clave_portal_banco,
                    CASE
                    WHEN com.id ISNULL
                      THEN TO_CHAR(sup.credit_limit, 'FM9,999,999,990.00')
                    ELSE TO_CHAR(com.credit_limit, 'FM9,999,999,990.00')
                    END limite_credito,
                    CASE
                    WHEN com.id ISNULL
                      THEN TO_CHAR(sup.credit_available, 'FM9,999,999,990.00')
                    ELSE TO_CHAR(com.credit_available, 'FM9,999,999,990.00')
                    END credito_disponible,
                    CASE
                    WHEN com.id ISNULL
                      THEN TO_CHAR(sup.balance, 'FM9,999,999,990.00')
                    ELSE TO_CHAR(com.balance, 'FM9,999,999,990.00')
                    END saldo,
                    CASE
                    WHEN com.id ISNULL
                      THEN 'FALSE'
                    ELSE 'TRUE'
                    END es_cadena,
                    CASE
                    WHEN sup.id ISNULL
                      THEN 'FALSE'
                    ELSE 'TRUE'
                    END es_proveedor
              FROM contributors con
              LEFT JOIN companies com ON (com.contributor_id = con.id)
              LEFT JOIN suppliers sup ON (sup.contributor_id = con.id)
              LEFT JOIN legal_entities len ON (len.id = con.legal_entity_id)
              LEFT JOIN people peo ON (peo.id = con.person_id);"
    @contributors_main = execute_statement(@query)
    render json: @contributors_main
  end

  def user_options
    @query = "SELECT opt.group grupo, usr.id usuario, opt.name nombre, opt.description descripcion, opt.url url
    FROM users usr, options opt, user_options uso
    WHERE usr.id = uso.user_id
    AND opt.id = uso.option_id
    AND usr.id = :user_id;"
    @query = @query.gsub ':user_id', params[:user_id].to_s
    @user_options = execute_statement(@query)
    render json: @user_options
  end

  def general_report_requests
    @query = "SELECT req.id id_solicitud, req.folio folio_solicitud, com.business_name cadena, sup.business_name proveedor, req.status estatus, req.request_date fecha_solicitud, req.used_date fecha_operacion, req.due_date fecha_vencimiento, req.currency moneda, TO_CHAR(req.total, 'FM9,999,999,990.00') total, req.capacity porcentaje_operacion, TO_CHAR(req.total_used, 'FM9,999,999,990.00') total_operado, TO_CHAR(req.balance, 'FM9,999,999,990.00') saldo, TO_CHAR(req.interests, 'FM9,999,999,990.00') intereses, TO_CHAR(req.net_amount, 'FM9,999,999,990.00') monto_neto, req.financial_cost costo_financiero, usr.name usuario, req.created_at fecha_creacion, req.updated_at fecha_modificacion
              FROM requests req, companies com, suppliers sup, users usr
              WHERE req.company_id = com.id
              AND req.supplier_id = sup.id
              and req.user_id = usr.id;"
    @general_report_requests = execute_statement(@query)
    render json: @general_report_requests
  end

  def general_report_funding_requests
    @query = "SELECT req.id id_solicitud_fondeo, req.folio folio_solicitud_fondeo, com.business_name cadena, fun.name fondedor, req.funding_request_date fecha_solicitud, req.currency moneda, TO_CHAR(req.total, 'FM9,999,999,990.00') total, TO_CHAR(req.total_used, 'FM9,999,999,990.00') total_operado, TO_CHAR(req.interests, 'FM9,999,999,990.00') intereses, TO_CHAR(req.net_amount, 'FM9,999,999,990.00') monto_neto, usr.name usuario, req.created_at fecha_creacion, req.updated_at fecha_modificacion
              FROM funding_requests req, companies com, funders fun, users usr
              WHERE req.company_id = com.id
              AND req.funder_id = fun.id
              and req.user_id = usr.id;"
    @general_report_requests = execute_statement(@query)
    render json: @general_report_requests
  end

  def director_report_resume
    @query = "SELECT first_monday_of_month() s1_del, first_monday_of_month() +6 s1_al,(
                SELECT
                TO_CHAR(COALESCE(SUM(CASE
                WHEN rei.total_used ISNULL
                  THEN inv.total
                ELSE rei.total_used - rei.interests
                END),0.00), 'FM9,999,999,990.00') s1_descuentos
                FROM invoices inv
                LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
                LEFT JOIN requests req ON (rei.request_id = req.id AND req.status NOT IN ('EJECUTADA', 'LIQUIDADA', 'CANCELADA') AND req.used_date BETWEEN first_monday_of_month() AND first_monday_of_month() +6)
                WHERE inv.status NOT IN ('EJECUTADA', 'LIQUIDADA', 'CANCELADA')
                AND inv.supplier_payment_id ISNULL
                AND (inv.used_date BETWEEN first_monday_of_month() AND first_monday_of_month() +6 OR req.used_date BETWEEN first_monday_of_month() AND first_monday_of_month() +6)
                AND inv.currency = 'PESOS'),(
                SELECT
                TO_CHAR(COALESCE(SUM(inv.total),0.00), 'FM9,999,999,990.00') s1_pagos
                FROM invoices inv
                WHERE inv.status NOT IN ('LIQUIDADA', 'CANCELADA')
                AND inv.company_payment_id ISNULL
                AND inv.due_date BETWEEN first_monday_of_month() AND first_monday_of_month() +6
                AND inv.currency = 'PESOS'),
                (SELECT first_monday_of_month() +7 s2_del), (SELECT first_monday_of_month() +13 s2_al),(
                SELECT
                TO_CHAR(COALESCE(SUM(CASE
                WHEN rei.total_used ISNULL
                  THEN inv.total
                ELSE rei.total_used - rei.interests
                END),0.00), 'FM9,999,999,990.00') s2_descuentos
                FROM invoices inv
                LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
                LEFT JOIN requests req ON (rei.request_id = req.id AND req.status NOT IN ('EJECUTADA', 'LIQUIDADA', 'CANCELADA') AND req.used_date BETWEEN first_monday_of_month()+7 AND first_monday_of_month() +17)
                WHERE inv.status NOT IN ('EJECUTADA', 'LIQUIDADA', 'CANCELADA')
                AND inv.supplier_payment_id ISNULL
                AND (inv.used_date BETWEEN first_monday_of_month()+7 AND first_monday_of_month() +13 OR req.used_date BETWEEN first_monday_of_month()+7 AND first_monday_of_month() +17)
                AND inv.currency = 'PESOS'),(
                SELECT
                TO_CHAR(COALESCE(SUM(inv.total),0.00), 'FM9,999,999,990.00') s2_pagos
                FROM invoices inv
                WHERE inv.status NOT IN ('LIQUIDADA', 'CANCELADA')
                AND inv.company_payment_id ISNULL
                AND inv.due_date BETWEEN first_monday_of_month()+7 AND first_monday_of_month() +13
                AND inv.currency = 'PESOS'),
                (SELECT first_monday_of_month()+14 s3_del), (SELECT first_monday_of_month() +20 s3_al),(
                SELECT
                TO_CHAR(COALESCE(SUM(CASE
                WHEN rei.total_used ISNULL
                  THEN inv.total
                ELSE rei.total_used - rei.interests
                END),0.00), 'FM9,999,999,990.00') s3_descuentos
                FROM invoices inv
                LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
                LEFT JOIN requests req ON (rei.request_id = req.id AND req.status NOT IN ('EJECUTADA', 'LIQUIDADA', 'CANCELADA') AND req.used_date BETWEEN first_monday_of_month()+14 AND first_monday_of_month() +20)
                WHERE inv.status NOT IN ('EJECUTADA', 'LIQUIDADA', 'CANCELADA')
                AND inv.supplier_payment_id ISNULL
                AND (inv.used_date BETWEEN first_monday_of_month()+14 AND first_monday_of_month() +20 OR req.used_date BETWEEN first_monday_of_month()+14 AND first_monday_of_month() +20)
                AND inv.currency = 'PESOS'),(
                SELECT
                TO_CHAR(COALESCE(SUM(inv.total),0.00), 'FM9,999,999,990.00') s3_pagos
                FROM invoices inv
                WHERE inv.status NOT IN ('LIQUIDADA', 'CANCELADA')
                AND inv.company_payment_id ISNULL
                AND inv.due_date BETWEEN first_monday_of_month()+14 AND first_monday_of_month() +20
                AND inv.currency = 'PESOS'),

              (SELECT first_monday_of_month()+21 s4_del), (SELECT first_monday_of_month() +27 s4_al),(
                SELECT
                TO_CHAR(COALESCE(SUM(CASE
                WHEN rei.total_used ISNULL
                  THEN inv.total
                ELSE rei.total_used - rei.interests
                END),0.00), 'FM9,999,999,990.00') s4_descuentos
                FROM invoices inv
                LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
                LEFT JOIN requests req ON (rei.request_id = req.id AND req.status NOT IN ('EJECUTADA', 'LIQUIDADA', 'CANCELADA') AND req.used_date BETWEEN first_monday_of_month()+14 AND first_monday_of_month() +20)
                WHERE inv.status NOT IN ('EJECUTADA', 'LIQUIDADA', 'CANCELADA')
                AND inv.supplier_payment_id ISNULL
                AND (inv.used_date BETWEEN first_monday_of_month()+21 AND first_monday_of_month() +27 OR req.used_date BETWEEN first_monday_of_month()+21 AND first_monday_of_month() +27)
                AND inv.currency = 'PESOS'),(
                SELECT
                TO_CHAR(COALESCE(SUM(inv.total),0.00), 'FM9,999,999,990.00') s4_pagos
                FROM invoices inv
                WHERE inv.status NOT IN ('LIQUIDADA', 'CANCELADA')
                AND inv.company_payment_id ISNULL
                AND inv.due_date BETWEEN first_monday_of_month()+21 AND first_monday_of_month() +27
                AND inv.currency = 'PESOS');"
    @director_report_resume = execute_statement(@query)
    render json: @director_report_resume
  end

  def director_report_detail_discounts
    @query = "SELECT
              inv.id, invoice_folio folio_factura,
              COALESCE(req.folio, 'NA') folio_solicitud,
              TO_CHAR(CASE
              WHEN rei.total_used ISNULL
                THEN inv.total
              ELSE rei.total_used - rei.interests
              END, 'FM9,999,999,990.00') descuento,
              sup.business_name emisor,
              com.business_name receptor,
              inv.currency moneda,
              CASE
              WHEN req.used_date ISNULL
              THEN inv.used_date
              ELSE req.used_date
              END fecha_operacion,
              CASE
              WHEN req.due_date ISNULL
              THEN inv.due_date
              ELSE req.due_date
              END fecha_vencimiento,
              inv.invoice_date fecha_emision,
              inv.entry_date fecha_carga,
              inv.status estatus,
              TO_CHAR(CASE
              WHEN rei.interests ISNULL
                THEN 0.00
              ELSE rei.interests
              END, 'FM9,999,999,990.00') intereses
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id AND req.status NOT IN ('EJECUTADA', 'LIQUIDADA', 'CANCELADA') AND req.used_date BETWEEN first_monday_of_month() AND first_monday_of_month() +27)
              JOIN suppliers sup ON (inv.supplier_id = sup.id)
              JOIN companies com ON (inv.company_id = com.id)
              WHERE inv.status NOT IN ('EJECUTADA', 'LIQUIDADA', 'CANCELADA')
              AND inv.supplier_payment_id ISNULL
              AND (inv.used_date BETWEEN first_monday_of_month() AND first_monday_of_month() +27 OR req.used_date BETWEEN first_monday_of_month() AND first_monday_of_month() +27)
              AND inv.currency = 'PESOS';"
    @director_report_detail_discounts = execute_statement(@query)
    render json: @director_report_detail_discounts
  end

  def director_report_detail_payments
    @query = "SELECT
              invoice_folio folio_factura,
              COALESCE(req.folio, 'NA') folio_solicitud,
              TO_CHAR(inv.total, 'FM9,999,999,990.00') pago,
              sup.business_name emisor,
              com.business_name receptor,
              inv.currency moneda,
              CASE
              WHEN req.used_date ISNULL
                THEN inv.used_date
              ELSE req.used_date
              END fecha_operacion,
              CASE
              WHEN req.due_date ISNULL
                THEN inv.due_date
              ELSE req.due_date
              END fecha_vencimiento,
              inv.invoice_date fecha_emision,
              inv.entry_date fecha_carga,
              inv.status estatus,
              CASE
              WHEN rei.interests ISNULL
                THEN 0.00
              ELSE rei.interests
              END intereses
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id AND req.status = 'EJECUTADA')
              JOIN suppliers sup ON (inv.supplier_id = sup.id)
              JOIN companies com ON (inv.company_id = com.id)
              WHERE inv.status NOT IN ('LIQUIDADA', 'CANCELADA')
              AND inv.company_payment_id ISNULL
              AND inv.due_date BETWEEN first_monday_of_month() AND first_monday_of_month() +27
              AND inv.currency = 'PESOS';"
    @director_report_detail_payments = execute_statement(@query)
    render json: @director_report_detail_payments
  end

  def dashboard_supplier_inv_to_expire_week_not_request
    @query = "SELECT sup.business_name proveedor, com.business_name cadena, inv.invoice_folio folio_factura, inv.uuid uuid_factura, TO_CHAR(inv.total, 'FM9,999,999,990.00') total_factura, inv.invoice_date fecha_factura, inv.entry_date fecha_alta, inv.due_date fecha_vencimiento
    FROM invoices inv, suppliers sup, companies com
    WHERE inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND inv.id NOT IN(select invoice_id from request_invoices)
    AND inv.due_date BETWEEN TO_DATE(to_char(date_trunc('week',current_date),'YYYY-MM-DD'), 'YYYY-MM-DD') AND TO_DATE(to_char(date_trunc('week',current_date),'YYYY-MM-DD'), 'YYYY-MM-DD') +6
    AND inv.status not in ('EJECUTADA', 'LIQUIDADA', 'CANCELADA')
    AND inv.id NOT IN(select invoice_id from payment_invoices)
    AND sup.id = :supplier_id;"
    @query = @query.gsub ':supplier_id', params[:supplier_id].to_s
    @supplier_inv_week = execute_statement(@query)
    render json: @supplier_inv_week
  end

  def dashboard_supplier_inv_to_expire_not_request
    @query = "SELECT sup.business_name proveedor, com.business_name cadena, inv.invoice_folio folio_factura, inv.uuid uuid_factura, TO_CHAR(inv.total, 'FM9,999,999,990.00') total_factura, inv.invoice_date fecha_factura, inv.entry_date fecha_alta, inv.due_date fecha_vencimiento, pro.key clave_proyecto, pro.name nombre_proyecto
    FROM suppliers sup, companies com, invoices inv
    LEFT JOIN company_projects pro ON (inv.company_project_id = pro.id)
    WHERE inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND inv.id NOT IN(select invoice_id from request_invoices)
    AND inv.status not in ('EJECUTADA', 'LIQUIDADA', 'CANCELADA')
    AND inv.id NOT IN(select invoice_id from payment_invoices)
    AND sup.id = :supplier_id;"
    @query = @query.gsub ':supplier_id', params[:supplier_id].to_s
    @supplier_inv = execute_statement(@query)
    render json: @supplier_inv
  end

  def dashboard_supplier_inv_request
    @query = "SELECT sup.business_name proveedor, com.business_name cadena, inv.invoice_folio folio_factura, inv.uuid uuid_factura, TO_CHAR(inv.total, 'FM9,999,999,990.00') total_factura, TO_CHAR(rei.total_used, 'FM9,999,999,990.00') total_operado, TO_CHAR(rei.interests, 'FM9,999,999,990.00') intereses, TO_CHAR(rei.total_used - rei.interests, 'FM9,999,999,990.00') total_neto, inv.invoice_date fecha_factura, inv.entry_date fecha_alta, req.folio folio_solicitud, req.used_date fecha_operacion, pro.key clave_proyecto, pro.name nombre_proyecto
    FROM requests req, request_invoices rei, suppliers sup, companies com, invoices inv
    LEFT JOIN company_projects pro ON (inv.company_project_id = pro.id)
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND inv.status in ('EJECUTADA', 'LIQUIDADA')
    AND inv.id IN(select invoice_id from payment_invoices)
    AND sup.id = :supplier_id;"
    @query = @query.gsub ':supplier_id', params[:supplier_id].to_s
    @supplier_inv_req = execute_statement(@query)
    render json: @supplier_inv_req
  end

  def dashboard_supplier_used_int_rate_month
    @query = "SELECT TO_CHAR(COALESCE(SUM(rei.total_used), 0.00), 'FM9,999,999,990.00') total_operado, TO_CHAR(COALESCE(SUM(rei.interests), 0.00), 'FM9,999,999,990.00') intereses, TO_CHAR(COALESCE(AVG(rei.total_rate),0.00), 'FM9,999,999,990.00') tasa_promedio
    FROM requests req, request_invoices rei, suppliers sup, companies com, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND inv.status in ('EJECUTADA', 'LIQUIDADA')
    AND inv.id IN(select invoice_id from payment_invoices)
    AND req.used_date BETWEEN TO_DATE(to_char(date_trunc('month',current_date),'YYYY-MM-DD'), 'YYYY-MM-DD') AND TO_DATE(to_char(date_trunc('month',current_date) + INTERVAL '1' MONTH - INTERVAL '1' DAY,'YYYY-MM-DD'), 'YYYY-MM-DD')
    AND sup.id = :supplier_id;"
    @query = @query.gsub ':supplier_id', params[:supplier_id].to_s
    @supplier_used_int_rate_month = execute_statement(@query)
    render json: @supplier_used_int_rate_month
  end

  def dashboard_supplier_used_int
    @query = "SELECT TO_CHAR(SUM(rei.total_used), 'FM9,999,999,990.00') total_operado, TO_CHAR(SUM(rei.interests), 'FM9,999,999,990.00') intereses, (SUM(inv.due_date - req.used_date))/count(inv.id) promedio_dias_descontados
    FROM requests req, request_invoices rei, suppliers sup, companies com, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND inv.status in ('EJECUTADA', 'LIQUIDADA')
    AND inv.id IN(select invoice_id from payment_invoices)
    AND sup.id = :supplier_id;"
    @query = @query.gsub ':supplier_id', params[:supplier_id].to_s
    @supplier_used_int = execute_statement(@query)
    render json: @supplier_used_int
  end

  def dashboard_company_invoices_ca
    @query = "SELECT com.business_name cadena, sup.business_name proveedor, inv.invoice_folio folio_factura, inv.uuid uuid_factura, TO_CHAR(inv.total, 'FM9,999,999,990.00') total_factura, inv.invoice_date fecha_factura, inv.entry_date fecha_alta, inv.due_date fecha_vencimiento, pro.key clave_proyecto, pro.name nombre_proyecto
    FROM suppliers sup, companies com, invoices inv
    LEFT JOIN company_projects pro ON (inv.company_project_id = pro.id)
    WHERE inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND inv.status = 'CANCELADA'
    AND com.id = :company_id;"
    @query = @query.gsub ':company_id', params[:company_id].to_s
    @company_invoices_ca = execute_statement(@query)
    render json: @company_invoices_ca
  end

  def dashboard_company_next_payments
    @query = "SELECT
    invoice_folio folio_factura,
    COALESCE(req.folio, 'NA') folio_solicitud,
    TO_CHAR(inv.total, 'FM9,999,999,990.00') pago,
    sup.business_name emisor,
    com.business_name receptor,
    inv.currency moneda,
    CASE
    WHEN req.used_date ISNULL
    THEN inv.used_date
    ELSE req.used_date
    END fecha_operacion,
    CASE
    WHEN req.due_date ISNULL
    THEN inv.due_date
    ELSE req.due_date
    END fecha_vencimiento,
    inv.invoice_date fecha_emision,
    inv.entry_date fecha_carga,
    inv.status estatus,
    TO_CHAR(CASE
    WHEN rei.interests ISNULL
    THEN 0.00
    ELSE rei.interests
    END, 'FM9,999,999,990.00') intereses
    FROM invoices inv
    LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
    LEFT JOIN requests req ON (rei.request_id = req.id AND req.status = 'EJECUTADA')
    JOIN suppliers sup ON (inv.supplier_id = sup.id)
    JOIN companies com ON (inv.company_id = com.id)
    WHERE inv.status = 'EJECUTADA'
    AND inv.company_payment_id ISNULL
    AND inv.due_date BETWEEN current_date AND current_date +27
    AND inv.currency = 'PESOS'
    AND com.id=:company_id;"
    @query = @query.gsub ':company_id', params[:company_id].to_s
    @company_next_payments = execute_statement(@query)
    render json: @company_next_payments
  end

  def dashboard_company_all_invoices
    @query = "SELECT
    invoice_folio folio_factura,
    COALESCE(req.folio, 'NA') folio_solicitud,
    inv.uuid uuid_factura_descontada,
    sup.business_name emisor,
    com.business_name receptor,
    inv.currency moneda,
    CASE
    WHEN req.used_date ISNULL
      THEN inv.used_date
    ELSE req.used_date
    END fecha_operacion,
    CASE
    WHEN req.capacity ISNULL
      THEN 100.00
    ELSE req.capacity
    END porcentaje_operado,
    CASE
    WHEN rei.total_used ISNULL
      THEN TO_CHAR(inv.total, 'FM9,999,999,990.00')
    ELSE TO_CHAR(rei.total_used, 'FM9,999,999,990.00')
    END monto_operado,
    TO_CHAR(CASE
    WHEN rei.total_used ISNULL
      THEN 0.00
    ELSE inv.total - rei.total_used
    END, 'FM9,999,999,990.00') disponible,
    CASE
    WHEN req.due_date ISNULL
      THEN inv.due_date
    ELSE req.due_date
    END fecha_vencimiento,
    inv.invoice_date fecha_emision,
    inv.entry_date fecha_carga,
    inv.status estatus,
    TO_CHAR(CASE
    WHEN rei.interests ISNULL
      THEN 0.00
    ELSE rei.interests
    END, 'FM9,999,999,990.00') intereses,
    CASE
    WHEN rei.interests ISNULL
      THEN TO_CHAR(0.00, 'FM9,999,999,990.00')
    ELSE  TO_CHAR(rei.interests * (cse.fee / 100), 'FM9,999,999,990.00')
    END comision_cadena,
    pay.payment_date dia_pago_cadena,
    inv.due_date - pay.payment_date dias_al_vencimiento
    FROM invoices inv
    LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
    LEFT JOIN requests req ON (rei.request_id = req.id)
    JOIN suppliers sup ON (inv.supplier_id = sup.id)
    JOIN companies com ON (inv.company_id = com.id)
    JOIN company_segments cse ON (com.id = cse.company_id)
    LEFT JOIN payments pay ON (inv.company_payment_id = pay.id)
    WHERE com.id = :company_id;"
    @query = @query.gsub ':company_id', params[:company_id].to_s
    @company_all_invoices = execute_statement(@query)
    render json: @company_all_invoices
  end

  def dashboard_company_invoices_vs_desc
    @query = "SELECT TO_CHAR(count(inv.id), 'FM9,999,999,990') total_facturas, TO_CHAR(count(rei.invoice_id), 'FM9,999,999,990') total_facturas_en_descuento, TO_CHAR((count(rei.invoice_id) * 100)/count(inv.id), 'FM990.00') porcentaje_descuento
    FROM companies com, invoices inv
    LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
    LEFT JOIN requests req ON (rei.request_id = req.id)
    WHERE inv.company_id = com.id
    AND com.id = :company_id;"
    @query = @query.gsub ':company_id', params[:company_id].to_s
    @company_invoices_vs_desc = execute_statement(@query)
    render json: @company_invoices_vs_desc
  end

  def dashboard_company_cancel_invoices
    @query = "SELECT
    (SELECT COUNT(inv.id) enero
    FROM invoices inv, invoice_details ind, companies com, suppliers sup
    WHERE inv.company_id = com.id
    AND inv.supplier_id = sup.id
    AND inv.id = ind.invoice_id
    AND ind.status = 'CANCELADA'
    AND com.id = company_id
    AND com.id = :company_id
    AND TO_CHAR(ind.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-01'),
    (SELECT COUNT(inv.id) febrero
    FROM invoices inv, invoice_details ind, companies com, suppliers sup
    WHERE inv.company_id = com.id
    AND inv.supplier_id = sup.id
    AND inv.id = ind.invoice_id
    AND ind.status = 'CANCELADA'
    AND com.id = company_id
    AND com.id = :company_id
    AND TO_CHAR(ind.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-02'),
    (SELECT COUNT(inv.id) marzo
    FROM invoices inv, invoice_details ind, companies com, suppliers sup
    WHERE inv.company_id = com.id
    AND inv.supplier_id = sup.id
    AND inv.id = ind.invoice_id
    AND ind.status = 'CANCELADA'
    AND com.id = company_id
    AND com.id = :company_id
    AND TO_CHAR(ind.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-03'),
    (SELECT COUNT(inv.id) abril
    FROM invoices inv, invoice_details ind, companies com, suppliers sup
    WHERE inv.company_id = com.id
    AND inv.supplier_id = sup.id
    AND inv.id = ind.invoice_id
    AND ind.status = 'CANCELADA'
    AND com.id = company_id
    AND com.id = :company_id
    AND TO_CHAR(ind.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-04'),
    (SELECT COUNT(inv.id) mayo
    FROM invoices inv, invoice_details ind, companies com, suppliers sup
    WHERE inv.company_id = com.id
    AND inv.supplier_id = sup.id
    AND inv.id = ind.invoice_id
    AND ind.status = 'CANCELADA'
    AND com.id = company_id
    AND com.id = :company_id
    AND TO_CHAR(ind.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-05'),
    (SELECT COUNT(inv.id) junio
    FROM invoices inv, invoice_details ind, companies com, suppliers sup
    WHERE inv.company_id = com.id
    AND inv.supplier_id = sup.id
    AND inv.id = ind.invoice_id
    AND ind.status = 'CANCELADA'
    AND com.id = company_id
    AND com.id = :company_id
    AND TO_CHAR(ind.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-06'),
    (SELECT COUNT(inv.id) julio
    FROM invoices inv, invoice_details ind, companies com, suppliers sup
    WHERE inv.company_id = com.id
    AND inv.supplier_id = sup.id
    AND inv.id = ind.invoice_id
    AND ind.status = 'CANCELADA'
    AND com.id = company_id
    AND com.id = :company_id
    AND TO_CHAR(ind.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-07'),
    (SELECT COUNT(inv.id) agosto
    FROM invoices inv, invoice_details ind, companies com, suppliers sup
    WHERE inv.company_id = com.id
    AND inv.supplier_id = sup.id
    AND inv.id = ind.invoice_id
    AND ind.status = 'CANCELADA'
    AND com.id = company_id
    AND com.id = :company_id
    AND TO_CHAR(ind.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-08'),
    (SELECT COUNT(inv.id) septiembre
    FROM invoices inv, invoice_details ind, companies com, suppliers sup
    WHERE inv.company_id = com.id
    AND inv.supplier_id = sup.id
    AND inv.id = ind.invoice_id
    AND ind.status = 'CANCELADA'
    AND com.id = company_id
    AND com.id = :company_id
    AND TO_CHAR(ind.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-09'),
    (SELECT COUNT(inv.id) octubre
    FROM invoices inv, invoice_details ind, companies com, suppliers sup
    WHERE inv.company_id = com.id
    AND inv.supplier_id = sup.id
    AND inv.id = ind.invoice_id
    AND ind.status = 'CANCELADA'
    AND com.id = company_id
    AND com.id = :company_id
    AND TO_CHAR(ind.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-10'),
    (SELECT COUNT(inv.id) noviembre
    FROM invoices inv, invoice_details ind, companies com, suppliers sup
    WHERE inv.company_id = com.id
    AND inv.supplier_id = sup.id
    AND inv.id = ind.invoice_id
    AND ind.status = 'CANCELADA'
    AND com.id = company_id
    AND com.id = :company_id
    AND TO_CHAR(ind.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-11'),
    (SELECT COUNT(inv.id) diciembre
    FROM invoices inv, invoice_details ind, companies com, suppliers sup
    WHERE inv.company_id = com.id
    AND inv.supplier_id = sup.id
    AND inv.id = ind.invoice_id
    AND ind.status = 'CANCELADA'
    AND com.id = company_id
    AND com.id = :company_id
    AND TO_CHAR(ind.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-12');"
    @query = @query.gsub ':company_id', params[:company_id].to_s
    @company_cancel_invoices = execute_statement(@query)
    render json: @company_cancel_invoices
  end

  def dashboard_company_cancel_invoices_detail
    @query = "SELECT
    invoice_folio folio_factura,
    inv.uuid uuid_factura,
    sup.business_name emisor,
    com.business_name receptor,
    TO_CHAR(inv.total, 'FM9,999,999,990.00') total_factura,
    inv.currency moneda,
    inv.invoice_date fecha_emision,
    inv.entry_date fecha_carga,
    inv.used_date fecha_operacion,
    inv.due_date fecha_vencimiento,
    ind.created_at fecha_cancelacion,
    inv.status estatus,
    ind.notes comentarios
    FROM invoices inv, invoice_details ind, companies com, suppliers sup
    WHERE inv.company_id = com.id
    AND inv.supplier_id = sup.id
    AND inv.id = ind.invoice_id
    AND ind.status = 'CANCELADA'
    AND com.id = company_id
    AND com.id = :company_id
    AND TO_CHAR(ind.created_at, 'YYYY') = to_char(CURRENT_DATE, 'YYYY');"
    @query = @query.gsub ':company_id', params[:company_id].to_s
    @company_cancel_invoices_detail = execute_statement(@query)
    render json: @company_cancel_invoices_detail
  end

  def dashboard_company_fees
    @query = "SELECT
    (SELECT cos.fee porcentaje_comision
    FROM companies com, company_segments cos
    WHERE com.id = cos.company_id
    AND com.id = :company_id),
    (SELECT TO_CHAR(COALESCE(sum((cos.fee * rei.interests) / rei.total_rate),0.00), 'FM9,999,999,990.00') comision_enero
    FROM requests req, request_invoices rei, suppliers sup, companies com, company_segments cos, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND com.id = cos.company_id
    AND inv.status != ('CANCELADA')
    AND TO_CHAR(req.used_date, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-01'
    AND com.id = :company_id),
    (SELECT TO_CHAR(COALESCE(sum((cos.fee * rei.interests) / rei.total_rate),0.00), 'FM9,999,999,990.00') comision_febrero
    FROM requests req, request_invoices rei, suppliers sup, companies com, company_segments cos, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND com.id = cos.company_id
    AND inv.status != ('CANCELADA')
    AND TO_CHAR(req.used_date, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-02'
    AND com.id = :company_id),
    (SELECT TO_CHAR(COALESCE(sum((cos.fee * rei.interests) / rei.total_rate),0.00), 'FM9,999,999,990.00') comision_marzo
    FROM requests req, request_invoices rei, suppliers sup, companies com, company_segments cos, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND com.id = cos.company_id
    AND inv.status != ('CANCELADA')
    AND TO_CHAR(req.used_date, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-03'
    AND com.id = :company_id),
    (SELECT TO_CHAR(COALESCE(sum((cos.fee * rei.interests) / rei.total_rate),0.00), 'FM9,999,999,990.00') comision_abril
    FROM requests req, request_invoices rei, suppliers sup, companies com, company_segments cos, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND com.id = cos.company_id
    AND inv.status != ('CANCELADA')
    AND TO_CHAR(req.used_date, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-04'
    AND com.id = :company_id),
    (SELECT TO_CHAR(COALESCE(sum((cos.fee * rei.interests) / rei.total_rate),0.00), 'FM9,999,999,990.00') comision_mayo
    FROM requests req, request_invoices rei, suppliers sup, companies com, company_segments cos, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND com.id = cos.company_id
    AND inv.status != ('CANCELADA')
    AND TO_CHAR(req.used_date, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-05'
    AND com.id = :company_id),
    (SELECT TO_CHAR(COALESCE(sum((cos.fee * rei.interests) / rei.total_rate),0.00), 'FM9,999,999,990.00') comision_junio
    FROM requests req, request_invoices rei, suppliers sup, companies com, company_segments cos, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND com.id = cos.company_id
    AND inv.status != ('CANCELADA')
    AND TO_CHAR(req.used_date, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-06'
    AND com.id = :company_id),
    (SELECT TO_CHAR(COALESCE(sum((cos.fee * rei.interests) / rei.total_rate),0.00), 'FM9,999,999,990.00') comision_julio
    FROM requests req, request_invoices rei, suppliers sup, companies com, company_segments cos, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND com.id = cos.company_id
    AND inv.status != ('CANCELADA')
    AND TO_CHAR(req.used_date, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-07'
    AND com.id = :company_id),
    (SELECT TO_CHAR(COALESCE(sum((cos.fee * rei.interests) / rei.total_rate),0.00), 'FM9,999,999,990.00') comision_agosto
    FROM requests req, request_invoices rei, suppliers sup, companies com, company_segments cos, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND com.id = cos.company_id
    AND inv.status != ('CANCELADA')
    AND TO_CHAR(req.used_date, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-08'
    AND com.id = :company_id),
    (SELECT TO_CHAR(COALESCE(sum((cos.fee * rei.interests) / rei.total_rate),0.00), 'FM9,999,999,990.00') comision_septiembre
    FROM requests req, request_invoices rei, suppliers sup, companies com, company_segments cos, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND com.id = cos.company_id
    AND inv.status != ('CANCELADA')
    AND TO_CHAR(req.used_date, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-09'
    AND com.id = :company_id),
    (SELECT TO_CHAR(COALESCE(sum((cos.fee * rei.interests) / rei.total_rate),0.00), 'FM9,999,999,990.00') comision_octubre
    FROM requests req, request_invoices rei, suppliers sup, companies com, company_segments cos, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND com.id = cos.company_id
    AND inv.status != ('CANCELADA')
    AND TO_CHAR(req.used_date, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-10'
    AND com.id = :company_id),
    (SELECT TO_CHAR(COALESCE(sum((cos.fee * rei.interests) / rei.total_rate),0.00), 'FM9,999,999,990.00') comision_noviembre
    FROM requests req, request_invoices rei, suppliers sup, companies com, company_segments cos, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND com.id = cos.company_id
    AND inv.status != ('CANCELADA')
    AND TO_CHAR(req.used_date, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-11'
    AND com.id = :company_id),
    (SELECT TO_CHAR(COALESCE(sum((cos.fee * rei.interests) / rei.total_rate),0.00), 'FM9,999,999,990.00') comision_diciembre
    FROM requests req, request_invoices rei, suppliers sup, companies com, company_segments cos, invoices inv
    WHERE inv.id = rei.invoice_id
    AND req.id = rei.request_id
    AND inv.supplier_id = sup.id
    AND inv.company_id = com.id
    AND com.id = cos.company_id
    AND inv.status != ('CANCELADA')
    AND TO_CHAR(req.used_date, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-12'
    AND com.id = :company_id);"
    @query = @query.gsub ':company_id', params[:company_id].to_s
    @company_fees = execute_statement(@query)
    render json: @company_fees
  end

  def dashboard_sofom_payments_vs_discounts
    @query = "SELECT first_monday_of_month() del, first_monday_of_month() +27 al,(
              SELECT
              TO_CHAR(COALESCE(SUM(CASE
              WHEN rei.total_used ISNULL
              THEN inv.total
              ELSE rei.total_used - rei.interests
              END),0.00), 'FM9,999,999,990.00') descuentos
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id AND req.status NOT IN ('EJECUTADA', 'LIQUIDADA', 'CANCELADA') AND req.used_date BETWEEN first_monday_of_month() AND first_monday_of_month() +27)
              WHERE inv.status NOT IN ('EJECUTADA', 'LIQUIDADA', 'CANCELADA')
              AND inv.supplier_payment_id ISNULL
              AND (inv.used_date BETWEEN first_monday_of_month() AND first_monday_of_month() +27 OR req.used_date BETWEEN first_monday_of_month() AND first_monday_of_month() +27)
              AND inv.currency = 'PESOS'),(
              SELECT
              TO_CHAR(COALESCE(SUM(inv.total),0.00), 'FM9,999,999,990.00') pagos
              FROM invoices inv
              WHERE inv.status NOT IN ('LIQUIDADA', 'CANCELADA')
              AND inv.company_payment_id ISNULL
              AND inv.due_date BETWEEN first_monday_of_month() AND first_monday_of_month() +27
              AND inv.currency = 'PESOS');"
    @sofom_payments_vs_discounts = execute_statement(@query)
    render json: @sofom_payments_vs_discounts
  end

  def dashboard_sofom_suppliers_for_company
    @query = "SELECT compa.business_name cadena, COUNT(suppl.id)  afiliados
              FROM companies compa, suppliers suppl, supplier_segments suseg
              WHERE compa.id = suseg.company_id
              AND suppl.id = suseg.supplier_id
              GROUP BY compa.business_name;"
    @sofom_suppliers_for_company = execute_statement(@query)
    render json: @sofom_suppliers_for_company
  end

  def dashboard_sofom_interest_discounts_month
    @query = "SELECT (SELECT 'ENERO' mes), (SELECT TO_CHAR(COALESCE(SUM(rei.interests), 0.00), 'FM9,999,999,990.00') total_intereses_enero
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-01'),
              (SELECT TO_CHAR(COALESCE(SUM(rei.total_used - rei.interests),0.00), 'FM9,999,990.00') total_dispuesto_enero
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-01'),
              (SELECT 'FEBRERO' mes), (SELECT TO_CHAR(COALESCE(SUM(rei.interests), 0.00), 'FM9,999,999,990.00') total_intereses_febrero
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-02'),
              (SELECT TO_CHAR(COALESCE(SUM(rei.total_used - rei.interests),0.00), 'FM9,999,990.00') total_dispuesto_febrero
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-02'),
              (SELECT 'MAZO' mes), (SELECT TO_CHAR(COALESCE(SUM(rei.interests), 0.00), 'FM9,999,999,990.00') total_intereses_marzo
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-03'),
              (SELECT TO_CHAR(COALESCE(SUM(rei.total_used - rei.interests),0.00), 'FM9,999,990.00') total_dispuesto_marzo
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-03'),
              (SELECT 'ABRIL' mes), (SELECT TO_CHAR(COALESCE(SUM(rei.interests), 0.00), 'FM9,999,999,990.00') total_intereses_abril
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-04'),
              (SELECT TO_CHAR(COALESCE(SUM(rei.total_used - rei.interests),0.00), 'FM9,999,990.00') total_dispuesto_abril
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-04'),
              (SELECT 'MAYO' mes), (SELECT TO_CHAR(COALESCE(SUM(rei.interests), 0.00), 'FM9,999,999,990.00') total_intereses_mayo
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-05'),
              (SELECT TO_CHAR(COALESCE(SUM(rei.total_used - rei.interests),0.00), 'FM9,999,990.00') total_dispuesto_mayo
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-05'),
              (SELECT 'JUNIO' mes), (SELECT TO_CHAR(COALESCE(SUM(rei.interests), 0.00), 'FM9,999,999,990.00') total_intereses_junio
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-06'),
              (SELECT TO_CHAR(COALESCE(SUM(rei.total_used - rei.interests),0.00), 'FM9,999,990.00') total_dispuesto_junio
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-06'),
              (SELECT 'JULIO' mes), (SELECT TO_CHAR(COALESCE(SUM(rei.interests), 0.00), 'FM9,999,999,990.00') total_intereses_julio
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-07'),
              (SELECT TO_CHAR(COALESCE(SUM(rei.total_used - rei.interests),0.00), 'FM9,999,990.00') total_dispuesto_julio
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-07'),
              (SELECT 'AGOSTO' mes), (SELECT TO_CHAR(COALESCE(SUM(rei.interests), 0.00), 'FM9,999,999,990.00') total_intereses_agosto
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-08'),
              (SELECT TO_CHAR(COALESCE(SUM(rei.total_used - rei.interests),0.00), 'FM9,999,990.00') total_dispuesto_agosto
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-08'),
              (SELECT 'SEPTIEMBRE' mes), (SELECT TO_CHAR(COALESCE(SUM(rei.interests), 0.00), 'FM9,999,999,990.00') total_intereses_septiembre
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-09'),
              (SELECT TO_CHAR(COALESCE(SUM(rei.total_used - rei.interests),0.00), 'FM9,999,990.00') total_dispuesto_septiembre
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-09'),
              (SELECT 'OCTUBRE' mes), (SELECT TO_CHAR(COALESCE(SUM(rei.interests), 0.00), 'FM9,999,999,990.00') total_intereses_octubre
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-10'),
              (SELECT TO_CHAR(COALESCE(SUM(rei.total_used - rei.interests),0.00), 'FM9,999,990.00') total_dispuesto_octubre
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-10'),
              (SELECT 'NOVIEMBRE' mes), (SELECT TO_CHAR(COALESCE(SUM(rei.interests), 0.00), 'FM9,999,999,990.00') total_intereses_noviembre
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-11'),
              (SELECT TO_CHAR(COALESCE(SUM(rei.total_used - rei.interests),0.00), 'FM9,999,990.00') total_dispuesto_noviembre
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-11'),
              (SELECT 'DICIEMBRE' diciembre), (SELECT TO_CHAR(COALESCE(SUM(rei.interests), 0.00), 'FM9,999,999,990.00') total_intereses_diciembre
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-12'),
              (SELECT TO_CHAR(COALESCE(SUM(rei.total_used - rei.interests),0.00), 'FM9,999,990.00') total_dispuesto_diciembre
              FROM companies com, suppliers sup, supplier_segments sus, contributors con, invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              LEFT JOIN payments pay ON (pay.id = inv.supplier_payment_id AND inv.supplier_payment_id IS NOT NULL)
              WHERE com.id = sus.company_id
              AND sup.id = sus.supplier_id
              AND inv.company_id = com.id
              AND inv.supplier_id = sup.id
              AND com.contributor_id = con.id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-12');"
    @sofom_interest_discounts_month = execute_statement(@query)
    render json: @sofom_interest_discounts_month
  end

  def dashboard_sofom_invoices_vs_discounts_month
    @query = "SELECT 'ENERO' mes, count(inv.id) total_facturas, count(rei.invoice_id) total_facturas_en_descuento, CASE
                                                                                                                    WHEN count(inv.id) = 0
                                                                                                                    THEN 0
                                                                                                                    ELSE (count(rei.invoice_id) * 100)/count(inv.id)
                                                                                                                    END porcentaje_descuento
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              WHERE inv.status NOT IN ('CANCELADA')
              AND TO_CHAR(inv.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-01'
              UNION
              SELECT 'FEBRERO' mes, count(inv.id) total_facturas, count(rei.invoice_id) total_facturas_en_descuento, CASE
                                                                                                                      WHEN count(inv.id) = 0
                                                                                                                      THEN 0
                                                                                                                      ELSE (count(rei.invoice_id) * 100)/count(inv.id)
                                                                                                                      END porcentaje_descuento
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              WHERE inv.status NOT IN ('CANCELADA')
              AND TO_CHAR(inv.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-02'
              UNION
              SELECT 'MARZO' mes, count(inv.id) total_facturas, count(rei.invoice_id) total_facturas_en_descuento, CASE
                                                                                                                    WHEN count(inv.id) = 0
                                                                                                                    THEN 0
                                                                                                                    ELSE (count(rei.invoice_id) * 100)/count(inv.id)
                                                                                                                    END porcentaje_descuento
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              WHERE inv.status NOT IN ('CANCELADA')
              AND TO_CHAR(inv.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-03'
              UNION
              SELECT 'ABRIL' mes, count(inv.id) total_facturas, count(rei.invoice_id) total_facturas_en_descuento, CASE
                                                                                                                    WHEN count(inv.id) = 0
                                                                                                                    THEN 0
                                                                                                                    ELSE (count(rei.invoice_id) * 100)/count(inv.id)
                                                                                                                    END porcentaje_descuento
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              WHERE inv.status NOT IN ('CANCELADA')
              AND TO_CHAR(inv.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-04'
              UNION
              SELECT 'MAYO' mes, count(inv.id) total_facturas, count(rei.invoice_id) total_facturas_en_descuento, CASE
                                                                                                                    WHEN count(inv.id) = 0
                                                                                                                    THEN 0
                                                                                                                    ELSE (count(rei.invoice_id) * 100)/count(inv.id)
                                                                                                                    END porcentaje_descuento
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              WHERE inv.status NOT IN ('CANCELADA')
              AND TO_CHAR(inv.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-05'
              UNION
              SELECT 'JUNIO' mes, count(inv.id) total_facturas, count(rei.invoice_id) total_facturas_en_descuento, CASE
                                                                                                                    WHEN count(inv.id) = 0
                                                                                                                    THEN 0
                                                                                                                    ELSE (count(rei.invoice_id) * 100)/count(inv.id)
                                                                                                                    END porcentaje_descuento
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              WHERE inv.status NOT IN ('CANCELADA')
              AND TO_CHAR(inv.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-06'
              UNION
              SELECT 'JULIO' mes, count(inv.id) total_facturas, count(rei.invoice_id) total_facturas_en_descuento, CASE
                                                                                                                    WHEN count(inv.id) = 0
                                                                                                                    THEN 0
                                                                                                                    ELSE (count(rei.invoice_id) * 100)/count(inv.id)
                                                                                                                    END porcentaje_descuento
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              WHERE inv.status NOT IN ('CANCELADA')
              AND TO_CHAR(inv.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-07'
              UNION
              SELECT 'AGOSTO' mes, count(inv.id) total_facturas, count(rei.invoice_id) total_facturas_en_descuento, CASE
                                                                                                                      WHEN count(inv.id) = 0
                                                                                                                      THEN 0
                                                                                                                      ELSE (count(rei.invoice_id) * 100)/count(inv.id)
                                                                                                                      END porcentaje_descuento
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              WHERE inv.status NOT IN ('CANCELADA')
              AND TO_CHAR(inv.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-08'
              UNION
              SELECT 'SEPTIEMBRE' mes, count(inv.id) total_facturas, count(rei.invoice_id) total_facturas_en_descuento, CASE
                                                                                                                          WHEN count(inv.id) = 0
                                                                                                                          THEN 0
                                                                                                                          ELSE (count(rei.invoice_id) * 100)/count(inv.id)
                                                                                                                          END porcentaje_descuento
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              WHERE inv.status NOT IN ('CANCELADA')
              AND TO_CHAR(inv.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-09'
              UNION
              SELECT 'OCTUBRE' mes, count(inv.id) total_facturas, count(rei.invoice_id) total_facturas_en_descuento, CASE
                                                                                                                      WHEN count(inv.id) = 0
                                                                                                                      THEN 0
                                                                                                                      ELSE (count(rei.invoice_id) * 100)/count(inv.id)
                                                                                                                      END porcentaje_descuento
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              WHERE inv.status NOT IN ('CANCELADA')
              AND TO_CHAR(inv.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-10'
              UNION
              SELECT 'NOVIEMBRE' mes, count(inv.id) total_facturas, count(rei.invoice_id) total_facturas_en_descuento, CASE
                                                                                                                        WHEN count(inv.id) = 0
                                                                                                                        THEN 0
                                                                                                                        ELSE (count(rei.invoice_id) * 100)/count(inv.id)
                                                                                                                        END porcentaje_descuento
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              WHERE inv.status NOT IN ('CANCELADA')
              AND TO_CHAR(inv.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-11'
              UNION
              SELECT 'DICIEMBRE' mes, count(inv.id) total_facturas, count(rei.invoice_id) total_facturas_en_descuento, CASE
                                                                                                                        WHEN count(inv.id) = 0
                                                                                                                        THEN 0
                                                                                                                        ELSE (count(rei.invoice_id) * 100)/count(inv.id)
                                                                                                                        END porcentaje_descuento
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              WHERE inv.status NOT IN ('CANCELADA')
              AND TO_CHAR(inv.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-12';"
    @sofom_invoices_vs_discounts_month = execute_statement(@query)
    render json: @sofom_invoices_vs_discounts_month
  end

  def dashboard_sofom_suppliers_movements
    @query = "SELECT 'ENERO' mes,
              (SELECT COUNT(sup.id)
              FROM suppliers sup
              WHERE TO_CHAR(sup.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-01') afiliados,
              (SELECT COUNT(sup.id)
              FROM suppliers sup, supplier_segments sus
              WHERE sup.id = sus.supplier_id
              AND sus.status = 'BLOQUEADO'
              AND TO_CHAR(sus.updated_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-01') bloqueados,
              (SELECT COUNT(distinct(sup.id))
              FROM suppliers sup, contributors con, payments pay
              WHERE sup.contributor_id = con.id
              AND con.id = pay.contributor_to_id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-01') que_operaron
              UNION
              SELECT 'FEBRERO' mes,
              (SELECT COUNT(sup.id)
              FROM suppliers sup
              WHERE TO_CHAR(sup.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-02'),
              (SELECT COUNT(sup.id)
              FROM suppliers sup, supplier_segments sus
              WHERE sup.id = sus.supplier_id
              AND sus.status = 'BLOQUEADO'
              AND TO_CHAR(sus.updated_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-02'),
              (SELECT COUNT(distinct(sup.id))
              FROM suppliers sup, contributors con, payments pay
              WHERE sup.contributor_id = con.id
              AND con.id = pay.contributor_to_id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-02')
              UNION
              SELECT 'MARZO' mes,
              (SELECT COUNT(sup.id)
              FROM suppliers sup
              WHERE TO_CHAR(sup.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-03'),
              (SELECT COUNT(sup.id)
              FROM suppliers sup, supplier_segments sus
              WHERE sup.id = sus.supplier_id
              AND sus.status = 'BLOQUEADO'
              AND TO_CHAR(sus.updated_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-03'),
              (SELECT COUNT(distinct(sup.id))
              FROM suppliers sup, contributors con, payments pay
              WHERE sup.contributor_id = con.id
              AND con.id = pay.contributor_to_id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-03')
              UNION
              SELECT 'ABRIL' mes,
              (SELECT COUNT(sup.id)
              FROM suppliers sup
              WHERE TO_CHAR(sup.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-04'),
              (SELECT COUNT(sup.id)
              FROM suppliers sup, supplier_segments sus
              WHERE sup.id = sus.supplier_id
              AND sus.status = 'BLOQUEADO'
              AND TO_CHAR(sus.updated_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-04'),
              (SELECT COUNT(distinct(sup.id))
              FROM suppliers sup, contributors con, payments pay
              WHERE sup.contributor_id = con.id
              AND con.id = pay.contributor_to_id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-04')
              UNION
              SELECT 'MAYO' mes,
              (SELECT COUNT(sup.id)
              FROM suppliers sup
              WHERE TO_CHAR(sup.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-05'),
              (SELECT COUNT(sup.id)
              FROM suppliers sup, supplier_segments sus
              WHERE sup.id = sus.supplier_id
              AND sus.status = 'BLOQUEADO'
              AND TO_CHAR(sus.updated_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-05'),
              (SELECT COUNT(distinct(sup.id))
              FROM suppliers sup, contributors con, payments pay
              WHERE sup.contributor_id = con.id
              AND con.id = pay.contributor_to_id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-05')
              UNION
              SELECT 'JUNIO' mes,
              (SELECT COUNT(sup.id)
              FROM suppliers sup
              WHERE TO_CHAR(sup.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-06'),
              (SELECT COUNT(sup.id)
              FROM suppliers sup, supplier_segments sus
              WHERE sup.id = sus.supplier_id
              AND sus.status = 'BLOQUEADO'
              AND TO_CHAR(sus.updated_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-06'),
              (SELECT COUNT(distinct(sup.id))
              FROM suppliers sup, contributors con, payments pay
              WHERE sup.contributor_id = con.id
              AND con.id = pay.contributor_to_id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-06')
              UNION
              SELECT 'JULIO' mes,
              (SELECT COUNT(sup.id)
              FROM suppliers sup
              WHERE TO_CHAR(sup.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-07'),
              (SELECT COUNT(sup.id)
              FROM suppliers sup, supplier_segments sus
              WHERE sup.id = sus.supplier_id
              AND sus.status = 'BLOQUEADO'
              AND TO_CHAR(sus.updated_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-07'),
              (SELECT COUNT(distinct(sup.id))
              FROM suppliers sup, contributors con, payments pay
              WHERE sup.contributor_id = con.id
              AND con.id = pay.contributor_to_id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-07')
              UNION
              SELECT 'AGOSTO' mes,
              (SELECT COUNT(sup.id)
              FROM suppliers sup
              WHERE TO_CHAR(sup.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-08'),
              (SELECT COUNT(sup.id)
              FROM suppliers sup, supplier_segments sus
              WHERE sup.id = sus.supplier_id
              AND sus.status = 'BLOQUEADO'
              AND TO_CHAR(sus.updated_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-08'),
              (SELECT COUNT(distinct(sup.id))
              FROM suppliers sup, contributors con, payments pay
              WHERE sup.contributor_id = con.id
              AND con.id = pay.contributor_to_id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-09')
              UNION
              SELECT 'SEPTIEMBRE' mes,
              (SELECT COUNT(sup.id)
              FROM suppliers sup
              WHERE TO_CHAR(sup.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-09'),
              (SELECT COUNT(sup.id)
              FROM suppliers sup, supplier_segments sus
              WHERE sup.id = sus.supplier_id
              AND sus.status = 'BLOQUEADO'
              AND TO_CHAR(sus.updated_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-09'),
              (SELECT COUNT(distinct(sup.id))
              FROM suppliers sup, contributors con, payments pay
              WHERE sup.contributor_id = con.id
              AND con.id = pay.contributor_to_id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-09')
              UNION
              SELECT 'OCTUBRE' mes,
              (SELECT COUNT(sup.id)
              FROM suppliers sup
              WHERE TO_CHAR(sup.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-10'),
              (SELECT COUNT(sup.id)
              FROM suppliers sup, supplier_segments sus
              WHERE sup.id = sus.supplier_id
              AND sus.status = 'BLOQUEADO'
              AND TO_CHAR(sus.updated_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-10'),
              (SELECT COUNT(distinct(sup.id))
              FROM suppliers sup, contributors con, payments pay
              WHERE sup.contributor_id = con.id
              AND con.id = pay.contributor_to_id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-10')
              UNION
              SELECT 'NOVIEMBRE' mes,
              (SELECT COUNT(sup.id)
              FROM suppliers sup
              WHERE TO_CHAR(sup.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-11'),
              (SELECT COUNT(sup.id)
              FROM suppliers sup, supplier_segments sus
              WHERE sup.id = sus.supplier_id
              AND sus.status = 'BLOQUEADO'
              AND TO_CHAR(sus.updated_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-11'),
              (SELECT COUNT(distinct(sup.id))
              FROM suppliers sup, contributors con, payments pay
              WHERE sup.contributor_id = con.id
              AND con.id = pay.contributor_to_id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-11')
              UNION
              SELECT 'DICIEMBRE' mes,
              (SELECT COUNT(sup.id)
              FROM suppliers sup
              WHERE TO_CHAR(sup.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-12'),
              (SELECT COUNT(sup.id)
              FROM suppliers sup, supplier_segments sus
              WHERE sup.id = sus.supplier_id
              AND sus.status = 'BLOQUEADO'
              AND TO_CHAR(sus.updated_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-12'),
              (SELECT COUNT(distinct(sup.id))
              FROM suppliers sup, contributors con, payments pay
              WHERE sup.contributor_id = con.id
              AND con.id = pay.contributor_to_id
              AND TO_CHAR(pay.created_at, 'YYYY-MM') = to_char(CURRENT_DATE, 'YYYY')||'-12');"
    @sofom_suppliers_for_company = execute_statement(@query)
    render json: @sofom_suppliers_for_company
  end

  def dashboard_sofom_avg_discount_days_avg
    @query = "SELECT (SELECT TO_CHAR(SUM(sus.rate) / COUNT(sus.rate), 'FM90.00')
		FROM supplier_segments sus) tasa_promedio,
		(SELECT TO_CHAR(sum(inv.due_date - req.used_date) / count(req.id), 'FM9,999,999,990.00') dias_descuento_promedio
		FROM invoices inv
		LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
		LEFT JOIN requests req ON (rei.request_id = req.id));"
    @sofom_avg_discount_days_avg = execute_statement(@query)
    render json: @sofom_avg_discount_days_avg
  end

  def invoice_cfdis
    @query = "SELECT
              inv.invoice_serie serie_factura,
              invoice_folio folio_factura,
              req.folio folio_solicitud,
              inv.uuid uuid_factura,
              sup.business_name proveedor,
              com.business_name cadena,
              inv.currency moneda,
              cfdi_int.uuid uuid_cfdi_intereses,
              cfdi_int.download_xml xml_cfdi_intereses,
              cfdi_int.download_pdf pdf_cfdi_intereses,
              cfdi_co_sup.uuid uuid_cfdi_complemento_proveedor,
              cfdi_co_sup.download_xml xml_cfdi_complemento_proveedor,
              cfdi_co_sup.download_pdf pdf_cfdi_complemento_proveedor,
              cfdi_co_com.uuid uuid_cfdi_complemento_cadena,
              cfdi_co_com.download_xml xml_cfdi_complemento_cadena,
              cfdi_co_com.download_pdf pdf_cfdi_complemento_cadena
              FROM invoices inv
              LEFT JOIN request_invoices rei ON (inv.id = rei.invoice_id)
              LEFT JOIN requests req ON (rei.request_id = req.id)
              JOIN suppliers sup ON (inv.supplier_id = sup.id)
              JOIN companies com ON (inv.company_id = com.id)
              LEFT JOIN payment_invoices payinv ON (payinv.invoice_id = inv.id)
              LEFT JOIN cfdis cfdi_int ON (cfdi_int.payment_invoice_id = payinv.id AND cfdi_int.source_type = 'INTERESES FINANCIERA')
              LEFT JOIN cfdis cfdi_co_sup ON (cfdi_co_sup.payment_invoice_id = payinv.id AND cfdi_co_sup.source_type = 'COMPLEMENTO PROVEEDOR')
              LEFT JOIN cfdis cfdi_co_com ON (cfdi_co_com.payment_invoice_id = payinv.id AND cfdi_co_com.source_type = 'COMPLEMENTO CADENA')
              ORDEr BY req.folio DESC;"
    @invoice_cfdis = execute_statement(@query)
    render json: @invoice_cfdis
  end

  def signatories
    @query = "SELECT con.id, peo.first_name ||' '||peo.last_name||' '||peo.second_last_name nombre, peo.rfc
              FROM people peo, contributors con
              WHERE peo.id = con.person_id
              ORDER BY peo.first_name ||' '||peo.last_name||' '||peo.second_last_name;"
    @signatories = execute_statement(@query)
    render json: @signatories
  end

  def user_type
    @query = "SELECT us.id user_id,'SUPPLER' tipo_usuario, su.id supplier_id, 0 company_id
              FROM users us, suppliers su, supplier_users suus
              WHERE us.id = suus.user_id
              AND su.id = suus.supplier_id
              AND us.id = :user_id
              UNION ALL
              SELECT us.id user_id, 'COMPANY' tipo_usuario, 0 supplier_id, co.id company_id
              FROM users us, companies co, company_users cous
              WHERE us.id = cous.user_id
              AND co.id = cous.company_id
              AND us.id = :user_id
              UNION ALL
              SELECT us.id user_id, 'SOFOM' tipo_usuario, 0 supplier_id, 0 company_id
              FROM users us
              WHERE us.id not in (select user_id from company_users)
              AND us.id not in (select user_id from supplier_users)
              AND us.id = :user_id;"
    @query = @query.gsub ':user_id', params[:user_id].to_s
    @user_type = execute_statement(@query)
    render json: @user_type
  end

  def get_request_used_date
    direct_used_date_mode = GeneralParameter.get_general_parameter_value('DIRECT_USED_DATE_MODE')
    if direct_used_date_mode == 'SI'
      Time.zone = 'America/Chihuahua'
      now_date_time = Time.zone.now.strftime('%F %T')
      limit_date_time = Time.zone.now.strftime('%F 11:30:00')
      final_date = if now_date_time < limit_date_time
                     Time.zone.now.strftime('%F').to_date
                   else
                     Time.zone.now.strftime('%F').to_date + 1.days
                   end
      render json: final_date.to_s
    else
      render json: 'calendar'
    end
  end

  def get_company
    @query = "select com.* , concat (peo.rfc, lee.rfc ) rfc from companies com
    JOIN contributors con ON (com.contributor_id = con.id)
    left JOIN people peo ON (peo.id = con.person_id)
    left JOIN legal_entities lee ON (lee.id = con.legal_entity_id);"
    @get_company = execute_statement(@query)
    render json: @get_company
  end

  def get_customer
    @query = "SELECT cus.*, con.*, peo.*, coa.*
    FROM customer_credits cuc
    JOIN customers cus ON (cus.id = cuc.customer_id)
    JOIN contributors con ON (cus.contributor_id = con.id)
    LEFT JOIN people peo ON (peo.id = con.person_id)
    JOIN contributor_addresses coa ON (coa.contributor_id = con.id)
    JOIN states sta ON (sta.id = coa.state_id)
    JOIN municipalities mun ON (mun.id = coa.municipality_id)
    JOIN countries cou ON (cou.id = sta.country_id)
    WHERE cuc.id = ':customer_credit_id';"

    @query = @query.gsub ':customer_credit_id', params[:customer_credit_id].to_s
    @get_credit_customer_report = execute_statement(@query)
    render json: @get_credit_customer_report
  end

  def get_user_registration
    @query = "SELECT cus.id customer_id, cus.name, cus.salary, cus.salary_period, cus.customer_type, cus.status, cus.other_income,
    cus.net_expenses, cus.family_expenses, cus.house_rent, cus.credit_cp, cus.credit_lp,
    cus.attached, cus.extra1 customer_extra1, cus.extra2 customer_extra2, cus.extra3 customer_extra3,
    cus.contributor_id customer_contributor, cus.user_id customer_user, cus.file_type_id,
    cus.immediate_superior, cus.seniority, cus.ontime_bonus, cus.assist_bonus, cus.food_vouchers,
    cus.total_income, cus.total_savings_found, cus.christmas_bonus, cus.taxes, cus.imms,
    cus.savings_found, cus.savings_found_loand, cus.savings_bank, cus.insurance_discount,
    cus.child_support, cus.extra_expenses, cus.infonavit, cus.company_id customer_company, cus.job,
    cus.public_charge, cus.public_charge_det, cus.relative_charge, cus.relative_charge_det,cus.other_income_detail, cus.benefit,
    cus.benefit_detail, cus.responsible, cus.responsible_detail,
    con.id contributor_id, con.contributor_type, con.bank, con.account_number, con.clabe, con.extra1 contributor_extra1,
    con.extra2 contributor_extra2, con.extra3 contributor_extra3, con.person_id contributor_person,
    con.legal_entity_id contributor_le, peo.id people_id, peo.fiscal_regime, peo.rfc, peo.curp, peo.imss, peo.first_name,
    peo.last_name, peo.second_last_name, peo.gender, peo.nationality, peo.birth_country, peo.birthplace,
    peo.birthdate, peo.martial_status, peo.minior_dependents, peo.senior_dependents, peo.housing_type,
    peo.id_type, peo.identification, peo.phone, peo.mobile, peo.email, peo.fiel, peo.extra1 people_extra1,
    peo.extra2 people_extra2, peo.extra3 people_extra3, coa.street, coa.suburb suburb, coa.external_number, coa.apartment_number, coa.address_reference,
    coa.postal_code , sta.name estado, mun.name municipio, cou.name pais
   FROM customer_credits cuc
   JOIN customers cus ON (cus.id = cuc.customer_id)
   JOIN contributors con ON (cus.contributor_id = con.id)
   LEFT JOIN people peo ON (peo.id = con.person_id)
   JOIN contributor_addresses coa ON (coa.contributor_id = con.id)
   JOIN states sta ON (sta.id = coa.state_id)
   JOIN municipalities mun ON (mun.id = coa.municipality_id)
   JOIN countries cou ON (cou.id = sta.country_id)
    WHERE cuc.user_id = ':user_id';"

    @query = @query.gsub ':user_id', params[:user_id].to_s
    @get_user_registration = execute_statement(@query)
    render json: @get_user_registration
  end
  
  def get_customer_pr
    @query = "SELECT * from customer_personal_references cpr
    join customers cus on (cus.id = cpr.customer_id)
    where cus.user_id = ':user_id'"
    @query = @query.gsub ':user_id', params[:user_id].to_s
    @get_customer_pr = execute_statement(@query)
    render json: @get_customer_pr
  end

  # Reporte para mostrar los datos del cliente a partir de un credito
  def get_credit_customer_report
    @query = "SELECT cuc.id id_credito, cuc.rate tasa_empleado, cuc.total_requested total_solicitado, cuc.interests total_intereseses, 
    cuc.destination ,cuc.start_date fecha_credito,cuc.credit_number, cuc.status status_credito, ter.value periodo_pago, pap.pp_type tipo_periodo_pago,
    cus.id id_cliente,cus.name nombre_cliente,cus.customer_type tipo_cliente,cus.status status_cliente,cus.salary_period,cus.user_id id_usuario,
    cus.file_type_id id_tipo_expediente,cus.other_income otros_ingresos,cus.net_expenses egresos_netos,cus.family_expenses gastos_familiares, 
    cus.house_rent renta,cus.credit_cp creditos_cp, cus.credit_lp creditos_lp, cus.total_income ingreso_total, con.id id_contribuyente, 
    con.contributor_type tipo_contribuyente, con.bank banco, con.account_number cuenta_bancaria, con.clabe cuenta_clabe, 
    con.person_id id_persona_fisica, con.legal_entity_id id_persona_moral, peo.fiscal_regime pf_regimen_fiscal, 
    peo.rfc pf_rfc, peo.curp pf_curp, peo.imss pf_numero_seguro_social, peo.first_name || ' ' || peo.last_name || ' ' || peo.second_last_name pf_nombre, 
    peo.gender pf_genero, peo.nationality pf_nacionalidad, peo.birthplace pf_lugar_nacimiento, peo.birthdate pf_fecha_nacimiento, 
    peo.martial_status pf_estado_civil, peo.id_type pf_tipo_identificacion, peo.identification pf_numero_identificacion, 
    peo.phone pf_telefono, peo.mobile pf_celular, peo.email pf_correo, peo.fiel pf_fiel, lee.fiscal_regime pm_regimen_fiscal, 
    lee.rfc pm_rfc, lee.rug pm_rug, lee.business_name pm_nombre, lee.phone pm_telefono, lee.mobile pm_celular, 
    lee.email pm_correo, lee.business_email pm_correo_negocio, lee.main_activity pm_actividad_pricipal, lee.fiel pm_fiel, 
    coa.street calle, coa.suburb suburb, coa.external_number numero_exterior, coa.postal_code codigo_postal,
    sta.name estado, mun.name municipio, cou.name pais, com.business_name
    FROM customer_credits cuc
    JOIN customers cus ON (cus.id = cuc.customer_id)
    JOIN contributors con ON (cus.contributor_id = con.id)
    JOIN payment_periods pap ON (pap.id = cuc.payment_period_id)
    JOIN terms ter ON (ter.id = cuc.term_id)
    JOIN companies com ON (com.id = cus.company_id)
    LEFT JOIN people peo ON (peo.id = con.person_id)
    LEFT JOIN legal_entities lee ON (lee.id = con.legal_entity_id)
    JOIN contributor_addresses coa ON (coa.contributor_id = con.id)
    JOIN states sta ON (sta.id = coa.state_id)
    JOIN municipalities mun ON (mun.id = coa.municipality_id)
    JOIN countries cou ON (cou.id = sta.country_id)
            WHERE cuc.id = ':customer_credit_id';"
    @query = @query.gsub ':customer_credit_id', params[:customer_credit_id].to_s
    @get_credit_customer_report = execute_statement(@query)
    render json: @get_credit_customer_report
 end

 # REPORTE DE LAS CONSULTAS REALIZADAS A BURO EN RANGO DE FECHAS
 def buro_consults_report
  @query = "SELECT ':cr_folio' buro_consults_report,ab.*
  FROM((SELECT ROW_NUMBER () OVER (ORDER BY cb.id) as No,
  cb.bureau_report ->'results'->1->'query'->'Personas'->'Persona'->'Encabezado'->>'NumeroReferenciaOperador' noreferenciaoperador,
  cb.bureau_report ->'results'->1->'response'->'return'->'Personas'->'Persona'->0->'ResumenReporte'->'ResumenReporte'->0->>'FechaSolicitudReporteMasReciente' fechas,
  peo.first_name Nombre,
  peo.last_name paterno,
  peo.second_last_name materno,
  peo.rfc  RFC,
  CONCAT (ca.street,' ', ca.external_number)  calleyNumero,
  ca.suburb colonia,
  mu.name ciudad,
  st.name edo,
  ('VERDADERO') ingresonip,
  ('VERDADERO') respuestaautorizacion,
  cb.customer_id cuenta,
  cb.bureau_report ->'results'->1->>'id' folioBC
  FROM credit_bureaus cb, contributors con, contributor_addresses ca, customers cus, states st, municipalities mu, people peo
  WHERE cb.created_at BETWEEN ':fecha_inicio' AND ':fecha_fin'
		AND cb.customer_id = cus.id
		AND cus.contributor_id = con.id
		AND cus.contributor_id = ca.contributor_id
		AND ca.state_id = st.id
		AND ca.municipality_id = mu.id
		AND con.person_id = peo.id
     )
    ) ab;"

  @query = @query.gsub ':fecha_inicio', params[:fecha_inicio].to_s
  @query = @query.gsub ':fecha_fin', params[:fecha_fin].to_s
  t = Time.now
  # @folio = t.to_i
  @cr_folio = "BCR#{t}"
  @query = @query.gsub ':cr_folio', @cr_folio
  @buro_consults_report = execute_statement(@query)
  # @daily_operations.type_map = PG::TypeMapByColumn.new [nil, PG::TextDecoder::JSON.new]
  # render 'api/v1/reports/show_daily_operations'
  render json: @buro_consults_report
 end

 def get_company_update
  @query = "SELECT com.id company_id , com.business_name, com.start_date, com.credit_limit, com.credit_available, com.balance, com.document, com.sector,
    com.subsector, com.company_rate ,con.id contributor_id, con.contributor_type, con.bank, con.account_number, con.clabe, con.extra1 contributor_extra1,
    con.extra2 contributor_extra2, con.extra3 contributor_extra3, peo.id people_id, peo.fiscal_regime people_fiscal_regime, peo.rfc people_rfc, peo.curp people_curp, 
    peo.imss, peo.first_name, peo.last_name, peo.second_last_name, peo.gender, peo.nationality, peo.birth_country, peo.birthplace, peo.birthdate, peo.martial_status, 
    peo.id_type, peo.identification, peo.phone people_phone, peo.mobile people_mobile, peo.email people_email, peo.fiel people_fiel, peo.extra1 people_extra1, 
    peo.extra2 people_extra2, peo.extra3 people_extra3, lee.id legal_entity_id, lee.fiscal_regime legale_fiscal_regime, lee.rfc legale_rfc, lee.rug, lee.business_name, 
    lee.phone legale_phone, lee.mobile legale_mobile, lee.email legale_mail, lee.business_email, lee.main_activity, lee.fiel legale_fiel,lee.extra1 legal_entity_extra1, 
    lee.extra2 legal_entity_extra2, lee.extra3 legal_entity_extra3, coa.id contributor_addresses_id, coa.address_type, coa.suburb suburb, coa.suburb_type, coa.street, 
    coa.external_number, coa.apartment_number, coa.postal_code, coa.address_reference, coa.postal_code, sta.name estado, mun.name municipio, cou.name pais, sta.id state_id, 
    sta.name, mun.id municipalitiy_id, mun.name, cou.id country_id, cou.name
  FROM companies com
  JOIN contributors con ON (com.contributor_id = con.id)
  JOIN contributor_addresses coa ON (coa.contributor_id = con.id)
  JOIN states sta ON (sta.id = coa.state_id)
  JOIN municipalities mun ON (mun.id = coa.municipality_id)
  JOIN countries cou ON (cou.id = sta.country_id)
  LEFT JOIN people peo ON (peo.id = con.person_id)
  LEFT JOIN legal_entities lee ON (lee.id = con.legal_entity_id)
  WHERE com.id = ':company_id';"

  @query = @query.gsub ':company_id', params[:company_id].to_s
  @get_company_update = execute_statement(@query)
  render json: @get_company_update
 end

end




