#INCLUDE "UBSA060.CH"
#INCLUDE "PROTHEUS.CH" 

/*/{Protheus.doc} UBSA060
Manutenção do termo de conformidade
@type function
@version  P12
@author Daniel Silveira / claudineia.reinert
@since 24/11/2023
/*/
Function UBSA060()
   	Local oMBrowse 		:= Nil
	Local cFiltroDef 	:= "NNN_TIPO == 'N'"

	If .not. UBSC060DIC()
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NNN" )
	oMBrowse:SetDescription( STR0001 ) //##"Manutenção Termo de Conformidade"
	oMBrowse:SetFilterDefault( cFiltroDef )
	oMBrowse:SetMenuDef( "UBSA060" )
	oMBrowse:DisableDetails()
	oMBrowse:SetAttach( .T. ) 
	oMBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Menu da rotina
@type function
@version  P12
@author claudineia.reinert
@since 24/11/2023
/*/
Static Function MenuDef()
	Local aRotina 	:= {}
	aAdd( aRotina, { STR0002   	, "UBSA060MNT"  	, 0, 2, 0, Nil } ) //"Manutenção"
	aAdd( aRotina, { STR0003    , "UBSA060IMP"  	, 0, 2, 0, Nil } ) //"Imprimir Termo"
	aAdd( aRotina, { STR0004	, "UBSA060EXC"  	, 0, 5, 0, Nil } ) //"Excluir Termo"
	aAdd( aRotina, { STR0005   	, "UBSA060HIS"      , 0, 7, 0, Nil } ) //"Histórico"  	
	
Return( aRotina )

/*/{Protheus.doc} UBSA060EXC
Função para Excluir o termo de conformidade
@type function
@version  P12
@author Daniel Silveira / claudineia.reinert
@since 23/11/2023
/*/
Function UBSA060EXC()

    Local cQryExc := GetNextAlias()

    If AGRGRAVAHIS(STR0009 + alltrim(NNN->NNN_NUM) + " ?","NNN",cFilAnt+NNN->NNN_NUM+NNN->NNN_CODSAF+NNN->NNN_TIPO,"5") = 1 //##"Confirma a exclusão do termo de conformidade "
		

        BEGINSQL Alias cQryExc
            select NP9_FILIAL, NP9_CODSAF, NP9_PROD, NP9_LOTE, NP9_TIPOTE 
            from %Table:NP9% NP9
            where NP9.D_E_L_E_T_=' ' 
            AND NP9_FILIAL= %xFilial:NP9%
            AND NP9_CODSAF = %Exp:NNN->NNN_CODSAF%
            AND NP9_NTERMC = %Exp:NNN->NNN_NUM%
            AND NP9_PROD   = %Exp:NNN->NNN_CODPRO%
			AND NP9_TIPOTE = %Exp:NNN->NNN_TIPO%			
        ENDSQL
		
	    BEGIN TRANSACTION
			DbSelectArea("NP9")
			NP9->(DBSETORDER(1))
			while !(cQryExc)->(Eof())

				If NP9->(DBSEEK( xFilial("NP9") +(cQryExc)->NP9_CODSAF + (cQryExc)->NP9_PROD + (cQryExc)->NP9_LOTE))
					Reclock("NP9", .F.)
					NP9->NP9_NTERMC := ""
					NP9->NP9_TIPOTE := ""
					NP9->(MsUnLock())
				endif
				(cQryExc)->(DbSkip())

			enddo
			NP9->(DBCLOSEAREA())

			Reclock("NNN", .F.)
			DbDelete()
			MsUnlock()
		end TRANSACTION
		FwAlertSucess(STR0011) //##"Termo excluído com Sucesso."
    ENDIF

Return()

/*/{Protheus.doc} UBSA060IMP
 	Função para buscar os dados e realizar a reimpressão do termo de conformidade
    @type  Function
    @author Daniel Silveira
    @since 21/02/2023
