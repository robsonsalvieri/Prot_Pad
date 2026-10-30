#INCLUDE "OMSA200A.CH" 
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'parmtype.ch'
#INCLUDE 'totvs.ch'

#DEFINE DS_MODALFRAME   128

#DEFINE CARGA_ENABLE    1
#DEFINE CARGA_VEIC      10
#DEFINE CARGA_TPOP      25
#DEFINE CARGA_CLFR      26

//-----------------------------------------------------------
/*/{Protheus.doc} OMSA200A
Simulação de Calculo de Frete de Carga x Calculo GFE

Função para calcular frete de carga quando tem integração com GFE
@author equipe OMS
@Since	10/10/2023
/*/
//-----------------------------------------------------------/
Function OMSA200A(aArrayCarga, aArrayMan, cDakTransp)
	Local oSay 		  := NIL // CAIXA DE DIÁLOGO GERADA

	//O processo de calculo apenas será disparado se as configurações com o GFE estiverem ativas.
	If !fGFEAtivo()
		Help(" ",1,"OMS200A01") //-- "Configurações do GFE x OMS não estão ativas."
		Return .T.
	EndIf

	//Realiza chamada da tela de criação de estrutura
	FwMsgRun(,{ |oSay| CriaTemp( @aArrayCarga, @aArrayMan, @cDakTransp, oSay) },STR0001,STR0002) //-- Montando Tela de Simulação de Calculo de Frete ## Aguarde

Return .T.

//-----------------------------------------------------------
/*/{Protheus.doc} CriaTemp
Função para criar estruturas

@author equipe OMS
@Since	10/10/2023
/*/
//-----------------------------------------------------------/
Static Function CriaTemp(aArrayCarga, aArrayMan, cDakTransp, oTexJan)
	Local aMemoria  := {}
	Local aColumPed := {}
	Local cAliasPed := GetNextAlias()
	Local aColumTra := {}
	Local cAliasTra := GetNextAlias()
	Local aColumRes := {}
	Local cAliasRes := GetNextAlias()

	Local oTablePed, oTableTra, oTableRes

	Local lFalhaSC5 := .F. //Variavel para validar se tem algum pedido com problema de emissor.
	Local nQtdPedi  := 0

	Default oTexJan   := Nil

	oTexJan:SetText(STR0003) //-- "Criando estrutura de tabelas auxiliares"

	CriTabPed(@aColumPed,cAliasPed,@oTablePed)	//Criar tabela de Pedidos
	CriTabTra(@aColumTra,cAliasTra,@oTableTra)	//Criar tabela de Transportadora
	CriTabRes(@aColumRes,cAliasRes,@oTableRes)	//Criar tabela de Resumo

	oTexJan:SetText(STR0004) //-- "Carregando listagem de pedidos da carga"

	//Função para carregar tabela de pedido
	fCargPed( @aArrayCarga, @aArrayMan, "" /*cDakTransp*/, cAliasPed, @lFalhaSC5, @nQtdPedi)	

	//Validação de Carga sem ter pedidos vinculados
	If nQtdPedi <= 0 .Or. lFalhaSC5
		Help(" ", 1, "OMS200A02") //-- "Esta carga está sem pedidos vinculados e não pode ser calculado o valor do frete."
		Return .T.		
	EndIf 

	oTexJan:SetText(STR0005) //-- "Executando calculo de frete da carga"

	//Chama a rotina de calculo de frete
	fPrepFret(.F., oTexJan, @aMemoria, @oTablePed, @oTableTra, @oTableRes)

	//Chamar tela se tiver interface
	oTexJan:SetText(STR0006) //-- "Montagem de Tela de Calculo de Frete"
	MontTela(@aArrayCarga, @aArrayMan, @cDakTransp, @aMemoria, @aColumPed, cAliasPed, @aColumTra, cAliasTra, @aColumRes, cAliasRes)

Return .T.

