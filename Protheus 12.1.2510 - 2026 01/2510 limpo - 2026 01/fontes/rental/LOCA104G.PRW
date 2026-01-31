#Include "loca104g.ch"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"
/*/{Protheus.doc} LOCA104G
Rotina para Emissão do documento de entrada referente ao romaneio posicionado
@type function
@version 25.10
@author Alexandre Circenis
@since 05/11/2025
@return variant, retorna o sucesso da operação
/*/
Function LOCA104G()
	Local aArea := GetArea()

	PRIVATE _LTUDOOK   := .F.
	PRIVATE cAviso     := ""
	PRIVATE cProjet    := FQU->FQU_PROJET
	PRIVATE _CFILAUX   // FRANK 07/10/2020 - FILIAL PARA GERACAO DA NOTA DE REMESSA SEM SER VIA ROMANEIO
	PRIVATE aFPYTransf := {} // Deve ser private e serão utilizadas no LOCM006
	PRIVATE aFPZTransf := {} // Deve ser private e serão utilizadas no LOCM006
	Private aBlqRemessa // Array com bloqueios de documento
	private _nzuc     := 0  // recno da zuc (conjunto transportador) usado no ponto de entrada mt103fim, gernfret e a103devol - frank 02/11/20

	// Validação pré geração de nota de retorno
	if FQW->FQW_STATUS $ '56'
		MsgAlert(STR0001, STR0003) //" //"Romaneio já teve a nota gerada. Não é possivel continuar!" //"Atenção"
		RestArea(aArea)
		REturn .T.
	endif

	if FQW->FQW_STATUS = '1'
		MsgAlert(STR0002, STR0003) //" //"Romaneio não possue itens informados. Não é possivel continuar!" //"Atenção"
		RestArea(aArea)
		REturn .T.
	endif

	if FQW->FQW_STATUS = '4'
		MsgAlert(STR0004, STR0003) //" //"Atenção" //"Romaneio apresenta divergencias nas contagens. Não é possivel continuar!"
		RestArea(aArea)
		REturn .T.
	endif

	if Loca104GID() // Há itens que presisam de segunda contagem mas ainda não foi realizada
		MsgAlert(STR0022, STR0003) //" //"Atenção" //"Romaneio apresenta divergencias nas contagens. Não é possivel continuar!" //"Há itens com Bens Quantificaveis sem I.D. informados. Não será possivel continuar!"
		RestArea(aArea)
		REturn .T.
	endif

	// Verificar se o contrato exige segunda contagem
	If FP0->(FieldPos("FP0_CONFD")) > 0 .and. Posicione("FP0",1, xFilial("FP0")+FQW->FQW_PROJET, "FP0_CONFD") = '1'
		if FQV->FQV_STATUS <> '3'
			MsgAlert(STR0005, STR0003) //" //"O Contrato exige a realização de uma segunda contagem para conferencia. Não é possivel continuar!" //"Atenção"
			RestArea(aArea)
			REturn .T.
		endif
	endif

	RestArea(aArea)
