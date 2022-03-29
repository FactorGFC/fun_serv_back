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
    factory :gp_banxico_token do
      key { "BANXICO_TOKEN" }
      description { "Token para consumir APIs de Banco de México" }
      used_values { "Valor único" }
      value { "5db60195d4af52075d36d0965b14de3923bab9cd1ccbe8ab331c4d6a1d2b27e1" }
      documentation { "Token para APIs de Banco de México, se puede generar desde https://www.banxico.org.mx/SieAPIRest/service/v1/token" }
    end
    factory :gp_banxico_url do
      key { "BANXICO_URL" }
      description { "URL para consumir APIs de Banco de México" }
      used_values { "Valor único" }
      value { "https://www.banxico.org.mx/SieAPIRest/service/v1/series/<:serie>/datos/<:fechaini>/<:fechafin>?token=<:token>" }
      documentation { "URL para APIs de Banco de México, se deben reemplazar las variables: serie, fecha_inicio, fecha_fin" }
    end
    factory :gp_banxico_serie_tiie28d do
      key { "BANXICO_SERIE_TIIE28D" }
      description { "Serie utilizada por banxico para obtener la tiie 28 días" }
      used_values { "Valor único" }
      value { "SF43783" }
      documentation { "Serie para obtener la tiie a 28 días en Banco de México, se deben reemplazar la variable serie de la URL por este valor" }
    end
    factory :gp_base_anual_dias do
      key { "BASE_ANUAL_DIAS" }
      description { "Base anual en días para el cálculo del costo financiero de factoraje" }
      used_values { "Valor único" }
      value { "360" }
      documentation { "Se utiliza en la simulación del costo financiero para el cálculo" }
    end
    factory :gp_funder_dif_rate do
      key { "FUNDER_DIF_RATE" }
      description { "Diferencia de la tasa de interes para el inversionista" }
      used_values { "Valor único" }
      value { "3" }
      documentation { "Se utiliza para obtener la tasa de rendimiento del inversionista restando este valor a la suma de la tasa y la tiee" }
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
    # Parámetros para facturación
    factory :gp_complemento_cadena do
      key { "FACTURACION_GENERA_COMPLEMENTO_CADENA" }
      description { "Parámetro para indicar si generamos complementos a la cadena despues de registrar el pago" }
      used_values { "SI, para cuando queremos generar complementos, NO para cuando no queremos generar complementos" }
      value { "SI" }
      documentation { "Se utiliza para validar que la última tarifa libor capturada no tenga una antiguedad mayor a la indicada en este parámetro" }
    end
    factory :gp_complemento_proveedor do
      key { "FACTURACION_GENERA_COMPLEMENTO_PROVEEDOR" }
      description { "Parámetro para indicar si generamos complementos del proveedor despues de registrar el pago" }
      used_values { "SI, para cuando queremos generar complementos, NO para cuando no queremos generar complementos" }
      value { "SI" }
      documentation { "Se utiliza para deshabilitar la generación de complementos de los proveedores a través del sistema" }
    end
    factory :gp_factura_intereses do
      key { "FACTURACION_GENERA_FACTURA_INTERESES" }
      description { "Parámetro para indicar si generamos la factura de intereses a los proveedores" }
      used_values { "SI, para cuando queremos generar la factura de intereses, NO para cuando no queremos generar la factura de intereses" }
      value { "SI" }
      documentation { "Se utiliza para deshabilitar la generación de intereses a través del sistema" }
    end
    factory :gp_url_facturacion do
      key { "URL_FACTURACION" }
      description { "Url para consumir el api de facturacion" }
      used_values { "Los valores que cambian son los métodos, puede ser: generarCfdi, probarConexion, informacionCfdi, cancelarCfdi, enviarCorreo" }
      value { "https://api.enlacefiscal.com/v6/:metodo" }
      documentation { "Se utiliza para consumir el end point de facturación despues de generar un pago, ya se apara generar la factura de intereses, el complemento de pago del proveedor, o el compelemento de pago para la cadena" }
    end
    factory :gp_facturacion_saldo do
      key { "URL_FACTURACION_SALDO" }
      description { "Url para consultar el saldo de facturación disponible" }
      used_values { "Valor único" }
      value { "https://api.enlacefiscal.com/rest/v1/comprobantes/obtenerSaldo" }
      documentation { "Se utiliza para consumir el end point de facturación para saber cuanto es el saldo que hay en la cuenta" }
    end
    factory :gp_metodo_genera_cfdi do
      key { "FACTURACION_METODO_GENERAR_CFDI" }
      description { "Método para generar CFDIs en el sistema de facturación" }
      used_values { "Valor único" }
      value { "generarCfdi" }
      documentation { "Se utiliza para ser concatenado en url del entpoint para generar cfdis" }
    end
    factory :gp_metodo_probar_conexion do
      key { "FACTURACION_METODO_PROBAR_CONEXION" }
      description { "Método para generar probar conexión en el sistema de facturación" }
      used_values { "Valor único" }
      value { "probarConexion" }
      documentation { "Se utiliza para ser concatenado en url del entpoint para probar conexión" }
    end
    factory :gp_informacion_cfdi do
      key { "FACTURACION_METODO_INFORMACION_CFDI" }
      description { "Método para consultar CFDIs en el sistema de facturación" }
      used_values { "Valor único" }
      value { "informacionCfdi" }
      documentation { "Se utiliza para ser concatenado en url del entpoint para consultar cfdis" }
    end
    factory :gp_cancelar_cfdi do
      key { "FACTURACION_METODO_CANCELAR_CFDI" }
      description { "Método para cancelar CFDIs en el sistema de facturación" }
      used_values { "Valor único" }
      value { "cancelarCfdi" }
      documentation { "Se utiliza para ser concatenado en url del entpoint para cancelar cfdis" }
    end
    factory :gp_enviar_correo do
      key { "FACTURACION_METODO_ENVIAR_CORREO" }
      description { "Método para mandar por correo los CFDIs generados en el sistema de facturación" }
      used_values { "Valor único" }
      value { "enviarCorreo" }
      documentation { "Se utiliza para ser concatenado en url del entpoint para mandar por correo los cfdis generados" }
    end
    factory :gp_modo do
      key { "FACTURACION_MODO" }
      description { "Modo de uso para api de facturación" }
      used_values { "Los posibles valors son: debug, produccion" }
      value { "debug" }
      documentation { "Se utiliza para cambiar el modo del llamado del API de facturación, a debug o producción" }
    end
    factory :gp_rfc_financiera do
      key { "RFC_FINANCIERA" }
      description { "RFC de la financiera" }
      used_values { "Valor único" }
      value { "FGG120928632" }
      documentation { "Este parámero se utilza para obtener el RFC de la financiera" }
    end
    factory :gp_metodo_genera_reciboep do
      key { "FACTURACION_METODO_GENERAR_RECIBOEP" }
      description { "Método para generar Recibo Electrónico de Pago en el sistema de facturación" }
      used_values { "Valor único" }
      value { "generarReciboElectronicoPago" }
      documentation { "Se utiliza para ser concatenado en url del entpoint para generar recibos electrónicos de pago" }
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
    factory :frontend_url do
      key { "FRONTEND_URL" }
      description { "URL del Frontend" }
      used_values { "Valor único" }
      value { "https://google.com" }
      documentation { "Se utiliza para configurar la url de frontend" }
    end
    factory :sat_cfdi_val_mode do
      key { "SAT_CFDI_VAL_MODE" }
      description { "Validación de facturas por el SAT" }
      used_values { "Valor único" }
      value { "NO" }
      documentation { "Se utiliza para saber si vamos a validar las facturas con el SAT" }
    end
    factory :calculo_por_proyecto do
      key { "CALCULO_POR_PROYECTO" }
      description { "Parámetro para prender o apagar el cálculo de solicitudes por proyecto" }
      used_values { "Valor único" }
      value { "NO" }
      documentation { "Se utiliza para saber si los cálculos serán por segmento o por proyecto" }
    end
    factory :token_pago_financiera do
      key { "TOKEN_PAGO_FINANCIERA" }
      description { "Token de pago de la cuenta de enlace digital de la financiera" }
      used_values { "Valor único" }
      value { "6a764041670a80fd0194e3838e7b614bd1e1da8a" }
      documentation { "Este token se manda como parte de los parámetros de json a enlace fiscal y sirve para que el cobro de facturación de en lace fiscal se haga a la empresa concentradora en este caso a la financiera" }
    end
  end
end