/*/
Function UBSA060IMP()
	Local aAux := {}
	Local aDados := {}
    Local cAliasTer := GetNextAlias()
    Local cVarBol  := SUPERGETMV( "MV_AGRS008", .F.,"")
	Local cCodTerm  := NNN->NNN_NUM
	Local cTerSafra := NNN->NNN_CODSAF
	Local cTerCultr := NNN->NNN_CULTRA
	Local cTerCtvar := NNN->NNN_CTVAR
	Local cTerCateg := NNN->NNN_CATEG
	Local cTerResp  := NNN->NNN_RESTEC
	Local cCodLab   := NNN->NNN_CODLA
	Local cLojaLab  := NNN->NNN_LJLAB
	Local dDataTerm	:= NNN->NNN_DATA
	Local cTerProd	:= NNN->NNN_CODPRO

	//## Variaveis para a função de impressão - caso mudar as posições abaixo avaliar ajuste tambem no fonte UBSC060 ##
	Private _nPosLote := 1
	Private _nPosProd := 2
	Private _nPosSafr := 3
	Private _nPosQtde := 4 //qtd lote NP9
	Private _nPosPSMDEN := 5 //Peso Medio Ensaque       
	Private _nPosPSMDSC  := 6 //Peso de Mil Sementes     
	Private _nPosNume := 7 //numero boletim
	Private _nPosData := 8 //data analise
	Private _nPosPura := 9 
	Private _nPosGerm := 10
	Private _nPosDura := 11	
	Private _nPosVali := 12 // DATA VALIDADE caracter	
	Private _nPosObs	 := 13 //NP9_OBS
	Private _nPosOFat := 14 //OUTROS FATORES
		
    BEGINSQL Alias cAliasTer
        SELECT distinct NP9_FILIAL, NP9_CODSAF, NP9_PROD, NP9_PRDDES, NP9_LOTE, NPX_RESTXT 
		FROM %Table:NP9% NP9
        INNER JOIN %TABLE:NPX% NPX ON NPX_FILIAL = NP9_FILIAL AND NPX_LOTE = NP9_LOTE AND NPX_CODPRO=NP9_PROD AND NPX_CODSAF = NP9_CODSAF
        WHERE NP9.D_E_L_E_T_ = ' ' 
		AND NPX.D_E_L_E_T_ = ' ' 
        AND NP9_FILIAL= %xFilial:NP9%
		AND NP9_CODSAF = %Exp:cTerSafra%
		AND NP9.NP9_PROD = %Exp:cTerProd%
		AND NP9_NTERMC = %Exp:cCodTerm%		
        AND NPX_CODVA = %Exp:Alltrim(cVarBol)%		
		AND NPX_ATIVO = '1'
        ORDER BY NPX_RESTXT 
    ENDSQL

	while !(cAliasTer)->(Eof())
		aAux := {}	
		aAux := UBSC060BDL((cAliasTer)->NP9_CODSAF , (cAliasTer)->NP9_LOTE, (cAliasTer)->NP9_PROD)
		If LEN(aAux) > 0 
			aadd(aDados, aAux)
		EndIf
		(cAliasTer)->(dbSkip())
	enddo
	if len(aDados) > 0
  		FWMsgRun(, {|| UBSC060A(aDados,cCodTerm, cTerResp, cTerSafra, cTerCultr, cTerCtvar, cTerCateg, cCodLab, cLojaLab, dDataTerm) }, "Gerando Termo de Conformidade", "Processando...")
	endif
return .T.

/*/{Protheus.doc} UBSA060MNT
 	Função para remover lotes do termo de conformidade
    @type  Function
    @author Daniel Silveira
    @since 21/02/2023
