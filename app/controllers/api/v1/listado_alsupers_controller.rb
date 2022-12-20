class Api::V1::ListadoAlsupersController < Api::V1::MasterApiController

  before_action :authenticate
  before_action :set_listado_alsuper, only: %i[ show edit update destroy ]
  
    # GET /listado_alsuper or /listado_alsuper.json
    def index
      @listado_alsupers = ListadoAlsuper.all
    end
  
    # GET /listado_alsuper/1 or /listado_alsupers/1.json
    def show; end
  
    # GET /listado_alsupers/new
    def new
      @listado_alsuper = ListadoAlsuper.new
    end
  
    # GET /listado_alsupers/1/edit
    def edit
    end

    # GET /listado_alsupers/:nss/
    def get_empleado_by_nss
      @listado_alsuper = ListadoAlsuper.where(noafiliacion: params['noafiliacion'])
      @listado_alsuper = @listado_alsuper[0]
      unless @listado_alsuper.blank?
        render template: 'api/v1/listado_alsupers/show'
      else
        render json: { error: "No se encuentra empleado con NSS: #{params['noafiliacion']}" }, status: :not_found
      end
    end
  
    # POST /listado_alsupers or /listado_alsupers.json
    def create
      @listado_alsuper = ListadoAlsuper.new(listado_alsuper_params)
        if @listado_alsuper.save
          render template: 'api/v1/listado_alsupers/show'
        else
          render json: { error: @listado_alsuper.errors }, status: :unprocessable_entity
        end
    end
  
    # PATCH/PUT /listado_alsupers/1 or /listado_alsupers/1.json
    def update
      # respond_to do |format|
        if @listado_alsuper.update(listado_alsuper_params)
          # format.html { redirect_to listado_alsupers_url(@listado_alsuper), notice: "Listado alsuper was successfully updated." }
          # format.json { render :show, status: :ok, location: @listado_alsuper }
          render template: 'api/v1/listado_alsupers/show'
        else
          # format.html { render :edit, status: :unprocessable_entity }
          # format.json { render json: @listado_alsuper.errors, status: :unprocessable_entity }
          render json: { error: @listado_alsuper.errors }, status: :unprocessable_entity
        end

    end
  
    # DELETE /listado_alsupers/1 or /listado_alsupers/1.json
    def destroy
      @listado_alsuper.destroy
        render json: { message: 'El registro fue eliminado' }
    end  

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_listado_alsuper
        @listado_alsuper = ListadoAlsuper.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def listado_alsuper_params
        params.require(:listado_alsuper).permit(
        :nombre,
        :primer_apellido,
        :segundo_apellido,
        :banco,
        :clabe,
        :cla_trab,
        :cla_depto,
        :departamento,
        :cla_area,
        :area,
        :cla_puesto,
        :puesto,
        :noafiliacion,
        :rfc,
        :curp,
        :tarjeta,
        :tipo_puesto,
        :fecha_ingreso,
        :categoria,
        :customer_id,
        :extra1, 
        :extra2, 
        :extra3, )
      end
  end