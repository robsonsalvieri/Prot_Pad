#Include "DLGA015.CH"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
//---------------------------------------
/*	Manutencao do Unitizador Analitico
@author 	Leandro Paulino
@version	P10 R1.4
@build		7.00.101202A
@since		31/03/2011
@return		oView Objeto do View*/
//---------------------------------------
Function DLGA015()

Local oBrowse := Nil

Private aRotina := MenuDef()
Private lMsErroAuto := .F.

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DCO")
oBrowse:SetDescription(STR0001) //"Manutenção Unitizadores
oBrowse:Activate()

Return Nil
                      	
//-------------------------------------
/*	Modelo de Dados
@author		Leandro Paulino
@version	P10 R1.4
@build		7.00.101202A
@since		16/02/2013
@return		oModel Objeto do Modelo*/
//-------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStruDCO	:= FWFormStruct(1,"DCO")                                         
Local bPosValid	:= { |oMdl| DLA015MntU(oMdl) }

oModel:= MpFormMOdel():New("DLGA015",/*PREVAL*/, bPosValid, /*Commit*/,/*BCANCEL*/)

oModel:AddFields("MdFieldDCO",Nil,oStruDCO,/*prevalid*/,,/*bCarga*/)

oModel:SetDescription(STR0002) // "Unitizadores Analiticos

oModel:GetModel("MdFieldDCO"):SetDescription( "MdFieldDCO" )
                                                                      
oModel:SetPrimaryKey( { "DCO_UNITIZ", "DCO_CODANA" } )

Return (oModel)
//---------------------------------------
/*	Exibe browser de acordo com estrutura
@author 	Leandro Paulino
@version	P10 R1.4
@build		7.00.101202A
@since		16/02/2013
@return		oView Objeto do View*/
//---------------------------------------
Static Function ViewDef()

Local oModel	:= FwLoadModel("DLGA015")
Local oStruDCO	:= FWFormStruct(2,"DCO",{|cCampo| AllTrim(cCampo)+"|" $ "DCO_UNITIZ|DCO_CODANA|DCO_DESANA|DCO_STATUS|DCO_FILBAS|DCO_FILATU|DCO_FILORI|DCO_VIAGEM|DCO_DTINI|DCO_HRINI|DCO_DTFIM|DCO_HRFIM|DCO_CODCLI|DCO_LOJCLI|DCO_NOMCLI|DCO_CODFOR|DCO_LOJFOR|DCO_NOMFOR|"}) //controle unitizador
Local oView     := Nil

oView := FwFormView():New()

oView:SetModel(oModel)

oView:AddField("VwFieldDCO", oStruDCO, "MdFieldDCO")                

oView:CreateHorizontalBox("Field",100)

oView:SetOwnerView("VwFieldDCO","Field")

Return(oView)

//---------------------------------------
/*	Verifica se o campo será alterável
@author 	Leandro Paulino
@version	P10 R1.80
@build		7.00.101202A
@since		16/02/2013
@return		Lógico*/
//---------------------------------------
Function DLGA015When( cCampo )
Local lRet     := .F.

If "DCO_FILATU" $ Upper( cCampo )
	If IsInCallStack('DLGA015')
		lRet := .T.
	EndIf
EndIf

Return(lRet)

                                         
//-----------------------------------------------------------
/*	Atualização do Unitizador Analitco através da Manunteção
@author 	Leandro Paulino
@version	P10 R1.80
@build		7.00.101202A
@since		16/02/2013
@return		Lógico*/
//-----------------------------------------------------------
Static Function DLA015MntU(oMdl)

Local lRet      := .T.
Local aAreaAnt  := GetArea()                               
Local aCab 		:= {}                         
Local aItens    := {}
LOcal cCodOco	:= ""
Local cSertms	:= ""

//Projeto Controle de Unitizadores. Validação para não permitir informar apenas o cod do cliente ou parceiro na manutenção
If (!Empty(M->DCO_CODCLI) .AND. Empty(M->DCO_LOJCLI)) .OR. (!Empty(M->DCO_CODFOR) .AND. Empty(M->DCO_LOJFOR))
	oMdl:GetModel():SetErrorMessage(,,,,,STR0006) //'Por favor, identifique o Cliente/Parceiro para este Unitizador.'  
	lRet := .F.
