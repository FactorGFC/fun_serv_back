# frozen_string_literal: true

class Api::V1::UserRegistrationController < Api::V1::MasterApiController

  before_action :authenticate

  def create
    @error_desc = []
    ActiveRecord::Base.transaction do

      @company = Company.find_by_sql ["SELECT ab.*
      FROM ((SELECT comp.*
             FROM companies comp, contributors cont, people peop
             WHERE comp.contributor_id = cont.id
             AND cont.person_id = peop.id
             AND peop.rfc in (:rfc)
             AND cont.contributor_type in ('PF')
             ) UNION ALL
             (SELECT comp.*
             FROM companies comp, contributors cont, legal_entities leen
             WHERE comp.contributor_id = cont.id
             AND cont.legal_entity_id = leen.id
             AND leen.rfc in (:rfc)
             AND cont.contributor_type = 'PM'
             )
           ) ab", { rfc: params[:person][:rfc]}]
    if @company[0].blank?
    @error_desc.push("No se encontró una cadena dada de alta con el RFC: #{params[:rfc]}")
    error_array!(@error_desc, :unprocessable_entity)
    raise ActiveRecord::Rollback
    end

      #Revisamos que el tipo de contribuyente no venga vacio
      if contributors_params[:contributor_type].blank?
        @error_desc.push('Se tiene que mandar el tipo de contribuyente')
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
        #Si no viene vacio se revisa que sea PM o PF
      elsif contributors_params[:contributor_type] != 'PM' and contributors_params[:contributor_type] != 'PF'
        @error_desc.push('El tipo de contribuyente tiene que ser: PM o PM')
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      elsif contributors_params[:contributor_type] == 'PM'
        @legal_entity = LegalEntity.new(legal_entities_params)
        if @legal_entity.save
          @contributor = Contributor.new(contributor_type: contributors_params[:contributor_type], bank: contributors_params[:bank], account_number: contributors_params[:account_number],
                                         clabe: contributors_params[:clabe], legal_entity_id: @legal_entity.id)
          unless @contributor.save
            render json: { error: @contributor.errors }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        else
          render json: { error: @legal_entity.errors }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      elsif contributors_params[:contributor_type] == 'PF'
        @person = Person.new(people_params)
        if @person.save
          @contributor = Contributor.new(contributor_type: contributors_params[:contributor_type], bank: contributors_params[:bank], account_number: contributors_params[:account_number],
                                         clabe: contributors_params[:clabe], person_id: @person.id)
          unless @contributor.save
            render json: { error: @contributor.errors }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        else
          render json: { error: @person.errors }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      end
      @contributor_address = ContributorAddress.new(contributor_id: @contributor.id, address_type: contributor_address_params[:address_type], street: contributor_address_params[:street],
                                                    external_number: contributor_address_params[:external_number], apartment_number: contributor_address_params[:apartment_number], suburb_type: contributor_address_params[:suburb_type], suburb: contributor_address_params[:suburb], address_reference: contributor_address_params[:address_reference], postal_code: contributor_address_params[:postal_code], municipality_id: contributor_address_params[:municipality_id], state_id: contributor_address_params[:state_id])
      unless @contributor_address.save
        render json: { error: @contributor_address.errors }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      # if customer_params[:name].blank? and funder_params[:name].blank?
      #  @error_desc.push('Se tienen que mandar los datos de la persona física o de la persona moral según corresponda')
      #  error_array!(@error_desc, :not_found)
      #  raise ActiveRecord::Rollback
      # end
      if params[:type].blank?
        @error_desc.push('Se tiene que mandar el tipo de operacion type = customer')
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      elsif params[:type] != 'customer' 
        @error_desc.push('Se tiene que mandar el tipo de operacion type = customer')
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
      if params[:type] == 'customer'
        @customer = Customer.new(contributor_id: @contributor.id, attached: customer_params[:attached], customer_type: customer_params[:customer_type], name: customer_params[:name],
                                 status: customer_params[:status], user_id: customer_params[:user_id], salary_period: customer_params[:salary_period], salary: customer_params[:salary],
                                 other_income: customer_params[:other_income], net_expenses: customer_params[:net_expenses], family_expenses: customer_params[:family_expenses],
                                 house_rent: customer_params[:house_rent], credit_cp: customer_params[:credit_cp], credit_lp: customer_params[:credit_lp], immediate_superior: customer_params[:immediate_superior], 
                                 seniority: customer_params[:seniority], ontime_bonus: customer_params[:ontime_bonus], assist_bonus: customer_params[:assist_bonus], food_vouchers: customer_params[:food_vouchers], 
                                 total_income: customer_params[:total_income], total_savings_found: customer_params[:total_savings_found], christmas_bonus: customer_params[:christmas_bonus], taxes: customer_params[:taxes], 
                                 imms: customer_params[:imms], savings_found:customer_params[:savings_found], savings_found_loand: customer_params[:savings_found_loand], savings_bank:customer_params[:savings_bank], 
                                 insurance_discount: customer_params[:insurance_discount], child_support: customer_params[:child_support], extra_expenses: customer_params[:extra_expenses], infonavit: customer_params[:infonavit], company_id: customer_params[:company_id])
        unless @customer.customer_type.blank?
          @file_types = FileType.where(customer_type: @customer.customer_type)
          if @file_types.blank?
            @error_desc.push("No se encontró un tipo de expediente para el tipo de cliente: #{@customer.customer_type}")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          else
            create_contributor_documents
            @customer.update(file_type_id: @file_types[0].id)
            if @customer.save
                     #Agregamos las referencias de un customer
                  @customer_personal_refrence = CustomerPersonalReference.new(customer_id: @customer.id, first_name: customer_pr_params[:first_name], last_name: customer_pr_params[:last_name], 
                                                                                second_last_name: customer_pr_params[:second_last_name], address: customer_pr_params[:address], 
                                                                                phone: customer_pr_params[:phone], reference_type: customer_pr_params[:reference_type])
                  unless @customer_personal_refrence.save
                  render json: { error: @customer_personal_refrence.errors }, status: :unprocessable_entity
                  raise ActiveRecord::Rollback
                  end
                render 'api/v1/user_registers/pf_customer'
            else
              render json: { error: @customer.errors }, status: :unprocessable_entity
              raise ActiveRecord::Rollback
            end
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
                                   :martial_status, :martial_regime, :minior_dependents, :senior_dependents,
                                   :housing_type, :id_type, :identification, :phone,
                                   :mobile, :email, :fiel, :extra1, :extra2, :extra3)
  end

  def contributors_params
    params.require(:contributor).permit(:contributor_type, :bank, :account_number, :clabe, :person_id, :legal_entity_id, :extra1, :extra2, :extra3)
  end

  def contributor_address_params
    params.require(:contributor_address).permit(:contributor_id, :address_type, :street, :external_number, :apartment_number, :suburb_type, :suburb, :address_reference, :postal_code,
                                                :municipality_id, :state_id)
  end

 # def customer_params
  #  params.require(:customer).permit(:contributor_id, :attached, :customer_type, :name, :status, :user_id)
  end

  def customer_params
    params.require(:customer).permit(:contributor_id, :attached, :customer_type, :name, :status, :user_id,
                                     :salary_period, :salary, :other_income, :net_expenses,
                                     :family_expenses, :house_rent, :credit_cp, :credit_lp,
                                     :immediate_superior, :seniority, :ontime_bonus, :assist_bonus,
                                     :food_vouchers, :total_income, :total_savings_found,
                                     :christmas_bonus, :taxes, :imms, :savings_found,
                                     :savings_found_loand, :savings_bank, :insurance_discount,
                                     :child_support, :extra_expenses, :infonavit, :user_id, :company_id)
                                    end
  
  def create_contributor_documents
    @file_type_documents = FileTypeDocument.where(file_type_id: @file_types[0].id)
    @file_type_documents.each do |file_type_document|
      @documents = Document.where(id: file_type_document.document_id)
      unless @documents.blank?
        ContributorDocument.custom_update_or_create(@contributor.id, file_type_document.id, @documents[0].name, 'PI') # PI - Por ingresar, estatus inicial
      end
    end
 

  def customer_pr_params
    params.require(:customer_personal_reference).permit(:first_name, :last_name, :second_last_name, :address, :phone, :reference_type, :customer_id)
  end
end
