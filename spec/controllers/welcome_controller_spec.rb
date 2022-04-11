# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  describe 'GET #index' do
    it 'returns http success' do
      #get :index
      get :ok
      expect(response).to have_http_status(:success)
    end
  end
end
