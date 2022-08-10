# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id             :uuid             not null, primary key
#  description    :string           not null
#  document_type  :string           not null
#  extra1         :string
#  extra2         :string
#  extra3         :string
#  name           :string           not null
#  validation     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  ext_service_id :uuid
#
# Indexes
#
#  index_documents_on_ext_service_id  (ext_service_id)
#
# Foreign Keys
#
#  fk_rails_...  (ext_service_id => ext_services.id)
#
require 'aws-sdk-s3'  # v2: require 'aws-sdk'

class Document < ApplicationRecord
  include Swagger::Blocks
  include Swagger::DocumentSchema  
  belongs_to :ext_service, optional: true
  has_many :file_type_documents

  validates :document_type, presence: true
  validates :name, presence: true
  validates :description, presence: true

  def self.error_array!(array, status)
    @errors += array
    response.status = status
    render 'api/v1/errors'
  end
    
  def self.nomina_env 
    if ENV['RAILS_ENV'] == 'development'
      trae_local_env
    elsif ENV['RAILS_ENV'] == 'test'
      trae_local_env
    else 
      return trae_nomina_env
    end
  end

  def self.trae_local_env
    unless ENV['LOCAL_NOMINA_ENV'].blank?
      return ENV['LOCAL_NOMINA_ENV']
    else
      @error_desc.push("No se encontró la variable de entorno LOCAL_NOMINA_ENV")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
     end
  end

  def self.trae_nomina_env
    unless ENV['NOMINA_ENV'].blank?
        return ENV['NOMINA_ENV']
      else
        @error_desc.push("No se encontró la variable de entorno NOMINA_ENV")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
  end

  def self.s3_save(file, s3_path)
    obj = s3.bucket(bucket_name).object(s3_path)
    obj.put(
      body: file,
      acl: "public-read" # optional: makes the file readable by anyone
      )
  end

  def self.s3    
      unless ENV['LOCAL_ACCESS_KEY_ID'].blank? || ENV['LOCAL_AWS_REGION'].blank?  || ENV['LOCAL_SECRET_ACCESS_KEY'].blank? || ENV['LOCAL_BUCKET_NAME'].blank?
        return Aws::S3::Resource.new(
          access_key_id:   ENV['LOCAL_ACCESS_KEY_ID'] ,
          region: ENV['LOCAL_AWS_REGION'],
          secret_access_key:  ENV['LOCAL_SECRET_ACCESS_KEY']
        )
      else
        @error_desc.push("No se encontraron las variables de entorno para AWS")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
  end

  def self.bucket_name
    unless ENV['LOCAL_BUCKET_NAME'].blank?
      return ENV['LOCAL_BUCKET_NAME']
    else
      @error_desc.push("No se encontró la variable de entorno LOCAL_BUCKET_NAME")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
    end
  end

  def self.borra_de_local(document_name)
    File.delete(Rails.root.join("#{document_name}.pdf"))if File.exist?(Rails.root.join("#{document_name}.pdf"))
  end

  def self.borra_de_s3(document_name,folio)
    bucket = s3.bucket(bucket_name)
    obj = bucket.object("nomina_customer_documents/#{nomina_env}/#{folio}/customer_credit_#{document_name}_report_#{folio}.pdf")
    obj.delete
  end

  def self.borra_documentos(documents_array,folio)

    documents_array.each do |document_name|
      # BORRA ARCHIVOS GUARDADOS LOCALMENTE CUANDO YA NO SE REQUIEREN
      borra_de_local(document_name)
      #BORRA ARCHIVOS GUARDADOS EN BUCKET S3
      borra_de_s3(document_name,folio)
    end
    borra_de_local("final_#{folio}")
  end

end