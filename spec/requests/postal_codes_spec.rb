# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::PostalCodesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /lists/domain/:domain' do
    before :each do
      @postal_code = '99999'
      FactoryBot.create(:postal_code, pc: @postal_code)
      FactoryBot.create(:postal_code, pc: @postal_code)
      FactoryBot.create(:postal_code, pc: @postal_code)
      get api_v1_postal_code_filter_path(@postal_code), params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'cuenta las colonias con el mismo código postal' do
      get api_v1_postal_code_filter_path(@postal_code), params: { token: token.token, secret_key: my_app.secret_key }
      expect(PostalCode.where(pc: @postal_code).count).to eq(PostalCode.count)
    end
  end
end
