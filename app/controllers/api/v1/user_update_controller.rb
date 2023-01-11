# frozen_string_literal: true

class Api::V1::UserUpdateController < Api::V1::MasterApiController

  before_action :authenticate

  def update_user_info
    #Poner bandera en 0 si todo esta bien si no poner 1
    #si bandera = 0 render si no rollback
  @error_desc = []
  ActiveRecord::Base.transaction do
   # is_ok = 0
 #  @person = ''
    unless params[:person_id].nil?
      @person_id = Person.where(id: params[:person_id])
      @person = @person_id[0]
      if people_params.nil?
        @error_desc.push("Se debe de mandar el id y el nombre del empleado")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
      if @person_id[0].update(people_params)
         is_ok = 1
      else  
        is_ok = 0 
        @error_desc.push("Oucrrio un error al actualizar los datos personales del empleado")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
    else
      @error_desc.push("Se debe de mandar el id y el nombre del empleado")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
    end
    unless params[:contributor_id].nil?
      @contributor_id = Contributor.where(id: params[:contributor_id])
      if @contributor_id[0].update(contributors_params)
        is_ok = 1
      else   
        is_ok = 0
        @error_desc.push("Oucrrio un error al actualizar los datos del contribuidor")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
    end
    unless params[:contributor_address_id].nil?
      @contributor_address_id = ContributorAddress.where(id: params[:contributor_address_id])
      if @contributor_address_id[0].update(contributor_addresses_params)
        is_ok = 1
      else 
        is_ok = 0  
        @error_desc.push("Oucrrio un error al actualizar los datos de la direccion del empleado")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
    end
    unless params[:customer_id].nil?
      @customer_id = Customer.where(id: params[:customer_id])
      if @customer_id[0].update(customers_params)
        is_ok = 1
      else   
        is_ok = 0
        @error_desc.push("Oucrrio un error al actualizar los datos del empleado")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
    end
    unless params[:customer_pr_id].nil?
      @customer_pr_id = CustomerPersonalReference.where(id: params[:customer_pr_id])
      if @customer_pr_id[0].update(customer_personal_references_params)
        is_ok = 1
      else  
        is_ok = 0 
        @error_desc.push("Oucrrio un error al actualizar los datos de las referencias personales del empleado")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollbackder json: @person.errors, status: :unprocessable_entity
      end
    end
    if is_ok == 1
      render 'api/v1/user_updates/pf_customer'
    else
      raise ActiveRecord::Rollback
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
    params.require(:contributor_address).permit(:id, :contributor_id, :address_type, :street, :external_number, :apartment_number, :suburb_type, :suburb, :address_reference, :postal_code,                                                :municipality_id, :state_id)
end

def customers_params
    params.require(:customer).permit(:id, :contributor_id, :attached, :customer_type, :name, :status, :user_id,
                                     :salary_period, :salary, :other_income, :net_expenses,
                                     :family_expenses, :house_rent, :credit_cp, :credit_lp,
                                     :immediate_superior, :seniority, :ontime_bonus, :assist_bonus,
                                     :food_vouchers, :total_income, :total_savings_found,
                                     :christmas_bonus, :taxes, :imms, :savings_found,
                                     :savings_found_loand, :savings_bank, :insurance_discount,
                                     :child_support, :extra_expenses, :infonavit, :user_id, :company_id, :extra3)
end
   
def customer_personal_references_params
    params.require(:customer_personal_reference).permit(:id, :first_name, :last_name, :second_last_name, :address, :phone, :reference_type, :customer_id)
end

end
