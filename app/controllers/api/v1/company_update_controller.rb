# frozen_string_literal: true

class Api::V1::CompanyUpdateController < Api::V1::MasterApiController

  before_action :authenticate

  def company_update_info
    #Poner bandera en 0 si todo esta bien si no poner 1
    #si bandera = 0 render si no rollback
    @error_desc = []
    ActiveRecord::Base.transaction do
    unless params[:company_id].nil?
      @companies = Company.where(id: params[:company_id])
      @company = @companies[0]
      if @company.update(companies_params)
        is_ok = 1
      else  
       is_ok = 0 
       @error_desc.push("Oucrrio un error al actualizar los datos de la empresa")
       error_array!(@error_desc, :not_found)
       raise ActiveRecord::Rollback
      end
     else
      @error_desc.push("Se debe de mandar el id de la empresa a modificar")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
    end

    unless params[:contributor_id].nil?
      @contributors = Contributor.where(id: params[:contributor_id])
      @contributor = @contributors[0]
      if @contributor.update(contributors_params)
        is_ok = 1
      else   
        is_ok = 0
        @error_desc.push("Oucrrio un error al actualizar los datos del contribuyente")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
    end

    unless params[:contributor_address_id].nil?
      @contributor_addresses = ContributorAddress.where(id: params[:contributor_address_id])
      @contributor_address = @contributor_addresses[0]
      if @contributor_address.update(contributor_addresses_params)
        is_ok = 1
      else 
        is_ok = 0  
        @error_desc.push("Oucrrio un error al actualizar los datos de la direccion del empleado")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
    end

        unless params[:legal_entity_id].nil?
          @legal_entities = LegalEntity.where(id: params[:legal_entity_id])
          @legal_entity = @legal_entities[0]
          if @legal_entity.update(legal_entities_params)
            is_ok = 1
          else 
            is_ok = 0  
            @error_desc.push("Oucrrio un error al actualizar los datos de persona moral")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          end
        end

        unless params[:person_id].nil?
          @people = Person.where(id: params[:person_id])
          @person = @people[0]
          if @person.update(people_params)
            is_ok = 1
          else 
            is_ok = 0  
            @error_desc.push("Oucrrio un error al actualizar los datos de persona fisica")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          end
        end
    if is_ok == 1
      if contributors_params[:contributor_type] == 'PM'
        render 'api/v1/company_update/pm_company'
      elsif contributors_params[:contributor_type] == 'PF'
        render 'api/v1/company_update/pf_company' 
      else 
        raise ActiveRecord::Rollback
      end  
    end
    end
  end


def people_params
  params.require(:person).permit(:id, :fiscal_regime, :rfc, :curp, :imss,
                                 :first_name, :last_name, :second_last_name, :gender,
                                 :nationality, :birth_country, :birthplace, :birthdate,
                                 :martial_status, :martial_regime, :minior_dependents, :senior_dependents,
                                 :housing_type, :id_type, :identification, :phone,
                                 :mobile, :email, :fiel, :extra1, :extra2, :extra3)
end

def contributors_params
    params.require(:contributor).permit(:id, :contributor_type, :bank, :account_number, :clabe, :person_id, :legal_entity_id, :extra1, :extra2, :extra3)
end

def contributor_addresses_params
    params.require(:contributor_address).permit(:id, :contributor_id, :address_type, :street, :external_number, :apartment_number, :suburb_type, :suburb, :address_reference, :postal_code,:municipality_id, :state_id)
end

def legal_entities_params
  params.require(:legal_entity).permit(:id, :fiscal_regime,
                                       :rfc, :rug, :business_name, :phone, :mobile, :email,
                                       :business_email, :main_activity, :fiel, :extra1, :extra2, :extra3)
end

def companies_params
  params.require(:company).permit(:id, :business_name, :start_date, :credit_limit, :credit_available, :document, :sector, :subsector, :company_rate)
end

end


