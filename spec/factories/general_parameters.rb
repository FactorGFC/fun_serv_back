# frozen_string_literal: true
# == Schema Information
#
# Table name: general_parameters
#
#  id            :uuid             not null, primary key
#  description   :string           not null
#  documentation :string
#  id_table      :integer
#  key           :string           not null
#  table         :string
#  used_values   :string
#  value         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :general_parameter do
    table { "Usuarios" }
    id_table { 1 }
    #key { "usuario_admin" }
    sequence(:key) { |n| "admin#{n}" }
    description { "El usuario es administrador general" }
    used_values { "SI, NO" }
    value { "SI" }
    documentation { "Privilegio para saber cual es el usuario que es el administrador general" }
    factory :gp_base_anual_dias do
      key { "BASE_ANUAL_DIAS" }
      description { "Base anual en días para el cálculo del costo financiero de factoraje" }
      used_values { "Valor único" }
      value { "360" }
      documentation { "Se utiliza en la simulación del costo financiero para el cálculo" }
    end
    factory :gp_clave_tiie do
      key { "CLAVE_TIIE" }
      description { "Clave de la tarifa tiie" }
      used_values { "Valor único" }
      value { "tiie_28d" }
      documentation { "Se utiliza para filtrar las tarifas (rates) tiee por medio de su clave (key)" }
    end
    factory :gp_clave_libor do
      key { "CLAVE_LIBOR" }
      description { "Clave de la tarifa libor" }
      used_values { "Valor único" }
      value { "libor_1m" }
      documentation { "Se utiliza para filtrar las tarifas (rates) libor por medio de su clave (key)" }
    end
    factory :gp_dias_libor do
      key { "MAX_DIAS_LIBOR" }
      description { "Días de antiguedad máximos de libor" }
      used_values { "Valor único" }
      value { "1" }
      documentation { "Se utiliza para validar que la última tarifa libor capturada no tenga una antiguedad mayor a la indicada en este parámetro" }
    end
    factory :gp_rfc_financiera do
      key { "RFC_FINANCIERA" }
      description { "RFC de la financiera" }
      used_values { "Valor único" }
      value { "FGG120928632" }
      documentation { "Este parámero se utilza para obtener el RFC de la financiera" }
    end

    factory :mailer_mode do
      key { "MAILER_MODE" }
      description { "Modo del mailer" }
      used_values { "TEST, PROD" }
      value { "TEST" }
      documentation { "Se utiliza para configurar en modo prueba el mailer" }
    end
    factory :mailer_test_email do
      key { "MAILER_TEST_EMAIL" }
      description { "Correo al que se mandan los correos de prueba" }
      used_values { "valor único" }
      value { "eloyr@gmail.com" }
      documentation { "Se utiliza para configurar el correo al que se mandaran todos los correos del mailer" }
    end
    factory :gp_dias_dispersion do
      key { "DIAS_DISPERSION" }
      description { "Dias para dispersion del pago del credito" }
      used_values { "valor único" }
      value { "5" }
      documentation { "Son los dias que tiene el empleado para realizar la dispersion del credito" }
    end
    factory :gp_dia_pago do
      key { "DIA_PAGO" }
      description { "Dia de la semana que " }
      used_values { "Jueves" }
      value { "4" }
      documentation { "Es el dia de la semana en el que se realizan los pagos de creditos" }
    end
  end
end
