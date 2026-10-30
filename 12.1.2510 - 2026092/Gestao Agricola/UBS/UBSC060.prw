#INCLUDE "UBSC060.CH"
#INCLUDE "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "TOPCONN.CH"

/*/{Protheus.doc} UBSC060
UBS - Tela para seleção de lotes para impressão do Termo de Conformidade de semente 
@type function
@version P12
@author Daniel Silveira / claudineia.reinert
@since 10/11/2023
/*/
Function UBSC060()
    Private _cPerg := "UBSC060"

	If UBSC060DIC()
		If Pergunte(_cPerg,.T.)
			UBSC060TSL()
		endif
	Else
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	EndIf

Return 

/*/{Protheus.doc} user function UBSC060TSL
Função para montar o markbrowse com os lotes elegíveis para o termo de conformidade
@type Function
@author Daniel Silveira / claudineia.reinert
@since 10/11/2023
/*/
Static Function UBSC060TSL()
    Local nx		:= 0
	Local aColumns	:= {}
	Local aCposTmp	:= {}
	Local aIndex	:= {}
	Local aFldfilter:= {}
	Local acPosBrw  := {}
	Local aRetTRB 	:= {} 
	Local aColumTMP := ""		
	Local cTrabTMP 	:= ""

	Private _cAliasTMP 	:= nil
	Private _aMarcados 	:= {}
	Private _oBrwMrk	:= nil

	aCposTmp :={{"MARK" 			, "C" 					,2						 ,0						  	,""							,"@!"},;
				{"LOT_FILIAL"      , TamSX3("NP9_FILIAL")[3], TamSX3("NP9_FILIAL")[1], TamSX3("NP9_FILIAL")[2]	,RetTitle( "NP9_FILIAL" )	,PesqPict("NP9","NP9_FILIAL")},;
				{"LOT_CODSAF"      , TamSX3("NP9_CODSAF")[3], TamSX3("NP9_CODSAF")[1], TamSX3("NP9_CODSAF")[2]	,RetTitle( "NP9_CODSAF" )	,PesqPict("NP9","NP9_CODSAF")},;
				{"LOT_PROD"        , TamSX3("NP9_PROD")[3]  , TamSX3("NP9_PROD")[1]  , TamSX3("NP9_PROD")[2]	,RetTitle( "NP9_PROD" )		,PesqPict("NP9","NP9_PROD")},;
				{"LOT_PRDDES"      , TamSX3("NP9_PRDDES")[3], TamSX3("NP9_PRDDES")[1], TamSX3("NP9_PRDDES")[2]	,RetTitle( "NP9_PRDDES" )	,PesqPict("NP9","NP9_PRDDES")},;
				{"LOT_LOTE"        , TamSX3("NP9_LOTE")[3]  , TamSX3("NP9_LOTE")[1]  , TamSX3("NP9_LOTE")[2]	,RetTitle( "NP9_LOTE" )		,PesqPict("NP9","NP9_LOTE")},;
				{"LOT_NBOLET"      , TamSX3("NPX_RESTXT")[3], TamSX3("NPX_RESTXT")[1], TamSX3("NPX_RESTXT")[2]	,STR0008					,"@!"}}

	aIndex := {"LOT_FILIAL+LOT_CODSAF+LOT_NBOLET+LOT_LOTE","LOT_FILIAL+LOT_CODSAF+LOT_LOTE+LOT_NBOLET"}

	//--- Criação das tabelas temporárias ---//
	aRetTRB := AGRCRIATRB( , aCposTmp, aIndex, FunName(), .T. )//oga250f
	 
	cTrabTMP 	:= aRetTRB[3] //Nome do arquivo temporário 
	_cAliasTMP   := aRetTRB[4] //Nome do alias do arquivo temporario
	aColumTMP 	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picture

	aIndex	:= AGRINDICONS(aIndex , aColumTMP  )	

	aFldfilter := AGRITEMCBRW(aColumTMP)

	fDadosTela() //monta os dados no alias _cAliasTMP que será apresentado em tela

	acPosBrw := {{"LOT_FILIAL", RetTitle( "NP9_FILIAL" )	, "NP9_FILIAL"},;
	     		 {"LOT_NBOLET" , STR0008   	 				, "NPX_RESTXT"},;
				 {"LOT_LOTE"   , RetTitle( "NP9_LOTE" )		, "NP9_LOTE"  },;
                 {"LOT_PROD"   , RetTitle( "NP9_PROD" )		, "NP9_PROD"  },;
                 {"LOT_PRDDES" , RetTitle( "NP9_PRDDES" )	, "NP9_PRDDES"},;
                 {"LOT_CODSAF" , RetTitle( "NP9_CODSAF" )	, "NP9_CODSAF"}}
	
	For nx := 1 To Len(acPosBRW)

		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+acPosBRW[ nX,1 ]+"}"))
		aColumns[Len(aColumns)]:SetTitle( acPosBRW[nX,2] )
		aColumns[Len(aColumns)]:SetSize(TamSx3(acPosBRW[nX,3])[1])
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(acPosBRW[nX,3])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(acPosBRW[nX,3]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(acPosBRW[nX,3])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
	Next nx

	SetKey( VK_F12, { || UBSC060F12() } )

	_oBrwMrk := FWMarkBrowse():New()	
	_oBrwMrk:SetAlias(_cAliasTMP)
	_oBrwMrk:SetColumns(aColumns)
	_oBrwMrk:SetFieldMark("MARK")
	_oBrwMrk:SetCustomMarkRec({||fmarcar()})
	_oBrwMrk:SetDescription(STR0001) //###Geração Termo de Conformidade - Lotes Elegíveis
	_oBrwMrk:SetFieldFilter( aFldfilter )
	_oBrwMrk:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	_oBrwMrk:DisableConfig()	// Desabilita a opcao de configuracao do MarkBrowse
	_oBrwMrk:DisableDetails()	// Desabilita a exibicao dos detalhes do MarkBrowse
	_oBrwMrk:DisableReport()	// Desabilita a opcao de imprimir
	_oBrwMrk:SetSeek( ,aIndex)	
	_oBrwMrk:SetUseFilter(.T.)	

	_oBrwMrk:SetMenuDef( "UBSC060" )
	
	_oBrwMrk:Activate()
	//--- Apaga as tabelas temporárias ---//
	AGRDELETRB( _cAliasTMP, cTrabTMP )  
Return 

/*/{Protheus.doc} static function MenuDef
Função de menu 
@type  Function
@author claudineia.reinert
@since 10/11/2023
/*/
Static Function MenuDef()
	Local aRotina := {} 

	aAdd(aRotina, {STR0003, "UBSC60PRC()", 0, 3, 0, Nil})  //"Gerar Termo"

Return aRotina

/*/{Protheus.doc} static function fMarcar
Função para marcar o markbrowse
@type  Function
@author Daniel Silveira / claudineia.reinert
@since 10/11/2023
/*/
Static Function fMarcar(  )

    Local nPosBol 	:= 0
    Local nPosProd 	:= 0
	Local lCodSeq  	:= SUPERGETMV( "MV_AGRS004", .F., .T. ) //define se o numero do termo será sequencial, padrão .T. - IA_TCSEQUE
	
	If ( !_oBrwMrk:IsMark() )
		//validação apra marcar apenas boletins iguais
		nPosBol := aScan(_aMarcados, {|x| x[1] == AllTrim((_oBrwMrk:Alias())->LOT_NBOLET)})
		nPosProd := aScan(_aMarcados, {|x| x[3] == AllTrim((_oBrwMrk:Alias())->LOT_PROD)})
		If nPosProd == 0 .AND. Len(_aMarcados) > 0 
			FwAlertWarning(STR0015,STR0004) //####"Somente é permitido marcar lotes com mesmo código de produto.", "Atenção"
		ElseIf nPosBol == 0 .AND. Len(_aMarcados) > 0 .and. !lCodSeq .and. !EXISTBLOCK("UBSC60NR")
			FwAlertWarning(STR0005,STR0004) //####"Somente é permitido marcar lotes com mesmo nº. de Botelim.", "Atenção"
		Else
			RecLock(_oBrwMrk:Alias(),.F.)
			(_oBrwMrk:Alias())->MARK  := _oBrwMrk:Mark()
			(_oBrwMrk:Alias())->(MsUnLock()) 
			Aadd(_aMarcados, {AllTrim((_oBrwMrk:Alias())->LOT_NBOLET), AllTrim((_oBrwMrk:Alias())->LOT_LOTE),AllTrim((_oBrwMrk:Alias())->LOT_PROD)})
		EndIF
	else
		RecLock(_oBrwMrk:Alias(),.F.)
		(_oBrwMrk:Alias())->MARK  := ""
		(_oBrwMrk:Alias())->(MsUnLock())
		//validação da desmarcação
		adel(_aMarcados, 1)
		asize(_aMarcados, len(_aMarcados) - 1)
	endif
Return( .T. )

/*/{Protheus.doc} static function UBSC60PRC
Processar os registros para gerar a impressão
@type  Function
@author Daniel Silveira / claudineia.reinert
@since 10/11/2023
/*/
Function UBSC60PRC()
	Local lRetorno  := .F. //padrão .F.
	Local aAux := {}
	Local nI	:= 0
	Local cCodTerm := "" 
	Local lCodSeq  := SUPERGETMV( "MV_AGRS004", .F., .T. ) //define se o numero do termo será sequencial, padrão .T. - IA_TCSEQUE
	Local cTerSafra := MV_PAR01
	Local cTerCultr := MV_PAR02
	Local cTerCtvar := MV_PAR03
	Local cTerCateg := MV_PAR04 
	Local cTerResp  := MV_PAR07
	Local cCodLab 	:= MV_PAR08
	Local cLojaLab 	:= MV_PAR09
	Local aDados 	:= {}
	Local cTipoTerm := "N" // N=Normal - termo de conformidade
	
	//## Variaveis para a função de impressão - caso mudar as posições abaixo ajustar tambem no fonte UBSA060 ##
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

	If Empty(MV_PAR07) .OR. Empty(MV_PAR08) .OR. Empty(MV_PAR09)			
		AgrHelp(STR0009,STR0010,STR0011) //####"AJUDA","Dados Obrigatórios não informados.","Informe o responsavel técnico, o laboratório e loja do laboratório no pergunte da tela(F12).")
		Return .F.
	EndIf

	(_oBrwMrk:Alias())->(DbGotop())

	while !(_oBrwMrk:Alias())->(Eof())
 
		if _oBrwMrk:IsMark()
			aAux := {}	
			aAux := UBSC060BDL((_oBrwMrk:Alias())->LOT_CODSAF , (_oBrwMrk:Alias())->LOT_LOTE, (_oBrwMrk:Alias())->LOT_PROD)
			If LEN(aAux) > 0 
				aadd(aDados, aAux)
			EndIf
		endif
		(_oBrwMrk:Alias())->(dbSkip())

	enddo
		
	if len(aDados) > 0
		cId := fNextCod(cTerSafra)
		IF EXISTBLOCK("UBSC60NR")
			cCodTerm := ExecBlock("UBSC60NR")
		else
			IF lCodSeq
				cCodTerm := cId + "/" + Year2Str(Date())
			else
				cCodTerm := AllTrim(aDados[1][_nPosNume]) //o número do termo será o mesmo número do boletim
			endif
		endif

		If Empty(cCodTerm)
			AGRHELP(STR0009,STR0013,STR0014) //###"Não foi possivel determinar o numero do termo de conformidade.","Favor rever o parametro MV_AGRS004."
			Return .F.
		EndIf

		DBSELECTAREA("NNN")
		NNN->(DBSETORDER( 1 ))
		if .NOT.(NNN->(DbSeek(cFilAnt + PadR(cCodTerm,TamSX3("NNN_NUM")[1]," ") + PadR(cTerSafra,TamSX3("NNN_CODSAF")[1]," ") + PadR(cTipoTerm,TamSX3("NNN_TIPO")[1]," ") ))) //se não tem inclui
			BEGIN TRANSACTION	
				If AGRGRAVAHIS(STR0012,"NNN",cFilAnt+PadR(cCodTerm,TamSX3("NNN_NUM")[1]," ")+PadR(cTerSafra,TamSX3("NNN_CODSAF")[1]," ")+PadR(cTipoTerm,TamSX3("NNN_TIPO")[1]," "),"3") = 1 //####"Confirma a geração do termo de conformidade?"
					lRetorno := .T.
					RECLOCK("NNN", .T.)
					NNN->NNN_FILIAL := cFilAnt   
					NNN->NNN_NUM    := cCodTerm
					NNN->NNN_DATA   := DDATABASE
					NNN->NNN_RESTEC := cTerResp
					NNN->NNN_CULTRA := cTerCultr
					NNN->NNN_CTVAR  := cTerCtvar	
					NNN->NNN_CODSAF := cTerSafra
					NNN->NNN_CATEG	:= cTerCateg
					NNN->NNN_CODPRO	:= aDados[1][_nPosProd]
					NNN->NNN_ID		:= cId
					NNN->NNN_CODLA	:= cCodLab
					NNN->NNN_LJLAB	:= cLojaLab
					NNN->NNN_TIPO	:= cTipoTerm
					NNN->(MSUNLOCK())
					NNN->(DBCLOSEAREA())				

					DBSELECTAREA("NP9")
					NP9->(DBSETORDER(1)) 				
					for nI:=1 to len(aDados)
						if NP9->(DbSeek(xFilial("NP9") + aDados[ni][_nPosSafr] + aDados[ni][_nPosProd] + aDados[ni][_nPosLote] ))
							RecLock("NP9", .F.)
							NP9->NP9_NTERMC := cCodTerm	
							NP9->NP9_TIPOTE := cTipoTerm
							NP9->(MSUNLOCK())
						endif
					next nI			
					NP9->(DBCLOSEAREA())

				Else
					lRetorno := .F.
				EndIF
			End TRANSACTION
		Else
			lRetorno := .F.
			AGRHELP(STR0009,STR0016,STR0017) //##"Numero do termo de conformidade já existente."#"Favor verificar a forma de geração da numeração do termo de conformidade."
		EndIf
		
		If lRetorno
			FWMsgRun(, {|| UBSC060A(aDados,cCodTerm, cTerResp, cTerSafra, cTerCultr , cTerCtvar, cTerCateg, cCodLab, cLojaLab) }, STR0007+cCodTerm, STR0006 ) //###"Gerando Termo de Conformidade", "Processando..."
			fRefresh() //refresh browser
		EndIf
	
	endif
	
Return lRetorno

/*/{Protheus.doc} UBSC060BDL
Busca as informações dos lotes para impressão
@type function
@version P12
@author claudineia.reinert
@since 23/11/2023
@param cSafra, character, codigo da safra
@param cLote, character, codigo do lote de semente
@param cProduto, character, codigo do produto
@return array, array com os dados do lote para impressão
/*/
Function UBSC060BDL(cSafra, cLote, cProduto)
	Local aRet 		:= {} 
	Local cAliasDad := GetNextAlias()
	Local dDataAux := nil
	Local cIdPurez 	:= SUPERGETMV( "MV_AGRS010", .F., "") //variável de tipo de análise que contém a pureza do lote - IA_VARPURE
	Local cIdGermi 	:= SUPERGETMV( "MV_AGRS011", .F., "") //variável de tipo de análise que contém a germinação do lote - IA_VARGERM
	Local cIdDuras 	:= SUPERGETMV( "MV_AGRS012", .F., "") //variável de tipo de análise que contém a quantidade de sementes duras - IA_VARDURA
	Local cIdBolte 	:= SUPERGETMV( "MV_AGRS008", .F., "") //variável de tipo de análise que contém o número do boletim - IA_VARBOLT
	Local cIdDataB 	:= SUPERGETMV( "MV_AGRS009", .F., "") //variável de tipo de análise que contém a data do boletim - IA_VARDTBL
	Local cIdDatViaG := SUPERGETMV( "MV_AGRS016", .F., "") //variável de tipo de análise que contém a data de germinação ou viabilidade técnica
	Local nVldTerC 	:= SUPERGETMV( "MV_AGRS005", .F., 0) //quantos meses vale o termo de conformidade - IA_VLDTERM
	Local cOutFator := SUPERGETMV( "MV_AGRS015", .F., "") //outros fatores
	Local aOFator	:= {}

	BEGINSQL alias cAliasDad
		select NP9_QUANT, NP9_PSMDEN, NPX_CODVA, NPX_RESTXT, NPX_RESDTA, NPX_RESNUM, NP9_PENE, NP9_PROD, NP9_CODSAF, NP9_PSMDSC, NP9_OBS
		from %Table:NP9% NP9
		inner join %Table:NPX% NPX ON NPX_FILIAL = NP9_FILIAL AND NPX_CODPRO = NP9_PROD AND NP9_LOTE = NPX_LOTE
		where NP9.%NotDel%	
		and NP9.NP9_FILIAL = %xFilial:NP9%
		and NP9.NP9_CODSAF = %Exp:cSafra%
		and NP9.NP9_PROD = %Exp:cProduto%
		and NP9.NP9_LOTE = %Exp:cLote%
		AND NPX.NPX_ATIVO = '1'
	endsql

	while !(cAliasDad)->(Eof())
		If LEN(aRet) = 0
			aRet := {"","","",0,0,0,"",nil,"","","","","",{}} //inicializa array que recebe as informações de lote
			aRet[_nPosLote] := cLote
			aRet[_nPosProd] := (cAliasDad)->NP9_PROD
			aRet[_nPosSafr] := (cAliasDad)->NP9_CODSAF
			aRet[_nPosQtde] := cValtochar((cAliasDad)->NP9_QUANT)
			aRet[_nPosPSMDEN] := cValtochar((cAliasDad)->NP9_PSMDEN)
			aRet[_nPosPSMDSC]  := cValtochar((cAliasDad)->NP9_PSMDSC)	
			aRet[_nPosObs]  := (cAliasDad)->NP9_OBS
		EndIf

		do CASE	
			case alltrim((cAliasDad)->NPX_CODVA) $ cIdBolte
				aRet[_nPosNume] := (cAliasDad)->NPX_RESTXT

			case alltrim((cAliasDad)->NPX_CODVA) $ cIdPurez
				aRet[_nPosPura] := cValtochar((cAliasDad)->NPX_RESNUM)

			case alltrim((cAliasDad)->NPX_CODVA) $ cIdDuras
				aRet[_nPosDura] := cValtochar((cAliasDad)->NPX_RESNUM)

			case alltrim((cAliasDad)->NPX_CODVA) $ cIdGermi
				aRet[_nPosGerm] := cValtochar((cAliasDad)->NPX_RESNUM )

			case alltrim((cAliasDad)->NPX_CODVA) $ cIdDataB
				aRet[_nPosData] := DTOC(stod((cAliasDad)->NPX_RESDTA))
			case alltrim((cAliasDad)->NPX_CODVA) $ cIdDatViaG
				dDataAux 	   := MonthSum(stod((cAliasDad)->NPX_RESDTA),nVldTerC)
				aRet[_nPosVali] := AGRMesAno(SUBSTR( DTOC(dDataAux), 4, 10) , 3) 
			case alltrim((cAliasDad)->NPX_CODVA) $ Alltrim(cOutFator) .and. !Empty(cOutFator)
				DbSelectArea("NPU")
				NPU->(dbSetOrder(2)) //NPU_FILIAL+NPU_CODVA
				If NPU->(dbSeek(FWxFilial("NPU",xFilial("NP9"))+alltrim((cAliasDad)->NPX_CODVA)))
					aadd(aOFator,{NPU->NPU_CODVA,NPU->NPU_DESVA,cValtochar((cAliasDad)->NPX_RESNUM)})					
					aRet[_nPosOFat] := aOFator //aqui pode repetir tendo varios array{{"UBS_00010","XYZ","1"},{"UBS_00010","ABC","41"}....}
				EndIf
		endcase

		(cAliasDad)->(DBSKIP())
	enddo

	(cAliasDad)->(DBCLOSEAREA())

Return aRet

/*/{Protheus.doc} fNextCod
função para retornar o próximo numero sequencial para o termo de acordo com o tipo do termo de safra
@type  Function
@author Daniel Silveira / claudineia.reinert
@since 10/11/2023
/*/
Static Function fNextCod(cCodSaf)
	Local cRet := ""
	Local cAliasNNN := GetNextAlias()

	BeginSQL alias cAliasNNN
		SELECT MAX(NNN_ID) NNN_ID
		FROM %TABLE:NNN% NNN
		WHERE NNN.%NotDel%
		AND NNN_FILIAL = %xFilial:NNN%
		AND NNN_CODSAF = %Exp:cCodSaf%
		AND NNN_TIPO = 'N'
	endsql
	// NNN_TIPO = 'N' --> N=Normal - termo de conformidade

	while !(cAliasNNN)->(Eof())	
		cRet := (cAliasNNN)->NNN_ID
		(cAliasNNN)->(Dbskip())
	enddo

	(cAliasNNN)->(DBCLOSEAREA())

	if EMPTY(cRet)
		cRet := soma1(Replicate("0",TamSx3('NNN_ID')[1]))
	else
		cRet := soma1(cRet)
	endif

Return cRet

/*/{Protheus.doc} fDadosTela
Inserindo/Atualizando registros na tabela temporária com os dados que será mostrados em tela para seleção dos lotes para o termo de conformidade
@type Function
@author Daniel Silveira / claudineia.reinert
@since 10/11/2023
/*/
static function fDadosTela()
	Local cAliasQRY := GetNextAlias()
	Local cVarBol  := SUPERGETMV( "MV_AGRS008", .F.,"") //Variável de tipo de análise(NPU_CODVA) que contém o número do boletim do lote de semente(UBS) - IA_VARBOLT
	Local dDataIni 	:= DToS(MV_PAR05)
	Local dDataFim 	:= DToS(MV_PAR06)

    BEGINSQL Alias cAliasQRY
        SELECT DISTINCT NP9_FILIAL, NP9_CODSAF, NP9_PROD, NP9_PRDDES, NP9_LOTE, NPX_RESTXT
		FROM %Table:NP9% NP9
        INNER JOIN %Table:NPX% NPX ON NPX_FILIAL = NP9_FILIAL AND NPX_LOTE = NP9_LOTE AND NPX_CODPRO=NP9_PROD  AND NPX_CODSAF=NP9_CODSAF
        WHERE NP9.%NotDel%
		AND NPX.%NotDel%
        AND NP9_FILIAL= %xFilial:NP9%        
		AND NP9_CODSAF = %Exp:alltrim(MV_PAR01)%
		AND NP9_CATEG = %Exp:alltrim(MV_PAR04)%
		AND NP9_CTVAR = %Exp:alltrim(MV_PAR03)%
		AND NP9_CULTRA = %Exp:alltrim(MV_PAR02)%
		AND NP9_DATA >= %Exp:dDataIni%
		AND NP9_DATA <= %Exp:dDataFim%
		AND NP9_NTERMC = ''
		AND NP9_TRATO = '2'
		AND NPX_ATIVO = '1'
		AND NPX_CODVA = %Exp:cVarBol%
        AND NPX_RESTXT <> '  '		
        ORDER BY NPX_RESTXT 
    ENDSQL

	(cAliasQRY)->(dbGoTop())
	//inserindo registros na tabela temporária
	While (cAliasQRY)->(!Eof())

		DbSelectArea(_cAliasTMP)		

		IF  RecLock(_cAliasTMP, .t.)
            (_cAliasTMP)->MARK  		:= " "
            (_cAliasTMP)->LOT_FILIAL	:= (cAliasQry)->NP9_FILIAL
            (_cAliasTMP)->LOT_CODSAF := (cAliasQry)->NP9_CODSAF
            (_cAliasTMP)->LOT_PROD   := (cAliasQry)->NP9_PROD
            (_cAliasTMP)->LOT_PRDDES := (cAliasQry)->NP9_PRDDES
            (_cAliasTMP)->LOT_LOTE   := (cAliasQry)->NP9_LOTE
            (_cAliasTMP)->LOT_NBOLET := (cAliasQry)->NPX_RESTXT
			(_cAliasTMP)->( Msunlock() )
		EndIF

		(cAliasQRY)->(dbSkip())
	EndDo

	(cAliasQRY)->(DbCloseArea())
	(_cAliasTMP)->( dbGoTop() )
return

/*/{Protheus.doc} fRefresh
Atualiza as informações do Browser - REFRESH dos dados
@type  Function
@author Daniel Silveira / claudineia.reinert
@since 10/11/2023
/*/
static function fRefresh()
	_aMarcados := {}
	//--- Apaga conteúdo anterior da tabela temporária para recriar ---//
	If Select( _cAliasTMP ) > 0
        DbSelectArea( _cAliasTMP )
        Zap
    Endif  
	_oBrwMrk:Refresh()
	fDadosTela() //refaz os dados da tela recriando os dados na tabela temporaria
	_oBrwMrk:Refresh()
	_oBrwMrk:GoTop(.T.)
Return 

/*/{Protheus.doc} UBSC060F12
Tecla para acionar o Pergunte e atualizar os dados conforme o filtro do pergunte
@type function
@version P12
@author claudineia.reinert
@since 11/13/2023
/*/
Function UBSC060F12()
	If !Pergunte(_cPerg, .T.)
		Return 
	EndIf
	fRefresh()
Return .T.

/*/{Protheus.doc} UBSC060DIC
Função para validar se existe tabelas e campos no dicionario 
@type function
@version P12
@author claudineia.reinert
@since 11/24/2023
@return Logical, valor logico 
/*/
Function UBSC060DIC()
	Local lRet := .T.
	
	DBSELECTAREA( "NP8" )
	If !TableInDic("NNN") .OR. NP8->(FieldPos("NP8_EMAIL")) = 0 .OR. NP8->(FieldPos("NP8_EST")) = 0
		lRet := .F.
	EndIf

Return lRet
