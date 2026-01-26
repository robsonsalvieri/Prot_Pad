#include "eADVPL.ch"

Function ScriptI2()
dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000001"
HUP->HUP_DESC	:="Qual é a Marca apoiada no estabelecimento?"
HUP->HUP_SCORE	:=0
HUP->HUP_IDTREE	:="0000000"
HUP->HUP_TIPOOBJ	:="1"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000002"
HUP->HUP_DESC	:="A"
HUP->HUP_IDTREE	:="0000001"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000003"
HUP->HUP_DESC	:="B"
HUP->HUP_IDTREE	:="0000001"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000004"
HUP->HUP_DESC	:="C"
HUP->HUP_IDTREE	:="0000001"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000005"
HUP->HUP_DESC	:="D"
HUP->HUP_IDTREE	:="0000001"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000006"
HUP->HUP_DESC	:="E"
HUP->HUP_IDTREE	:="0000001"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000007"
HUP->HUP_DESC	:="Como você analisa o estabelecimento"
HUP->HUP_SCORE	:=0
HUP->HUP_IDTREE	:="0000000"
HUP->HUP_TIPOOBJ	:="1"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000008"
HUP->HUP_DESC	:="A"
HUP->HUP_IDTREE	:="0000007"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000009"
HUP->HUP_DESC	:="B"
HUP->HUP_IDTREE	:="0000007"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000010"
HUP->HUP_DESC	:="C"
HUP->HUP_IDTREE	:="0000007"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000011"
HUP->HUP_DESC	:="Qual o tipo de peça publicitária faz-se necessário neste Estabelecimento?"
HUP->HUP_IDTREE	:="0000000"
HUP->HUP_TIPOOBJ	:="2"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000012"
HUP->HUP_DESC	:="Panfletos"
HUP->HUP_IDTREE	:="0000011"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000013"
HUP->HUP_DESC	:="Cartazes"
HUP->HUP_IDTREE	:="0000011"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000014"
HUP->HUP_DESC	:="Displays"
HUP->HUP_IDTREE	:="0000011"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000015"
HUP->HUP_DESC	:="Parede"
HUP->HUP_IDTREE	:="0000011"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000016"
HUP->HUP_DESC	:="Grande"
HUP->HUP_IDTREE	:="0000011"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000017"
HUP->HUP_DESC	:="Peças estão bem visíveis"
HUP->HUP_IDTREE	:="0000000"
HUP->HUP_TIPOOBJ	:="1"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000018"
HUP->HUP_DESC	:="Local Nobre"
HUP->HUP_IDTREE	:="0000017"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000019"
HUP->HUP_DESC	:="Secundário"
HUP->HUP_IDTREE	:="0000017"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000020"
HUP->HUP_DESC	:="Motivos Retirar Diplay"
HUP->HUP_IDTREE	:="0000000"
HUP->HUP_TIPOOBJ	:="3"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000002"
HUP->HUP_CODPERG	:="0000021"
HUP->HUP_DESC	:="Observação"
HUP->HUP_IDTREE	:="0000000"
HUP->HUP_TIPOOBJ	:="3"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000001"
HUP->HUP_DESC	:="Forma de Pagto. do Concorrência?"
HUP->HUP_SCORE	:=0
HUP->HUP_IDTREE	:="0000000"
HUP->HUP_TIPOOBJ	:="1"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000002"
HUP->HUP_DESC	:="À Vista"
HUP->HUP_IDTREE	:="0000001"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000003"
HUP->HUP_DESC	:="7 dd"
HUP->HUP_IDTREE	:="0000001"
dbCommit()             

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000004"
HUP->HUP_DESC	:="10 dd"
HUP->HUP_IDTREE	:="0000001"
dbCommit()     
                        
dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000005"
HUP->HUP_DESC	:="15 dd"
HUP->HUP_IDTREE	:="0000001"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000006"
HUP->HUP_DESC	:="Freq. Visita Concorrência?"
HUP->HUP_SCORE	:=0
HUP->HUP_IDTREE	:="0000000"
HUP->HUP_TIPOOBJ	:="1"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000007"
HUP->HUP_DESC	:="Diária"
HUP->HUP_IDTREE	:="0000006"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000008"
HUP->HUP_DESC	:="Semanal"
HUP->HUP_IDTREE	:="0000006"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000009"
HUP->HUP_DESC	:="Quinzenal"
HUP->HUP_IDTREE	:="0000006"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000010"
HUP->HUP_DESC	:="Mensal"
HUP->HUP_IDTREE	:="0000006"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000011"
HUP->HUP_DESC	:="Preços da Concorrência"
HUP->HUP_IDTREE	:="0000000"
HUP->HUP_TIPOOBJ	:="3"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000012"
HUP->HUP_DESC	:="Estoque da Concorrência"
HUP->HUP_IDTREE	:="0000000"
HUP->HUP_TIPOOBJ	:="3"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000013"
HUP->HUP_DESC	:="Qual a Marca que Vende mais?"
HUP->HUP_IDTREE	:="0000000"
HUP->HUP_TIPOOBJ	:="1"
dbCommit()

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000014"
HUP->HUP_DESC	:="Free"
HUP->HUP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000015"
HUP->HUP_DESC	:="Malboro"
HUP->HUP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000016"
HUP->HUP_DESC	:="Carlton"
HUP->HUP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000017"
HUP->HUP_DESC	:="Hollywood"
HUP->HUP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000018"
HUP->HUP_DESC	:="Kent"
HUP->HUP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000019"
HUP->HUP_DESC	:="Camel"
HUP->HUP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000020"
HUP->HUP_DESC	:="Sampoerna"
HUP->HUP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000021"
HUP->HUP_DESC	:="Gudan Garan"
HUP->HUP_IDTREE	:="0000013"
dbCommit()     

dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000022"
HUP->HUP_DESC	:="Preços da Concorrência"
HUP->HUP_IDTREE	:="0000000"
HUP->HUP_TIPOOBJ	:="3"
dbCommit()


dbAppend()
HUP->HUP_FILIAL := RetFilial("HUP")
HUP->HUP_CODSCRI	:="000003"
HUP->HUP_CODPERG	:="0000023"
HUP->HUP_DESC	:="Observação"
HUP->HUP_IDTREE	:="0000000"
HUP->HUP_TIPOOBJ	:="3"
dbCommit()


Return Nil