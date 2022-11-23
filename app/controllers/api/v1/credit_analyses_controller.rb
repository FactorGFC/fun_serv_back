class Api::V1::CreditAnalysesController <  Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::CreditAnalysesApi

  before_action :authenticate
  before_action :set_credit_analysis, only: %i[show update destroy]

  def index
      @credit_analyses = CreditAnalysis.all
  end

  def show; end

  def create
    ActiveRecord::Base.transaction do
      @error_desc = []
      @credit_analysis = CreditAnalysis.new(credit_analysis_params)
      @customer_credits = CustomerCredit.where(id: @credit_analysis.customer_credit_id)
      @customer_credit = @customer_credits[0]
      @sim_customer_payments = SimCustomerPayment.where(customer_credit_id: @customer_credit.id)
      @sim_customer_payment = @sim_customer_payments[0]
      @house_rent = GeneralParameter.get_general_parameter_value('HOUSE_RENT')
      if @house_rent.blank?
         @error_desc.push("No se encontró parametro general HOUSE_RENT")
         error_array!(@error_desc, :not_found)
         raise ActiveRecord::Rollback
      end
      @child_expense = GeneralParameter.get_general_parameter_value('CHILD_EXPENSE')
      if @child_expense.blank?
         @error_desc.push("No se encontró parametro general CHILD_EXPENSE")
         error_array!(@error_desc, :not_found)
         raise ActiveRecord::Rollback
      end
      @adult_expense = GeneralParameter.get_general_parameter_value('ADULT_EXPENSE')
      if @adult_expense.blank?
        @error_desc.push("No se encontró parametro general ADULT_EXPENSE")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
      if @customer_credit.blank?
          error_array!(@error_desc, :unprocessable_entity)
          @error_desc.push("No existe el credito: #{@credit_analysis.customer_credit_id}")
          raise ActiveRecord::Rollback
        else
          @customers = Customer.where(id: @customer_credit.customer_id)
          @customer = @customers[0]
          @contributors = Contributor.where(id: @customer.contributor_id)
          @contributor = @contributors[0]
          @people = Person.where(id: @contributor.person.id)
          @person = @people[0]
          @total_income = 0
          @credit_analysis.total_income = @total_income
          @total_expenses = 0
          @credit_analysis.total_expenses = @total_expenses
          @monthly_income = 0
          @credit_analysis.monthly_income = @monthly_income
          @monthly_expenses = 0
          @credit_analysis.monthly_expenses = @monthly_expenses
          if @credit_analysis.save
            @payment_periods = PaymentPeriod.where(key: @customer.salary_period)
            @payment_period = @payment_periods[0]
            if @payment_period.blank?
              @error_desc.push("No existe un periodo con el id1: #{@customer_credit.payment_period_id}")
              error_array!(@error_desc, :not_found)
              raise ActiveRecord::Rollback
            end 
            salary = @customer.salary
            ontime_bonus = @customer.ontime_bonus
            assist_bonus = @customer.assist_bonus
            food_vouchers = @customer.food_vouchers
            @total_income = salary.to_f + ontime_bonus.to_f + assist_bonus.to_f + food_vouchers.to_f
            taxes = @customer.taxes
            imss = @customer.imms
            savings_found = @customer.savings_found
            savings_found_loand = @customer.savings_found_loand
            savings_bank = @customer.savings_bank
            insurance_discount = @customer.insurance_discount
            extra_expenses = @customer.extra_expenses
            infonavit = @customer.infonavit
            child_support = @customer.child_support
            @total_expenses = taxes.to_f + imss.to_f + savings_found.to_f + savings_found_loand.to_f + savings_bank.to_f + insurance_discount.to_f 
                              + extra_expenses.to_f + infonavit.to_f + child_support.to_f
            payment_period = @payment_period.pp_type
            @monthly_income = @total_income.to_f * payment_period.to_f
            @montly_expenses = @total_expenses.to_f * payment_period.to_f
            if @person.minior_dependents. nil?
               @person.minior_dependents = 0.00
            end
            if @person.senior_dependents.nil?
               @person.senior_dependents = 0.00
            end
            minior_dependents = @person.minior_dependents.to_f * @child_expense.to_f
            senior_dependents = @person.senior_dependents.to_f * @adult_expense.to_f
            @family_expenses = minior_dependents + senior_dependents
            if @credit_analysis.car_credit.nil?
              @credit_analysis.car_credit = 0.00
            end
            if @credit_analysis.mortagage_loan.nil?
              @credit_analysis.mortagage_loan = 0.00
            end
            if @customer.credit_cp.nil?
             @customer.credit_cp = 0.00
             @payment_credit_cp = @customer.credit_cp
            end
            @payment_credit_lp = @credit_analysis.car_credit.to_f + @credit_analysis.mortagage_loan.to_f + @customer.credit_lp.to_f
            if @person.housing_type == 'Rentada'
            @customer.house_rent = @house_rent
            else
              @customer.house_rent = 0
            end
            @rent = @customer.house_rent
            @debt = @sim_customer_payment.payment.to_f * payment_period.to_f
            #Flujo neto es el ingreso mensual menos los egresos
            @net_flow = @monthly_income.to_f - @montly_expenses.to_f - @family_expenses.to_f - @rent.to_f - @payment_credit_lp.to_f - @customer.credit_cp.to_f - @debt.to_f
            @payment_capacity = ((@payment_credit_lp.to_f + @customer.credit_cp.to_f + @debt.to_f) / @monthly_income.to_f) * 100
            @debt_rate = (@debt.to_f / @monthly_income) * 100
            @cash_flow = ((@montly_expenses.to_f + @family_expenses.to_f + @rent.to_f + @payment_credit_lp.to_f + @customer.credit_cp.to_f + @debt.to_f) / @monthly_income.to_f) * 100
            @credit_analysis.update(total_income: @total_income.round(2), total_expenses: @total_expenses.round(2), monthly_income: @monthly_income.round(2), 
                                    monthly_expenses: @montly_expenses,  payment_credit_cp: @customer.credit_cp,
                                    payment_credit_lp: @payment_credit_lp.round(2), debt: @debt.round(2), net_flow: @net_flow.round(2),
                                    payment_capacity: @payment_capacity.round(2), debt_rate: @debt_rate.round(2), cash_flow: @cash_flow.round(2),
                                    debt_horizon: @customer_credit.debt_time.round(2))
            @customer.update(family_expenses: @family_expenses.round(2), house_rent: @rent.round(2))
            render template: 'api/v1/credit_analyses/show'
          else
            error_array!(@credit_analysis.errors.full_messages, :unprocessable_entity)
            raise ActiveRecord::Rollback
          end
        end
     end
    end

    def update
      if @credit_analysis.update(credit_analysis_params)
        render template: 'api/v1/credit_analyses/show'
      else
        render json: { error: @credit_analysis.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      @credit_analysis.destroy
      render json: { message: '' }
    end

    def credit_analysis_params
      params.require(:credit_analysis).permit(:debt_rate, :cash_flow, :credit_status, :previus_credit, :discounts, :debt_horizon,
                                              :report_date, :mop_key, :last_key, :balance_due, :payment_capacity, :lowest_key, :departamental_credit,
                                              :car_credit, :mortagage_loan, :other_credits, :accured_liabilities, :debt, :net_flow, :customer_credit_id,
                                              :total_amount, :credit_type, :anual_rate, :total_cost, :overal_rate, :total_debt,
                                              :car_debt, :debt_cp, :departamentalc_debt, :monthly_expenses, :monthly_income, :mortagage_debt, 
                                              :payment_credit_cp, :personalc_debt, :total_expenses, :total_income, :otherc_debt, :payment_credit_lp, :debt)
    end

      def set_credit_analysis
        @credit_analysis = CreditAnalysis.find(params[:id])
      end
    
          #VALIDA SI EL CLIENTE TIENE GUARDADO EN DB SU ANALISIS DE CREDITO/ DEVUELVE FALSO/VERDADERO CON EL REGISTRO
    def has_credit_analysis
      @credit_analysis = CreditAnalysis.where(customer_credit_id: params[:id])
      unless @credit_analysis.blank?
        # response = generate_customer_buro_report_pdf(@customer_credit.id)
          render json: { message: 'Ok', credit_analysis:@credit_analysis, status: true}, status: 200
      else
        render json: { message: "No se ha realizado analisis de credito:  #{params[:id]}", status: false }, status: 206
      end
    end

end
