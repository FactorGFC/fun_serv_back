# frozen_string_literal: true

class Api::V1::PostalCodesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::PostalCodesApi

  before_action :authenticate

  def pc
    @postal_codes = PostalCode.where(pc: params[:pc])
  end
end