// Apresenta a tela do romaneio agurdando a confirmação da emissao da remessa
	oView := FWLoadView("LOCA104F")
	oView:AddUserButton(STR0006,STR0008,{|oView| Loca104GDV(oView) },STR0007,,,.T.) //"Gerar Devolução" //"Gerar Documento de Devolução" //"OK"
	oView:EnableControlBar(.T.)

	aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
		{.F.,Nil},{.T.,NIL},{.T.,STR0009},{.F.,Nil},{.F.,Nil},; //"Cancelar"
		{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oExecView := FWViewExec():New()
	oExecView:setView(oView)
	oExecView:setTitle(STR0006) //"Gerar Remessa" //"Gerar Devolução"
//oExecView:setSource("LOCA104F")
	oExecView:setModal(.F.)
	oExecView:SetButtons(aButtons)
	oExecView:setOperation(MODEL_OPERATION_VIEW)
	oExecView:openView(.T.)

RETURN .T.

/*/{Protheus.doc} LOCA229IRM
Processo de emissão de Documento de Devolução
@type function
@version  25.10
@author Alexandre Circenis
@since 6/25/2025
@param oView, object, View de origem 
@return variant, Retorna .f. para fechar a janela
/*/
FUNCTION LOCA104GDV(oView)
	Local aArea := GetArea()
	Local lFormPropr := .T.

	Private cAviso := ""

	oView:ButtonCancelAction()
	_nzuc := 1
	if _nzuc > 0
		if empty(getmv("MV_LOCX299",,"")) // indica se existe integracao com o rm - frank 04/10/22
			lformpropr := msgyesno(STR0011, STR0010) //"Informar o tipo do formulário" //"O Documento de retono será via Formulário Próprio?"
			FWMsgRun( , {|oSay|LOCA104GGN(FQW->FQW_num,lformpropr, oSay)}, "",STR0020) //"Processando a Geração do Documento de Retorno"
		else
			// LOCA76R() Preparar para a Integração RM
			//	if !Empty(cAviso)
			// 		Aviso("Rental: "+alltrim(upper(Procname())),; //
			// 		cAviso , {"Ok"})
			//	endif
		endif
	endif

	RestArea(aArea)

RETURN .F.

/*/{Protheus.doc} LOCA104GGN
Prepara a emissaão dos itens da Nota
@type function
@version 25.10
@author Alexandre Circenis
@since 31/10/2025
@param cNumRom, character, Numero do Romaneio
@param lFormPropr, logical, Formulario proprio
/*/
Function LOCA104GGN( cNumRom , lFormPropr, oSay )

	Local cCliente		:= ""
	Local cLoja			:= ""
    Local lLOCA11E := ExistBlock("LOCA11E")
	Local cQry
	Local lZuc
	Local aItens    := {}
    Local cMV_LOC025 := SuperGetMv("MV_LOCX025")

	Default lFormPropr	:= .F. //José Eulálio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulário quando for Formulário Próprio = Sim.

	Private aItensNota := {}

	Private cTesDv
	Private cTipoNf   := "E" // Frank 25/11/2020 para uso na rotina do mata100b
	Private cTEs             // Frank 25/11/2020 para uso na rotina do mata100b
	Private aAsgrv    := {} // uso no mata103fim, ou no locm008

	IF lLOCA11E
		_nZuc := EXECBLOCK("LOCA11E",.T.,.T.,{})
	ENDIF
	lZuc := type("_nZuc")== "N"

    FQX->(dbSetOrder(1))
	// --> Inicia o Posicionamento das Tabelas
	If FQX->(dbSeek(xFilial("FQX")+FQW->FQW_NUM))	// Realiza a Busca do Romaneio.

		While FQX->(!Eof()) .And. (FQX->FQX_FILIAL == xFilial("FQX") .And. FQX->FQX_NUM == FQW->FQW_NUM)

			FPA->(dbSetOrder(3))
			If FPA->(dbSeek(xFilial("FPA")+FQX->FQX_AS))//Realiza a Busca do Romaneio.

				cQry:= " SELECT D2_CLIENTE , D2_IDENTB6, D2_LOJA , D2_PRCVEN , D2_TOTAL , D2_TES , D2_VALFRE , D2_SEGURO , D2_DESPESA , D2_IPI , "
				cQry+=        " D2_LOCAL , D2_COD , D2_QUANT , D2_UM , D2_ICMSRET, D2_LOTECTL , R_E_C_N_O_, D2_ITEM "
				cQry+= " FROM "+RetSqlName("SD2")+" SD2 "
				cQry+= " WHERE  SD2.D_E_L_E_T_ = ' ' "
				cQry+=   " AND  D2_FILIAL = ? "
				cQry+=   " AND  D2_DOC    = ? "
				cQry+=   " AND  D2_SERIE  = ? "
				cQry+=   " AND  D2_COD    = ? "
				cQry+=   " AND  D2_ITEMPV = ? "
				cQry := CHANGEQUERY(cQry)
				aBindParam := {FPA->FPA_FILREM,FPA->FPA_NFREM,FPA->FPA_SERREM,FPA->FPA_PRODUTO,FPA->FPA_ITEREM}
				MPSysOpenQuery(cQry,"QRY",,,aBindParam)
				//TcQuery cQry New Alias "QRY"

				While QRY->(!Eof())
					cTesDv:= Posicione("SF4",1,xFilial("SF4")+QRY->D2_TES,"F4_TESDV")
					If Empty(cTesDv)
						MsgAlert(STR0014+QRY->D2_TES+STR0012 ,STR0013) //STR0014###" sem Tipo de Devolução Cadastrada, Cadastrar TES de Devolução."###"Atenção!" //" sem TES de devolução cadastrado. Informar o TES de devolução no TES usado para remessa." //"Atenção !" //"TES de Saída "
						Return
					EndIf

					cNFORI		:= FPA->FPA_NFREM
					cSERIORI	:= FPA->FPA_SERREM
					cITEMORI	:= QRY->D2_ITEM //AllTrim(FPA->FPA_ITEREM) - Frank em 13/11/23

					cCliente    := FQW->FQW_CLIDEV
					cLoja       := FQW->FQW_LOjDEV

					FP0->(dbSetOrder(1))
					FP0->(dbSeek(xfilial("FP0")+FPA->FPA_PROJET))

					If lZuc //type("_nZuc")== "N" // Variavel criada na rotina LOC05102.prw - frank 02/11/20
						If _nZuc > 0
							_lTemZUC := .T.
						Else
							_lTemZUC := .F.
						EndIf
					Else
						_lTemZUC := .F.
					EndIf

					// Frank 25/11/2020
					// antes vinha da nota de remessa
					cTesDv := cMV_LOC025 //SuperGetMV("MV_LOCX025",,"004")
					cTEs   := cTesDv

					// --> Realiza a Montagem de todos os itens
					aItens := {}
					aAdd( aItens, { "D1_COD"     , QRY->D2_COD     , Nil } )
					aAdd( aItens, { "D1_QUANT"   , FQX->FQX_QTD          , Nil } )
					aAdd( aItens, { "D1_VUNIT"   , QRY->D2_PRCVEN  , Nil } )
					aAdd( aItens, { "D1_TOTAL"   , FQX->FQX_QTD  * QRY->D2_PRCVEN   , Nil } ) 	 //	aAdd( aItens, { "D1_VALDESC" , SD2->D2_TOTAL , Nil } )

					aAdd( aItens, {"D1_LOTECTL"  , QRY->D2_LOTECTL  , NIL} )

					aAdd( aItens, { "D1_TES" 	 , cTesDv		   , Nil } )	 //	aAdd( aLinha, { "D1_CF"	     , cCfop         , Nil } )
					aAdd( aItens, { "D1_NFORI"   , cNFORI          , Nil } )
					aAdd( aItens, { "D1_SERIORI" , cSERIORI        , Nil } )
					aAdd( aItens, { "D1_ITEMORI" , cITEMORI        , Nil } )
					aAdd( aItens, { "D1_IDENTB6" , QRY->D2_IDENTB6 , Nil } )

					If FQX->(ColumnPos("FQX_OBSCCM")) > 0 .And. FQX->(ColumnPos("FQX_OBSCON")) > 0 .And. FQX->(ColumnPos("FQX_OBSFCM")) > 0 .And. FQX->(ColumnPos("FQX_OBSFIS")) > 0
						aAdd( aItens, { "D1_OBSCTIT" , FQX->FQX_OBSCCM , Nil } )
						aAdd( aItens, { "D1_OBSCONT" , FQX->FQX_OBSCON , Nil } )
						aAdd( aItens, { "D1_OBSFTIT" , FQX->FQX_OBSFCM , Nil } )
						aAdd( aItens, { "D1_OBSFISC" , FQX->FQX_OBSFIS , Nil } )
					EndIf

					aAdd( aItensNota, aItens)

					QRY->(dbSkip())
				Enddo
				QRY->(DbCloseArea())
			EndIf

			FQX->(dbSkip())
		EndDo

		If Len(aItensNota) > 0
			LOCA104GNF(,cCliente,cLoja,,FQW->FQW_NUM,lFormPropr, oSay)
		EndIf

	Else
		MsgAlert(STR0016+FQW->FQW_NUM+STR0015,STR0017)  //" não possue itens vinculados!" //"Romaneio " //"Atenção!"
		Return
	EndIf

Return

/*/{Protheus.doc} LOCA104GNF
Gera o Cabecalho do Documento de Retorno 
@type function
@version 25.10
@author Alexandre Circenis
@since 31/10/2025
@param lCliente, logical, Indica se usa o cliente
@param cCliente, character, Codigo do Cliente
@param cLoja, character, Codigo da Loja
@param cDocSF2, character, Codigo do Documento
@param cNumRom, character, Numero do Romaneio
@param lFormPropr, logical, Formulario Proprio (S/N)
@return variant, .T. para finalizar
/*/
Function LOCA104GNF(lCliente,cCliente,cLoja,cDocSF2,cNumRom,lFormPropr, oSay)
Local aArea      := GetArea()
Local aAreaSF2   := SF2->(GetArea())
Local aCab       := {}
Local cFormProp  := "N"
Local lFlagDev	 := SF2->(FieldPos("F2_FLAGDEV")) > 0  .And. GetNewPar("MV_FLAGDEV",.F.)

Local lLOCA11H   := EXISTBLOCK("LOCA11H")
Local nX
Local nPosNf
Local nPosNfSer
Local nQtdDev    := 0
Local cNotasProc := ''

Private _lErroNf := .F. // variavel que sofre alteracao no fonte MT103FIM
Private cRomaX
Private _nZUC    :=  1  // Para indicar que tem romaneio 

    
	Default lCliente := .F.
	Default cCliente := SF2->F2_CLIENTE
	Default cLoja    := SF2->F2_LOJA
	Default cDocSF2  := ""

	If Type("cTipo") == "U"
		Private cTipo := ""
	EndIf

	cRomaX := cNumRom // uso do cRomaX no ponto de entrada MT103FIM, a variavel foi criada como private no loc05102.prw Frank 29/10/20

	If !SF2->(Eof())
		//cDoc := GetSxeNum("SF1","F1_DOC")
		//ConfirmSx8()
		// [inicio] José Eulálio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulário quando for Formulário Próprio = Sim.

		If lFormPropr
			cDoc 		:= Space(TamSx3("F1_DOC")[1])
			cFormProp	:= "S"
		Else
			cDoc := strzero(0,TamSx3("F1_DOC")[1])
			SF1->(dbSetOrder(1))
			While .T.
				If SF1->(dbSeek(xFilial("SF1")+cDoc))
					cDoc := soma1(cDoc)
				Else
					Exit
				EndIf
			EndDo
		EndIf
		// [final] José Eulálio - 03/06/2022 - SIGALOC94-346 - #27421 - NF de Retorno Apresentar o formulário quando for Formulário Próprio = Sim.

		// Frank 12/11/20
		// a tes esta posicionada pela montagem dos itens
		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+cTesDv))
		_cTipo := "D"
		If SF4->F4_PODER3 == "D"
			_cTipo := "B"
		EndIF
		//_cTipo := "B"

		// --> Montagem do Cabecalho da Nota fiscal de Devolucao/Retorno.
		//aAdd( aCab , {"F1_DOC"      , cDoc/*CriaVar("F1_DOC",.F.)*/ , Nil} ) 	// Numero da NF      : Obrigatorio
		aAdd( aCab , {"F1_DOC"      , STRZERO(0,TAMSX3("D1_DOC")[1])/*CriaVar("F1_DOC",.F.)*/ , Nil} ) 	// Numero da NF      : Obrigatorio
		//aAdd( aCab , {"F1_SERIE"    , CriaVar("F1_SERIE",.F.)       , Nil} ) 	// Serie da NF       : Obrigatorio
		aAdd( aCab , {"F1_SERIE"    , STRZERO(0,TAMSX3("D1_SERIE")[1])       , Nil} ) 	// Serie da NF       : Obrigatorio
		aAdd( aCab , {"F1_TIPO"     , _cTipo                        , Nil} ) 	// Tipo da NF        : Obrigatorio
		aAdd( aCab , {"F1_FORNECE"  , cCliente                      , Nil} ) 	// Codigo Fornecedor : Obrigatorio
		aAdd( aCab , {"F1_LOJA"     , cLoja                         , Nil} ) 	// Loja Fornecedor   : Obrigatorio
		aAdd( aCab , {"F1_EMISSAO"  , dDataBase                     , Nil} ) 	// Emissao da NF     : Obrigatorio
		aAdd( aCab , {"F1_FORMUL"   , cFormProp                     , Nil} ) 	// Formulario
		aAdd( aCab , { "F1_ESPECIE" , Iif(Empty(CriaVar("F1_ESPECIE",.T.)),	PadR("SPED",Len(SF1->F1_ESPECIE)),CriaVar("F1_ESPECIE",.T.)), Nil } )  // Especie
		aAdd( aCab , { "F1_FRETE"   , 0                             , Nil} )
		aAdd( aCab , { "F1_SEGURO"  , 0                             , Nil} )
		aAdd( aCab , { "F1_DESPESA" , 0                             , Nil} )
		aAdd( aCab , { "F1_IT_ROMA" , cNumRom                       , Nil} )

		lForca := .F.
		IF lLOCA11H
			lFORCA := EXECBLOCK("LOCA11H",.T.,.T.,{})
		ENDIF

		oSay:SetText(STR0021)  //"Gerando a Nota Retorno ..."

		If cFilAnt <> FQW->FQW_FILREM .or. lForca
			cFilAux := cFilAnt
			nRecSM0 := SM0->(RECNO())
			cFilAnt := FQW->FQW_FILREM
			Mata103( aCab, aItensNota , 3 , .T.)
			cFilAnt := cFilAux
			SM0->(dbGoTo(nRecSM0))

		Else
			Mata103( aCab, aItensNota , 3 , .T.)

		EndIf

		/*If .f.  .and. ValGerNfe() 
			_lErroNF := .F.
		else
			_lErroNF := .T.
		EndIF
		*/
		If _lErroNF .or. len(aAsgrv) = 0
			MsgInfo(STR0018, STR0017) //"A nota de entrada não foi gerada." //"Atenção!"

		else

			SF1->(RecLock("SF1",.F.))
			SF1->F1_IT_ROMA := cNumRom
			SF1->(MsUnLock())


			MsgInfo(STR0019+alltrim(SF1->F1_DOC)+"-"+alltrim(SF1->F1_SERIE),STR0017) //"Nota de entrada gerada: " //"Atenção!"


			cDoc := SF1->F1_DOC

			FQW->(RecLock("FQW",.F.))
			FQW->FQW_STATUS := if (FQW->FQW_STATUS='2', '5','6' )
			FQW->FQW_NFRET  := SF1->F1_DOC
			FQW->FQW_SERRET := SF1->F1_SERIE
			FQW->FQW_TIPONF := SF1->F1_TIPO
			FQW->FQW_FORMUL := SF1->F1_FORMUL
			FQW->(MsUnLock())
			
			// --> Verifica se nao ha mais saldo para devolucao.
			If lFlagDev
				aAreaBkp := SF2->(GetArea())
				cNotasProc := ''
				for nX := 1 to len(aItensNota)
					nPosNf 	  := aScan(aItensNota[nX],{|x| AllTrim(x[1])=="D1_NFORI"})
					nPosNfSer := aScan(aItensNota[nX],{|x| AllTrim(x[1])=="D1_SERIORI"})
					if nPosNf > 0 .and. nPosNfSer > 0
						if !(aItensNota[nX][nPosNf][2] + aItensNota[nX][nPosNfSer][2] $ cNotasProc) // Anida não processada
							cNotasProc += aItensNota[nX][nPosNf][2] + aItensNota[nX][nPosNfSer][2] + " # "
							SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA
							if SF2->(MsSeek(fwxFilial("SF2") + aItensNota[nX][nPosNf][2] + aItensNota[nX][nPosNfSer][2] + cCliente + cLoja))

								nQtdDev :=0
								DbSelectArea("SD2")
								DbSetOrder(3)
								MsSeek(xFilial("SD2")+aItensNota[nX][nPosNf][2] + aItensNota[nX][nPosNfSer][2] + cCliente + cLoja)
								While !Eof() .And. D2_FILIAL  == xFilial("SD2");
										.And. D2_DOC     == aItensNota[nX][nPosNf][2];
										.And. D2_SERIE   == aItensNota[nX][nPosNfSer][2];
										.And. D2_CLIENTE == cCliente;
										.And. D2_LOJA    == cLoja

									//Verifica se possui Tes de Devolução amarrada
									DbSelectArea("SF4")
									DbSetOrder(1)
									If MsSeek(xFilial("SF4")+SD2->D2_TES)
										If !Empty(SF4->F4_TESDV)
											MsSeek(xFilial("SF4")+SF4->F4_TESDV)
											nQTDDEV:=nQTDDEV + SD2->D2_QUANT-SD2->D2_QTDEDEV
										EndIf
									EndIf
									SD2->(dbSkip())
								EndDo
							
								if nQtdDev = 0 // Não há saldo a Devolver
									if RecLock("SF2",.F.)
										SF2->F2_FLAGDEV := "1"
										SF2->(MsUnlock())
									endif
								endif
							endif
						EndIf
					endif
				next nX
				RestArea(aAreaBkp)
			EndIf
		EndIf 
	endif

	// --> Restaura a entrada da rotina.
	RestArea(aAreaSF2)
	RestArea(aArea)

