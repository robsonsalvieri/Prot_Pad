#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'WMSA380.CH'

//---------------------------------------------------------------------------//
//---------- Corte de Produtos de OS WMS de Expedição e Embalagem  ----------//
//---------------------------------------------------------------------------//
Function WmsA380()
Local oSize      
Local cMapaSep := Space(Len(SDB->DB_MAPSEP))
Local aButtons := {}
Local aAltera	:= {'C6_QTDLIB'} // Campos que poderão ser alterados

Private oGetD
Private aHeader  := {}
Private aCols    := {}
Private aRotina  := {{STR0001,'AxPesqui',0,1},; // Pesquisar
							{STR0002,'AxVisual',0,2},; // Visualizar
							{STR0003,'AxInclui',0,3},; // Incluir
							{STR0004,'AxAltera',0,4},; // Alterar
							{STR0005,'AxDeleta',0,5} } // Excluir
	
	If SuperGetMv("MV_WMSNEW",.F.,.F.)
		Return WMSA381()
	EndIf
	
	oSize := FWDefSize():New(.T.)
										  
	oSize:AddObject( "CAMPOMAPA", 100, 10, .T., .T. ) // Área útil vertical da tela que o campo Mapa Separação irá ocupar 10%                          
	oSize:AddObject( "ITENSGRID", 100, 90, .T., .T. ) // Área útil vertical da tela que a MSGetDados irá ocupar 90%                             
	
	// Permite redimensionar as telas de acordo com a proporção do AddObject
	oSize:lProp := .T. 
	
	// Executa os cálculos
	oSize:Process() 
	
	// Inicia aHeader e aCols
	InicHC()
	
	DEFINE MSDIALOG oDlg TITLE STR0006 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL
	
	@ oSize:GetDimension("CAMPOMAPA","LININI")+15,oSize:GetDimension("CAMPOMAPA","COLINI")+15 SAY   STR0007 SIZE 20,9 OF oDlg PIXEL // Mapa
	@ oSize:GetDimension("CAMPOMAPA","LININI")+15,oSize:GetDimension("CAMPOMAPA","COLINI")+35 MSGET cMapaSep SIZE 25,9 VALID VldMapa(cMapaSep) OF oDlg PIXEL
	
	oGetD := MSGetDados():New(oSize:GetDimension("ITENSGRID","LININI"),;
									  oSize:GetDimension("ITENSGRID","COLINI"),;
									  oSize:GetDimension("ITENSGRID","LINEND"),;
									  oSize:GetDimension("ITENSGRID","COLEND"),;
									  3,,'AllWaysTrue',,,aAltera)     
									  
	oGetD:OBROWSE:BADD := { || { || .F.  }} // Não permite incluir nova linha no browse                
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| Iif(WmsA380TOk(),(WmsA380Grv(),InicHC(@cMapaSep),oGetD:ForceRefresh()),.F.)},{||oDlg:End()},, aButtons )//Ativa a Dialog e inclui a Enchoice

Return

