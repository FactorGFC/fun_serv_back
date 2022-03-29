# frozen_string_literal: true

class Api::V1::UserRegistrationController < Api::V1::MasterApiController
  #include Swagger::Blocks
  #include Swagger::PostalCodesApi

  before_action :authenticate

  def create
    @error_desc = []
    ActiveRecord::Base.transaction do            
      if contributors_params[:contributor_type].blank?
        @error_desc.push('Se tiene que mandar el tipo de contribuyente')
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      elsif contributors_params[:contributor_type] != 'PM' and contributors_params[:contributor_type] != 'PF'
        @error_desc.push('El tipo de contribuyente tiene que ser: PM o PM')
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      elsif contributors_params[:contributor_type] == 'PM'
        @legal_entity = LegalEntity.new(legal_entities_params)
        unless @legal_entity.save
          render json: { error: @legal_entity.errors }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        else
          @contributor = Contributor.new(contributor_type: contributors_params[:contributor_type], bank: contributors_params[:bank], account_number: contributors_params[:account_number], clabe: contributors_params[:clabe], legal_entity_id: @legal_entity.id)
          unless @contributor.save
            render json: { error: @contributor.errors }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end        
      elsif contributors_params[:contributor_type] == 'PF'
        @person = Person.new(people_params)
        unless @person.save
          render json: { error: @person.errors }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        else
          @contributor = Contributor.new(contributor_type: contributors_params[:contributor_type], bank: contributors_params[:bank], account_number: contributors_params[:account_number], clabe: contributors_params[:clabe], person_id: @person.id)        
          unless @contributor.save
            render json: { error: @contributor.errors }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end
      end
      @contributor_address = ContributorAddress.new(contributor_id: @contributor.id, address_type: contributor_address_params[:address_type], street: contributor_address_params[:street], external_number: contributor_address_params[:external_number], apartment_number: contributor_address_params[:apartment_number], suburb_type: contributor_address_params[:suburb_type], suburb: contributor_address_params[:suburb], address_reference: contributor_address_params[:address_reference], postal_code: contributor_address_params[:postal_code], municipality_id: contributor_address_params[:municipality_id], state_id: contributor_address_params[:state_id])
      unless @contributor_address.save
        render json: { error: @contributor_address.errors }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      #if customer_params[:name].blank? and funder_params[:name].blank?
      #  @error_desc.push('Se tienen que mandar los datos de la persona física o de la persona moral según corresponda')
      #  error_array!(@error_desc, :not_found)
      #  raise ActiveRecord::Rollback
      #end
      if params[:type].blank?
        @error_desc.push('Se tiene que mandar el tipo de operacion type = customer o type = funder')
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      elsif params[:type] != 'customer' and params[:type] != 'funder'
        @error_desc.push('Se tiene que mandar el tipo de operacion type = customer o type = funder')
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
      if params[:type] == 'customer'
        @customer = Customer.new(contributor_id: @contributor.id, attached: customer_params[:attached], customer_type: customer_params[:customer_type], name: customer_params[:name], status: customer_params[:status], user_id: customer_params[:user_id])        
        unless @customer.customer_type.blank?
          @file_types = FileType.where(customer_type: @customer.customer_type)
          unless @file_types.blank?
            create_contributor_documents
            @customer.update(file_type_id: @file_types[0].id)
            if @customer.save
              unless @legal_entity.blank?              
                render 'api/v1/user_registers/pm_customer'
              else
                render 'api/v1/user_registers/pf_customer'
              end
            else
              render json: { error: @customer.errors }, status: :unprocessable_entity
            end            
          else
            @error_desc.push("No se encontró un tipo de expediente para el tipo de cliente: #{@customer.customer_type}")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          end
        end
      end  
      if params[:type] == 'funder'
        puts "111111111"
        @funder = Funder.new(contributor_id: @contributor.id, attached: funder_params[:attached], funder_type: funder_params[:funder_type], name: funder_params[:name], status: funder_params[:status], user_id: funder_params[:user_id])        
        unless @funder.funder_type.blank?
          @file_types = FileType.where(funder_type: @funder.funder_type)
          unless @file_types.blank?
            create_contributor_documents
            @funder.update(file_type_id: @file_types[0].id)
            if @funder.save
              unless @legal_entity.blank?
                render 'api/v1/user_registers/pm_funder'
              else
                render 'api/v1/user_registers/pf_funder'
              end
            else
              render json: { error: @funder.errors }, status: :unprocessable_entity
            end              
          else
            @error_desc.push("No se encontró un tipo de expediente para el tipo de inversionista: #{@funder.funder_type}")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          end
        end
      end
    end
  end

  private  

  def legal_entities_params
    params.require(:legal_entity).permit(:fiscal_regime, 
      :rfc, :rug, :business_name, :phone, :mobile, :email, 
      :business_email, :main_activity, :fiel, :extra1, :extra2, :extra3)
  end

  def people_params
    params.require(:person).permit(:fiscal_regime, :rfc, :curp, :imss, 
                   :first_name, :last_name, :second_last_name, :gender, 
                   :nationality, :birth_country, :birthplace, :birthdate, 
                   :martial_status, :id_type, :identification, :phone, 
                   :mobile, :email, :fiel, :extra1, :extra2, :extra3)
  end

  def contributors_params
    params.require(:contributor).permit(:contributor_type, :bank, :account_number, :clabe, :person_id, :legal_entity_id, :extra1, :extra2, :extra3)
  end

  def contributor_address_params
    params.require(:contributor_address).permit(:contributor_id, :address_type, :street, :external_number, :apartment_number, :suburb_type, :suburb, :address_reference, :postal_code, :municipality_id, :state_id)
  end

  def customer_params
    params.require(:customer).permit(:contributor_id, :attached, :customer_type, :name, :status, :user_id)
  end

  def funder_params
    params.require(:funder).permit(:contributor_id, :attached, :funder_type, :name, :status, :user_id)
  end

  def create_contributor_documents
    @file_type_documents = FileTypeDocument.where(file_type_id: @file_types[0].id)
    @file_type_documents.each do |file_type_document|
      @documents = Document.where(id: file_type_document.document_id)
      unless @documents.blank?
        ContributorDocument.custom_update_or_create(@contributor.id, file_type_document.id, @documents[0].name, 'PI') #PI - Por ingresar, estatus inicial
      end
    end
  end  
end
