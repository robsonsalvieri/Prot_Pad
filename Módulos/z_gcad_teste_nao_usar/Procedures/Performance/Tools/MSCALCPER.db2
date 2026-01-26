create procedure MSCALCPER (
	in  IN_PERINI	Char( 254 ),
	in  IN_PERFIM	Char( 254 ),
	in  IN_DATA	Char( 08),
	out OUT_PERIODO	Char( 02 )
)

LANGUAGE SQL

begin
declare vnCont     integer ;
declare vcDataIni  char( 08 ) ;
declare vcDataFim  char( 08 ) ;
declare vAux       integer;

set vnCont  = 1 ;
parse1:
while (vnCont	< 18 ) do
set vcDataIni = Substr ( IN_PERINI , 8	*  (vnCont	- 1 )  + 1 , 8 );
set vcDataFim = Substr ( IN_PERFIM , 8	*  (vnCont	- 1 )  + 1 , 8 );
if IN_DATA	>= vcDataIni and IN_DATA  <= vcDataFim  then
set vAux = 2;
call MSSTRZERO (vnCont, vAux, OUT_PERIODO );
set vnCont = 19;
leave parse1;
end if;
set vnCont = vnCont + 1 ;
end while;
end