//---------------------------------------------------------------------------//
//------------------------ Inicializa aHeader e aCols -----------------------//
//---------------------------------------------------------------------------//
Static Function InicHC(cMapaSep)
Local aCampos  := {}
Local nX       := 1
Local aColsSX3 := {}

	If !Empty(cMapaSep)
		cMapaSep := Space(Len(SDB->DB_MAPSEP))
		aHeader  := {}
		aCols    := {}
	EndIf

	AAdd(aCampos,{"DCF","DCF_DOCTO" ,"C"})
	AAdd(aCampos,{"SDB","DB_LOCAL"  ,"C"})
	AAdd(aCampos,{"SDB","DB_PRODUTO","C"})
	AAdd(aCampos,{"SDB","DB_QUANT"  ,"N"})
	AAdd(aCampos,{"SC6","C6_QTDLIB" ,"N"})

	For nX := 1 To Len(aCampos)
		BuscarSX3(aCampos[nX,2],,aColsSX3)
		AAdd(aHeader,{;
		              Iif(AllTrim(aCampos[nX,2])=='DB_QUANT',STR0008,;  // Qtde Original
		              Iif(AllTrim(aCampos[nX,2])=='C6_QTDLIB',STR0009,; // Qtde p/ Corte
		              AllTrim(aColsSX3[1]))),;                          // Titulo
		              aCampos[nX,2],;                                   // Campo
		              aColsSX3[2],;                                     // Picture
		              aColsSX3[3],;                                     // Tamanho
		              aColsSX3[4],;                                     // Decimal
		              Iif(AllTrim(aCampos[nX,2])=='C6_QTDLIB','VldQtCorte()',''),; // Valid
		              X3Usado(aCampos[nX,2]),;                           // Usado
		              aCampos[nX,3],;                                    // Tipo
		              aCampos[nX,1],;                                    // Arquivo
		              "R"})                                              // Contexto
	Next

	// Cria uma linha no aCols
	AAdd(aCols,Array(Len(aHeader)+1))
	For nX := 1 To Len(aHeader)
		GdFieldPut(aHeader[nX,2],CriaVar(aHeader[nX,2],.F.,,.F.),1)
	Next
	aCols[1,Len(aHeader)+1] := .F.

Return 

//---------------------------------------------------------------------------//
//---- Valida mapa de separação e carrega seus respectivos itens na tela ----//
//---------------------------------------------------------------------------//
Static Function VldMapa(cMapaSep)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
	If !Empty(cMapaSep)
		
		aCols := {}
			
		cQuery := "SELECT SDB.R_E_C_N_O_ RECNOSDB"
		cQuery +=  " FROM " + RetSqlName('SDB')+" SDB"
		cQuery += " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
		cQuery +=   " AND SDB.DB_MAPSEP = '"+cMapaSep+"'"
		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
		cQuery +=   " AND SDB.DB_ATUEST = 'N'"
		cQuery +=   " AND SDB.DB_STATUS = '4'"
		cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY SDB.DB_DOC, SDB.DB_LOCAL, SDB.DB_PRODUTO"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		
		While (cAliasQry)->(!Eof())
			
			// Posiciona SDB
			SDB->(DbGoTo((cAliasQry)->RECNOSDB))
			
			// Carrega os itens do mapa que serão mostrados na tela
			AAdd(aCols,{SDB->DB_DOC    ,;
							SDB->DB_LOCAL  ,;
							SDB->DB_PRODUTO,;
							SDB->DB_QUANT  ,;
							0              ,;
							SDB->(Recno())}) 
  
			(cAliasQry)->(DbSkip())
		EndDo
		
		(cAliasQry)->(DbCloseArea())
		
		If Empty(aCols)
			WmsMessage(STR0010) // Cortes sao permitidos somente em o.s.wms de expedicao e embalagem, pois se trata de um processo manual e sera considerado pela conferencia (wmsa360)
			lRet := .F.
		Else
			oGetD:ForceRefresh()
		EndIf
		
	Else
		WmsMessage(STR0017,,1) // Informe o mapa de separação!
		lRet := .F.
	EndIf
	
	RestArea(aAreaAnt)
Return lRet

//---------------------------------------------------------------------------//
//----------------------- Valida o campo Qtde p/ Corte ----------------------//
//---------------------------------------------------------------------------//
Function VldQtCorte()
	If QtdComp(M->C6_QTDLIB) > QtdComp(GdFieldGet('DB_QUANT',n))
		WmsMessage(STR0013,,1) // Quantidade para corte maior que quantidade original                                                                                                                                                                                                                                                                                                                                                                                                                                                               
		Return .F.
	EndIf
Return .T.

