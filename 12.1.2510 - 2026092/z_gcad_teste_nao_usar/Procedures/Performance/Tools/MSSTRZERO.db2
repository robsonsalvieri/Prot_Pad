create procedure MSSTRZERO
(
in  IN_VALOR    integer ,
in  IN_INTEGER  integer ,
out OUT_VALOR   char( 254 )
)
language SQL
begin
declare vAux   varchar( 254 );
set vAux = repeat( '0', IN_INTEGER ) || RTrim( Char( IN_VALOR ) );
set OUT_VALOR = Substr( vAux, ( length( vAux ) - IN_INTEGER ) + 1, IN_INTEGER );
end
