# frozen_string_literal: true

json.partial! partial: 'api/v1/resource', collection: @sim_customer_payments.sort {|a,b| a.pay_number <=> b.pay_number}, as: :resource