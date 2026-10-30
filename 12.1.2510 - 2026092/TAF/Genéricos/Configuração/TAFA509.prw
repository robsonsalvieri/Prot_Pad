#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA509
Cadastro MVC Log alteração manual do protocolo - LOG TSS      

@author Ronaldo Tapia
@since 09/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA509()

Local oBrw := FwMBrowse():New()

// Chama função para decriptar os dados
If MsgYesNo ("Esta rotina irá decriptar os dados da tabela V1V. Deseja continuar?")
	FWMsgRun( , { || CursorWait(),TAFADecrip() }, , "Aguarde! Decriptando dados..." )
EndIf

oBrw:SetDescription("Log alteração manual de protocolo") //"Log alteração manual do protocolo"
oBrw:SetAlias("V1V")
oBrw:SetMenuDef("TAFA509")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Ronaldo Tapia
@since 09/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Ronaldo Tapia
@since 09/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruVIX := FwFormStruct(1,"V1V")
Local oModel   := MpFormModel():New("TAFA509")

oModel:AddFields("MODEL_V1V",/*cOwner*/,oStruVIX)

// Define uma chave primaria (obrigatorio mesmo que vazia)	
oModel:SetPrimaryKey( {} )

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Ronaldo Tapia
@since 09/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA509")
Local oStruVIX := FwFormStruct(2,"V1V")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddGrid( 'VIEW_V1V' , oStruVIX , 'V1V' )
oView:EnableTitleView("VIEW_V1V","Log alteração manual do protocolo") //"Log alteração manual do protocolo"

Return(oView)


//-------------------------------------------------------------------
/*/{Protheus.doc}TAFADecrip
Atualiza tabela V1V com os dados decriptados

@author Ronaldo Tapia
@since 09/05/2018
@protected
/*/
//-------------------------------------------------------------------
Static Function TAFADecrip()

	Local cQry  := ""
	Local cCheck1, cCheck2, cCheck3, cCheck4 := ""
	
	cQry := ""
	cQry += " SELECT V1V_FILIAL FILIAL,V1V_ID ID,V1V_TABELA TABELA,V1V_CHAVE CHAVE,V1V_VATUAL VATUAL,V1V_CHECK1 CHECK1,V1V_CHECK2 CHECK2,V1V_CHECK3 CHECK3,V1V_CHECK4 CHECK4"
	cQry += " FROM "+RetSQLName("V1V")+" V1V"
	cQry += " WHERE V1V_DECRIP <> 'S' AND V1V.D_E_L_E_T_ = '' "
	If (Select("TRBDECR") <> 0)
		dbSelectArea("TRBDECR")
		dbCloseArea()
	Endif
	cQry := ChangeQuery(cQry)
	TCQuery cQry NEW ALIAS "TRBDECR"
	Dbselectarea("TRBDECR")
	TRBDECR->(dbgotop())
	
	While TRBDECR->(!Eof())	
		
		// Adiono os campos e decripto os dados dos campos _CHECK
		cCheck1 := TafHexDecr(TRBDECR->CHECK1)
		cCheck2 := TafHexDecr(TRBDECR->CHECK2)
		cCheck3 := TafHexDecr(TRBDECR->CHECK3)
		cCheck4 := TafHexDecr(TRBDECR->CHECK4)
		
		// Faço o update dos dados decriptados
		V1V->(DBCOMMIT())
		cQuery := "UPDATE "+RetSqlname("V1V")+" "
		cQuery += "SET V1V_CHECK1 = '"+cCheck1+"', "
		cQuery += "V1V_CHECK2 = '"+cCheck2+"',"
		cQuery += "V1V_CHECK3 = '"+cCheck3+"',"
		cQuery += "V1V_CHECK4 = '"+cCheck4+"',"
		cQuery += "V1V_DECRIP = 'S'"
		cQuery += "WHERE V1V_FILIAL='"+TRBDECR->FILIAL+"' AND "
		cQuery += "V1V_ID='"+TRBDECR->ID+"' "
		If TcSrvType() <> "AS/400"
			cQuery += "AND D_E_L_E_T_=' ' "
		Else
			cQuery += "AND @DELETED@=' ' "
		Endif

		TcSqlExec(cQuery)
		
		dbSkip()
	EndDo

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TafHexDecr
Converte de HexaDecimal para String para descriptografar no rc4crypt

@Param ( Nil )

@author    Ronaldo Tapia
@version   12.1.17
@since     09/05/2018
@protected

@Return ( Nil )
/*/
//------------------------------------------------------------------------------------------
Static Function TafHexDecr(cWord)

	Local cChaveCript := "123456789"
	Local cVar	:= ""
	Local cRet	:= ""
	Local nX	:= 0
	
	Default cWord := ""
	cWord := Alltrim(cWord)

	// Converte os dados
		For nX := 0 To Len(cWord)-2 Step 2
			cVar += chr(CTON(Substr(cWord,1+nX,2),16))
		Next
	
	// Decripta os dados
		cRet := rc4crypt(cVar,cChaveCript,.F.)

Return cRet