Return(.T.)

/*/{Protheus.doc} Loca104GID
Retorna .T. se existem linhas na FQX com contagem divergente ou sem contagem
@type function
@version 25.10
@author Alexandre Circenis
@since 30/12/2025
@return variant, .T. se faltam dados para retornar
/*/
Function Loca104GID() 
Local lRet := .F.
Local aAreaFQW := GetArea()
Local cQuery   := ""
Local aParam := {}

	cQuery += "SELECT FQX_STATUS"
	cQuery += " FROM "+REtSqlName("FQX")
	cQuery += " WHERE FQX_FILIAL = '"+xFilial("FQX")+"'"
	cQuery += " AND FQX_NUM = ?"
	Aadd(aParam, FQW->FQW_NUM)
	cQuery += " AND FQX_STATUS <> '3'" 
	cQuery += " AND EXISTS ( SELECT B1_COD FROM "+ RetSqlName("SB1") + " SB1 "
	cQuery +=          " INNER JOIN "+ RetSqlName("SBM") + " SBM ON BM_FILIAL = '"+xFilial("SBM")+"' and BM_GRUPO = B1_GRUPO and BM_XACESS = '3' and SBM.D_E_L_E_T_ = ' ' "
	cQuery +=          " WHERE B1_FILIAL = '"+xFilial('SB1')+"' and B1_COD = FQX_PROD and SB1.D_E_L_E_T_ = ' ')" 

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery,"FQXTRB",,,aParam)

	lRet := !(FQXTRB->(Eof()))	

	RestArea(aAreaFQW)

Return lRet
