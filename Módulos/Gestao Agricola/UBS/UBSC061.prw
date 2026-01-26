#INCLUDE "UBSC061.CH"
#INCLUDE "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "TOPCONN.CH"

/*/{Protheus.doc} UBSC061
UBS - Tela para seleção de lotes para impressão do Termo ADITIVO de Conformidade de semente 
@type function
@version P12
@author Daniel Silveira / claudineia.reinert
@since 29/11/2023
/*/
Function UBSC061()
    Private _cPerg := "UBSC061"

	If UBSC060DIC()
		If Pergunte(_cPerg,.T.)
			UBSC061TSL()
		endif
	Else
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	EndIf

Return 

/*/{Protheus.doc} user function UBSC061TSL
Função para montar o markbrowse com os lotes elegíveis para o termo aditivo de conformidade
@type Function
@author Daniel Silveira / claudineia.reinert
@since 29/11/2023
/*/
Static Function UBSC061TSL()
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

	aCposTmp :={{"MARK" 		, "C" 						,2							,0							, ""						, "@"},;
				{"LOT_FILIAL"   , TamSX3("NP9_FILIAL")[3]	, TamSX3("NP9_FILIAL")[1]	, TamSX3("NP9_FILIAL")[2]	, RetTitle( "NP9_FILIAL" )	,PesqPict("NP9","NP9_FILIAL")},;
				{"LOT_CODSAF"   , TamSX3("NP9_CODSAF")[3]	, TamSX3("NP9_CODSAF")[1]	, TamSX3("NP9_CODSAF")[2]	, RetTitle( "NP9_CODSAF" )	,PesqPict("NP9","NP9_CODSAF")},;
				{"LOT_PROD"     , TamSX3("NP9_PROD")[3]  	, TamSX3("NP9_PROD")[1]  	, TamSX3("NP9_PROD")[2]		, RetTitle( "NP9_PROD" )	,PesqPict("NP9","NP9_PROD")},;
				{"LOT_PRDDES"   , TamSX3("NP9_PRDDES")[3]	, TamSX3("NP9_PRDDES")[1]	, TamSX3("NP9_PRDDES")[2]	, RetTitle( "NP9_PRDDES" )	,PesqPict("NP9","NP9_PRDDES")},;
				{"LOT_LOTE"     , TamSX3("NP9_LOTE")[3]  	, TamSX3("NP9_LOTE")[1]  	, TamSX3("NP9_LOTE")[2]		, RetTitle( "NP9_LOTE" )	,PesqPict("NP9","NP9_LOTE")},;
				{"LOT_NBOLET"   , TamSX3("NPX_RESTXT")[3]	, TamSX3("NPX_RESTXT")[1]	, TamSX3("NPX_RESTXT")[2]	, RetTitle( "NPX_RESTXT" )	,PesqPict("NP9","NPX_RESTXT")},;
				{"LOT_UM"	    , TamSX3("NP9_UM")[3]		, TamSX3("NP9_UM")[1]		, TamSX3("NP9_UM")[2]		, RetTitle( "NP9_UM" )		,PesqPict("NP9","NP9_UM")},;
				{"LOT_TRATO"    , "C" 						, 5							, 0							, RetTitle( "NP9_TRATO" )	, "@!"}} 
	
	aIndex := {"LOT_FILIAL+LOT_CODSAF+LOT_NBOLET+LOT_LOTE","LOT_FILIAL+LOT_CODSAF+LOT_LOTE+LOT_NBOLET"}

	//--- Criação das tabelas temporárias ---//
	aRetTRB := AGRCRIATRB( , aCposTmp, aIndex, FunName(), .T. )//oga250f
	 
	cTrabTMP 	:= aRetTRB[3] //Nome do arquivo temporário 
	_cAliasTMP   := aRetTRB[4] //Nome do alias do arquivo temporario
	aColumTMP 	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picture

	aIndex	:= AGRINDICONS(aIndex , aColumTMP  )	

	aFldfilter := AGRITEMCBRW(aColumTMP)

	fDadosTela() //monta os dados no alias _cAliasTMP que será apresentado em tela

	acPosBrw := {	{"LOT_FILIAL", RetTitle( "NP9_FILIAL" )    	, "NP9_FILIAL"},;
					{"LOT_NBOLET" , STR0002  					, "NPX_RESTXT"},; //##"Numero Boletim"
					{"LOT_LOTE"   , RetTitle( "NP9_LOTE" )      , "NP9_LOTE"  },;
					{"LOT_PROD"   , RetTitle( "NP9_PROD" )   	, "NP9_PROD"  },;
					{"LOT_PRDDES" , RetTitle( "NP9_PRDDES" ) 	, "NP9_PRDDES"},;
					{"LOT_CODSAF" , RetTitle( "NP9_CODSAF" )	, "NP9_CODSAF"},;
					{"LOT_UM" 	  , RetTitle( "NP9_UM" ) 		, "NP9_UM"	  },;
					{"LOT_TRATO"  , RetTitle( "NP9_TRATO" )		, "NP9_TRATO" }}
	
	For nx := 1 To Len(acPosBRW)

		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+acPosBRW[ nX,1 ]+"}"))
		aColumns[Len(aColumns)]:SetTitle( acPosBRW[nX,2] )
		aColumns[Len(aColumns)]:SetSize(TamSx3(acPosBRW[nX,3])[1])
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(acPosBRW[nX,3])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(acPosBRW[nX,3]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(acPosBRW[nX,3])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
	Next nx

	SetKey( VK_F12, { || UBSC061F12() } )

	_oBrwMrk := FWMarkBrowse():New()	
	_oBrwMrk:SetAlias(_cAliasTMP)
	_oBrwMrk:SetColumns(aColumns)
	_oBrwMrk:SetFieldMark("MARK")
	_oBrwMrk:SetCustomMarkRec({||fmarcar()})
	_oBrwMrk:SetDescription(STR0001) //###"Geração Termo Aditivo - Lotes Elegíveis"
	_oBrwMrk:SetFieldFilter( aFldfilter )
	_oBrwMrk:SetSemaphore(.T.)	// Define se utiliza marcacao exclusiva
	_oBrwMrk:DisableConfig()	// Desabilita a opcao de configuracao do MarkBrowse
	_oBrwMrk:DisableDetails()	// Desabilita a exibicao dos detalhes do MarkBrowse
	_oBrwMrk:DisableReport()	// Desabilita a opcao de imprimir
	_oBrwMrk:SetSeek( ,aIndex)	
	_oBrwMrk:SetUseFilter(.T.)	

	_oBrwMrk:SetMenuDef( "UBSC061" )
	
	_oBrwMrk:Activate()
	//--- Apaga as tabelas temporárias ---//
	AGRDELETRB( _cAliasTMP, cTrabTMP )  
Return 

/*/{Protheus.doc} static function MenuDef
Função de menu 
@type  Function
@author claudineia.reinert
@since 29/11/2023
/*/
Static Function MenuDef()
	Local aRotina := {} 

	aAdd(aRotina, {STR0003, "UBSC61PRC()", 0, 3, 0, Nil})  //"Gerar Termo"

Return aRotina

/*/{Protheus.doc} static function fMarcar
Função para marcar o markbrowse
@type  Function
@author Daniel Silveira / claudineia.reinert
@since 29/11/2023
/*/
Static Function fMarcar(  )

	If ( !_oBrwMrk:IsMark() )
		//validação para marcar apenas um lote para gerar o termo aditivo
		If Len(_aMarcados) = 0
			RecLock(_oBrwMrk:Alias(),.F.)
			(_oBrwMrk:Alias())->MARK  := _oBrwMrk:Mark()
			(_oBrwMrk:Alias())->(MsUnLock()) 
			Aadd(_aMarcados, {AllTrim((_oBrwMrk:Alias())->LOT_NBOLET), AllTrim((_oBrwMrk:Alias())->LOT_LOTE)})
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


/*/{Protheus.doc} static function UBSC61PRC
Processar os registros para gerar a impressão
@type  Function
@author Daniel Silveira / claudineia.reinert
@since 10/11/2023
/*/
Function UBSC61PRC()
	Local lRetorno  := .F. //padrão .F.
	Local aAux := {}
	Local nI	:= 0
	Local cCodTerm := "" 
	Local cTerSafra := MV_PAR01
	Local cTerCultr := MV_PAR02
	Local cTerCtvar := MV_PAR03
	Local cTerCateg := MV_PAR04 
	Local cTerResp  := MV_PAR07
	Local aDados 	:= {}
	Local cTipoAdt 	:= "" //tipo do aditivo do termo de conformidade
	Local aRetPe	:= {}
	Local aObsTrat	:= {}
	Local cId		:= ""
	
	//## Variaveis para a função de impressão - caso mudar as posições abaixo ajustar tambem no fonte UBSA061 ##
	Private _nPosLote 	:= 1 //numero do lote
	Private _nPosSafr 	:= 2 //numero do lote
	Private _nPosDataLT := 3 //data do lote
	Private _nPosPrdTR 	:= 4 //produto do lote tratado/reembalado
	Private _nPosQtTR 	:= 5 //qtd lote NP9 tratado/reembalado
	Private _nPosPMETR 	:= 6 //Peso Medio Ensaque tratado/reembalado      
	Private _nPosPMSTR  := 7 //Peso de Mil Sementes tratado/reembalado     
	Private _nPosBole 	:= 8 //numero boletim
	Private _nPosDtBl 	:= 9 //data boletim
	Private _nPosCert 	:= 10 //numero certificado
	Private _nPosDtCt 	:= 11 //data certificado
	Private _nPosPrdOri := 12 //produto origem
	Private _nPosPMEOri := 13 //peso medio ensaque do lote origem
	Private _nPosQtOri 	:= 14 //Quantidade do lote origem
	Private _nTCmfeOri	:= 15 //numero termo conformidade origem
	Private _DTCmfeOri	:= 16 //data termo conformidade origem

	If Empty(MV_PAR07)			
		AgrHelp(STR0006,STR0007,STR0008) //##"Dados Obrigatórios não informados.","Informe o responsavel técnico no pergunte da tela(F12)."
		Return .F.
	EndIf

	(_oBrwMrk:Alias())->(DbGotop())

	while !(_oBrwMrk:Alias())->(Eof())
 
		if _oBrwMrk:IsMark()
			aAux := {}	
			aAux := UBSC061BDL((_oBrwMrk:Alias())->LOT_CODSAF , (_oBrwMrk:Alias())->LOT_LOTE, (_oBrwMrk:Alias())->LOT_PROD, @cTipoAdt,"")
			If LEN(aAux) > 0 
				aadd(aDados, aAux)
			EndIf
		endif
		(_oBrwMrk:Alias())->(dbSkip())

	enddo
		
	if len(aDados) > 0
		cId := fNextCod(cTerSafra)
		cCodTerm := cId + "/" + Year2Str(Date())
				
		IF EXISTBLOCK("UBSC61NR")
			aRetPe := ExecBlock("UBSC61NR",.F.,.F.,{cCodTerm,cTipoAdt,aDados})
			If ValType(aRetPe) == "A" .And. Len(aRetPe) == 3 .And. ValType(aRetPe[1]) == "L" .And. ValType(aRetPe[2]) == "C" .And. ValType(aRetPe[3]) == "A" 
				If aRetPe[1] == .F.
					Return .F.
				EndIf
				cCodTerm	:= aRetPe[2]
				aObsTrat	:= aClone(aRetPe[3])
			EndIf			
		endif

		If Empty(cCodTerm)
			AGRHELP(STR0006,STR0009, STR0010) //##"AJUDA","Não foi possivel determinar o numero do termo de conformidade.","Favor rever o parametro MV_AGRS004.")
			Return .F.
		EndIf

		DBSELECTAREA("NNN")
		NNN->(DBSETORDER( 1 ))
		If .NOT.(NNN->(DbSeek(cFilAnt + PadR(cCodTerm,TamSX3("NNN_NUM")[1]," ") + PadR(cTerSafra,TamSX3("NNN_CODSAF")[1]," ") + PadR(cTipoAdt,TamSX3("NNN_TIPO")[1]," ")  ))) //se não tem inclui
			BEGIN TRANSACTION
				If AGRGRAVAHIS(STR0011,"NNN",cFilAnt+PadR(cCodTerm,TamSX3("NNN_NUM")[1]," ")+PadR(cTerSafra,TamSX3("NNN_CODSAF")[1]," ")+PadR(cTipoAdt,TamSX3("NNN_TIPO")[1]," "),"3") = 1 //####"Confirma a geração do termo aditivo?"
					
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
					NNN->NNN_CODPRO	:= aDados[1][_nPosPrdTR]
					NNN->NNN_ID		:= cId
					NNN->NNN_TIPO	:= cTipoAdt  //tipo do termo
					NNN->(MSUNLOCK())
					NNN->(DBCLOSEAREA())
				
					DBSELECTAREA("NP9")
					NP9->(DBSETORDER(1)) 			
					for nI:=1 to len(aDados)
						If NP9->(DbSeek(xFilial("NP9") + aDados[ni][_nPosSafr] + aDados[ni][_nPosPrdTR] + aDados[ni][_nPosLote] ))
							RecLock("NP9", .F.)
							NP9->NP9_NTERMC := cCodTerm	
							NP9->NP9_TIPOTE := cTipoAdt
							NP9->(MSUNLOCK())
						Endif
					next nI			
					NP9->(DBCLOSEAREA())
					
				Else
					lRetorno := .F.
				EndIF
			End TRANSACTION
		Else
			lRetorno := .F.
			AGRHELP(STR0006,STR0014,STR0015) //##"Numero do termo aditivo já existente."#"Favor verificar a forma de geração da numeração do termo aditivo."
		EndIf	
		
		If lRetorno
			FWMsgRun(, {|| UBSC061A(aDados,cCodTerm, cTerResp, cTerSafra, cTerCultr , cTerCtvar, cTerCateg,cTipoAdt, DDATABASE, aObsTrat) }, STR0012+cCodTerm, STR0013 ) //###"Gerando Termo Aditivo", "Processando..."
			fRefresh() //refresh browser
		EndIf
	
	endif
	
Return lRetorno

/*/{Protheus.doc} UBSC061BDL
Busca as informações dos lotes para impressão
@type function
@version P12
@author claudineia.reinert
@since 29/11/2023
@param cSafra, character, codigo da safra
@param cLote, character, codigo do lote de semente
@param cProduto, character, codigo do produto
@param cTipoAdt, character, tipo do termo, variavel passada por referencia para receber o valor
@param cCodTerm, character, codigo do termo, só deve ser passado quando é reimpressão do termo aditivo
@return array, array com os dados do lote para impressão
/*/
Function UBSC061BDL(cSafra, cLote, cProduto, cTipoAdt, cCodTerm)
	Local aRet 		:= {} 
	Local cAliasDad := GetNextAlias()
	Local cIdBolte 	:= SUPERGETMV( "MV_AGRS008", .F., "") //variável de tipo de análise que contém o número do boletim - IA_VARBOLT
	Local cIdDataB 	:= SUPERGETMV( "MV_AGRS009", .F., "") //variável de tipo de análise que contém a data do boletim - IA_VARDTBL
	Local cIdCerti 	:= SUPERGETMV( "MV_AGRS013", .F., "")  //variável de tipo de análise que contém o número do certificado
	Local cIdDataC 	:= SUPERGETMV( "MV_AGRS014", .F., "")  //variável de tipo de análise que contém a data do certificado
	
	BEGINSQL alias cAliasDad
		SELECT NP9.NP9_FILIAL
		,NP9.NP9_LOTE
		,ORI.NP9_PROD ORI_PROD
		,ORI.NP9_QUANT ORI_QUANT
		,NPX.NPX_RESTXT
		,NPX.NPX_RESDTA
		,NP9.NP9_UM
		,ORI.NP9_UM ORI_UM
		,NP9.NP9_TRATO
		,NP9.NP9_DATA
		,NPX.NPX_CODVA
		,NP9.NP9_QUANT
		,NP9.NP9_PSMDEN
		,ORI.NP9_PSMDEN ORI_PSMDEN
		,NP9.NP9_PSMDSC
		,NP9.NP9_PENE
		,NP9.NP9_PROD
		,NP9.NP9_CODSAF
		,NP9.NP9_PSMDSC
		,NP9.NP9_CATEG
		,NP9.NP9_DATA
		,NP9.NP9_DTVAL
		,NPX.NPX_RESNUM
		,NPX.NPX_RESDTA
		,ORI.NP9_NTERMC ORI_NTERMC
		,NNN_DATA ORI_DTTERMC
		FROM %Table:NP9% NP9
		INNER JOIN %Table:NP9% ORI ON ORI.NP9_FILIAL = NP9.NP9_FILIAL AND ORI.NP9_LOTE = NP9.NP9_LOTE AND ORI.NP9_SAFRA = NP9.NP9_SAFRA AND ORI.NP9_TRATO = '2' AND ORI.D_E_L_E_T_=' '
		INNER JOIN %Table:NPX% NPX ON NPX_FILIAL = ORI.NP9_FILIAL AND NPX_LOTE = ORI.NP9_LOTE AND NPX_CODPRO = ORI.NP9_PROD AND NPX.NPX_SAFRA = NP9.NP9_SAFRA
		LEFT OUTER JOIN NNNT10 NNN ON NNN.D_E_L_E_T_ = '' AND NNN_NUM = ORI.NP9_NTERMC AND NNN_CODSAF = ORI.NP9_CODSAF AND NNN_TIPO = 'N'
		WHERE NP9.D_E_L_E_T_ = ' '
		AND NPX.D_E_L_E_T_ = ' '
		AND NP9.NP9_FILIAL = %xFilial:NP9%
		AND NP9.NP9_CODSAF = %Exp:cSafra%
		AND NP9.NP9_PROD = %Exp:cProduto%
		AND NP9.NP9_LOTE = %Exp:cLote%
		AND NPX_ATIVO = '1'
		AND NP9.NP9_NTERMC = %Exp:cCodTerm%
	endsql

	while !(cAliasDad)->(Eof())
		If LEN(aRet) = 0
			aRet := Array(16) //inicializa array que recebe as informações de lote
			aRet[_nPosLote] 	:= (cAliasDad)->NP9_LOTE
			aRet[_nPosSafr] 	:= (cAliasDad)->NP9_CODSAF
			aRet[_nPosQtTR] 	:= alltrim(Transform((cAliasDad)->NP9_QUANT, "@E 999,999,999.99"))
			aRet[_nPosPMETR] 	:= alltrim(Transform((cAliasDad)->NP9_PSMDEN, "@E 999,999,999.99"))
			aRet[_nPosPMSTR]  	:= alltrim(Transform((cAliasDad)->NP9_PSMDSC, "@E 999,999,999.99"))
			aRet[_nPosPrdTR] 	:= (cAliasDad)->NP9_PROD
			aRet[_nPosPrdOri] 	:= (cAliasDad)->ORI_PROD
			aRet[_nPosPMEOri] 	:= alltrim(Transform((cAliasDad)->ORI_PSMDEN, "@E 999,999,999.99"))
			aRet[_nPosDataLT] 	:= dtoc(stod((cAliasDad)->NP9_DATA))
			aRet[_nPosQtOri] 	:= alltrim(Transform((cAliasDad)->ORI_QUANT, "@E 999,999,999.99"))
			aRet[_nTCmfeOri] 	:= alltrim((cAliasDad)->ORI_NTERMC)
			aRet[_DTCmfeOri] 	:= IIF(Empty((cAliasDad)->ORI_DTTERMC),'',dtoc(stod((cAliasDad)->ORI_DTTERMC)))
		EndIf

		if alltrim((cAliasDad)->NP9_UM) <> alltrim((cAliasDad)->ORI_UM)  .AND. (cAliasDad)->NP9_TRATO == '2'
			cTipoAdt   := "R" //REEMBALADO
		elseif alltrim((cAliasDad)->NP9_UM) <> alltrim((cAliasDad)->ORI_UM)  .AND. (cAliasDad)->NP9_TRATO == '1'
			cTipoAdt   := "C" //REEMBALADO E TRATADO
		ELSEIF alltrim((cAliasDad)->NP9_UM) == alltrim((cAliasDad)->ORI_UM)  .AND. (cAliasDad)->NP9_TRATO == '1'
			cTipoAdt   := "T" //TRATADO
		endif

		Do case	
			case alltrim((cAliasDad)->NPX_CODVA) $ cIdBolte
				aRet[_nPosBole] := (cAliasDad)->NPX_RESTXT

			case alltrim((cAliasDad)->NPX_CODVA) $ cIdDataB
				aRet[_nPosDtBl] := DTOC(stod((cAliasDad)->NPX_RESDTA))

			case alltrim((cAliasDad)->NPX_CODVA) $ cIdCerti .and. (cAliasDad)->NP9_CATEG $ "C1/C2"
				aRet[_nPosCert] := (cAliasDad)->NPX_RESTXT
			
			case alltrim((cAliasDad)->NPX_CODVA) $ cIdDataC .and. (cAliasDad)->NP9_CATEG $ "C1/C2"
				aRet[_nPosDtCt] := DTOC(stod((cAliasDad)->NPX_RESDTA))
		endcase

		(cAliasDad)->(DBSKIP())
	enddo

	(cAliasDad)->(DBCLOSEAREA())

Return aRet

/*/{Protheus.doc} fNextCod
função para retornar o próximo numero sequencial para o termo de acordo com o tipo do termo e safra
@type  Function
@author Daniel Silveira / claudineia.reinert
@since 29/11/2023
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
		AND NNN_TIPO <> 'N'
	endsql
	// NNN_TIPO <> 'N' --> T=Tratado;R=Reembalado;C=Reembalado/Tratado === termo aditivo

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
Inserindo/Atualizando registros na tabela temporária com os dados que será mostrados em tela para seleção dos lotes para o termo aditivo
@type Function
@author Daniel Silveira / claudineia.reinert
@since 29/11/2023
/*/
static function fDadosTela()
	Local cAliasQRY := GetNextAlias()
	Local cVarBol  := SUPERGETMV( "MV_AGRS008", .F.,"") //Variável de tipo de análise(NPU_CODVA) que contém o número do boletim do lote de semente(UBS) - IA_VARBOLT
	Local dDataIni 	:= DToS(MV_PAR05)
	Local dDataFim 	:= DToS(MV_PAR06)

    BEGINSQL Alias cAliasQRY
		SELECT DISTINCT NP9.NP9_FILIAL
			,NP9.NP9_CODSAF
			,NP9.NP9_PROD
			,NP9.NP9_PRDDES 
			,NP9.NP9_LOTE
			,NP9.NP9_UM
			,NP9.NP9_TRATO
			,ORI.NP9_LOTE ORIGEM
			,ORI.NP9_PROD PROD
		,NPX.NPX_RESTXT
		,NP9.NP9_UM
		FROM %Table:NP9% NP9
		INNER JOIN %Table:NP9% ORI ON ORI.NP9_LOTE = NP9.NP9_LOTE AND ORI.NP9_TRATO = '2' AND ORI.D_E_L_E_T_=' '
		INNER JOIN %Table:NPX% NPX ON NPX_FILIAL = ORI.NP9_FILIAL AND NPX_LOTE = ORI.NP9_LOTE AND NPX_CODPRO = ORI.NP9_PROD
		WHERE NP9.D_E_L_E_T_ = ' '
		AND NPX.D_E_L_E_T_ = ' '
		AND NPX_FILIAL = ORI.NP9_FILIAL
		AND NPX_CODVA = %Exp:cVarBol%
		AND NPX_RESTXT <> '  '
		AND NP9.NP9_FILIAL= %xFilial:NP9%
		AND NPX_CODSAF = %Exp:alltrim(MV_PAR01)%
		AND NP9.NP9_CATEG = %Exp:alltrim(MV_PAR04)%
		AND NP9.NP9_CTVAR = %Exp:alltrim(MV_PAR03)%
		AND NP9.NP9_DATA >= %Exp:dDataIni%
		AND NP9.NP9_DATA <= %Exp:dDataFim%
		AND NPX_ATIVO = '1'
		AND NP9.NP9_NTERMC = ""
		AND (NP9.NP9_TRATO = '1' OR NP9.NP9_UM <> ORI.NP9_UM)
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
			(_cAliasTMP)->LOT_UM 	:= (cAliasQry)->NP9_UM
			(_cAliasTMP)->LOT_TRATO  := X3CboxDesc( "NP9_TRATO", (cAliasQry)->NP9_TRATO ) // IIF((cAliasQry)->NP9_TRATO=='1', 'Sim', "Nao")
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
@since 29/11/2023
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

/*/{Protheus.doc} UBSC061F12
Tecla para acionar o Pergunte e atualizar os dados conforme o filtro do pergunte
@type function
@version P12
@author claudineia.reinert
@since 29/11/2023
/*/
Function UBSC061F12()
	If !Pergunte(_cPerg, .T.)
		Return 
	EndIf
	fRefresh()
Return .T.
