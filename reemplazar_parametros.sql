create or replace function reemplazar_parametros (
    p_plantilla   in clob,
    p_cliente_id  in number
) return clob is
    l_mensaje  clob := p_plantilla;
    l_nombre   clientes.nombre%type;
begin
    select nombre into l_nombre from clientes where id_cliente = p_cliente_id;

    -- Reemplaza {NOMBRE} por el nombre del cliente
    l_mensaje := replace(l_mensaje, '{NOMBRE}', l_nombre);

    -- Aquí puedes agregar más parámetros si tu plantilla lo requiere
    return l_mensaje;
end;
