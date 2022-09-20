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
      
end