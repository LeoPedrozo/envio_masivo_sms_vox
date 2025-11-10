create or replace procedure vox_enviar_sms(
    p_nro_origen   in varchar2,
    p_nro_destino  in varchar2,
    p_contenido    in varchar2,
    p_status       out varchar2,
    p_respuesta    out clob
) is
    l_url     varchar2(500) := 'https://www.vox.com.py/smssenderrest/api/mensaje/enviarsms';
    l_result  clob;
    l_user    varchar2(100) := 'username';  -- reemplazar con el usuario
    l_pass    varchar2(100) := 'password'; -- reemplazar con la contrasena
    l_auth_raw  raw(32767);
    l_auth_enc  varchar2(400);
    l_auth      varchar2(400);
    l_result_code number;
    l_result_msg  varchar2(4000);
begin
    -- Generar Authorization: Basic base64(usuario:password)
    l_auth_raw := utl_raw.cast_to_raw(l_user || ':' || l_pass);
    l_auth_enc := utl_raw.cast_to_varchar2(utl_encode.base64_encode(l_auth_raw));
    l_auth     := 'Basic ' || l_auth_enc;

    -- Cabeceras
    apex_web_service.g_request_headers(1).name  := 'Content-Type';
    apex_web_service.g_request_headers(1).value := 'application/x-www-form-urlencoded';
    apex_web_service.g_request_headers(2).name  := 'Authorization';
    apex_web_service.g_request_headers(2).value := l_auth;

    -- Enviar solicitud POST
    l_result := apex_web_service.make_rest_request(
        p_url         => l_url,
        p_http_method => 'POST',
        p_parm_name   => apex_string.string_to_table('nroorigen:nrodestino:contenido', ':'),
        p_parm_value  => apex_string.string_to_table(p_nro_origen || ':' || p_nro_destino || ':' || p_contenido, ':')
    );

    -- Parsear JSON
    p_respuesta := l_result;
    apex_json.parse(l_result);
    l_result_code := apex_json.get_number('Result');
    l_result_msg  := apex_json.get_varchar2('Message');

    -- Estado final
    p_status := l_result_code;

exception
    when others then
        p_status := l_result_code;
        p_respuesta := to_clob(sqlerrm);
        raise;
end vox_enviar_sms;
