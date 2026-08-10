//Ponto de Entrada: PEPV0001
//Retorna campo local de entrega (exemplo)

Function PEPV0001(oDlg,oComp,aCabPed)

Local cMensagem := space(100)
Local oObj

ADD FOLDER oComp CAPTION "Complemento" OF oDlg
@ 30,01 TO 130,158 CAPTION "Local Entrega" OF oComp
@ 40,05 GET oObj VAR cMensagem MULTILINE VSCROLL SIZE 150,90 of oComp

Return cMensagem
