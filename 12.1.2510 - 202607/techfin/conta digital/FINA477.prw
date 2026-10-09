#include "Totvs.ch"
#include "FINA477.ch"

#define NSM0EMP  1
#define NSM0FIL  2
#define NSM0CNPJ 18

Static __aSM0     := Nil
Static __lDicCDig := Nil
Static __nTamHora := Nil

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} ReconciliationMessageMessageReader
Classe de Integração com o TOTVS Conta Digital via Smartlink

@author Claudio Yoshio Muramatsu
@since 04/12/2023
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Class ReconciliationMessageMessageReader From LongNameClass
 
    Method New() Constructor
    Method Read()
    Method ProxNum()
	Method MovBCACD()
 
End Class
											

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author Claudio Yoshio Muramatsu
@since 04/12/2023
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Method New() Class ReconciliationMessageMessageReader

Return Self
 

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} Read()
Método responsável pela leitura e processamento da mensagem.

@author Claudio Yoshio Muramatsu
@since 04/12/2023
@version 1.0
@param oLinkMessage, object, Instância de FwTotvsLinkMesage da mensagem
@return logical, sucesso ou falha. Determina se deve ou não retirar a mensagem da fila.
/*/
//-----------------------------------------------------------------------------------------
Method Read( oLinkMessage As Object ) Class ReconciliationMessageMessageReader

	Local cAgencia  As Character
	Local cBanco    As Character
	Local cCnpj     As Character
	Local cConta    As Character
	Local cDescri   As Character
	Local cDvConta  As Character
	Local cId       As Character
	Local cIdProc   As Character
	Local cItem     As Character
	Local cLock     As Character
	Local cTipoMov  As Character
	Local cTipoOper As Character
	Local cTranId   As Character
	Local dDataMov  As Date
	Local nValorMov As Numeric
	Local lRet      As Logical
	Local oContent  As Object
	Local nX	 	As Numeric
	Local nTotal 	As Numeric

	cLock   := "FINA477"
	lRet    := .T.
	nX		:= 0
	nTotal  := 0
	
	If LockByName(cLock, .F., .F.)
		oContent := JsonObject():New()
		oContent:FromJSON(oLinkMessage:RawMessage())		
		cCnpj     := oContent["data"]:GetJsonText("tenantCNPJ")		
		cBanco    := Padr(oContent["data"]:GetJsonText("bank"),TamSx3("A6_COD")[1])
		cAgencia  := Padr(oContent["data"]:GetJsonText("branch"),TamSx3("A6_AGENCIA")[1])
		cConta    := Padr(oContent["data"]:GetJsonText("accountNumber"),TamSx3("A6_NUMCON")[1])
		cDvConta  := oContent["data"]:GetJsonText("checkDigit")

		nTotal	  := Len(oContent["data","items"])
		
		For nX := 1 to nTotal				
			cId       := oContent["data","items",nX]:GetJsonText("id")
			cTranId   := oContent["data","items",nX]:GetJsonText("transactionId")
			cDescri   := oContent["data","items",nX]:GetJsonText("description")
			dDataMov  := SToD(Replace(Left(oContent["data","items",nX]:GetJsonText("movementDate"),10),"-",""))
			nValorMov := Val(oContent["data","items",nX]:GetJsonText("operationAmount"))
			cTipoOper := oContent["data","items",nX]:GetJsonText("operationType") //1=Entrada; 2=Saída
			cTipoMov  := oContent["data","items",nX]:GetJsonText("movementType") //1=Pix; 2=Boleto

			If __aSM0 == Nil
				__aSM0 := AdmAbreSM0()
			EndIf

			nPosEmpFil := aScan(__aSM0, { |x| AllTrim(x[NSM0CNPJ]) == cCnpj })
			If nPosEmpFil > 0
				If __aSM0[nPosEmpFil, NSM0EMP] <> cEmpAnt .Or. __aSM0[nPosEmpFil, NSM0FIL] <> cFilAnt
					If __aSM0[nPosEmpFil, NSM0EMP] <> cEmpAnt
						__lDicCDig := Nil
					EndIf
					RpcSetEnv(__aSM0[nPosEmpFil, NSM0EMP], __aSM0[nPosEmpFil, NSM0FIL], Nil, Nil, Nil, "FINA477")
				EndIf

				If __nTamHora == Nil
					__nTamHora := TamSx3("CV8_HORA")[1]
				Endif

				If __lDicCDig == Nil
					__lDicCDig := SIF->(ColumnPos("IF_CONTA")) > 0 .And. SIG->(ColumnPos("IG_BCOEXT")) > 0 .And. SIG->(FieldPos("IG_IDCD")) > 0 .And. SIG->(FieldPos("IG_CODBAR")) > 0 .And. SIG->(FieldPos("IG_IDTPIX")) > 0 .And. !Empty(SIG->(IndexKey(4)))
				EndIf

				If __lDicCDig
					SIG->(DbSetOrder(4)) //IG_FILIAL+IG_IDCD
					If SIG->(!MsSeek(xFilial("SIG") + cId))
						cIdProc := ""
						cItem := Replicate("0", TamSx3("IG_ITEM")[1])
						
						SA6->(DbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
						If SA6->(MsSeek(xFilial("SA6") + cBanco + cAgencia + cConta)) .And. SA6->A6_BLOCKED <> "1"
							
							If ::MovBCACD(cBanco,cAgencia,cConta, dDataMov, @cIdProc, @cItem)
								RecLock("SIF",.T.)
								SIF->IF_FILIAL 	:= xFilial("SIF")
								SIF->IF_IDPROC  := cIdProc
								SIF->IF_DTPROC  := dDataMov
								SIF->IF_BANCO	:= cBanco
								SIF->IF_AGENCIA	:= cAgencia
								SIF->IF_CONTA	:= cConta
								SIF->IF_DESC	:= "TOTVS Conta Digital"
								SIF->IF_STATUS 	:= "1"
								SIF->IF_HORA	:= SubStr(Time(),1,__nTamHora)
								SIF->(MsUnlock())
							EndIf

							cItem := Soma1(cItem)
							RecLock("SIG",.T.)
							SIG->IG_FILIAL 	:= xFilial("SIG")
							SIG->IG_IDPROC	:= cIdProc
							SIG->IG_ITEM	:= cItem
							SIG->IG_STATUS	:= "1"
							SIG->IG_DTEXTR	:= dDataMov
							SIG->IG_SEQMOV  := ::ProxNum("SIG")
							SIG->IG_VLREXT 	:= nValorMov
							SIG->IG_CARTER	:= cTipoOper
							SIG->IG_BCOEXT  := cBanco
							SIG->IG_AGEEXT  := cAgencia
							SIG->IG_CONEXT  := cConta
							SIG->IG_HISTEXT := cDescri
							SIG->IG_FILORIG := cFilAnt
							SIG->IG_IDCD    := cId
							If cTipoMov == "1"
								SIG->IG_IDTPIX := cTranId
							ElseIf cTipoMov == "2"
								SIG->IG_CODBAR := cTranId
							EndIf
							SIG->(MsUnlock())
							F476Send( SIG->IG_FILIAL, SIG->IG_IDPROC, SIG->IG_ITEM )
						Else
							FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", I18N(STR0001, {cId, AllTrim(cBanco), AllTrim(cAgencia), AllTrim(cConta)}), 0, 0, {}) //"Id #1 - Banco #2 Agencia #3 Conta #4 nao encontrado ou bloqueado para movimentacoes."
							lRet := .F.
						EndIf				
					Else
						FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", I18N(STR0005, {cId, cEmpAnt, cFilAnt}), 0, 0, {}) //"Id #1 - Ja existe um movimento com o mesmo Id na Empresa #2 Filial #3."
					EndIf
				Else
					FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", I18N(STR0002, {cEmpAnt, cFilAnt}), 0, 0, {}) //"Empresa #1 Filial #2 - As tabelas SIF e/ou SIG nao possuem os campos IF_CONTA, IG_BCOEXT, IG_IDCD, IG_IDTPIX e IG_CODBAR e/ou o indice 4 da SIG necessarios para a importacao dos movimentos do TOTVS Conta Digital."
					lRet := .F.
				EndIf
				UnLockByName( cLock, .T., .F. )
			Else
				FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", I18N(STR0003, {cId, cCnpj}), 0, 0, {}) //"Id #1 - CNPJ #2 nao encontrado no cadastro de empresas."
				lRet := .F.
			EndIf
		Next
	Else
		FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0004, 0, 0, {}) //"Job ja esta em execucao por outra instancia."
		lRet := .F.
	EndIf

	FwFreeObj(oContent)

Return lRet

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} ProxNum
Método para verificação da próxima sequência do campo 

@author Claudio Yoshio Muramatsu
@since 04/12/2023
@version 1.0
@param cTab, character, tabela de referência para busca do próximo sequencial
@return cNovaChave, character, proxima sequência da tabela de referência
/*/
//-----------------------------------------------------------------------------------------
Method ProxNum(cTab As Character) Class ReconciliationMessageMessageReader

	Local aArea      As Array
	Local aAreaSIF   As Array
	Local aAreaSIG   As Array
	Local cCampo     As Character
	Local cChave     As Character
	Local cNovaChave As Character
	Local nIndex     As Numeric

	cNovaChave := ""
	aArea      := GetArea()
	aAreaSIF   := SIF->(GetArea())
	aAreaSIG   := SIG->(GetArea())
	cCampo     := ""
	cChave     := ""
	nIndex     := 0

	If cTab == "SIF"
		SIF->(DbSetOrder(1))//IF_FILIAL+IF_IDPROC
		cCampo := "IF_IDPROC"
		nIndex := 1	
	Else
		SIG->(DbSetOrder(2))//IG_FILIAL+IG_SEQMOV
		cCampo := "IG_SEQMOV"
		cChave := "IG_SEQMOV"+cEmpAnt
		nIndex := 2
	EndIf


	While .T.
		(cTab)->(DbSetOrder(nIndex))
		cNovaChave := GetSXEnum(cTab,cCampo,cChave,nIndex)
		ConfirmSX8()
		If cTab == "SIF" 
			If (cTab)->(!MsSeek(xFilial(cTab) + cNovaChave) )
				Exit
			EndIf
		Else
			If (cTab)->(!MsSeek(cNovaChave) )
				Exit
			EndIf
		EndIf
	EndDo

	RestArea(aAreaSIF)
	RestArea(aAreaSIG)
	RestArea(aArea)

	FwFreeArray(aAreaSIF)
	FwFreeArray(aAreaSIG)
	FwFreeArray(aArea)

