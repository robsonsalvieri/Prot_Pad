#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
   
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Consultar Ocorrência" 	ACTION "GFEC054ACO()" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Consultar Documento" 	ACTION "GFEC054ACD()" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir Ocorrência" 		ACTION "GFEC054AOCO()" OPERATION 2 ACCESS 0
	
Return aRotina

Function GFEC054ACO()
	Local aAreaGWD := GWD->(GetArea())
	dbSelectArea("GWD")
	GWD->(dbSetOrder(1))
	If !Empty((cAliasGWU)->GWD_NROCO) .And. GWD->(dbSeek((cAliasGWU)->(GWD_FILIAL+GWD_NROCO)))
		FwExecView('Visualizar','GFEC032',,,{||.T.})	
	RestArea(aAreaGWD)
	Else
		MsgInfo("Ocorrência não localizada")
	EndIf
Return

Function GFEC054ACD()
	Local aAreaGW1 := GW1->(GetArea())
	dbSelectArea("GW1")
	GW1->(dbSetOrder(1))
	If GW1->(dbSeek((cAliasGWU)->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC)))
		FwExecView('Visualizar','GFEC040',,,{||.T.})	
		RestArea(aAreaGW1)
	Else
		MsgInfo("Documento não localizado")
	EndIf
Return

Function GFEC054AOCO()
	Local aAreaGWU := GWU->(GetArea())
	Private cAliGWU
	Private _CodDocTransp // Privada em GFEA032
	_CodDocTransp := (cAliasGWE)->(GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT)
	dbSelectArea("GWU")
	GWU->( dbSetOrder(1) )
	If GWU->( dbSeek((cAliasGWU)->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ)) )
		FWExecView("Incluir", "GFEA032", MODEL_OPERATION_INSERT,, {|| .T.})
		RestArea(aAreaGWU)
		RptStatus({||C054Atualizar()}, "Carregando", "Aguarde, atualizando dados...")
	Else
		MsgInfo("Trecho não localizado")
	EndIf
	Pergunte("GFEC054",.F.)
Return