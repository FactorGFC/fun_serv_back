class Api::V1::CreditBureausController < ApplicationController
    before_action :set_credit_bureau, only: %i[ edit update destroy ]
  
    # GET /credit_bureaus or /credit_bureaus.json
    def index
      @credit_bureau = CreditBureau.all
    end
  
    # GET /credit_bureaus/1 or /credit_bureaus/1.json
    def show
      @credit_bureau = JSON.pretty_generate(BuroCredito.get_report_by_id params[:id])
  
    end
  
    # GET /credit_bureaus/new
    def new
      @credit_bureau = CreditBureau.new
    end
  
    # GET /credit_bureaus/1/edit
    def edit
    end
  
    # POST /credit_bureaus or /credit_bureaus.json
    def create
      @credit_bureau = CreditBureau.new(credit_bureau_params)
  
      respond_to do |format|
        if @credit_bureau.save
          format.html { redirect_to credit_bureau_url(@credit_bureau), notice: "Credit bureau was successfully created." }
          format.json { render :show, status: :created, location: @credit_bureau }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @credit_bureau.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /credit_bureaus/1 or /credit_bureaus/1.json
    def update
      respond_to do |format|
        if @credit_bureau.update(credit_bureau_params)
          format.html { redirect_to credit_bureau_url(@credit_bureau), notice: "Credit bureau was successfully updated." }
          format.json { render :show, status: :ok, location: @credit_bureau }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @credit_bureau.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /credit_bureaus/1 or /credit_bureaus/1.json
    def destroy
      @credit_bureau.destroy
  
      respond_to do |format|
        format.html { redirect_to credit_bureaus_url, notice: "Credit bureau was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    # DEVUELVE TRUE SI EL NIP ES VIGENTE
    def get_credit_bureau_nip_validation
      @customer = Customer.find_by_id(params[:id])
      unless @customer.blank?
        @token_nip_expiry = @customer.extra2
        @nip = @customer.extra1
        if @nip == params[:nip]
          if @token_nip_expiry > Time.now
              render json: { message: 'NIP Ok', status: true , customer_id: @customer.id}, status: 200
          else
            #EL TOKEN HA EXPIRADO
            render json: { message: 'NIP expiró', status: false }, status: 206
          end
        else
          #EL NIP NO COINCIDE
          render json: { message: 'El NIP es incorrecto', status: false }, status: 206
        end
      else
        # NO SE ENCONTRÓ EL TOKEN
        render json: { message: "No se encontró customer", customer: params[:id], status: false
          }, status: 206
      end
    end

    # GENERA UN NUEVO NIP DE BURO PARA ENVIARSELO AL CLIENTE (solo requiere el customer.id)
    def reset_credit_bureau_nip
      @customer = Customer.find_by_id(params[:id])
      unless @customer.blank?
        send_customer_nip_mailer(@customer)
        render json: { message: 'Mailer sent', status: true }, status: 200
      else
        # NO SE ENCONTRÓ EL NIP
        render json: { message: "No se encontró registro", customer: params[:id], status: false
          }, status: 206
      end
    end

    def traer_buro
      # CUSTOMER_CREDIT ID EN LOS PARAMS
      @customer_credit = CustomerCredit.where(id: params[:id])
      unless @customer_credit.blank?
        # MANDAR A TRAER EL REPORTE DE BURO MEDIANTE EL RFC
        # PRUEBA BURO DE CREDITO
        @buro = get_buro (@customer_credit[0].id)
        unless @buro.nil?
          #Evalua si la calificacion de buro es negativa
          if @buro[0]['bureau_report']['results'][1]['status'] == 'SUCCESS'
            if @buro[0]['bureau_report']['results'][1]['response']['return']['Personas']['Persona'][0]['ScoreBuroCredito']['ScoreBC'][0]['ValorScore'].to_i > 0
              render json: { message: 'ok', status: true, buro: @buro }, status: 200
            else
              # SCORE CON CODIGO ESPECIAL 
              render json: { message: "El cliente cuenta con codigo especial de SCORE", SCORE: "#{@buro[0]['bureau_report']['results'][1]['response']['return']['Personas']['Persona'][0]['ScoreBuroCredito']['ScoreBC'][0]['ValorScore']}", status: false
              }, status: 206
            end
          else
          # STATUS FAIL EN BURO PERSONA FISICA 
          render json: { message: "El cliente no cuenta con registros en Buró de Crédito", status_de_Buro: "#{@buro[0]['bureau_report']['results'][1]['status']}", status: false
          }, status: 206
          end
        else
         # NO SE ENCONTRÓ 
        render json: { message: "Error", status: false
        }, status: 206
        end
      else
        # NO SE ENCONTRÓ 
        render json: { message: "No se encontró registro", customer: "#{@customer_credit[0].inspect}", status: false
          }, status: 206
      end
    end
  

    def credit_bureau_pdf
      ActiveRecord::Base.transaction do
        @customer_credit = CustomerCredit.find_by_id(params[:id])
        unless @customer_credit.blank?
          response = generate_customer_buro_report_pdf(@customer_credit.id)
          unless response.blank?
            render json: { message: 'Ok', pdf:response}, status: 200
          else
            render json: { message: "No se encuentra reporte de buro para el id:  #{params[:id]}"}, status: 206
          end
        else
          render json: { message: "No se encuentra customer_credit para el id:  #{params[:id]}"}, status: 206
        end
      end
    end

    #VALIDA SI EL CLIENTE TIENE GUARDADO EN DB SU CONSULTA DE BURO DE CREDITO/ DEVUELVE FALSO/VERDADERO CON EL REGISTRO
    def has_credit_bureau
      @credit_bureau = CreditBureau.where(customer_id: params[:id])
      unless @credit_bureau.blank?
        #Evalua si la calificacion de buro es negativa
        if @credit_bureau[0]['bureau_report']['results'][1]['status'] == 'SUCCESS'
          if @credit_bureau[0]['bureau_report']['results'][1]['response']['return']['Personas']['Persona'][0]['ScoreBuroCredito']['ScoreBC'][0]['ValorScore'].to_i > 0
            render json: { message: 'Ok', credit_bureau:@credit_bureau, status: true}, status: 200
            # render json: { message: 'ok', status: true, buro: @buro }, status: 200
          else
            # SCORE CON CODIGO ESPECIAL 
            render json: { message: "El cliente cuenta con codigo especial de SCORE", SCORE: "#{@credit_bureau[0]['bureau_report']['results'][1]['response']['return']['Personas']['Persona'][0]['ScoreBuroCredito']['ScoreBC'][0]['ValorScore']}", status: false
            }, status: 206
          end
        else
        # STATUS FAIL EN BURO PERSONA FISICA 
        render json: { message: "El cliente no cuenta con registros en Buró de Crédito", status_de_Buro: "#{@credit_bureau[0]['bureau_report']['results'][1]['status']}", status: false
        }, status: 206
        end
      else
        render json: { message: "No se ha realizado consulta de buro para el customer:  #{params[:id]}", status: false }, status: 206
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_credit_bureau
        @credit_bureau = CreditBureau.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def credit_bureau_params
        params.fetch(:credit_bureau, {})
      end
  end