Endif

//-- Se o unitizador estiver em viagem para outra filial 
If !Empty(DCO->DCO_VIAGEM) .And. !Empty(DCO->DCO_FILORI) .And. DCO->DCO_FILATU <> M->DCO_FILATU
	If MsgYesNo(STR0003 + DCO->DCO_FILORI + DCO->DCO_VIAGEM + CHR(10) + CHR(13) + STR0004,STR0005)   //--"O Unitizador está carregado na Viagem"//--'Deseja efetuar a chegada eventual para a filial atual?'
		//posiciona na viagem saber qual o DTQ_SERTMS
		DbSelectArea("DTQ")
		DTQ->(DbSetOrder(2)) //Fil.Origem + Viagem + Rota
		If MsSeek(xFilial("DTQ")+DCO->DCO_FILORI+DCO->DCO_VIAGEM)
			cSerTms := DTQ->DTQ_SERTMS			
		Endif		                                 
		//posiciona na tabela de ocorrência para saber qual o codigo da ocorrência ate mesmo quando DT2_SERTMS em branco - Serv. Adic.
		DbSelectArea("DT2")
		DT2->(DbSetOrder(3)) //Serv.Transp + Tipo + Codigo
		If MsSeek(xFilial("DT2")+cSertms+StrZero(13,Len(DT2->DT2_TIPOCO)))
			cCodOco:= DT2->DT2_CODOCO
		Else
			cSertms := SPACE(TamSX3("DT2_SERTMS")[1])
			If MsSeek(xFilial("DT2")+cSertms+StrZero(13,Len(DT2->DT2_TIPOCO))) 	//procura ocorrência do tipo 13 com DT2_SERTMS em branco
				cCodOco:= DT2->DT2_CODOCO
			Endif
		Endif	
		
		//-- Cabecalho da Ocorrencia
		AAdd(aCab,{"DUA_FILORI",DCO->DCO_FILORI,Nil})
		AAdd(aCab,{"DUA_VIAGEM",DCO->DCO_VIAGEM,Nil})
		If !Empty(cCodOco)
			DUD->(dbSetOrder(2))
			If DUD->(dbSeek(cSeekDCO:= xFilial('DUD')+ DCO->(DCO_FILORI+DCO_VIAGEM)))
			While DUD->(!Eof()) .And. cSeekDCO == DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM)
					//-- Itens da Ocorrencia
					AAdd(aItens, {	{"DUA_SEQOCO", StrZero(1,Len(DUA->DUA_SEQOCO)) , Nil},;
									{"DUA_DATOCO", dDataBase                          , Nil},;
									{"DUA_HOROCO", StrTran(Left(Time(),5),":","")     , Nil},;
									{"DUA_CODOCO", cCodOco			                    , Nil},;
									{"DUA_SERTMS", cSerTms								 , Nil},;
									{"DUA_FILDOC", DUD->DUD_FILDOC                    , Nil},;
									{"DUA_DOC"   , DUD->DUD_DOC                       , Nil},;
									{"DUA_SERIE" , DUD->&(SerieNfId("DUD",3,"DUD_SERIE")) , Nil}})
			   DUD->(dbSkip())  
	         EndDo
  				MsExecAuto({|x,y,z|Tmsa360(x,y,z)},aCab,aItens,{},3)
  				If lMsErroAuto
					MostraErro()
				EndIf				
			EndIf	
		EndIf
	Else
		oMdl:GetModel():SetErrorMessage(,,,,,STR0007,STR0008) //"Manutenção não realizada."###"Para que esta manutenção ocorra, é necessário o apontamento da chegada Eventual"
		lRet := .F.	
	EndIf
EndIf	
            
RestArea(aAreaAnt)

Return lRet

//---------------------------------------                                                      s
/*	MenuDef do Browser
@author		Leandro Paulino
@version	P10 R11.80
@build		7.00.101202A
@since		16/02/2013
@return		aRotina array com o MENUDEF*/
//---------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar" ACTION "PesqBrw"         OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.DLGA015" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE "Manutencao" ACTION "VIEWDEF.DLGA015" OPERATION 4 ACCESS 0 // "Alterar"
Return ( aRotina )