/*/
Function UBSA060MNT()
    Local nx
	Local aColumns	:= {}
	Local aCposTmp	:= {}
	Local aIndex	:= {}
	Local aFldfilter:= {}
	Local acPosBrw  := {}
	Local lMarkAll	:= .f.
	
	Private _oMrkBrw := nil
	Private _cAliasTMP := GetNextAlias()
	Private _nContAlias	:= 0 //armazena o numero de registros do alias da tela
	Private _nContMKMNT	:= 0 //armazena o numero de registros marcados no browser
    
	aCposTmp :={{"MARK" , 'C' ,2,1},;
	{"LOT_FILIAL"      , TamSX3("NP9_FILIAL")[3], TamSX3("NP9_FILIAL")[1], TamSX3("NP9_FILIAL")[2]},;
	{"LOT_CODSAF"      , TamSX3("NP9_CODSAF")[3], TamSX3("NP9_CODSAF")[1], TamSX3("NP9_CODSAF")[2]},;
	{"LOT_PROD"        , TamSX3("NP9_PROD")[3]  , TamSX3("NP9_PROD")[1]  , TamSX3("NP9_PROD")[2]},;
	{"LOT_PRDDES"      , TamSX3("NP9_PRDDES")[3], TamSX3("NP9_PRDDES")[1], TamSX3("NP9_PRDDES")[2]},;
	{"LOT_LOTE"        , TamSX3("NP9_LOTE")[3]  , TamSX3("NP9_LOTE")[1]  , TamSX3("NP9_LOTE")[2]},;
	{"LOT_RESTXT"      , TamSX3("NPX_RESTXT")[3], TamSX3("NPX_RESTXT")[1], TamSX3("NPX_RESTXT")[2]}}

	aIndex := {}
	aadd(aIndex,{"LOT_FILIAL","LOT_CODSAF", "LOT_RESTXT", "LOT_LOTE"}) 

	oTempTable:= FWTemporaryTable():New( _cAliasTMP )	// Cria o objeto da tabela tempor?ia
	oTempTable:SetFields(aCposTmp)						// Informa a estrutura da tabela tempor?ia
	For nx := 1 to Len (aIndex)
		oTempTable:AddIndex( cValtochar(nX),aIndex[nX] )// Atribui o ?dice ?tabela tempor?ia
	next nX
	oTempTable:Create()									// Cria a tabela tempor?ia

	aTmpStruct := (_cAliasTMP )->( DbStruct() )   //Pego Strutura do arquivo temporario

	fDadosTMNT() //monta os dados no alias _cAliasTMP que será apresentado em tela

	acPosBrw := {{"LOT_FILIAL", "Filial"    , "NP9_FILIAL"},;
	     		{"LOT_RESTXT" , "Boletim"   , "NPX_RESTXT"},;
				{"LOT_LOTE"   , "Lote"      , "NP9_LOTE"  },;
                {"LOT_PROD"   , "Produto"   , "NP9_PROD"  },;
                {"LOT_PRDDES" , "Descrição" , "NP9_PRDDES"},;
                {"LOT_CODSAF" , "Cod. Safra", "NP9_CODSAF"}}

	For nx := 1 To Len(acPosBRW)

		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+acPosBRW[ nX,1 ]+"}"))

		cTitle := AllTrim(RetTitle(acPosBRW[nX,3]))

		aColumns[Len(aColumns)]:SetTitle( cTitle )
		aColumns[Len(aColumns)]:SetSize(TamSx3(acPosBRW[nX,3])[1])
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(acPosBRW[nX,3])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(acPosBRW[nX,3]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(acPosBRW[nX,3])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
	Next nx

	(_cAliasTMP)->( dbGoTop() )
	For nX:= 1 to len(aCposBRW)
		aAdd(aFldfilter, {ALLTRIM(aCposBRW[nx,1]), Alltrim(RetTitle(acPosBRW[nX,3])),TamSX3(aCposBRW[Nx,3])[3], TamSX3(aCposBRW[Nx,3])[2],TamSX3(aCposBRW[Nx,3])[1],X3PICTURE(acPosBRW[nX,3] )})
	nExt nX

	_oMrkBrw:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	_oMrkBrw:SetAlias(_cAliasTMP)
	_oMrkBrw:SetDescription( STR0006+NNN->NNN_NUM ) //"Manutenção Termo "
	_oMrkBrw:SetColumns(aColumns)
	_oMrkBrw:SetFieldMark("MARK")	// Define o campo utilizado para a marcacao
	_oMrkBrw:SetCustomMarkRec({||fmarcar( _oMrkBrw )})
	_oMrkBrw:bAllMark := { ||SetMarkAll(_oMrkBrw, lMarkAll := ! lMarkAll ), _oMrkBrw:Refresh(.T.)    }
	_oMrkBrw:SetFieldFilter( aFldfilter )
	_oMrkBrw:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	_oMrkBrw:DisableConfig()	// Desabilita a opcao de configuracao do MarkBrowse
	_oMrkBrw:DisableDetails()	// Desabilita a exibicao dos detalhes do MarkBrowse
	_oMrkBrw:DisableReport()	// Desabilita a opcao de imprimir
	_oMrkBrw:SetMenuDef( "" )
	_oMrkBrw:AddButton(STR0007,{|| CloseBrowse() },,9,0) //##"Sair"
	_oMrkBrw:AddButton(STR0008,{|| fProcDelLt(@_oMrkBrw) },,9,0) //##"Remover Lotes"
	_oMrkBrw:Activate()
return

/*/{Protheus.doc} static function fMarcar
Função para marcar um registro do markbrowse
@type  Function
@author Daniel Silveira
@since 30/01/2023
/*/
Static Function fMarcar( oMrkBrowse )
	Local aAreaAtu	:= GetArea()

	If ( !oMrkBrowse:IsMark() )
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->MARK  := oMrkBrowse:Mark()
		(oMrkBrowse:Alias())->(MsUnLock())
		_nContMKMNT += 1
	else
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->MARK  := ""
		(oMrkBrowse:Alias())->(MsUnLock())
		_nContMKMNT -= 1
	endif
	RestArea( aAreaAtu )
Return( .T. )

/*/{Protheus.doc} static function SetMarkAll
Função para marcar todos os itens do markbrowse
@type  Function
@author Daniel Silveira
@since 30/01/2023
/*/
Static Function SetMarkAll(oMrkBrowse,lMarcar )

	(oMrkBrowse:Alias())->( DbGotop() )
	While !( oMrkBrowse:Alias() )->( Eof() )

		fMarcar( oMrkBrowse)

		(oMrkBrowse:Alias())->(DbSkip() )

	EndDo

Return .T.

/*/{Protheus.doc} fDadosTMNT
busca e gera os registros na tabela temporária _cAliasTMP com os dados que será mostrados em tela para manutenção dos lotes vinculados ao termo de conformidade
@type function
@version  P12
@author claudineia.reinert
@since 23/11/2023
/*/
static function fDadosTMNT()
	Local cAliasQRY := GetNextAlias()
    Local cVarBol  := SUPERGETMV( "MV_AGRS008", .F.,"")

	_nContAlias := 0 //zera

	BEGINSQL Alias cAliasQRY
        SELECT distinct NP9_FILIAL, NP9_CODSAF, NP9_PROD, NP9_PRDDES, NP9_LOTE, NPX_RESTXT 
		FROM %Table:NP9% NP9
        INNER JOIN %Table:NPX% NPX ON NPX_FILIAL = NP9_FILIAL AND NPX_LOTE = NP9_LOTE AND NPX_CODPRO=NP9_PROD AND NPX_CODSAF=NP9_CODSAF
        WHERE NP9.D_E_L_E_T_=' ' 
        AND NP9_FILIAL= %xFilial:NP9%
        AND NP9_CODSAF = %Exp:NNN->NNN_CODSAF%
		AND NP9_PROD = %Exp:NNN->NNN_CODPRO%
		AND NP9_NTERMC = %Exp:NNN->NNN_NUM%
		AND NPX_ATIVO = '1'
		AND NPX_CODVA = %Exp:cVarBol%
		AND NPX_RESTXT <> '  '
        ORDER BY NPX_RESTXT 
    ENDSQL

	( cAliasQRY )->( dbGoTop() )

	While (cAliasQRY)->( !Eof() )

		DbSelectArea(_cAliasTMP)

		IF  RecLock(_cAliasTMP, .t.)
            (_cAliasTMP)->MARK  		:= " "
            (_cAliasTMP)->LOT_FILIAL	:= (cAliasQry)->NP9_FILIAL
            (_cAliasTMP)->LOT_CODSAF := (cAliasQry)->NP9_CODSAF
            (_cAliasTMP)->LOT_PROD   := (cAliasQry)->NP9_PROD
            (_cAliasTMP)->LOT_PRDDES := (cAliasQry)->NP9_PRDDES
            (_cAliasTMP)->LOT_LOTE   := (cAliasQry)->NP9_LOTE
            (_cAliasTMP)->LOT_RESTXT := (cAliasQry)->NPX_RESTXT
			(_cAliasTMP)->( Msunlock() )
			_nContAlias += 1
		EndIF

		(cAliasQRY)->(dbSkip())
	EndDo

	(cAliasQRY)->(dbclosearea())

Return 

/*/{Protheus.doc} fProcDelLt
Processar a exclusão do(s) lote(s) do termo de conformidade
caso seja removido todos os lotes o termo tambem será excluido
@type function
@version  P12
@author Daniel Silveira / claudineia.reinert
@since 23/11/2023
@param oMrkBrowse, object, objeto do FWMarkBrowse
/*/
Static Function fProcDelLt(oMrkBrowse)
    local cCodSaf 	:= ""
    local cCodPro 	:= ""
    local cCodLot 	:= ""
    Local lConfirm	:= .F.
	Local lDelTermo	:= .F. //se deve excluir o termo tambem
	Local cMsgLotes 	:= ""

	if _nContAlias = _nContMKMNT 
		//Ao remover todos os lotes o termo será excluido
		lConfirm := AGRGRAVAHIS(STR0009 + alltrim(NNN->NNN_NUM) + " ?","NNN",cFilAnt+NNN->NNN_NUM+NNN->NNN_CODSAF+NNN->NNN_TIPO,"5") = 1 //##"Confirma a exclusão do termo de conformidade "
		lDelTermo := .T.
	else
		cMsgLotes := STR0014+fTxLTRem(oMrkBrowse) + Chr(13) + Chr(10) //##"Lotes removidos: "
		lConfirm := AGRGRAVAHIS(STR0012,"NNN",xFilial("NNN")+NNN->NNN_NUM+NNN->NNN_CODSAF+NNN->NNN_TIPO,"4",,cMsgLotes) = 1 //##"Confirma a remoção do(s) lote(s) selecionado(s) ?"
	EndIf
	
	If lConfirm //confirma exclusão
		Begin TRANSACTION
			
			dbSelectArea("NP9")
			NP9->(DBSETORDER(1)) 
			(oMrkBrowse:Alias())->( DbGotop() )
			while !(oMrkBrowse:Alias())->( Eof() )
				if oMrkBrowse:IsMark()
					cCodSaf := (oMrkBrowse:Alias())->LOT_CODSAF
					cCodPro := (oMrkBrowse:Alias())->LOT_PROD
					cCodLot := (oMrkBrowse:Alias())->LOT_LOTE
					if NP9->(dbSeek(xFilial('NP9') + cCodSaf + cCodPro + cCodLot))
						RECLOCK( "NP9", .F.)
						NP9->NP9_NTERMC := ""
						NP9->NP9_TIPOTE := ""
						NP9->(MSUNLOCK())
					endif
				endif

				(oMrkBrowse:Alias())->(dbSkip())
			enddo

			If lDelTermo //deleta termo de conformidade
				Reclock("NNN", .F.)
				DbDelete()
				MsUnlock()
			EndIf

		end TRANSACTION
		
		FwAlertSucess(STR0013) //##"Exclusão realizada com sucesso!"
		_nContMKMNT := 0 //reseta

		If lDelTermo
			CloseBrowse()
		else
			fMNTRefresh()
		EndIf
	EndIf

return 

/*/{Protheus.doc} fMNTRefresh
Atualiza as informações do Browser _oMrkBrw - REFRESH dos dados
@type  Function
@author Daniel Silveira / claudineia.reinert
@since 10/11/2023
/*/
static function fMNTRefresh()
	_nContMKMNT := 0 //reseta
	oTempTable:Zap()
	_oMrkBrw:Refresh()
	fDadosTMNT()
	_oMrkBrw:Refresh()
	_oMrkBrw:GoTop(.T.)
Return

/*/{Protheus.doc} UBSA060HIS
Mostra tela com o Historico do termo de conformidade
@type function
@version P12  
@author claudineia.reinert
@since 23/11/2023
/*/
Function UBSA060HIS()
	Local cChaveI := "NNN->("+Alltrim(AGRSEEKDIC("SIX","NNN",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("NNN",cChaveA)
Return

Static Function fTxLTRem(oMrkBrowse)
	Local cRet := ""
	(oMrkBrowse:Alias())->( DbGotop() )
	while !(oMrkBrowse:Alias())->( Eof() )
		if oMrkBrowse:IsMark()
			cRet += IIF(!Empty(cRet),"|","")
			cRet += (oMrkBrowse:Alias())->LOT_LOTE
		endif
		(oMrkBrowse:Alias())->(dbSkip())
	enddo
Return cRet