//-----------------------------------------------------------
/*/{Protheus.doc} MontTela
Função para criar a tela da Simulação 

@author equipe OMS
@Since	10/10/2023
/*/
//-----------------------------------------------------------/
Static Function MontTela(aArrayCarga, aArrayMan, cDakTransp, aMemoria, aColumPed, cAliasPed, aColumTra, cAliasTra, aColumRes, cAliasRes)
	//Variaveis relacionadas a carga posicionada
	Local nEdtPeso  := 0 //Peso da Carga
	Local nEdtVlrMe := 0 //Valor da Mercadoria
	Local cEdtVolCa := 0 //Volume da Carga
	Local aTmpRotin := {}
	// Declaração de Variaveis dos Objetos
	Local oJanSimul,oGpCarga,oEdtPeso ,oEdtVlrMe , oEdtVoCar
	Local oBtnSair ,oBtnMem
	Local oGpResu  ,oGrpPed ,oGpFrete ,oDivisor  , oPnlDvSu ,oPnlCentro
	Local oPnlDvIn ,oFolder ,oBrowsPed, oBrowsTra, oBrowsRes

	// Habilita a skin padrão dos componentes visuais
	SetSkinDefault()

	aEval(aArrayMan, {|x| nEdtPeso  += x[14]})    //-- Peso da Carga
	aEval(aArrayMan, {|x| nEdtVlrMe += x[25]})    //-- Valor da Mercadoria
	aEval(aArrayMan, {|x| cEdtVolCa += x[15]})    //-- Volume da Carga

	//Definicao do Dialog e todos os seus componentes.
	DEFINE MsDialog oJanSimul From 150,2291 To 690,3386 Title STR0007 Pixel Style DS_MODALFRAME //-- "Simulação de Frete de Carga (OMS x GFE)"

	//Componentes do Grupo de Configuração de Carga
	oGpCarga   := TGroup():New( 0,0,52,384,STR0008,oJanSimul,CLR_HRED,CLR_WHITE,.T.,.F. ) //-- " Informações da Carga "
	oGpCarga:align:= CONTROL_ALIGN_TOP

	oEdtVlrMe  := TGet():New( 010,004,{|u| If(PCount()>0,nEdtVlrMe:=u,nEdtVlrMe)}   ,oGpCarga,050,008,PESQPICT("DAK","DAK_VALOR")	,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nEdtVlrMe"   ,   ,   ,   ,   ,   ,   ,"Vlr. Mercadoria"      ,1  ,   ,   ,   ,   ,.T.    )
	oEdtVlrMe:Disable()
	oEdtPeso   := TGet():New( 010,084,{|u| If(PCount()>0,nEdtPeso:=u,nEdtPeso)}     ,oGpCarga,050,008,PESQPICT("DAK","DAK_PESO")	,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nEdtPeso"    ,   ,   ,   ,   ,   ,   ,"Peso Carga"           ,1  ,   ,   ,   ,   ,.T.    )
	oEdtPeso:Disable()
	oEdtVoCar  := TGet():New( 010,164,{|u| If(PCount()>0,cEdtVolCa:=u,cEdtVolCa)}	,oGpCarga,050,008,PESQPICT("DAK","DAK_CAPVOL")	,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cEdtVolCa"    ,   ,   ,   ,   ,   ,   ,"Volume Carga"		,1  ,   ,   ,   ,   ,.T.    )
	oEdtVoCar:Disable()

	//Componentes de botão
	oBtnSair   := TButton():New( 005,468,STR0015    ,oGpCarga,{||oJanSimul:End()}	,052,014,,,,.T.,,"",,,,.F. ) //-- "&Fechar"
	oBtnMem    := TButton():New( 020,468,STR0016    ,oGpCarga,{||fTelMem(aMemoria)} ,052,014,,,,.T.,,"",,,,.F. ) //-- "&Memória"

	//Componentes da Parte de Baixo
	oPnlCentro       := TPanel():New( 55,5,"",oJanSimul,,.F.,.F.,,,384,236,.T.,.F. )
	oPnlCentro:align := CONTROL_ALIGN_ALLCLIENT
	oFolder          := TFolder():New( 005,005,{STR0009,STR0014},{},oPnlCentro,,,,.T.,.F.,392,236-4,) //-- "Resumo de Calculo" ## "Detalhe do Calculo"
	oFolder:align    := CONTROL_ALIGN_ALLCLIENT
	oFolder:bChange  := { |nFolder| oBrowsPed:Refresh(),oBrowsTra:Refresh() }

	aTmpRotin := aRotina
	aRotina   := {}

	oGpResu    := TGroup():New( 72,5,205,384,STR0009,oFolder:aDialogs[1],CLR_HBLUE,CLR_WHITE,.T.,.F. ) //-- " Resumo de Calculo "
	oGpResu:align:= CONTROL_ALIGN_BOTTOM
	oBrowsRes := FwBrowse():New()
	oBrowsRes:DisableFilter()
	oBrowsRes:DisableConfig()
	oBrowsRes:DisableReport()
	oBrowsRes:DisableSeek()
	oBrowsRes:DisableSaveConfig()
	oBrowsRes:SetAlias(cAliasRes)
	oBrowsRes:SetDataTable()
	oBrowsRes:SetInsert(.F.)
	oBrowsRes:SetDelete(.F., { || .F. })
	oBrowsRes:lHeaderClick := .F.
	oBrowsRes:SetColumns(aColumRes)
	oBrowsRes:SetOwner(oGpResu)
	oBrowsRes:Activate()

	aRotina :=aTmpRotin

	//Componentes da Aba Detalhe do Calculo

	//Divisão da Aba de Detalhe de Calculo
	oDivisor := tSplitter():New( 05,05,oFolder:aDialogs[2],260,184 )
	oDivisor:align:= CONTROL_ALIGN_ALLCLIENT
	oDivisor:SetOrient(1)
	oDivisor:setOpaqueResize(.T.)

	oPnlDvSu  := TPanel():New( 005,005,"",oDivisor,,.F.,.F.,,,460,300,.T.,.F. )
	oPnlDvSu:align:= CONTROL_ALIGN_ALLCLIENT

	oPnlDvIn  := TPanel():New(005,005,"",oDivisor,,.F.,.F.,,,460,050,.T.,.F. )
	oPnlDvIn:align:= CONTROL_ALIGN_ALLCLIENT

	//Grid de Pedidos
	oGrpPed    := TGroup():New( 005,005,096,388,STR0017,oPnlDvSu,CLR_HBLUE,CLR_WHITE,.T.,.F. ) //-- " Listagem de Pedidos "
	oGrpPed:align:= CONTROL_ALIGN_ALLCLIENT
	// Painel de pedidos
	oBrowsPed := FwBrowse():New()
	oBrowsPed:DisableConfig()
	oBrowsPed:DisableReport()
	oBrowsPed:DisableSeek()
	oBrowsPed:DisableSaveConfig()
	oBrowsPed:SetAlias(cAliasPed)
	oBrowsPed:SetDataTable()
	oBrowsPed:SetInsert(.F.)
	oBrowsPed:SetDelete(.F., { || .F. })
	oBrowsPed:lHeaderClick := .F.
	oBrowsPed:SetColumns(aColumPed)
	oBrowsPed:SetOwner(oGrpPed)
	oBrowsPed:SetChange({|| fRefrTran(oBrowsTra,cAliasPed,cAliasTra)})
	oBrowsPed:Activate()

	//Grid de Transportadora
	oGpFrete   := TGroup():New( 100,005,200,388,STR0018,oPnlDvIn,CLR_HBLUE,CLR_WHITE,.T.,.F. ) //-- " Transportadoras disponiveis por Pedido "
	oGpFrete:align:= CONTROL_ALIGN_ALLCLIENT
	oBrowsTra := FwBrowse():New()
	oBrowsTra:DisableFilter()
	oBrowsTra:DisableConfig()
	oBrowsTra:DisableReport()
	oBrowsTra:DisableSeek()
	oBrowsTra:DisableSaveConfig()
	oBrowsTra:SetAlias(cAliasTra)
	oBrowsTra:SetDataTable()
	oBrowsTra:SetInsert(.F.)
	oBrowsTra:SetDelete(.F., { || .F. })
	oBrowsTra:lHeaderClick := .F.
	oBrowsTra:SetColumns(aColumTra)
	oBrowsTra:SetOwner(oGpFrete)
	oBrowsTra:SetFilterDefault("('"+cAliasPed+"')->nLinPFili = ('"+cAliasTra+"')->nLinTFili .And. ('"+cAliasPed+"')->nLinPNume = ('"+cAliasTra+"')->nLinTNume")
	oBrowsTra:Activate()
	
	oJanSimul:lCentered	:= .T.
	oJanSimul:Activate(,,,.T.)

Return .T.

//-----------------------------------------------------------
/*/{Protheus.doc} fCargPed
Função para carregar a listagem de pedidos que está na carga

@author equipe OMS
@Since	10/10/2023
/*/
//-----------------------------------------------------------/
Static Function fCargPed( aArrayCarga, aArrayMan, cDakTransp,cAliasPed,lFalhaSC5,nQtdPedi)
	Local aAreaSC5   := SC5->(GetArea())
	Local aAreaSA1   := SA1->(GetArea())
	Local aAreaSA2   := SA2->(GetArea())
	Local cCdEmis    := OMSM011COD(,,,.T.,xFilial("SF2"))
	Local cCdRem     := ""
	Local cCdDest    := ""
	Local cCnpj      := ""
	Local cUFCli     := ""
	Local cCidCli    := ""
	Local aItem      := {}
	Local nPosCarga  := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T. })
	Local cTranspor  := cDakTransp
	Local cPlacaVei  := IIf(!Empty(aArrayCarga[nPosCarga][CARGA_VEIC ]) ,aArrayCarga[nPosCarga][CARGA_VEIC ] ,Criavar("DA3_COD",.F.))
	Local cClassDAK  := IIf(!Empty(aArrayCarga[nPosCarga][CARGA_CLFR ]) ,aArrayCarga[nPosCarga][CARGA_CLFR ] ,Space(Len(DAK->DAK_CDCLFR)))
	Local cOperaDAK  := IIf(!Empty(aArrayCarga[nPosCarga][CARGA_TPOP ]) ,aArrayCarga[nPosCarga][CARGA_TPOP ] ,Space(Len(DAK->DAK_CDTPOP)))
	Local cTpDoc	 := ""
	Local cMVOMS2NEG := SuperGetMV("MV_OM2NEG",.F., "2")
	Local nCount
	
	cClassDAK   := Iif( Empty(cClassDAK), avKey( SuperGetMv("MV_CDCLFR",.F.,"") ,"DAK_CDCLFR"	), cClassDAK)	//Codigo da ClassIficação de Frete
	cOperaDAK   := Iif( Empty(cOperaDAK), avKey( SuperGetMv("MV_CDTPOP",.F.,"") ,"DAK_CDTPOP"	), cOperaDAK)	//Codigo do Tipo de Operação

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))

	DbSelectArea("SA2")
	SA2->(dbSetOrder(1))

	DbSelectArea("SA1")
	SA1->(dbSetOrder(1))

	For nCount := 1 to Len(aArrayMan)

		If  SC5->(DbSeek(xFilial("SC5",aArrayMan[nCount][12])+aArrayMan[nCount][5]))

			nQtdPedi += 1

			If !SC5->C5_TIPO $ "DB"
				SA1->( dbSeek( xFilial("SA1")+SC5->C5_CLIENT+SC5->C5_LOJAENT ) )
				cCnpj	:=  SA1->A1_CGC
				cUFCli	:=  SA1->A1_EST
				cCidCli	:=  SA1->A1_MUN
			Else
				SA2->( dbSeek( xFilial("SA2")+SC5->C5_CLIENT+SC5->C5_LOJAENT ) )
				cCnpj	:=  SA2->A2_CGC
				cUFCli	:=  SA2->A2_EST
				cCidCli	:=  SA2->A2_MUN				
			EndIf		

			cCdDest := IIf(MTA410ChkEmit(cCnpj),cCnpj, OMSM011COD(SC5->C5_CLIENT,SC5->C5_LOJAENT,1,,) )

			If SC5->(ColumnPos("C5_CLIRET")) > 0 .And. SC5->(ColumnPos("C5_LOJARET")) > 0 .And. !Empty(SC5->C5_CLIRET) .And. !Empty(SC5->C5_LOJARET)

				If !SC5->C5_TIPO $ "DB"
					SA1->( dbSeek( xFilial("SA1")+SC5->C5_CLIRET+SC5->C5_LOJARET ) )
				Else
					SA2->( dbSeek( xFilial("SA2")+SC5->C5_CLIRET+SC5->C5_LOJARET ) )
				EndIf

				//VerIfica primeiro se existe a chave "NS" cadastrada, se não busca a chave "N". Mesmo tratamento utilizado no OMSM011.
				cTpDoc := Alltrim(Tabela("MQ",SC5->C5_TIPO+"S",.F.))
				cTpDoc := Iif(Empty(cTpDoc), Tabela("MQ",SC5->C5_TIPO,.F.), cTpDoc)

				cCdRem 	:= OMSM011COD(SC5->C5_CLIRET,SC5->C5_LOJARET,1)
				//Valida o remetente que será utilizado no Doc. de Carga, conforme o sentido configurado na rotina de Tipos de Documentos de Carga.
				If ( Posicione("GV5", 1, xFilial("GV5") + cTpDoc, "GV5_SENTID") == "2" .And. Posicione("GU3", 1, xFilial("GU3") + cCdRem, "GU3_EMFIL") == "2" )
					Help(,,'HELP',,STR0010+Alltrim(cTpDoc)+STR0011 +CRLF +; //--"O sentido (GV5_SENTID) do tipo de Documento: " ## ", está configurado como saída."
								   STR0012+; //-- "Deverá ser informado no campo 'Cli. Retirada' (C5_CLIRET) um remetente do tipo filial (GU3_EMFIL)."
								   STR0013+Alltrim(SC5->C5_NUM) ,1,0,)//-- "Verifique o Pedido de Venda Nr.: "
					lFalhaSC5 := .T.
					Exit
				EndIf

			Else
				cCdRem := cCdEmis
			EndIf

			aItem := {}

			Reclock(cAliasPed,.T.)
			(cAliasPed)->nLinPFili	:= SC5->C5_FILIAL
			(cAliasPed)->nLinPNume	:= SC5->C5_NUM
			(cAliasPed)->nLinPTipo 	:= SC5->C5_TIPO
			(cAliasPed)->nLinPClie 	:= SC5->C5_CLIENTE
			(cAliasPed)->nLinPLoja	:= SC5->C5_LOJACLI
			(cAliasPed)->nLinPValo	:= aArrayMan[nCount][25]
			(cAliasPed)->nLinPPeso 	:= aArrayMan[nCount][14] 
			(cAliasPed)->nLinPVolu	:= aArrayMan[nCount][15] 
			(cAliasPed)->nLinPCOri 	:= Posicione("GU3",1,xFilial("GU3") + cCdRem	,"GU3_NRCID")
			(cAliasPed)->nLinPMOri	:= FWSM0Util():GetSM0Data(cEmpAnt , cFilAnt, { "M0_CIDCOB" } )[1][2]
			(cAliasPed)->nLinPEOri	:= FWSM0Util():GetSM0Data(cEmpAnt , cFilAnt, { "M0_ESTCOB" } )[1][2]
			(cAliasPed)->nLinPCDes	:= Posicione("GU3",1,xFilial("GU3") + cCdDest	,"GU3_NRCID")
			(cAliasPed)->nLinPMDes	:= cCidCli
			(cAliasPed)->nLinPEDes	:= cUFCli
			(cAliasPed)->nLinPEmit	:= cCdRem
			(cAliasPed)->nLinPDest	:= cCdDest
			(cAliasPed)->nLinPTran	:= cTranspor
			(cAliasPed)->nLinPPlac	:= cPlacaVei
			(cAliasPed)->nLinPClas	:= cClassDAK
			(cAliasPed)->nLinPOper	:= cOperaDAK
			(cAliasPed)->nLinPNego	:= cMVOMS2NEG
			(cAliasPed)->nLinPTpVe	:= IIf(Empty(cPlacaVei), "", POSICIONE("DA3",1,xFilial("DA3")+cPlacaVei,"DA3_TIPVEI"))
			(cAliasPed)->nLinPKM	:= 0
			(cAliasPed)->nLinPTFre	:= SC5->C5_TPFRETE
			(cAliasPed)->(MsUnlock())
		EndIf
	Next nCount

	RestArea( aAreaSA1 )
	RestArea( aAreaSA2 )
	RestArea( aAreaSC5 )

