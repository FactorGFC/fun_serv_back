class BuroCredito < ApplicationRecord

    require 'net/http'
    require 'uri'
    require 'json'
  
  
    def self.create_client data
  
      # uri = URI.parse("https://sandbox.moffin.mx/api/v1/profiles/info")
      # token = 'Token: 8d3f4980e76f1cf12da3005bac068636c1f36aa4cda8176de91bc64c00346f5b'
      # Production
      uri = URI.parse("https://app.moffin.mx/api/v1/profiles/info")
      token = 'Token: 59f899b9f9de3db1191b36d06cff5d63c563feba86a1678031637c9827156c7e'
  
      request = Net::HTTP::Post.new(uri.request_uri)
  
      data
  
      request.content_type = "application/json"
      request["Authorization"] = token
      request.body = data.to_json
  
      req_options = {
          use_ssl: uri.scheme == "https",
      }
  
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
  
      return JSON.parse(response.body)
  
    end
  
    def self.get_client id
      uri = URI.parse("https://sandbox.moffin.mx/api/v1/profiles/#{id}")
      token = 'Token: 8d3f4980e76f1cf12da3005bac068636c1f36aa4cda8176de91bc64c00346f5b'
      # prod
      # uri = URI.parse("#{ENV['URL_BUREAU_PRODUCTION']}api/v1/profiles/#{id}")
      # token = 'Token: 59f899b9f9de3db1191b36d06cff5d63c563feba86a1678031637c9827156c7e'

      request = Net::HTTP::Get.new(uri.request_uri)
  
      request.content_type = "application/json"
      request["Authorization"] = token
  
      req_options = {
          use_ssl: uri.scheme == "https",
      }
  
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
  
      return JSON.parse(response.body)
  
    end
  
  
    def self.get_buro_report id  , info_sat = nil
      # uri = URI.parse("https://sandbox.moffin.mx/api/v1/profiles/#{id}/query")
      # token = 'Token: 8d3f4980e76f1cf12da3005bac068636c1f36aa4cda8176de91bc64c00346f5b'

      # ENV['URL_BUREAU_PRODUCTION'] = 'https://app.moffin.mx/'
      # ENV['TOKEN_BURO_PRODUCTION'] = 'Token: 59f899b9f9de3db1191b36d06cff5d63c563feba86a1678031637c9827156c7e'
      #prod
      uri = URI.parse("https://app.moffin.mx/api/v1/profiles/#{id}/query")
      token = 'Token: 59f899b9f9de3db1191b36d06cff5d63c563feba86a1678031637c9827156c7e'

      account_type_pf_b = true
      account_type_pm_b = false

      data = {
          bureauPM: true,
          bureauPF: true,
          satBlackList: true,
          satRFC: true
      }
  
      request = Net::HTTP::Post.new(uri.request_uri)
  
      request.content_type = "application/json"
      request["Authorization"] = token
      request.body = data.to_json
  
  
      req_options = {
          use_ssl: uri.scheme == "https",
      }
  
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
  
      # p "JSON.parse(response.body) ------------------------------------------------------------------------"
      # p JSON.parse(response.body)
  
      return JSON.parse(response.body)
  
    end
  
    def self.get_buro_info id , info_sat = nil
      # uri = URI.parse("https://sandbox.moffin.mx/api/v1/profiles/#{id}/info")
      # token = 'Token: 8d3f4980e76f1cf12da3005bac068636c1f36aa4cda8176de91bc64c00346f5b'
      # prod
      # uri = URI.parse("#{ENV['URL_BUREAU_PRODUCTION']}api/v1/profiles/#{id}/info")
      # token = ENV['TOKEN_BURO_PRODUCTION']
      uri = URI.parse("https://app.moffin.mx/api/v1/profiles/#{id}/info")
      token = 'Token: 59f899b9f9de3db1191b36d06cff5d63c563feba86a1678031637c9827156c7e'

      account_type_pf_b = false
      account_type_pm_b = false

      data = {
          bureauPM: true,
          bureauPF: true,
          satBlackList: true,
          satRFC: true
      }
  
      request = Net::HTTP::Get.new(uri.request_uri)
  
      request.content_type = "application/json"
      request["Authorization"] = token
      request.body = data.to_json
  
  
      req_options = {
          use_ssl: uri.scheme == "https",
      }
  
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
  
      # p "JSON.parse(response.body) ------------------------------------------------------------------------"
      # p JSON.parse(response.body)
  
      return JSON.parse(response.body)
  
    end
  
    def self.get_all_reports
      uri = URI.parse("https://sandbox.moffin.mx/api/v1/report")
      token = 'Token: 8d3f4980e76f1cf12da3005bac068636c1f36aa4cda8176de91bc64c00346f5b'
      #prod
      # uri = URI.parse("#{ENV['URL_BUREAU_PRODUCTION']}api/v1/report")
      # token = 'Token: 59f899b9f9de3db1191b36d06cff5d63c563feba86a1678031637c9827156c7e'

      # data = {
      #     bureauPM: true,
      #     bureauPF: true,
      #     satBlackList: true,
      #     satRFC: true
      # }
  
      request = Net::HTTP::Get.new(uri.request_uri)
  
      request.content_type = "application/json"
      request["Authorization"] = token
      # request.body = data.to_json
  
  
      req_options = {
          use_ssl: uri.scheme == "https",
      }
  
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
  
      return JSON.parse(response.body)
  
    end
  
    def self.get_report_by_id id
      uri = URI.parse("https://sandbox.moffin.mx/api/v1/report/#{id}")
      token = 'Token: 8d3f4980e76f1cf12da3005bac068636c1f36aa4cda8176de91bc64c00346f5b'
      #prod
      # uri = URI.parse("#{ENV['URL_BUREAU_PRODUCTION']}api/v1/report/#{id}")
      # token = 'Token: 59f899b9f9de3db1191b36d06cff5d63c563feba86a1678031637c9827156c7e'

      # data = {
      #     bureauPM: true,
      #     bureauPF: true,
      #     satBlackList: true,
      #     satRFC: true
      # }
  
      request = Net::HTTP::Get.new(uri.request_uri)
  
      request.content_type = "application/json"
      request["Authorization"] = token
      # request.body = data.to_json
  
  
      req_options = {
          use_ssl: uri.scheme == "https",
      }
  
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
  
      return JSON.parse(response.body)
  
    end
  
  
    def self.get_report_by_id id
        uri = URI.parse("https://sandbox.moffin.mx/api/v1/report/#{id}")
        token = 'Token: 8d3f4980e76f1cf12da3005bac068636c1f36aa4cda8176de91bc64c00346f5b'
        #prod
        # uri = URI.parse("#{ENV['URL_BUREAU_PRODUCTION']}api/v1/report/#{id}")
        # token = 'Token: 59f899b9f9de3db1191b36d06cff5d63c563feba86a1678031637c9827156c7e'
        # data = {
        #     bureauPM: true,
        #     bureauPF: true,
        #     satBlackList: true,
        #     satRFC: true
        # }
  
        request = Net::HTTP::Get.new(uri.request_uri)
  
        request.content_type = "application/json"
        request["Authorization"] = token
        # request.body = data.to_json
  
  
        req_options = {
            use_ssl: uri.scheme == "https",
        }
  
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
  
        return JSON.parse(response.body)
  
    end

    def self.update_profile id

      # uri = URI.parse("#{ENV['URL_BUREAU_DEVELOP']}api/v1/profiles/#{id}")
      # token = ENV['TOKEN_BURO_DEVELOP']
      #prod
      uri = URI.parse("https://app.moffin.mx/api/v1/profiles/#{id}")
      token = 'Token: 59f899b9f9de3db1191b36d06cff5d63c563feba86a1678031637c9827156c7e'
  
      data = {
          rfc: 'DECL900402UW6'
          # accountType: "PM"
          #
      }
  
      request = Net::HTTP::Put.new(uri.request_uri)
  
      request.content_type = "application/json"
      request["Authorization"] = token
      request.body = data.to_json
  
  
      req_options = {
          use_ssl: uri.scheme == "https",
      }
  
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
  
      return JSON.parse(response.body)
  
    end
  
  
  end