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
        @credit_analysis = CreditAnalysis.new(credit_analysis_params)

        if @credit_analysis.save
          #TO DO: LLAMAR A TRAERSE LA CONSULTA DE BURO DE CREDITO?
          render template: 'api/v1/credit_analyses/show'
        else
          render json: { error: @credit_analysis.errors }, status: :unprocessable_entity
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
                                                :car_credit, :mortagage_loan, :other_credits, :accured_liabilities, :debt, :net_flow, :customer_credit_id)
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