Return .T.

//-----------------------------------------------------------
/*/{Protheus.doc} CriTabRes
Função para criar a Tabela Resumo

@author equipe OMS
@Since	10/10/2023
/*/
//-----------------------------------------------------------/
Static Function CriTabRes(aColumRes,cAliasRes,oTableRes)
	Local oColumn
	Local nAtual 	:= 0
	Local aFieldRes := {}
	aColumRes    := {}

	aAdd( aFieldRes	,{"nLinRCodi"	,TAMSX3("A4_COD")[3]	    ,TamSX3("A4_COD")[1]     	,TAMSX3("A4_COD")[2]	    ,FWX3Titulo("A4_COD")		,PESQPICT("SA4","A4_COD")	    ,.F.,""} )
	aAdd( aFieldRes	,{"nLinRNome"	,TAMSX3("A4_NOME")[3]		,TAMSX3("A4_NOME")[1]	    ,TAMSX3("A4_NOME")[2]		,FWX3Titulo("A4_NOME")		,PESQPICT("SA4","A4_NOME")		,.F.,""} )
	aAdd( aFieldRes	,{"nLinRValo"	,TAMSX3("GW8_VALOR")[3]  	,TamSX3("GW8_VALOR")[1]		,TAMSX3("GW8_VALOR")[2]    	,FWX3Titulo("GW8_VALOR")	,PESQPICT("GW8","GW8_VALOR")   	,.F.,""} )
	aAdd( aFieldRes	,{"nLinRQtde"	,"N"						,4   						,0							,"Qtde Ped."				,"9999"   						,.F.,""} )
	aAdd( aFieldRes	,{"nLinREmit"	,TAMSX3("GU3_CDEMIT")[3]  	,TamSX3("GU3_CDEMIT")[1]	,TAMSX3("GU3_CDEMIT")[2]    ,"Emitente GFE"				,PESQPICT("GU3","GU3_CDEMIT")   ,.F.,""} )

	oTableRes := FWTemporaryTable():New( cAliasRes )
	oTableRes:SetFields( aFieldRes )
	oTableRes:AddIndex("TRB_RES", {"nLinRCodi"} )
	oTableRes:Create()

	//Percorrendo e criando as colunas
	For nAtual := 1 To Len(aFieldRes)
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&("{|| " + cAliasRes + "->" + aFieldRes[nAtual][1] +"}"))
		oColumn:SetTitle(aFieldRes[nAtual][5])
		oColumn:SetType(aFieldRes[nAtual][2])
		oColumn:SetSize(aFieldRes[nAtual][3])
		oColumn:SetDecimal(aFieldRes[nAtual][4])
		oColumn:SetPicture(aFieldRes[nAtual][6])
		oColumn:SetAlign( If(aFieldRes[nAtual][2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )
		oColumn:SetEdit( .F. )
		aAdd(aColumRes, oColumn)
	Next nAtual

Return

//-----------------------------------------------------------
/*/{Protheus.doc} CriTabPed
Função para criar a Tabela Pedido

@author equipe OMS
@Since	10/10/2023
/*/
//-----------------------------------------------------------/
Static Function CriTabPed(aColumPed,cAliasPed,oTablePed)
	Local oColumn
	Local nAtual
	Local aFieldPed := {}
	aColumPed := {}

	aAdd( aFieldPed	,{"nLinPFili"	,TAMSX3("C5_FILIAL")[3]		,TamSX3("C5_FILIAL")[1]		,TAMSX3("C5_FILIAL")[2]		,FWX3Titulo("C5_FILIAL")	,PESQPICT("SC5","C5_FILIAL")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPNume"	,TAMSX3("C5_NUM")[3]	    ,TamSX3("C5_NUM")[1]     	,TAMSX3("C5_NUM")[2]	    ,FWX3Titulo("C5_NUM")		,PESQPICT("SC5","C5_NUM")	    ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPTipo"	,TAMSX3("C5_TIPO")[3]		,TAMSX3("C5_TIPO")[1]	    ,TAMSX3("C5_TIPO")[2]		,FWX3Titulo("C5_TIPO")		,PESQPICT("SC5","C5_TIPO")		,.F.,""} )
	aAdd( aFieldPed	,{"nLinPClie"	,TAMSX3("C5_CLIENTE")[3]  	,TamSX3("C5_CLIENTE")[1]	,TAMSX3("C5_CLIENTE")[2]    ,FWX3Titulo("C5_CLIENTE")	,PESQPICT("SC5","C5_CLIENTE")   ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPLoja"	,TAMSX3("C5_LOJACLI")[3]	,TamSX3("C5_LOJACLI")[1]    ,TAMSX3("C5_LOJACLI")[2]    ,FWX3Titulo("C5_LOJACLI")	,PESQPICT("SC5","C5_LOJACLI")   ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPValo"	,TAMSX3("DAK_VALOR")[3]   	,TamSX3("DAK_VALOR")[1]		,TAMSX3("DAK_VALOR")[2]     ,STR0017					,PESQPICT("DAK","DAK_VALOR")    ,.F.,""} ) //-- "Valor Pedido"
	aAdd( aFieldPed	,{"nLinPPeso"	,TAMSX3("DAK_PESO")[3]		,TamSX3("DAK_PESO")[1]		,TAMSX3("DAK_PESO")[2]		,FWX3Titulo("DAK_PESO")		,PESQPICT("DAK","DAK_PESO")		,.F.,""} )
	aAdd( aFieldPed	,{"nLinPVolu"	,TAMSX3("DAI_CAPVOL")[3]	,TamSX3("DAI_CAPVOL")[1]	,TAMSX3("DAI_CAPVOL")[2]	,FWX3Titulo("DAI_CAPVOL")	,PESQPICT("DAI","DAI_CAPVOL")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPCOri"   ,TAMSX3("GU3_NRCID")[3]   	,TamSX3("GU3_NRCID")[1]		,TAMSX3("GU3_NRCID")[2]     ,STR0018					,PESQPICT("GU3","GU3_NRCID")    ,.F.,""} ) //-- "IBGE Orig."
	aAdd( aFieldPed	,{"nLinPMOri"	,TAMSX3("A1_MUN")[3]      	,TamSX3("A1_MUN")[1]     	,TAMSX3("A1_MUN")[2]        ,STR0019					,PESQPICT("SA1","A1_MUN")       ,.F.,""} ) //-- "Cidade Orig."
	aAdd( aFieldPed	,{"nLinPEOri"	,TAMSX3("A1_EST")[3]      	,TamSX3("A1_EST")[1]        ,TAMSX3("A1_EST")[2]        ,STR0020					,PESQPICT("SA1","A1_EST")       ,.F.,""} ) //-- "UF. Origem"
	aAdd( aFieldPed	,{"nLinPCDes"   ,TAMSX3("GU3_NRCID")[3]   	,TamSX3("GU3_NRCID")[1]		,TAMSX3("GU3_NRCID")[2]     ,STR0021					,PESQPICT("GU3","GU3_NRCID")    ,.F.,""} ) //-- "IBGE Dest."
	aAdd( aFieldPed	,{"nLinPMDes"	,TAMSX3("A1_MUN")[3]      	,TamSX3("A1_MUN")[1]		,TAMSX3("A1_MUN")[2]        ,STR0022					,PESQPICT("SA1","A1_MUN")       ,.F.,""} ) //-- "Cidade Dest."
	aAdd( aFieldPed	,{"nLinPEDes"	,TAMSX3("A1_EST")[3]      	,TamSX3("A1_EST")[1]        ,TAMSX3("A1_EST")[2]        ,STR0023					,PESQPICT("SA1","A1_EST")       ,.F.,""} ) //-- "UF. Desti."
	aAdd( aFieldPed	,{"nLinPEmit"	,TAMSX3("GU3_CDEMIT")[3]  	,TamSX3("GU3_CDEMIT")[1]	,TAMSX3("GU3_CDEMIT")[2]    ,STR0024					,PESQPICT("GU3","GU3_CDEMIT")   ,.F.,""} ) //-- "Remetente GFE"
	aAdd( aFieldPed	,{"nLinPDest"	,TAMSX3("GU3_CDEMIT")[3]  	,TamSX3("GU3_CDEMIT")[1]    ,TAMSX3("GU3_CDEMIT")[2]    ,STR0025					,PESQPICT("GU3","GU3_CDEMIT")   ,.F.,""} ) //-- "Destinatario GFE"	
	aAdd( aFieldPed	,{"nLinPTran"	,TAMSX3("DAK_TRANSP")[3]	,TamSX3("DAK_TRANSP")[1]	,TAMSX3("DAK_TRANSP")[2]	,FWX3Titulo("DAK_TRANSP")	,PESQPICT("DAK","DAK_TRANSP")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPPlac"	,TAMSX3("DAK_CAMINH")[3]	,TamSX3("DAK_CAMINH")[1]	,TAMSX3("DAK_CAMINH")[2]	,FWX3Titulo("DAK_CAMINH")	,PESQPICT("DAK","DAK_CAMINH")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPClas"	,TAMSX3("DAK_CDCLFR")[3]	,TamSX3("DAK_CDCLFR")[1]	,TAMSX3("DAK_CDCLFR")[2]	,FWX3Titulo("DAK_CDCLFR")	,PESQPICT("DAK","DAK_CDCLFR")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPOper"	,TAMSX3("DAK_CDTPOP")[3]	,TamSX3("DAK_CDTPOP")[1]	,TAMSX3("DAK_CDTPOP")[2]	,FWX3Titulo("DAK_CDTPOP")	,PESQPICT("DAK","DAK_CDTPOP")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPNego"	,"C"						,1							,0							,STR0026					,"@!"							,.F.,""} ) //-- "Negociação"
	aAdd( aFieldPed	,{"nLinPTpVe"	,TAMSX3("DA3_TIPVEI")[3]	,TamSX3("DA3_TIPVEI")[1]	,TAMSX3("DA3_TIPVEI")[2]	,FWX3Titulo("DA3_TIPVEI")	,PESQPICT("DA3","DA3_TIPVEI")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPKM"		,TAMSX3("GWN_DISTAN")[3]	,TamSX3("GWN_DISTAN")[1]	,TAMSX3("GWN_DISTAN")[2]	,FWX3Titulo("GWN_DISTAN")	,PESQPICT("GWN","GWN_DISTAN")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPTFre"	,TAMSX3("C5_TPFRETE")[3]	,TamSX3("C5_TPFRETE")[1]	,TAMSX3("C5_TPFRETE")[2]	,FWX3Titulo("C5_TPFRETE")	,PESQPICT("SC5","C5_TPFRETE")	,.F.,""} )

	oTablePed := FWTemporaryTable():New( cAliasPed )
	oTablePed:SetFields( aFieldPed )
	oTablePed:AddIndex("TRB_PED", {"nLinPFili", "nLinPNume", "nLinPClie","nLinPLoja", "nLinPTipo"} )
	oTablePed:Create()

	//Percorrendo e criando as colunas
	For nAtual := 1 To Len(aFieldPed)
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&("{|| " + cAliasPed + "->" + aFieldPed[nAtual][1] +"}"))
		oColumn:SetTitle(aFieldPed[nAtual][5])
		oColumn:SetType(aFieldPed[nAtual][2])
		oColumn:SetSize(aFieldPed[nAtual][3])
		oColumn:SetDecimal(aFieldPed[nAtual][4])
		oColumn:SetPicture(aFieldPed[nAtual][6])
		oColumn:SetAlign( If(aFieldPed[nAtual][2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )
		oColumn:SetEdit( .F. )
		aAdd(aColumPed, oColumn)
	Next nAtual

Return

//-----------------------------------------------------------
/*/{Protheus.doc} CriTabTra
Função para criar a Headers Transportadora

@author equipe OMS
@Since	10/10/2023
/*/
//-----------------------------------------------------------/
Static Function CriTabTra(aColumTra,cAliasTra,oTableTra)
	Local oColumn
	Local nAtual
	Local aFieldTra := {}

	aColumTra := {}

	aAdd( aFieldTra	,{"nLinTCodi"	,TAMSX3("A4_COD")[3]	    ,TamSX3("A4_COD")[1]     	,TAMSX3("A4_COD")[2]	    ,FWX3Titulo("A4_COD")		,PESQPICT("SA4","A4_COD")	    ,.F.,""} )
	aAdd( aFieldTra	,{"nLinTNome"	,TAMSX3("A4_NOME")[3]		,TAMSX3("A4_NOME")[1]	    ,TAMSX3("A4_NOME")[2]		,FWX3Titulo("A4_NOME")		,PESQPICT("SA4","A4_NOME")		,.F.,""} )
	aAdd( aFieldTra	,{"nLinTValo"	,TAMSX3("GW8_VALOR")[3]  	,TamSX3("GW8_VALOR")[1]		,TAMSX3("GW8_VALOR")[2]    	,FWX3Titulo("GW8_VALOR")	,PESQPICT("GW8","GW8_VALOR")   	,.F.,""} )
	aAdd( aFieldTra	,{"nLinTQtde"	,TAMSX3("DAK_DATA")[3]  	,TamSX3("DAK_DATA")[1]		,TAMSX3("DAK_DATA")[2]    	,STR0027		 			,PESQPICT("DAK","DAK_DATA")   	,.F.,""} ) //-- "Prev. Entrega"
	aAdd( aFieldTra	,{"nLinTFili"	,TAMSX3("C5_FILIAL")[3]		,TamSX3("C5_FILIAL")[1]		,TAMSX3("C5_FILIAL")[2]		,FWX3Titulo("C5_FILIAL")	,PESQPICT("SC5","C5_FILIAL")	,.F.,""} )
	aAdd( aFieldTra	,{"nLinTNume"	,TAMSX3("C5_NUM")[3]	    ,TamSX3("C5_NUM")[1]     	,TAMSX3("C5_NUM")[2]	    ,FWX3Titulo("C5_NUM")		,PESQPICT("SC5","C5_NUM")	    ,.F.,""} )
	aAdd( aFieldTra	,{"nLinTTipo"	,TAMSX3("C5_TIPO")[3]		,TAMSX3("C5_TIPO")[1]	    ,TAMSX3("C5_TIPO")[2]		,FWX3Titulo("C5_TIPO")		,PESQPICT("SC5","C5_TIPO")		,.F.,""} )
	aAdd( aFieldTra	,{"nLinTClie"	,TAMSX3("C5_CLIENTE")[3]  	,TamSX3("C5_CLIENTE")[1]	,TAMSX3("C5_CLIENTE")[2]    ,FWX3Titulo("C5_CLIENTE")	,PESQPICT("SC5","C5_CLIENTE")   ,.F.,""} )
	aAdd( aFieldTra	,{"nLinTLoja"	,TAMSX3("C5_LOJACLI")[3]	,TamSX3("C5_LOJACLI")[1]    ,TAMSX3("C5_LOJACLI")[2]    ,FWX3Titulo("C5_LOJACLI")	,PESQPICT("SC5","C5_LOJACLI")   ,.F.,""} )
	aAdd( aFieldTra	,{"nLinTGU3"	,TAMSX3("GU3_CDEMIT")[3]  	,TamSX3("GU3_CDEMIT")[1]    ,TAMSX3("GU3_CDEMIT")[2]    ,STR0028					,PESQPICT("GU3","GU3_CDEMIT")   ,.F.,""} ) //-- "Emitente GFE"

	oTableTra := FWTemporaryTable():New( cAliasTra )
	oTableTra:SetFields( aFieldTra )
	oTableTra:AddIndex("TRB_TRA"	, {"nLinTCodi"} )
	oTableTra:AddIndex("TRB_TRAP"	, {"nLinTFili", "nLinTNume", "nLinTClie", "nLinTLoja"} )
	oTableTra:Create()

	//Percorrendo e criando as colunas
	For nAtual := 1 To Len(aFieldTra)
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&("{|| " + cAliasTra + "->" + aFieldTra[nAtual][1] +"}"))
		oColumn:SetTitle(aFieldTra[nAtual][5])
		oColumn:SetType(aFieldTra[nAtual][2])
		oColumn:SetSize(aFieldTra[nAtual][3])
		oColumn:SetDecimal(aFieldTra[nAtual][4])
		oColumn:SetPicture(aFieldTra[nAtual][6])
		oColumn:SetAlign( If(aFieldTra[nAtual][2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )
		oColumn:SetEdit( .F. )

		aAdd(aColumTra, oColumn)
	Next nAtual

Return

//-----------------------------------------------------------
/*/{Protheus.doc} fVlSA4GU3
Função para validar se a transportadora está OK no GFE

@author equipe OMS
@Since	10/10/2023
/*/
//-----------------------------------------------------------/
Static Function fVlSA4GU3(cTmpSA4)
	Local lRetVld := .T.
	Local lAchou  := .F.
	Local aAreaGU3 := GU3->(GetArea())

	// Pode existir mais de um emitente referenciando o mesmo transportador no ERP
	DbSelectArea("GU3")
	GU3->( dbSetOrder(13) )
	If GU3->( dbSeek( xFilial("GU3")+cTmpSA4 ) )
		lAchou := .F.

		While !GU3->(Eof()) .And. GU3->GU3_FILIAL+GU3->GU3_CDTERP == xFilial("GU3")+cTmpSA4
			If (GU3->GU3_TRANSP == '1' .Or. GU3->GU3_AUTON == '1') .And. GU3->GU3_FORN == "1"
				If GU3->GU3_SIT != "1"
					Help(" ",1,"OMS200A03") //-- "Transportadora está com Situação Bloqueada no GFE."
					lRetVld := .F.
					Exit
				EndIf

				lAchou := .T.
			EndIf
			GU3->(DbSkip())
		EndDo

		If !lAchou
			Help("",1,"OMS200A04") //-- "Transportadora vinculada no GFE está incorreta."
			lRetVld := .F.
		EndIf

	Else
		Help("",1,"OMS200A05") //-- "Transportadora não está integrada no GFE."
		lRetVld := .F.
	EndIf

	RestArea( aAreaGU3 )

Return lRetVld

//-----------------------------------------------------------
/*/{Protheus.doc} fPrepFret
Função para preparar o calculo de cada pedido

@author equipe OMS
@Since	10/10/2023
/*/
//-----------------------------------------------------------/
Static Function fPrepFret(lBotao, oTexCal,aMemoria,oTablePed,oTableTra,oTableRes)
	Local cNomTra    := oTableTra:GetRealName()
	Local cDelTra    := "DELETE FROM " + cNomTra
	Local cAliasRes  := oTableRes:GetAlias()
	Local cNomRes    := oTableRes:GetRealName()
	Local cDelRes    := "DELETE FROM " + cNomRes
	Local cAliaTmp   := oTablePed:GetAlias()
	Local aItemPed   := {}
	Local nFazLista	 := 0
	Local aLisResu   := {}
	Local lRet		 := .T.

	Default lBotao   := .F.
	Default oTexCal  := NIL

	//Apagar registros da tabela de Transportadora
	lRet := TCSqlExec(cDelTra) >= 0

	//Apagar registros da tabela de Resumo
	If lRet 
		lRet := TCSqlExec(cDelRes) >= 0
	EndIf

	If lRet
		DBSelectArea(cAliaTmp)
		(cAliaTmp)->(DbSetOrder(1))
		(cAliaTmp)->(dbGoTOp())
	EndIf
	//Percorrer a tabela de Pedidos para calcular frete
	While lRet .And. (cAliaTmp)->(!Eof())
		aItemPed	:= {}

		If  ValType(oTexCal) == "O"
			oTexCal:SetText(STR0029+cValToChar((cAliaTmp)->nLinPNume) ) //-- "Calculando Pedido: "
		EndIf

		aAdd(aItemPed, (cAliaTmp)->nLinPFili)	//Filial do Pedido de Venda
		aAdd(aItemPed, (cAliaTmp)->nLinPNume)	//Numero do Pedido de Venda
		aAdd(aItemPed, (cAliaTmp)->nLinPTipo)	//Tipo do Pedido de Venda
		aAdd(aItemPed, (cAliaTmp)->nLinPClie)	//Codigo do Cliente do Pedido de Venda
		aAdd(aItemPed, (cAliaTmp)->nLinPLoja)	//Codigo da Loja do Pedido de Venda
		aAdd(aItemPed, (cAliaTmp)->nLinPValo)	//Valor do Pedido de Venda
		aAdd(aItemPed, (cAliaTmp)->nLinPPeso)	//Peso do pedido de venda
		aAdd(aItemPed, (cAliaTmp)->nLinPVolu)	//Volume do pedido de venda
		aAdd(aItemPed, (cAliaTmp)->nLinPCOri)	//Codigo do IBGE da Cidade de Origem
		aAdd(aItemPed, (cAliaTmp)->nLinPMOri) 	//Nome do Municipio de Origem
		aAdd(aItemPed, (cAliaTmp)->nLinPEOri) 	//Estado do Municipio de Origem
		aAdd(aItemPed, (cAliaTmp)->nLinPCDes)	//Codigo do IBGE da Cidade de Destino
		aAdd(aItemPed, (cAliaTmp)->nLinPMDes) 	//Nome do Municipio de Destino
		aAdd(aItemPed, (cAliaTmp)->nLinPEDes) 	//Estado do Municipio de Destino
		aAdd(aItemPed, (cAliaTmp)->nLinPEmit)	//Codigo do Remetente		( referencia da GU3)
		aAdd(aItemPed, (cAliaTmp)->nLinPDest)	//Codigo do Destinatario	( referencia da GU3)
		aAdd(aItemPed, (cAliaTmp)->nLinPTran)	//Codigo da Transportadora do Pedido de Venda
		aAdd(aItemPed, (cAliaTmp)->nLinPPlac)	//Codigo da Placa do Veiculo
		aAdd(aItemPed, (cAliaTmp)->nLinPClas)	//Codigo da ClassIficação de Frete
		aAdd(aItemPed, (cAliaTmp)->nLinPOper)	//Codigo da Operação de Frete
		aAdd(aItemPed, (cAliaTmp)->nLinPNego)	//Controle se aceita tabelas de negociação de frete
		aAdd(aItemPed, (cAliaTmp)->nLinPTpVe)	//Tipo de Veiculo associado a Placa
		aAdd(aItemPed, (cAliaTmp)->nLinPKM  )	//KM associado ao pedido de venda

		fCalcFret(aItemPed,aMemoria,oTableTra:GetAlias(),@aLisResu)

		(cAliaTmp)->(DBSkip())
	Enddo

	If Len(aLisResu) > 0
		For nFazLista := 1 to Len(aLisResu)
			RecLock(cAliasRes,.T.)
			(cAliasRes)->nLinRCodi := aLisResu[nFazLista,2]
			(cAliasRes)->nLinRNome := aLisResu[nFazLista,3]
			(cAliasRes)->nLinRValo := aLisResu[nFazLista,4]
			(cAliasRes)->nLinRQtde := aLisResu[nFazLista,5]
			(cAliasRes)->nLinREmit := aLisResu[nFazLista,1]
			(cAliasRes)->(MsUnlock())

		Next nFazLista
	EndIf

	(cAliaTmp)->(dbGoTOp())

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} fCalcFret
Função para calcular o frete por pedido

@author equipe OMS
@Since	10/10/2023
/*/
//-----------------------------------------------------------/
Static Function fCalcFret(aCalFre,aMemCalc,cAliasTra,aLisResu)
	Local lRet       := .T.
	Local oModelSim  := FWLoadModel("GFEX010")
	Local oModelNeg  := oModelSim:GetModel("GFEX010_01")
	Local oModelAgr  := oModelSim:GetModel("DETAIL_01") // oModel do grid "Agrupadores"
	Local oModelDC   := oModelSim:GetModel("DETAIL_02") // oModel do grid "Doc Carga"
	Local oModelIt   := oModelSim:GetModel("DETAIL_03") // oModel do grid "Item Carga"
	Local oModelTr   := oModelSim:GetModel("DETAIL_04") // oModel do grid "Trechos"
	Local oModelInt  := oModelSim:GetModel("SIMULA")
	Local oModelCal1 := oModelSim:GetModel("DETAIL_05")
	Local oModelCal2 := oModelSim:GetModel("DETAIL_06")
	Local cPedTipo   := ""
	Local cPedTVeic	 := "" 
	Local cPedTran   := ""
	Local nCont      := 0

	//Variaveis recebidas via vetor
	Local cPedFil    := aCalFre[01] //Filial do Pedido de Venda
	Local cPedNume   := aCalFre[02] //Numero do Pedido de Venda
	Local cPedTpP    := aCalFre[03] //Tipo do Pedido de Venda
	Local cPedCli    := aCalFre[04] //Codigo do Cliente do Pedido de Venda
	Local cPedLoja   := aCalFre[05] //Codigo da Loja do Pedido de Venda
	Local nPedValo   := aCalFre[06] //Valor do Pedido de Venda
	Local nPedPeso   := aCalFre[07] //Peso do pedido de venda
	Local nPedVolu   := aCalFre[08] //Volume do pedido de venda
	Local cPedCidO   := aCalFre[09] //Codigo do IBGE da Cidade de Origem
	Local cPedMunO   := aCalFre[10] //Nome do Municipio de Origem
	Local cPedEstO   := aCalFre[11] //Estado do Municipio de Origem
	Local cPedCidD   := aCalFre[12] //Codigo do IBGE da Cidade de Destino
	Local cPedMunD   := aCalFre[13] //Nome do Municipio de Destino
	Local cPedEstD   := aCalFre[14] //Estado do Municipio de Destino
	Local cPedReme   := aCalFre[15] //Codigo do Remetente		( referencia da GU3)
	Local cPedDest   := aCalFre[16] //Codigo do Destinatario	( referencia da GU3)
	Local cPedSA4    := aCalFre[17] //Codigo da Transportadora do Pedido de Venda
	Local cPedPlac   := aCalFre[18] //Codigo da Placa do Veiculo
	Local cPedClas   := aCalFre[19] //Codigo da ClassIficação de Frete
	Local cPedOper   := aCalFre[20] //Codigo da Operação de Frete
	Local nPedRadi   := IIf(Valtype(aCalFre[21]) == "N", aCalFre[21], Val(aCalFre[21]) ) //Controle se aceita tabelas de negociação de frete
	Local cPedTpVe   := aCalFre[22] //Tipo de Veiculo do Pedido de Venda
	Local nPedDist   := aCalFre[23] //Distancia em KM do Pedido de Venda

	//Variaveis dentro das transportadora do calculo	
	Local cTmpSA4 := ""
	Local cTmpNom := ""
	Local nTmpFre := 0
	Local dTmpDat 
	Local cTmpGU3 := ""

	Local nPosResu := 0

	Default aMemCalc := {}

	cPedTVeic := Iif( !Empty(cPedPlac), Alltrim(POSICIONE("DA3",1,xFilial("DA3")+cPedPlac,"DA3_TIPVEI")), cPedTVeic)
	cPedTVeic := Iif( Empty(cPedPlac) .And.  !Empty(cPedTpVe), cPedTpVe, cPedTVeic)

	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- "					)
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0032															) //-- "Início de Cálculo de Frete por Pedido Venda"
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- "					)
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0033  														) //-- "Variáveis recebidas para Cálculo Frete"
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0034 + Repl(".",45-Len(STR0034))+": "+ cValToChar(cPedFil)	) //-- "Filial do Pedido de Venda"
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0035 + Repl(".",45-Len(STR0035))+": "+ cValToChar(cPedNume)	) //-- "Número do Pedido de Venda"
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0036 + Repl(".",45-Len(STR0036))+": "+ cValToChar(cPedTpP)	) //-- "Tipo do Pedido de Venda"
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0037 + Repl(".",45-Len(STR0037))+": "+ cValToChar(cPedCli)	) //-- "Código do Cliente do Pedido de Venda"
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0038 + Repl(".",45-Len(STR0038))+": "+ cValToChar(cPedLoja)	) //-- "Código da Loja do Pedido de Venda"
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0039 + Repl(".",45-Len(STR0039))+": "+ Alltrim(TRANSFORM(nPedValo, PESQPICT("DAK","DAK_VALOR")))		) //-- "Valor do Pedido de Venda.....................: "
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0040 + Repl(".",45-Len(STR0040))+": "+ Alltrim(TRANSFORM(nPedPeso, PESQPICT("DAK","DAK_PESO")))		) //-- "Peso do pedido de venda......................: "
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0041 + Repl(".",45-Len(STR0041))+": "+ Alltrim(TRANSFORM(nPedVolu, PESQPICT("DAK","DAK_CAPVOL"))) 	) //-- "Volume do pedido de venda....................: "
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0042 + Repl(".",45-Len(STR0042))+": "+ cValToChar(cPedCidO)			) //-- "Código do IBGE da Cidade de Origem"
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0043 + Repl(".",45-Len(STR0043))+": "+ cValToChar(cPedMunO)	) //-- "Nome do Município de Origem"					
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0044 + Repl(".",45-Len(STR0044))+": "+ cValToChar(cPedEstO)	) //-- "Estado do Município de Origem"				
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0045 + Repl(".",45-Len(STR0045))+": "+ cValToChar(cPedCidD)	) //-- "Código do IBGE da Cidade de Destino"			
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0046 + Repl(".",45-Len(STR0046))+": "+ cValToChar(cPedMunD)	) //-- "Nome do Município de Destino"				
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0047 + Repl(".",45-Len(STR0047))+": "+ cValToChar(cPedEstD)	) //-- "Estado do Município de Destino"				
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0048 + Repl(".",45-Len(STR0048))+": "+ cValToChar(cPedReme)	) //-- "Código do Remetente(referência da GU3)"		
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0049 + Repl(".",45-Len(STR0049))+": "+ cValToChar(cPedDest)	) //-- "Código do Destinátario (referência da GU3)"	
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0050 + Repl(".",45-Len(STR0050))+": "+ cValToChar(cPedSA4)	) //-- "Código da Transportadora do Pedido de Venda"		
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0051 + Repl(".",45-Len(STR0051))+": "+ cValToChar(cPedPlac)	) //-- "Código da Placa do Veículo"					
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0052 + Repl(".",45-Len(STR0052))+": "+ cValToChar(cPedClas)	) //-- "Código da Classificação de Frete"			
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0053 + Repl(".",45-Len(STR0053))+": "+ cValToChar(cPedOper)	) //-- "Código da Operação de Frete"					
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0054 + Repl(".",45-Len(STR0054))+": "+ cValToChar(nPedRadi)	) //-- "Aceita tabelas de negociação de frete"		
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0055 + Repl(".",45-Len(STR0055))+": "+ cValToChar(cPedTpVe)	) //-- "Tipo de Veículo do Pedido de Venda"			
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0056 + Repl(".",45-Len(STR0056))+": "+ cValToChar(nPedDist)	) //-- "Distância em KM do Pedido de Venda"			
		
	//VerIficar qual é tipo de documento correspondente no GFE
	cPedTipo := Alltrim(Tabela("MQ",AllTrim(cPedTpP)+"S",.F.))
	cPedTipo := Iif(Empty(cPedTipo), Alltrim(Tabela("MQ",AllTrim(cPedTpP),.F.)), cPedTipo)
	cPedTipo := PadR(cPedTipo,TamSx3("GW1_CDTPDC")[1])
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0057 + Repl(".",45-Len(STR0057))+": "+ cValToChar(cPedTipo)	) //-- "Tipo de Pedido Equiv. no GFE (GW1_CDTPDC)"

	// Não mostra a tela de Log do processamento
	GFEX010Slg(0/*nTelaGFE */) //-- nTelaGFE >> 0: Não apresentar / 1: Somente erros / 2: Sempre

	// Não mostra a barra de progresso
	GFEX010SBr(.T.) // .T. Oculta a barra de Progresso / .F. Mostrar a barra de progresso.

	//simula como inclusão
	oModelSim:SetOperation(3)
	oModelSim:Activate()

	oModelNeg:LoadValue('CONSNEG', cValToChar(nPedRadi) )// 1=Considera Tab.Frete em Negociacao; 2=Considera apenas Tab.Frete Aprovadas

	//Agrupadores
	oModelAgr:LoadValue('GWN_NRROM' , "01" 				) 
	oModelAgr:LoadValue('GWN_CDCLFR', Alltrim(cPedClas)	)
	oModelAgr:LoadValue('GWN_CDTPOP', Alltrim(cPedOper)	)
	oModelAgr:LoadValue('GWN_DOC'   , "ROMANEIO"		)
	oModelAgr:LoadValue('GWN_DISTAN', nPedDist			)
	//Documento de Carga
	oModelDC:LoadValue('GW1_EMISDC', Alltrim(cPedReme)	)
	oModelDC:LoadValue('GW1_NRDC'  , "00001"			)
	oModelDC:LoadValue('GW1_CDTPDC', Alltrim(cPedTipo)	)
	oModelDC:LoadValue('GW1_CDREM' , Alltrim(cPedReme)	)
	oModelDC:LoadValue('GW1_CDDEST', Alltrim(cPedDest)	)
	oModelDC:LoadValue('GW1_TPFRET', "1"				)
	oModelDC:LoadValue('GW1_ICMSDC', "2"				)
	oModelDC:LoadValue('GW1_USO'   , "1"				)
	oModelDC:LoadValue('GW1_NRROM' , "01"				)
	oModelDC:LoadValue('GW1_QTUNI' , 1					)
	//Trechos
	oModelTr:LoadValue('GWU_EMISDC', Alltrim(cPedReme)	)
	oModelTr:LoadValue('GWU_NRDC'  , "00001"			)
	oModelTr:LoadValue('GWU_CDTPDC', Alltrim(cPedTipo)	)
	oModelTr:LoadValue('GWU_SEQ'   , "01"				)

	//Codigo da Cidade de Origem
	oModelTr:LoadValue('GWU_NRCIDO', cPedCidO) 
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ IiF(!Empty(cPedCidO),STR0058,STR0059) + Repl(".",45-Len(IiF(!Empty(cPedCidO),STR0058,STR0059)))+": "+ cValToChar(cPedCidO)	) //-- "Adicionando código da Cidade Origem (GFE)" ## "Código da Cidade Origem (GFE) não informado"

	//Codigo da Cidade de Destino
	If !Empty(cPedCidD)
		oModelTr:LoadValue('GWU_NRCIDD', cPedCidD) 
		aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0060 + Repl(".",45-Len(STR0060))+": "+ cValToChar(cPedCidD)	) //-- "Adicionando código da Cidade Destino (GFE)"
	Else
		//Codigo da Cidade de Destino a partir do Destinatário
		If !Empty(cPedDest)
			oModelTr:LoadValue('GWU_NRCIDD', POSICIONE("GU3",1,xFilial("GU3")+cPedDest,"GU3_NRCID")) 
			aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0060 + Repl(".",45-Len(STR0060))+": "+ cValToChar(POSICIONE("GU3",1,xFilial("GU3")+cPedDest,"GU3_NRCID"))	) //-- "Adicionando código da Cidade Destino (GFE)"
			aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0061 + Repl(".",45-Len(STR0061))+": "+ cValToChar(cPedDest)	) //-- "Usando Código do Destinatario (GU3)"
		EndIf
	EndIf

	// adiciona o transportador
	If !Empty(cPedSA4) .And. fVlSA4GU3(cPedSA4)
		cPedTran := Alltrim(POSICIONE("GU3",13,xFilial("GU3")+cPedSA4,"GU3_CDEMIT"))
		If !Empty(cPedTran)
			oModelTr:LoadValue('GWU_CDTRP', cPedTran	) 
			aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0062 + Repl(".",45-Len(STR0062))+": "+ cValToChar(cPedTran)	) //-- "Transportadora Equivalente GFE. (GU3)"
		EndIf
	Else
		aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0063 + Repl(".",45-Len(STR0063))+": "+ cValToChar(cPedSA4)	) //-- "Transportadora (SA4) não existe no GFE"
	EndIf

	// adiciona o tipo do veículo para cálculo do frete
	If !Empty(cPedTVeic)
		oModelTr:LoadValue('GWU_CDTPVC', cPedTVeic ) 
		aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0064 + Repl(".",45-Len(STR0064))+": "+cValToChar(cPedTVeic)	) //-- "Tipo de Veículo Equiv. GFE (GWU_CDTPVC)"
	Else
		oModelTr:LoadValue('GWU_CDTPVC', SPACE(TamSX3("GWU_CDTPVC")[1]) ) 
		aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0064 + Repl(".",45-Len(STR0064))+": "+STR0065) //-- "Tipo de Veículo Equiv. GFE (GWU_CDTPVC)" ## "não tem informações no campo"
	EndIf

	//Itens
	oModelIt:LoadValue('GW8_EMISDC', Alltrim(cPedReme)	)
	oModelIt:LoadValue('GW8_NRDC'  , "00001"			)
	oModelIt:LoadValue('GW8_CDTPDC', Alltrim(cPedTipo)	)
	oModelIt:LoadValue('GW8_ITEM'  , "ItemA"  			)
	oModelIt:LoadValue('GW8_DSITEM', "Item Generico"	)
	oModelIt:LoadValue('GW8_CDCLFR', Alltrim(cPedClas)	)
	oModelIt:LoadValue('GW8_PESOR' , nPedPeso			)
	oModelIt:LoadValue('GW8_VALOR' , nPedValo			)
	oModelIt:LoadValue('GW8_VOLUME', nPedVolu			)
	oModelIt:LoadValue('GW8_TRIBP' , "1"				)
	// Dispara a simulação
	oModelInt:SetValue("INTEGRA", "A"					)

	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- ")
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0066 ) //-- "Resultado do Cálculo de Frete"
	aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- ")	

	//VerIfica se tem linhas no modelo do calculo, se nao tem linhas signIfica que o calculo falhou e retorna zero
	If oModelCal1:GetQtdLine() > 1 .Or. !Empty( oModelCal1:GetValue('C1_NRCALC'  ,1) )
		//Percorre o grid, cada linha corresponde a um calculo dIferente

		For nCont := 1 to oModelCal1:GetQtdLine()
			oModelCal1:GoLine( nCont )
			
			cTmpSA4 := POSICIONE("GU3",1,xFilial("GU3")+oModelCal2:GetValue('C2_CDEMIT',1 ),"GU3_CDTERP")
			cTmpNom := POSICIONE("GU3",1,xFilial("GU3")+oModelCal2:GetValue('C2_CDEMIT',1 ),"GU3_NMEMIT")
			nTmpFre := oModelCal1:GetValue('C1_VALFRT'  ,nCont)
			dTmpDat := oModelCal1:GetValue('C1_DTPREN'  ,nCont)
			cTmpGU3 := oModelCal2:GetValue('C2_CDEMIT'  ,1 )


			If nCont > 1
				aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- ")	
			EndIf

			aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0067 + Repl(".",45-Len(STR0067))+": "+ cValToChar(Alltrim(cTmpSA4))) //-- "Código do Transportadora (SA4)"
			aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0068 + Repl(".",45-Len(STR0068))+": "+ cValToChar(Alltrim(cTmpGU3))) //-- "Código do Emitente Transportadora GFE (GU3)"
			aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0069 + Repl(".",45-Len(STR0069))+": "+ cValToChar(Alltrim(cTmpNom))) //-- "Nome do Emitente Transportadora GFE (GU3)"
			aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0070 + Repl(".",45-Len(STR0070))+": "+ Alltrim(TRANSFORM(nTmpFre, PESQPICT("GW8","GW8_VALOR")))	)//-- Valor Frete Cálculo Transportadora GFE (GU3)
			aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0071 + Repl(".",45-Len(STR0071))+": "+ cValToChar(dTmpDat)) //-- "Data de Previsão de Entrega GFE"		

			If Empty(cTmpSA4)
				aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0072 + Repl(".",45-Len(STR0072))+": "+ STR0073) //-- "Transportadora possui tabela de Frete" ## "Cadastro está incorreto no Emitente (GU3)"
			EndIf

			If Empty(cPedTran) .Or. cPedSA4 == cTmpSA4

				RecLock(cAliasTra,.T.)
				(cAliasTra)->nLinTCodi	:= cTmpSA4
				(cAliasTra)->nLinTNome	:= cTmpNom
				(cAliasTra)->nLinTValo	:= nTmpFre
				(cAliasTra)->nLinTQtde	:= dTmpDat
				(cAliasTra)->nLinTFili	:= cPedFil
				(cAliasTra)->nLinTNume	:= cPedNume
				(cAliasTra)->nLinTTipo	:= cPedTpP
				(cAliasTra)->nLinTClie	:= cPedCli
				(cAliasTra)->nLinTLoja	:= cPedLoja
				(cAliasTra)->nLinTGU3	:= cTmpGU3
				(cAliasTra)->(MsUnlock())

				nPosResu := aScan(aLisResu,{|x| AllTrim(x[1]) == Alltrim(cTmpGU3) })
				If nPosResu > 0
					aLisResu[nPosResu,4] += nTmpFre
					aLisResu[nPosResu,5] += 1
				Else
					aAdd(aLisResu,{Alltrim(cTmpGU3), Alltrim(cTmpSA4), Alltrim(cTmpNom), nTmpFre, 1})
				EndIf

				If !Empty(cPedTran) .And. cPedSA4 == cTmpSA4
					EXIT
				EndIf
			EndIf
		Next nCont
	Else
		aAdd(aMemCalc, OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0074) //--"Dados informados não trouxe nenhuma referência"
		lRet := .F. //Para indicar que para o pedido não calculou nada
	EndIf

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} fRefrTran
Função para filtrar a transportadora conforme o pedido

