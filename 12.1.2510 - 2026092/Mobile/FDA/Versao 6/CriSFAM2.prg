#include "eADVPL.ch"

Function ScriptI2()
dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000001"
HUP->UP_DESC	:="Qual é a Marca apoiada no estabelecimento?"
HUP->UP_SCORE	:=0
HUP->UP_IDTREE	:="0000000"
HUP->UP_TIPOOBJ	:="1"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000002"
HUP->UP_DESC	:="A"
HUP->UP_IDTREE	:="0000001"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000003"
HUP->UP_DESC	:="B"
HUP->UP_IDTREE	:="0000001"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000004"
HUP->UP_DESC	:="C"
HUP->UP_IDTREE	:="0000001"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000005"
HUP->UP_DESC	:="D"
HUP->UP_IDTREE	:="0000001"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000006"
HUP->UP_DESC	:="E"
HUP->UP_IDTREE	:="0000001"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000007"
HUP->UP_DESC	:="Como você analisa o estabelecimento"
HUP->UP_SCORE	:=0
HUP->UP_IDTREE	:="0000000"
HUP->UP_TIPOOBJ	:="1"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000008"
HUP->UP_DESC	:="A"
HUP->UP_IDTREE	:="0000007"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000009"
HUP->UP_DESC	:="B"
HUP->UP_IDTREE	:="0000007"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000010"
HUP->UP_DESC	:="C"
HUP->UP_IDTREE	:="0000007"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000011"
HUP->UP_DESC	:="Qual o tipo de peça publicitária faz-se necessário neste Estabelecimento?"
HUP->UP_IDTREE	:="0000000"
HUP->UP_TIPOOBJ	:="2"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000012"
HUP->UP_DESC	:="Panfletos"
HUP->UP_IDTREE	:="0000011"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000013"
HUP->UP_DESC	:="Cartazes"
HUP->UP_IDTREE	:="0000011"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000014"
HUP->UP_DESC	:="Displays"
HUP->UP_IDTREE	:="0000011"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000015"
HUP->UP_DESC	:="Parede"
HUP->UP_IDTREE	:="0000011"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000016"
HUP->UP_DESC	:="Grande"
HUP->UP_IDTREE	:="0000011"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000017"
HUP->UP_DESC	:="Peças estão bem visíveis"
HUP->UP_IDTREE	:="0000000"
HUP->UP_TIPOOBJ	:="1"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000018"
HUP->UP_DESC	:="Local Nobre"
HUP->UP_IDTREE	:="0000017"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000019"
HUP->UP_DESC	:="Secundário"
HUP->UP_IDTREE	:="0000017"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000020"
HUP->UP_DESC	:="Motivos Retirar Diplay"
HUP->UP_IDTREE	:="0000000"
HUP->UP_TIPOOBJ	:="3"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000002"
HUP->UP_CODPERG	:="0000021"
HUP->UP_DESC	:="Observação"
HUP->UP_IDTREE	:="0000000"
HUP->UP_TIPOOBJ	:="3"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000001"
HUP->UP_DESC	:="Forma de Pagto. do Concorrência?"
HUP->UP_SCORE	:=0
HUP->UP_IDTREE	:="0000000"
HUP->UP_TIPOOBJ	:="1"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000002"
HUP->UP_DESC	:="À Vista"
HUP->UP_IDTREE	:="0000001"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000003"
HUP->UP_DESC	:="7 dd"
HUP->UP_IDTREE	:="0000001"
dbCommit()             

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000004"
HUP->UP_DESC	:="10 dd"
HUP->UP_IDTREE	:="0000001"
dbCommit()     
                        
dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000005"
HUP->UP_DESC	:="15 dd"
HUP->UP_IDTREE	:="0000001"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000006"
HUP->UP_DESC	:="Freq. Visita Concorrência?"
HUP->UP_SCORE	:=0
HUP->UP_IDTREE	:="0000000"
HUP->UP_TIPOOBJ	:="1"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000007"
HUP->UP_DESC	:="Diária"
HUP->UP_IDTREE	:="0000006"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000008"
HUP->UP_DESC	:="Semanal"
HUP->UP_IDTREE	:="0000006"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000009"
HUP->UP_DESC	:="Quinzenal"
HUP->UP_IDTREE	:="0000006"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000010"
HUP->UP_DESC	:="Mensal"
HUP->UP_IDTREE	:="0000006"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000011"
HUP->UP_DESC	:="Preços da Concorrência"
HUP->UP_IDTREE	:="0000000"
HUP->UP_TIPOOBJ	:="3"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000012"
HUP->UP_DESC	:="Estoque da Concorrência"
HUP->UP_IDTREE	:="0000000"
HUP->UP_TIPOOBJ	:="3"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000013"
HUP->UP_DESC	:="Qual a Marca que Vende mais?"
HUP->UP_IDTREE	:="0000000"
HUP->UP_TIPOOBJ	:="1"
dbCommit()

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000014"
HUP->UP_DESC	:="Free"
HUP->UP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000015"
HUP->UP_DESC	:="Malboro"
HUP->UP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000016"
HUP->UP_DESC	:="Carlton"
HUP->UP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000017"
HUP->UP_DESC	:="Hollywood"
HUP->UP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000018"
HUP->UP_DESC	:="Kent"
HUP->UP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000019"
HUP->UP_DESC	:="Camel"
HUP->UP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000020"
HUP->UP_DESC	:="Sampoerna"
HUP->UP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000021"
HUP->UP_DESC	:="Gudan Garan"
HUP->UP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000022"
HUP->UP_DESC	:="Preços da Concorrência"
HUP->UP_IDTREE	:="0000000"
HUP->UP_TIPOOBJ	:="3"
dbCommit()


dbAppend()
HUP->UP_CODSCRI	:="000003"
HUP->UP_CODPERG	:="0000023"
HUP->UP_DESC	:="Observação"
HUP->UP_IDTREE	:="0000000"
HUP->UP_TIPOOBJ	:="3"
dbCommit()


Return Nil