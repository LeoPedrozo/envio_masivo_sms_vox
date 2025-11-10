create or replace package twilio_envios is

  /**
   * Envía un mensaje a todos los clientes activos usando una plantilla
   * @param p_id_plantilla     ID de la plantilla a usar
   * @param p_numero_remitente Número registrado en Twilio desde el cual se enviará
   */
  procedure enviar_mensajes (
      p_id_plantilla     in number,
      p_numero_remitente in varchar2
  );

end twilio_envios;


-- Package spec twilio
create or replace package twilio is

  /**
   * Envía un SMS utilizando la API de Twilio.
   *
   * @param p_to_phone_no     Número de teléfono destino (formato E.164, ej. +595981234567)
   * @param p_from_phone_no   Número de Twilio remitente (también en formato E.164)
   * @param p_msg             Mensaje en formato CLOB
   */
  procedure send_sms (
      p_to_phone_no   in varchar2,
      p_from_phone_no in varchar2,
      p_msg           in clob
  );

end twilio;
/

-- Package body twilio
create or replace package body twilio is

  g_account_sid        constant varchar2(255) := 'account_sid_here';
  g_auth_str           constant varchar2(255) := 'Basic auth_token_here';
  g_twilio_host        constant varchar2(255) := 'https://api.twilio.com';
  g_twilio_api_version constant varchar2(20)  := '2010-04-01';

  procedure send_sms (
      p_to_phone_no   in varchar2,
      p_from_phone_no in varchar2,
      p_msg           in clob
  ) is
    l_result         clob;
    l_url            varchar2(1000);
    l_debug_template varchar2(4000) := 'twilio.send_sms %0 %1 %2 %3 %4 %5 %6 %7';
  begin
    apex_debug.enable;

    apex_debug.message(l_debug_template, 'START', 'To', p_to_phone_no, 'From', p_from_phone_no, 'Msg', dbms_lob.substr(p_msg, 100));

    l_url := g_twilio_host || '/' || g_twilio_api_version || '/Accounts/' || g_account_sid || '/Messages.json';

    apex_web_service.g_request_headers(1).name  := 'Content-Type';
    apex_web_service.g_request_headers(1).value := 'application/x-www-form-urlencoded';

    apex_web_service.g_request_headers(2).name  := 'Authorization';
    apex_web_service.g_request_headers(2).value := g_auth_str;

    l_result := apex_web_service.make_rest_request (
        p_url         => l_url,
        p_http_method => 'POST',
        p_parm_name   => apex_string.string_to_table('Body:To:From', ':'),
        p_parm_value  => apex_string.string_to_table(p_msg || ':' || p_to_phone_no || ':' || p_from_phone_no, ':')
    );

    apex_debug.message(l_debug_template, 'Respuesta', dbms_lob.substr(l_result, 100));
    apex_debug.message(l_debug_template, 'END');

    apex_debug.disable;
  exception
    when others then
      apex_debug.error(l_debug_template, 'ERROR', sqlerrm);
      raise;
  end send_sms;

end twilio;
/

create or replace package twilio_envios is

  /**
   * Envía un mensaje a todos los clientes activos usando una plantilla
   * @param p_id_plantilla     ID de la plantilla a usar
   * @param p_numero_remitente Número registrado en Twilio desde el cual se enviará
   */
  procedure enviar_mensajes (
      p_id_plantilla     in number,
      p_numero_remitente in varchar2
  );

end twilio_envios;