@author equipe OMS
@Since	10/10/2023
/*/
//-----------------------------------------------------------/
Static Function fRefrTran(oBrowsTra,cAliasPed,cAliasTra)
	Local cFiltro := ""

	If Valtype(oBrowsTra) == "O" 
		cFiltro += "       ('"+cAliasTra+"')->nLinTFili == '"+(cAliasPed)->nLinPFili+"' "
		cFiltro += " .And. ('"+cAliasTra+"')->nLinTNume == '"+(cAliasPed)->nLinPNume+"' "
		cFiltro += " .And. ('"+cAliasTra+"')->nLinTTipo == '"+(cAliasPed)->nLinPTipo+"' "
		cFiltro += " .And. ('"+cAliasTra+"')->nLinTClie == '"+(cAliasPed)->nLinPClie+"' "
		cFiltro += " .And. ('"+cAliasTra+"')->nLinTLoja == '"+(cAliasPed)->nLinPLoja+"' "

		oBrowsTra:CleanFilter()
		oBrowsTra:SetFilterDefault( cFiltro )
		oBrowsTra:Refresh(.t.)
	EndIf
	
Return .T.

//-----------------------------------------------------------
/*/{Protheus.doc} fGFEAtivo
Função para validar se o GFE está ativo

@author equipe OMS
@Since	10/10/2023
/*/
//-----------------------------------------------------------/
Static Function fGFEAtivo()
	Local lRetGFE   := .F.
	Local lIntGFE   := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2  := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cIntCarga := SuperGetMv("MV_GFEI12",.F.,"2")

	lRetGFE :=  lIntGFE .And. cIntGFE2 $ "1" .And. cIntCarga == "1"

Return lRetGFE

//-----------------------------------------------------------
/*/{Protheus.doc} fTelMem
Função para exibir tela com memória de cálculo

@author equipe OMS
@Since	10/10/2023
/*/
//-----------------------------------------------------------/
Static Function fTelMem(aMemoria)
	Local cMsgMemo	 := ""
	Local nFazMemo   := 0

	If Len(aMemoria) > 0
		For nFazMemo:= 1 to Len(aMemoria)
			cMsgMemo += aMemoria[nFazMemo]+CRLF
		Next nFazMemo

		cMsgMemo += ""+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- "+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> "+ STR0075                                      +CRLF //-- "Parâmetros da tela de Cálculo de Frete"
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- "+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> MV_OM2NEG : "+cValToChar(SuperGetMV("MV_OM2NEG",.F., "2"))		+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- "+CRLF

		//EECView(xMsg,cTitulo,cLabel, aButtons, bValid, lQuebraLinha, lSoExibeMsg) 
		EecView(cMsgMemo,STR0030, STR0031,/*aButtons*/, /*bValid*/, /*lQuebraLinha*/, .T.)	//-- "Calculo de Frete" ## "Simulação "
	EndIf
Return Nil