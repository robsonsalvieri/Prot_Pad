#INCLUDE 'OFCNHA10.CH' 
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PARMTYPE.CH'

/*/{Protheus.doc} OFCNHA10
Geração de arquivo texto CNH - Produto DMS
@type function
@version 1.0  
@author rodrigo
@since 11/04/2025
/*/
Function OFCNHA10()
	PRIVATE aRotina	:= MenuDef() As Array

	Mata120(1)

Return

/*/{Protheus.doc} MenuDef
Rotinas de Menu (Browse)
@type function
@version 1.0  
@author rodrigo
@since 11/04/2025
@return array, opcoes de menu
/*/
Static Function MenuDef() As Array
	Local aRotina 	:= {} As Array
	Local aSubMenu	:= {} As Array

	aAdd(aSubMenu, {STR0020, 'OFCA10E', 0, 7}) /*Gerar Arquivo*/
	aAdd(aSubMenu, {STR0028, 'VIEWVBE', 0, 7}) /*Consulta Pedido*/

	aAdd(aRotina, {STR0001, 'AxPesqui', 0, 1}) /*Pesquisar*/
	aAdd(aRotina, {STR0002, 'A120Pedido', 0, 2}) /*Visualizar*/
	aAdd(aRotina, {STR0003, 'A120Pedido', 0, 3}) /*Incluir*/

	//aAdd(aRotina, {STR0004, 'A120Pedido', 0, 4}) /*Alterar*/
	aAdd(aRotina, {STR0004, 'CheckVBE', 0, 4}) /*Alterar*/
	
	//aAdd(aRotina, {STR0005, 'A120Pedido', 0, 5}) /*Excluir*/
	aAdd(aRotina, {STR0005, 'CheckVBE', 0, 5}) /*Excluir*/

	aAdd(aRotina, {STR0019, aSubMenu, 0, 7}) /*CNH-DMS*/
	aAdd(aRotina, {STR0007, 'A120Legend', 0, 1}) /*Legenda*/
	
	/*
	Ponto de entrada para inclusão de novas opções no aRotina
	*/
	If ( ExistBlock("OFC10ABT") )
		aRotina := ExecBlock("OFC10ABT",.f.,.f.,{aRotina})
	EndIf

Return aRotina

/*/{Protheus.doc} OFCA10E
Geração do arquivo CNH
@type function
@version 1.0  
@author rodrigo
@since 11/04/2025
/*/
Function OFCA10E()
	Local aPergs   	:= {} As Array
	Local aRet     	:= {} As Array
	Local aButtons 	:= {} As Array
	Local aOpc		:= {} As Array
	Local cArquivo 	:= '' As Char
	Local cTipoPed	:= Space(FWTamSX3('VEJ_TIPPED')[1]) As Char
	Local cPedido	:= SC7->C7_NUM
	Local cFornece	:= SC7->C7_FORNECE
	Local cLjFor	:= SC7->C7_LOJA
	Local lExistVBE	:= .F. As Logical
	Local lExistVE4	:= .F. As Logical

	aOpc := {STR0008,STR0009} /*1-Local,2-Servidor*/
	aAdd(aPergs, {9,STR0010, 200, 40, .T.}) /*Defina a opção de geração:*/                 
    aAdd(aPergs, {2,STR0011, 01, aOpc, 50, '', .T.}) /*Opções:*/   
     
    aAdd(aPergs, {9, STR0012, 200, 40, .T.}) /*Defina o nome do arquivo:*/                    
    aAdd(aPergs, {1, STR0013, Upper(Space(100)), '', '', '', '', 110, .T.}) /*Arquivo: */

	aAdd(aPergs, {9, STR0021, 200, 40, .T.}) /*Defina o tipo de pedido:*/   
	aAdd(aPergs, {1, STR0022, cTipoPed, '', '', 'VEJ1', '', 110, .T.}) /*Selecione:*/                 
      
    IF ParamBox(aPergs,FunName(),aRet,{|| bOKaRet(aRet)},aButtons,,,,,,,)
		
		lExistVE4 := ExistVE4(cFornece, cLjFor)

		IF lExistVE4
			lExistVBE := ExistVBE(cPedido)
			IF !lExistVBE
				IF !Empty(aRet[4])      
					cArquivo := Alltrim(aRet[4])
					Processa({|| OFHA10E01(aRet[1],cArquivo,aRet[6],cPedido)}, STR0014) /*Selecionando e gerando dados...*/
				EndIF    
			ELSE
				FWAlertWarning(STR0027 + cPedido, STR0016) /*O pedido informado já existe na tabela VBE: */ /*Atenção*/        
			EndIF
		ELSE
			ExibeHelp(STR0034, STR0035, STR0036) /*MarcaMontadora*/ /*Fornecedor não localizado no registro de montadoras*/ /*Verifique o parâmetro de marca e cadastro de montadoras*/
		EndIF
    ELSE
        FWAlertWarning(STR0015,STR0016) /*Processo Cancelado pelo usuário*/ /*Atenção*/
        Return
    EndIF
     