//---------------------------------------------------------------------------//
//---------------------- Validação geral da MSGetDados, ---------------------//
//-------- verifica se existe alguma quantidade para realizar corte ---------//
//---------------------------------------------------------------------------//
Static Function WmsA380TOk()
	If AScan(aCols,{|x|x[5]>0}) == 0
		WmsMessage(STR0018) // É necessário informar quantidade para realizar o corte de produto!
		Return .F.
	EndIf
Return .T.

//---------------------------------------------------------------------------//
//------------------------- Grava o corte de produto ------------------------//
//----------------- atualizando as tabelas correspondentes ------------------//
//---------------------------------------------------------------------------//
Static Function WmsA380Grv()
Local aAreaAnt := GetArea()
Local aAreaDCF := DCF->(GetArea())
Local aAreaSC9 := SC9->(GetArea())
Local aAreaSB2 := SB2->(GetArea())
Local lRet     := .F.
Local nX       := 1
Local nQuant   := 0 
Local nQtdOrig := 0
Local nQtdMvto := 0
Local aVisErr  := {}

Private cStatExec := SuperGetMV('MV_RFSTEXE', .F., '1') //-- DB_STATUS indincando Atividade Executada

	For nX := 1 To Len(aCols)
		nQuant := aCols[nX,5]
		If QtdComp(nQuant) > QtdComp(0)
			// Posiciona no registro SDB
			SDB->(MsGoTo(aCols[nX,6]))
			// Se for a primeira atividade
			If DLPrimAtiv(SDB->DB_DOC,SDB->DB_SERIE, SDB->DB_CLIFOR, SDB->DB_LOJA, SDB->DB_SERVIC, SDB->DB_TAREFA, SDB->DB_IDMOVTO, SDB->DB_ORDATIV)
				nQtdOrig := SDB->DB_QUANT
				nQtdMvto := SDB->DB_QUANT - nQuant
				// Posiciona o DCF e trava o registro
				DCF->(DbSetOrder(2))
				If WmsChkDCF('SC9',SDB->DB_CARGA,SDB->DB_UNITIZ,SDB->DB_SERVIC,'3',,SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_LOCAL,SDB->DB_PRODUTO,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,,SDB->DB_IDDCF)
					Begin Transaction
						// Atualiza a liberação do pedido de venda
						lRet := DLGV030ALP(nQtdOrig,nQtdMvto)
						// Atualiza quantidade na ordem de serviço
						If lRet
							RecLock("DCF",.F.)
							If DCF->DCF_QTDORI == 0
								DCF->DCF_QTDORI := DCF->DCF_QUANT
							EndIf
							DCF->DCF_QUANT  := DCF->DCF_QUANT + (nQtdMvto-nQtdOrig)
							DCF->DCF_QTSEUM := ConvUm(DCF->DCF_CODPRO,DCF->DCF_QUANT,0,2)
							// Se zerar estorna o registro do DCF
							If QtdComp(DCF->DCF_QUANT) <= QtdComp(0)
								DCF->(DbDelete())
							EndIf
							DCF->(MsUnlock())
						EndIf
						// Atualiza movimentação de estoque da tarefa atual
						If lRet
							lRet := DLGV030ASC(.T.,nQtdOrig,nQtdMvto)
						EndIf
						// Atualizando, caso exista a atividade de conferência
						If lRet
							lRet := DLGV030ASC(.F.,nQtdOrig,nQtdMvto)
						EndIf
						If !lRet
							DisarmTransaction()
						EndIf
					End Transaction
				EndIf
			EndIf
			If !lRet
				AAdd(aVisErr, {AllTrim(aCols[nX,1])+' / '+AllTrim(aCols[nX,3])})
			EndIf
		EndIf
	Next

	If !Empty(aVisErr)
		TmsMsgErr(aVisErr, STR0019) // Houveram problemas no corte do documento/produto:
	Else
		WmsMessage(STR0020) // Corte de produto realizado com sucesso!
	EndIf

RestArea(aAreaSB2)
RestArea(aAreaSC9)
RestArea(aAreaDCF)
RestArea(aAreaAnt)
Return .T.
