# frozen_string_literal: true

class Api::V1::CompanyRegistrationController < Api::V1::MasterApiController

  before_action :authenticate

  def create
    @error_desc = []
    ActiveRecord::Base.transaction do

      #Revisamos que el tipo de contribuyente no venga vacio
            #Revisamos que el tipo de contribuyente no venga vacio
            if contributors_params[:contributor_type].blank?
              @error_desc.push('Se tiene que mandar el tipo de contribuyente')
              error_array!(@error_desc, :not_found)
              raise ActiveRecord::Rollback
              #Si no viene vacio se revisa que sea PM o PF
            elsif contributors_params[:contributor_type] != 'PM' and contributors_params[:contributor_type] != 'PF'
              @error_desc.push('El tipo de contribuyente tiene que ser: PM o PF')
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
      #Aqui se debde de crear company
      @company = Company.new(contributor_id: @contributor.id, business_name: company_params[:business_name], start_date: company_params[:start_date], 
                              credit_limit: company_params[:credit_limit], credit_available: company_params[:credit_available], document: company_params[:document], 
                              sector: company_params[:sector], subsector: company_params[:subsector], company_rate: company_params[:company_rate] )
            #create_contributor_documents
            if @company.save
                company_segments = []
                company_segments = params[:company_segments] 
                puts 'company_segment' + company_segments.inspect
                  for i in (0..2)
                    company_seg = company_segments[i]
                    @company_segment = CompanySegment.new(key: company_seg["key"], company_rate: company_seg["company_rate"], credit_limit: company_seg["credit_limit"],
                                                       max_period: company_seg["max_period"], commission: company_seg["commission"], currency: company_seg["currency"], extra1: company_seg["extra1"], company_id: @company.id )
                    @company_segment.save
                  end
                  unless @company_segment.save
                  render json: { error: @company_segment.errors }, status: :unprocessable_entity
                  raise ActiveRecord::Rollback
                  end
              unless @legal_entity.blank?
                render 'api/v1/company_registers/pm_company'
              else
                render 'api/v1/company_registers/pf_company'
              end
            else
              render json: { error: @company.errors }, status: :unprocessable_entity
              raise ActiveRecord::Rollback
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

  def company_params
    params.require(:company).permit(:business_name, :start_date, :credit_limit, :credit_available, :document, :sector, :subsector, :company_rate)
  end

  def company_segment_params
    params.require(:company_segment).permit(:key, :company_rate, :credit_limit, :max_period, :commission, :currency, :extra1)
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
 