Return cNovaChave

/*/{Protheus.doc} MovBCACD()
    Método para verificar se existe movimentos do mesmo banco, conta e agencia. Para gerar os movimentos em lotes na tabela SIG.
    @type  Static Function
    @author Luiz Gustavo R. Jesus
    @since 26/03/2024
	@version 1.0
	@param cBanco, 		character, Código do banco
	@param cAgencia, 	character, Código da agencia
	@param cConta,		character, Código da conta
	@param Date, 		Date, 	   Data do movimento
	@param cIdProc,		character, Código do processamento da SIF
	@param cItem, 		character, Código do Item do processamento 
	@return lRet, 		logical,   Determina se deve ou não criar o registro no cabeçado da tabela SIF
    /*/	
Method MovBCACD(cBanco As Character,cAgencia As Character, cConta As Character, dDtmov as Date, cIdProc As Character, cItem As Character) As Logical Class ReconciliationMessageMessageReader
    Local aArea         As Array    
    Local cQuery 		As Character
 	Local cNextAlias 	As Character
	Local cDtMov 	 	As Character
	Local lRet          As Logical	
    Local oQryCon       As Object	
	Default cBanco	    := ""
	Default cAgencia    := ""
	Default cConta	    := ""
	Default dDtmov	    := CtoD("  /  /  ")
	Default cIdProc		:= ""

	aArea   := GetArea()
	oQryCon	:= Nil   	    
	lRet    := .T.
	If (!Empty(cBanco) .and. !Empty(cAgencia) .and. !Empty(cConta) .and. !Empty(dDtmov) )
		cNextAlias := GetNextAlias()	
		cDtMov	   := DtoS(dDtmov)

		cQuery := "SELECT  "    
		cQuery += "     SIG.IG_FILIAL, "
		cQuery += "     SIG.IG_IDPROC, "
		cQuery += "     MAX(SIG.IG_ITEM) IG_ITEM "
		cQuery += " FROM ? SIG "
		cQuery += " WHERE "
		cQuery += "     SIG.IG_FILIAL = ? AND "
		cQuery += "     SIG.IG_BCOEXT = ? AND "
		cQuery += "     SIG.IG_AGEEXT = ? AND "
		cQuery += "     SIG.IG_CONEXT = ? AND "
		cQuery += "     SIG.IG_DTEXTR = ? AND "
		cQuery += "     SIG.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY SIG.IG_FILIAL, SIG.IG_IDPROC "		
		
		cQuery := ChangeQuery(cQuery)
		oQryCon := FWPreparedStatement():New(cQuery)
		oQryCon:SetUnsafe(1,RetSqlName("SIG"))
		oQryCon:SetString(2,xFilial("SIG"))	
		oQryCon:SetString(3,cBanco)
		oQryCon:SetString(4,cAgencia)
		oQryCon:SetString(5,cConta)
		oQryCon:SetString(6,cDtMov)

		cQuery := oQryCon:GetFixQuery()		
		cNextAlias := MPSysOpenQuery( cQuery )

		(cNextAlias)->(DBGoTop())
		If (cNextAlias)->(!Eof())
			cIdProc	:=  (cNextAlias)->IG_IDPROC
			cItem	:=  (cNextAlias)->IG_ITEM
			lRet    := .F.	
		EndIf		
		(cNextAlias)->(dbCloseArea())	
	End
	If Empty(cIdProc)
		cIdProc := ::ProxNum("SIF")
	EndIf
    
    RestArea(aArea)
    FwFreeArray(aArea)    
    FwFreeObj(oQryCon)
Return lRet