return

/*/{Protheus.doc} bOKaRet
Valida a obrigatoriedade de informar o nome do arquivo
@type function
@version 1.0  
@author rodrigo
@since 11/04/2025
@param aRet, array, conteudo do parambox
@return logical, validado ou nao
/*/
Static Function bOKaRet(aRet As Array) As Logical
	Local nRet	:= 0 As Numeric
	Local lRet	:= .T. As Logical
 
	For nRet := 1  To Len(aRet)
		IF Empty(aRet[4])
			FWAlertWarning(STR0017,STR0016) /*Nenhum arquivo foi informado*/ /*Atenção*/
			lRet := .F.
			Exit
		EndIF
	Next nRet 
Return lRet

/*/{Protheus.doc} OFHA10E01
Geração de arquivo
@type function
@version 1.0  
@author rodrigo
@since 11/04/2025
@param cLocal, character, local de geração
@param cFile, character, nome do arquivo
@param cTipo, character, tipo de pedido
@param cPedido, character, pedido
/*/
Static Function OFHA10E01(cLocal As Char, cFile As Char, cTipo As Char, cPedido As Char)
	Local cAliasSC7 := '' As Char
	Local cQuery	:= '' As Char
	Local cQueryVBE	:= '' As Char
	Local cPedEdi	:= '' As Char
	local lVBE := FWAliasInDic("VBE")

	Local oSQL	As Object
	Local oFile As Object

	DEFAULT cLocal	:= '\cnh\csps\'
	DEFAULT cFile	:= ''

	cQuery := " SELECT SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_QUANT, SC7.C7_PRODUTO, SB1.B1_CODFAB, SC7.R_E_C_N_O_ SC7RECNO, VEJ.VEJ_PEDEDI " + CRLF
	cQuery += " FROM " + CRLF
	cQuery += RetSqlName("SC7") + " SC7 " + CRLF
	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON  SB1.B1_FILIAL  = '" + FWxFilial("SB1") + "' AND SB1.B1_COD = SC7.C7_PRODUTO AND SB1.D_E_L_E_T_= ' ' " + CRLF
	cQuery += " LEFT JOIN " + RetSQLName("VEJ")+ " VEJ ON  VEJ.VEJ_FILIAL  = '" + FWxFilial("VEJ") + "' AND VEJ.VEJ_TIPPED  = '" + cTipo + "' AND VEJ.D_E_L_E_T_= ' ' " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += " SC7.C7_FILIAL= '" + FWxFilial("SC7") + "' AND SC7.C7_NUM = '" + cPedido + "'" + CRLF
	cQuery += " AND SC7.D_E_L_E_T_= ' ' " + CRLF

	oSQL := FWPreparedStatement():New()
	oSQL:SetQuery(cQuery)

	cQuery := oSQL:GetFixQuery()

	cAliasSC7 := MPSysOpenQuery(cQuery)

	dbSelectArea((cAliasSC7))

	/*
	Mantem o pededi...
	Entender melhor o processo e verificar se essa é a melhor alternativa...
	*/
	cPedEdi := AllTrim((cAliasSC7)->VEJ_PEDEDI)

	IF (cAliasSC7)->(EOF())
		FWAlertError(STR0018,STR0016) /*A consulta não possui dados*/ /*Atenção*/
		(cAliasSC7)->(dbCloseArea())
		Return .F.
	EndiF

	IF SubStr(cLocal,1,1) == '1'
		cLocal := GetTempPath()
	ELSE
		IF !ExistDir('\cnh\')
			IF FWMakeDir('\cnh\csps\', .T.)
				cLocal := '\cnh\csps\'
			EndIF
		EndIF	
	EndIF

	oFile := FWFileWriter():New(cLocal+cFile,.T.)
	oFile:SetCaseSensitive(.T.)
	oFile:Create()

	cCabTXT := "E0"+;
	Left((cAliasSC7)->C7_NUM+SPACE(35),35) + ;
	(cAliasSC7)->VEJ_PEDEDI + SPACE(3) +;
	SPACE(352)

	oFile:Write(cCabTXT+CRLF)

	cCabCompTXT := "E1"+;
	SPACE(40)

	oFile:Write(cCabCompTXT+CRLF)

	While !(cAliasSC7)->(EOF())
		cLinDet := "E6"+;
		Left(Alltrim((cAliasSC7)->(B1_CODFAB)) + SPACE(18),18) + ;
		STRZERO((cAliasSC7)->(C7_QUANT),10) + SPACE(3) + ;
		SPACE(71)+;
		SPACE(3)+;
		SPACE(5)
		
		oFile:Write(cLinDet+CRLF)
		dbSelectArea(cAliasSC7)
		(cAliasSC7)->(dbSkip())
	EndDo

	(cAliasSC7 )->(dbCloseArea())

	cTrailTXT := "E9"+;
	SPACE(24)

	oFile:Write(cTrailTXT+CRLF)

	oFile:Close()
	if lVBE
		GeraVBE(cPedido, cPedEdi)
	Endif
Return

/*/{Protheus.doc} GeraVBE
Inclui registro na tabela VBE com base no pedido gerado
@type function
@version 1.0  
@author Rodrigo
@since 18/05/2025
@param cPedido, character, numero do pedido
@param cPedEdi, character, pedido edi/tipo do pedido
/*/
Static Function GeraVBE(cPedido As Char, cPedEdi As Char)
	Local aArea		:= FWGetArea() As Array
	Local aAreaVBE 	:= VBE->(FWGetArea()) As Array

	Local cQuery 	:= '' As Char
	Local cView		:= '' As Char
	Local cCodVBE	:= '' As Char

	Local oSQL	:= NIL As Object

	Local lOK	:= .F. As Logical

	DEFAULT cNumPed := SC7->C7_NUM
		
	cQuery := " SELECT SC7.C7_DATPRF, SC7.C7_PRODUTO, SC7.C7_QUANT, SC7.C7_TOTAL, SC7.C7_NUM " + CRLF
	cQuery += " FROM " + RetSQLName("SC7") + " SC7 " + CRLF
	cQuery += " WHERE SC7.C7_FILIAL= '" + FWxFilial("SC7") + "' AND SC7.C7_NUM = '" + cPedido + "'" + CRLF
	cQuery += " AND SC7.D_E_L_E_T_ = ' ' " + CRLF

	oSQL := FWPreparedStatement():New()
	oSQL:SetQuery(cQuery)

	cQuery := oSQL:GetFixQuery(cQuery)

	cView := GetNextAlias()
	cView := MPSysOpenQuery(cQuery)

	dbSelectArea(cView)
	IF (cView)->(!EOF())
		While (cView)->(!EOF())
			cCodVBE := ''
			cCodVBE := GetSXENum('VBE', 'VBE_CODIGO')

			VBE->(dbAppend(.T.))
			VBE->VBE_FILIAL := FWxFilial('VBE')
			VBE->VBE_CODIGO := cCodVBE
			VBE->VBE_DATPED := CTOD((cView)->C7_DATPRF)
			VBE->VBE_PRODUT := AllTrim((cView)->C7_PRODUTO)
			VBE->VBE_QTDLIN := (cView)->C7_QUANT
			VBE->VBE_VLRTOT := (cView)->C7_TOTAL
			VBE->VBE_TIPPED := cPedEdi
			VBE->VBE_NUMPED := (cView)->C7_NUM
			VBE->(dbrUnlock())

			ConfirmSX8()

			lOK := .T.

			(cView)->(dbSkip())
		End
		(cView)->(dbCloseArea())
	EndIF

	IF lOK
		FWAlertSuccess(STR0023, STR0016) /*Registro VBE criado com sucesso*/ /*Atenção*/
	ELSE
		FWAlertError(STR0026, STR0016) /*Erro na geração de registros VBE*/ /*Atenção*/
	EndIF

	FWFreeObj(oSQL)
	
	FWRestArea(aAreaVBE)
	FWRestArea(aArea)

	FWFreeArray(aArea)
	FWFreeArray(aAreaVBE)
Return

/*/{Protheus.doc} ExistVBE
Verifica se o pedido posicionado existe na VBE
@type function
@version 1.0  
@author Rodrigo
@since 23/05/2025
@param cPedido, character, pedido
/*/
Static Function ExistVBE(cPedido As Char) As Logical
	Local aAreaVBE 	:= VBE->(FWGetArea()) As Array
	Local lExist	:= .F. As Logical
	
	dbSelectArea('VBE')
	VBE->(dbSetOrder(3)) /*VBE_FILIAL+VBE_NUMPED*/
	IF VBE->(dbSeek(FWxFilial('VBE')+cPedido))
		lExist := .T.
	EndIF
	
	FWRestArea(aAreaVBE)

	FWFreeArray(aAreaVBE)
Return lExist

/*/{Protheus.doc} CheckVBE
Verifica a existencia de registro na VBE para permitir ou nao a alteracao/exclusao
@type function
@version 1.0 
@author Rodrigo
@since 28/05/2025
/*/
Function CheckVBE()
	Local aAreaSC7 := SC7->(FWGetArea()) As Array

	Local lExistVBE	As Logical
	Local lInclui	As Logical
	Local lAltera	As Logical
	Local lExclui	As Logical
	
	lExistVBE 	:= ExistVBE(SC7->C7_NUM)
	lInclui		:= INCLUI
	lAltera		:= ALTERA
	lExclui		:= (!lInclui .AND. !lAltera)	
	
	IF (lAltera .OR. lExclui)
		IF lExistVBE
			ExibeHelp(STR0029, STR0030, STR0031) /*CNH-CSPS*/ /*Este pedido não pode ser alterado/excluído pois já foi integrado ao PRIM*/ /*Não é permitda a alteração ou exclusão*/
		ELSEIF (lAltera .AND. !lExistVBE)
			A120Pedido('SC7', SC7->(Recno()),4)
		ELSEIF (lExclui .AND. !lExistVBE)
			A120Pedido('SC7', SC7->(Recno()),5)
		EndIF
	EndIF

	FWRestArea(aAreaSC7)

	FWFreeArray(aAreaSC7)
Return	

/*/{Protheus.doc} ViewVBE
Valida se deve processar a visualização do pedido
@type function
@version 1.0  
@author Rodrigo
@since 28/05/2025
/*/
Function ViewVBE()
	Local cNumPed	:= SC7->C7_NUM As Char
	Local lExistVBE	:= ExistVBE(cNumPed)
	
	IF lExistVBE
		Processa({||OFCNHA09(cNumPed)}, STR0032) /*Consultando registros...*/
	ELSE
		FWAlertWarning(STR0033, STR0016) /*Não existe pedido PRIM relacionado*//*Atenção*/
	EndIF
Return

/*/{Protheus.doc} ExistVE4
Verifica se a marca e fornecedores sao validos para geração do arquivo CSPS
@type function
@version 1.0  
@author Rodrigo
@since 28/05/2025
@param cFornece, character, codigo do fornecedor
@param cLjFor, character, loja do fornecedor
@return logical, verdadeiro/falso
/*/
Static Function ExistVE4(cFornece As Char, cLjFor As Char) As Logical
	Local aAreaSA2 := SA2->(FWGetArea()) As Array
	Local aAreaVE4 := VE4->(FWGetArea()) As Array
	
	Local cKeyA2 := '' As Char
	Local cKeyFab:= GetNewPar('MV_MIL0006')

	Local lOK := .F. As Logical

	cFornece	:= Padr(cFornece, FWTamSX3('A2_COD')[1])
	cLjFor 		:= Padr(cLjFor, FWTamSX3('A2_LOJA')[1])
	
	dbSelectArea('SA2')
	SA2->(dbSetOrder(1))
	IF SA2->(dbSeek(FWxFilial('SA2')+cFornece+cLjFor))
		cKeyA2 := SA2->A2_CGC
		cKeyA2 := Padr(cKeyA2, FWTamSX3('A2_CGC')[1])
		lOK := .T.
	EndIF

	IF lOK
		
		cKeyFab := Padr(cKeyFab, FWTamSX3('VE4_PREFAB')[1])

		dbSelectArea('VE4')
		VE4->(dbSetOrder(1))
		IF !VE4->(dbSeek(FWxFilial('VE4')+cKeyFab+cKeyA2))
			lOK := .F.
		EndIF
	EndIF

	FWRestArea(aAreaVE4)
	FWRestArea(aAreaSA2)

	FWFreeArray(aAreaSA2)
	FWFreeArray(aAreaVE4)
Return lOK
