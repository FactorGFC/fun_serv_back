module CustomersHelper

    def get_ur_credits credits
        ur_credits = {mop: 'UR', cuentas_abiertas: 0, limite_abiertas: 0, maximo_abiertas: 0, saldo_actual: 0,
                    saldo_vencido: 0, pago_realizar: 0, cuentas_cerradas: 0, limite_cerradas: 0, maximo_cerradas: 0,
                    saldo_cerradas: 0, monto_cerradas: 0}

        credits_01 = {mop: '01',cuentas_abiertas: 0, limite_abiertas: 0, maximo_abiertas: 0, saldo_actual: 0, saldo_vencido: 0,
                    pago_realizar: 0, cuentas_cerradas: 0, limite_cerradas: 0, maximo_cerradas: 0, saldo_cerradas: 0,
                    monto_cerradas: 0}


        all_credits = []


        credits.each do |credit|


        if credit['FechaCierreCuenta'].present? && credit['FormaPagoActual'] == 'UR'

            ur_credits[:cuentas_cerradas] += 1
            ur_credits[:limite_cerradas] += credit['LimiteCredito'].to_i
            ur_credits[:maximo_cerradas] += credit['CreditoMaximo'].to_i
            ur_credits[:saldo_cerradas] += credit['SaldoActual'].to_i
            ur_credits[:monto_cerradas] += credit['MontoPagar'].to_i

        elsif credit['FechaCierreCuenta'].present? && credit['FormaPagoActual'] == '01'

            credits_01[:cuentas_cerradas] += 1
            credits_01[:limite_cerradas] += credit['LimiteCredito'].to_i
            credits_01[:maximo_cerradas] += credit['CreditoMaximo'].to_i
            credits_01[:saldo_cerradas] += credit['SaldoActual'].to_i
            credits_01[:monto_cerradas] += credit['MontoPagar'].to_i

        elsif !credit['FechaCierreCuenta'].present? && credit['FormaPagoActual'] == 'UR'

            ur_credits[:cuentas_abiertas] += 1
            ur_credits[:limite_abiertas] += credit['LimiteCredito'].to_i
            ur_credits[:maximo_abiertas] += credit['CreditoMaximo'].to_i
            ur_credits[:saldo_actual] += credit['SaldoActual'].to_i
            ur_credits[:saldo_vencido] += credit['SaldoVencido'].to_i
            ur_credits[:pago_realizar] += credit['MontoPagar'].to_i

        elsif !credit['FechaCierreCuenta'].present? && credit['FormaPagoActual'] == '01'
            credits_01[:cuentas_abiertas] += 1
            credits_01[:limite_abiertas] += credit['LimiteCredito'].to_i
            credits_01[:maximo_abiertas] += credit['CreditoMaximo'].to_i
            credits_01[:saldo_actual] += credit['SaldoActual'].to_i
            credits_01[:saldo_vencido] += credit['SaldoVencido'].to_i
            credits_01[:pago_realizar] += credit['MontoPagar'].to_i
        end
        end

        all_credits.push(ur_credits)
        all_credits.push(credits_01)

        return all_credits
    end


    def get_pm_birthdate date
        if date.present?

        day = date.first(2)
        month = get_month date[2,2]
        year = date.last(4)
        new_date = day + '-' + month + '-' + year
        else
        new_date = 'N/D'
        end

        return new_date
    end

    def get_history_payments account

      if account['FechaMasAntiguaHistoricoPagos'].nil?
        account['FechaMasAntiguaHistoricoPagos'] = account['FechaAperturaCuenta']
      end
      if account['FechaMasRecienteHistoricoPagos'].nil?
        account['FechaMasRecienteHistoricoPagos'] = account['FechaAperturaCuenta']
      end
      first_date = account['FechaMasAntiguaHistoricoPagos'].last(4).to_i
      first_month = account['FechaMasAntiguaHistoricoPagos'][2,2]
      last_date = account['FechaMasRecienteHistoricoPagos'].last(4).to_i
      last_month = account['FechaMasRecienteHistoricoPagos'][2,2]
      total_year = (last_date - first_date) + 1
      if account['HistoricoPagos'].nil?
        account['HistoricoPagos'] = '------------'
      end
      payment_history = account['HistoricoPagos']
  
      months = (1..12).to_a
  
      array = {}
  
      new_date = first_date
      total_year.times do |year|
        array["#{new_date}"] = []
  
        months.each do |month|
  
  
          if new_date == first_date && month <= first_month.to_i
            array["#{new_date}"].push({"value": 0})
          elsif new_date == first_date && month >= first_month.to_i
            if payment_history[0].present?
              array["#{new_date}"].push({"value": payment_history[0]})
              payment_history.slice!(0)
            else
              array["#{new_date}"].push({"value": 0})
  
            end
  
          elsif new_date == last_month && month <= last_month.to_i
            if payment_history[0].present?
              array["#{new_date}"].push({"value": payment_history[0]})
              payment_history.slice!(0)
            else
              array["#{new_date}"].push({"value": 0})
            end
          else
            if payment_history[0].present?
              array["#{new_date}"].push({"value": payment_history[0]})
              payment_history.slice!(0)
            else
              array["#{new_date}"].push({"value": 0})
            end
          end
        end
  
        new_date = new_date.to_i + 1
  
  
      end
  
      return array
  
    end

    def calculate_degrees score
        if score.present?
          if score < 550
            (score * 45)/549
          elsif score >= 550 and score < 650
            45+(((100-(650-score))*45)/100)
          elsif score >= 650 and score < 750
            90+(((100-(750-score))*45)/100)
          else
            135+(((100-(850-score))*45)/100)
          end
        else
          0
        end
    end

    def get_active_credits actives_credits

      otras_financieras_simple = {otorgante:'OTRAS FINANCIERAS',tipo_credito: 'SIMPLE' ,cuentas_abiertas: 0, cuentas_mxp: 0, cuentas_usd: 0, otras_monedas: 0, original: 0,
                                  saldo_actual: 0, vigente: 0, one:0, thirty: 0, sixty: 0,ninety: 0,one_twenty: 0,
                                  one_eighty: 0}
  
      banco_linea_credito = {otorgante:'BANCO',tipo_credito: 'LINEA DE CRÉDITO' , cuentas_abiertas: 0, cuentas_mxp: 0,
                             cuentas_usd: 0, otras_monedas: 0, original: 0, saldo_actual: 0, vigente: 0, one:0, thirty: 0,
                             sixty: 0,ninety: 0,one_twenty: 0, one_eighty: 0}
  
      banco_credito_empresarial = {otorgante:'BANCO',tipo_credito: 'T. CRED. EMPRESARIAL-CORPORATIVA',cuentas_abiertas: 0,
                                   cuentas_mxp: 0, cuentas_usd: 0, otras_monedas: 0, original: 0, saldo_actual: 0,
                                   vigente: 0, one:0, thirty: 0, sixty: 0,ninety: 0,one_twenty: 0, one_eighty: 0}
  
      otras_financieras = {otorgante:'OTRAS FINANCIERAS',tipo_credito: 'O.C. GARANTIA INMOB' , cuentas_abiertas: 0,
                                       cuentas_mxp: 0, cuentas_usd: 0, otras_monedas: 0, original: 0, saldo_actual: 0,
                                       vigente: 0, one:0, thirty: 0, sixty: 0,ninety: 0,one_twenty: 0, one_eighty: 0}
  
      arrendadora = {otorgante:'ARRENDADORA',tipo_credito: 'ARRENDAD' , cuentas_abiertas: 0,
                                       cuentas_mxp: 0, cuentas_usd: 0, otras_monedas: 0, original: 0, saldo_actual: 0,
                                       vigente: 0, one:0, thirty: 0, sixty: 0,ninety: 0,one_twenty: 0, one_eighty: 0}
  
  
      @actives_credits = []
  
  
      actives_credits.each do |active_credit|
        if active_credit['tipoUsuario'] == 'FACTOR GFC GLOBAL' && !active_credit['pagoCierre'].present?
  
  
          otras_financieras_simple[:cuentas_abiertas] += 1
          otras_financieras_simple[:cuentas_mxp] += 1
          otras_financieras_simple[:original] += active_credit['saldoInicial'].to_i / 1000
          otras_financieras_simple[:saldo_actual] += active_credit['saldoVigente'].to_i / 1000
          otras_financieras_simple[:vigente] += active_credit['saldoVigente'].to_i / 1000
          otras_financieras_simple[:one] += active_credit['saldoVencidoDe1a29Dias'].to_f
          otras_financieras_simple[:thirty] += active_credit['saldoVencidoDe30a59Dias'].to_f
          otras_financieras_simple[:sixty] += active_credit['saldoVencidoDe60a89Dias'].to_f
          otras_financieras_simple[:ninety] += active_credit['saldoVencidoDe90a119Dias'].to_f
          otras_financieras_simple[:one_twenty] += active_credit['saldoVencidoDe120a179Dias'].to_f
          otras_financieras_simple[:one_eighty] += active_credit['saldoVencidoDe180DiasOMas'].to_f
  
        elsif active_credit['tipoUsuario'] == 'BANCO' && active_credit['tipoCredito'] == "6280" && !active_credit['pagoCierre'].present?
  
          banco_linea_credito[:cuentas_abiertas] += 1
          banco_linea_credito[:cuentas_mxp] += 1
          banco_linea_credito[:original] += active_credit['saldoInicial'].to_i / 1000
          banco_linea_credito[:saldo_actual] += active_credit['saldoVigente'].to_i / 1000
          banco_linea_credito[:vigente] += active_credit['saldoVigente'].to_i / 1000
          banco_linea_credito[:one] += active_credit['saldoVencidoDe1a29Dias'].to_f
          banco_linea_credito[:thirty] += active_credit['saldoVencidoDe30a59Dias'].to_f
          banco_linea_credito[:sixty] += active_credit['saldoVencidoDe60a89Dias'].to_f
          banco_linea_credito[:ninety] += active_credit['saldoVencidoDe90a119Dias'].to_f
          banco_linea_credito[:one_twenty] += active_credit['saldoVencidoDe120a179Dias'].to_f
          banco_linea_credito[:one_eighty] += active_credit['saldoVencidoDe180DiasOMas'].to_f
  
        elsif active_credit['tipoUsuario'] == 'BANCO' && active_credit['tipoCredito'] == "1380" && !active_credit['pagoCierre'].present?
  
          banco_credito_empresarial[:cuentas_abiertas] += 1
          banco_credito_empresarial[:cuentas_mxp] += 1
          banco_credito_empresarial[:original] += active_credit['saldoInicial'].to_i / 1000
          banco_credito_empresarial[:saldo_actual] += active_credit['saldoVigente'].to_i / 1000
          banco_credito_empresarial[:vigente] += active_credit['saldoVigente'].to_i / 1000
          banco_credito_empresarial[:one] += active_credit['saldoVencidoDe1a29Dias'].to_f
          banco_credito_empresarial[:thirty] += active_credit['saldoVencidoDe30a59Dias'].to_f
          banco_credito_empresarial[:sixty] += active_credit['saldoVencidoDe60a89Dias'].to_f
          banco_credito_empresarial[:ninety] += active_credit['saldoVencidoDe90a119Dias'].to_f
          banco_credito_empresarial[:one_twenty] += active_credit['saldoVencidoDe120a179Dias'].to_f
          banco_credito_empresarial[:one_eighty] += active_credit['saldoVencidoDe180DiasOMas'].to_f
        elsif active_credit['tipoUsuario'] == 'OTRAS FINANCIERAS' && !active_credit['pagoCierre'].present?
  
          otras_financieras[:cuentas_abiertas] += 1
          otras_financieras[:cuentas_mxp] += 1
          otras_financieras[:original] += active_credit['saldoInicial'].to_i / 1000
          otras_financieras[:saldo_actual] += active_credit['saldoVigente'].to_i / 1000
          otras_financieras[:vigente] += active_credit['saldoVigente'].to_i / 1000
          otras_financieras[:one] += active_credit['saldoVencidoDe1a29Dias'].to_f
          otras_financieras[:thirty] += active_credit['saldoVencidoDe30a59Dias'].to_f
          otras_financieras[:sixty] += active_credit['saldoVencidoDe60a89Dias'].to_f
          otras_financieras[:ninety] += active_credit['saldoVencidoDe90a119Dias'].to_f
          otras_financieras[:one_twenty] += active_credit['saldoVencidoDe120a179Dias'].to_f
          otras_financieras[:one_eighty] += active_credit['saldoVencidoDe180DiasOMas'].to_f
        elsif active_credit['tipoUsuario'] == 'ARRENDADORA' && !active_credit['pagoCierre'].present?
  
          arrendadora[:cuentas_abiertas] += 1
          arrendadora[:cuentas_mxp] += 1
          arrendadora[:original] += active_credit['saldoInicial'].to_i / 1000
          arrendadora[:saldo_actual] += active_credit['saldoVigente'].to_i / 1000
          arrendadora[:vigente] += active_credit['saldoVigente'].to_i / 1000
          arrendadora[:one] += active_credit['saldoVencidoDe1a29Dias'].to_f
          arrendadora[:thirty] += active_credit['saldoVencidoDe30a59Dias'].to_f
          arrendadora[:sixty] += active_credit['saldoVencidoDe60a89Dias'].to_f
          arrendadora[:ninety] += active_credit['saldoVencidoDe90a119Dias'].to_f
          arrendadora[:one_twenty] += active_credit['saldoVencidoDe120a179Dias'].to_f
          arrendadora[:one_eighty] += active_credit['saldoVencidoDe180DiasOMas'].to_f
  
        end
      end
  
      @actives_credits.push(otras_financieras_simple)
      @actives_credits.push(banco_linea_credito)
      @actives_credits.push(banco_credito_empresarial)
      @actives_credits.push(otras_financieras)
      @actives_credits.push(arrendadora)
  
      return @actives_credits
  
    end

    def get_total_active_credits actives_credits

      otras_financieras_simple = {cuentas_abiertas: 0, cuentas_mxp: 0, cuentas_usd: 0, otras_monedas: 0, original: 0,
                                  saldo_actual: 0, vigente: 0, one:0, thirty: 0, sixty: 0,ninety: 0,one_twenty: 0,
                                  one_eighty: 0}
  
  
      total_actives_credits = []
  
  
      actives_credits.each do |active_credit|
        unless active_credit['pagoCierre']
  
          otras_financieras_simple[:cuentas_abiertas] += 1
          otras_financieras_simple[:cuentas_mxp] += 1
          otras_financieras_simple[:original] += active_credit['saldoInicial'].to_i / 1000
          otras_financieras_simple[:saldo_actual] += active_credit['saldoVigente'].to_i / 1000
          otras_financieras_simple[:vigente] += active_credit['saldoVigente'].to_i / 1000
          otras_financieras_simple[:one] += active_credit['saldoVencidoDe1a29Dias'].to_f
          otras_financieras_simple[:thirty] += active_credit['saldoVencidoDe30a59Dias'].to_f
          otras_financieras_simple[:sixty] += active_credit['saldoVencidoDe60a89Dias'].to_f
          otras_financieras_simple[:ninety] += active_credit['saldoVencidoDe90a119Dias'].to_f
          otras_financieras_simple[:one_twenty] += active_credit['saldoVencidoDe120a179Dias'].to_f
          otras_financieras_simple[:one_eighty] += active_credit['saldoVencidoDe180DiasOMas'].to_f
        end
  
  
  
      end
  
      total_actives_credits.push(otras_financieras_simple)
  
      return total_actives_credits
  
    end
      
end