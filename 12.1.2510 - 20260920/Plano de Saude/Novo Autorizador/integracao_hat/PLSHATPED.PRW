#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "hatActions.ch"

#define _glossProtocol_B4D_alt              "0054"
//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATPedPD
Funcao generica de cadastro de pedidos simples.

	cCodtra  -> Codigo do EndPoint                            
	cAlias -> Alias da tabela que esta sendo gravada 
	cChave -> Chave do registro na tabela correspondente
	aDadosAlt -> Array com os campos que sao enviados no HAT 
	nInd -> Indice para posicionar no registro correspondente

@author  Renan Sakai 
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATPedPD(nOpc,cCodtra,cAlias,cChave,aDadosAlt,nInd,nRecno)
Local nX := 0
Local cCamposAlt  := ""
Local cBase       := ""
Local cAlt        := ""
Local lFind       := .F.
Local aArea       := (cAlias)->(GetArea())
Default aDadosAlt := {}
Default nInd      := 1
Default nRecno    := 0

if PLHTACTRA(cCodtra)

	if nOpc == K_Incluir
		PLHTGrvPed(cCodtra,cChave,"",cAlias,nRecno)

	elseif nOpc == K_Alterar
		(cAlias)->(DbSetOrder(nInd))
		//Para achar o registro, priorizo a busca pelo Recno
		if nRecno > 0
			(cAlias)->(DbGoTo(nRecno))
			lFind := .T.
		elseIf (cAlias)->(MsSeek(xFilial(cAlias)+cChave)) 
			lFind := .T.
		endIf

		if lFind
			for nX := 1 to len(aDadosAlt)
				if Valtype(&(cAlias+"->"+aDadosAlt[nX][1])) == "C"
					cBase := Alltrim(&(cAlias+"->"+aDadosAlt[nX][1]))
					cAlt  := Alltrim(aDadosAlt[nX][2])
					iif(cBase <> cAlt .Or. cAlt <> cBase,cCamposAlt += ","+aDadosAlt[nX][1],cCamposAlt += "")
				else
					iif(&(cAlias+"->"+aDadosAlt[nX][1]) <> aDadosAlt[nX][2],cCamposAlt += ","+aDadosAlt[nX][1],cCamposAlt += "")
				endIf
			next
			
		endIf
		
		if !Empty(cCamposAlt)
			PLHTGrvPed(cCodtra,cChave,cCamposAlt,cAlias,nRecno)
		endIf
				
	endIf

	//Se for uma transacao prioritaria, ja realizo o envio
	VerifPrior(cCodtra)
	restArea(aArea)

endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATPedGD
Funcao generica de cadastro padrão de Grids

	cCodtra  -> Codigo do EndPoint                            
	cAlias -> Alias da tabela que esta sendo gravada 
	cChave -> Chave do registro na tabela correspondente
	aDadosAlt -> Array com os campos que sao enviados no HAT 
	nInd -> Indice para posicionar no registro correspondente

@author  Renan Sakai 
@version P12
@since   06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATPedGD(nOpc,cCodTraInc,cCodTraAlt,cAlias,aHeader,aCols,nInd,aChave,cCompChave,aCamposAlt)
Local nX   := 0
Local nY   := 0
Local nPos := 0
Local cChave  := ""
Local cBase   := ""
Local cAlt    := ""
Local cCamposAlt := ""
Local aArea       := (cAlias)->(GetArea())
Local lExitChave  := .F.
Default nInd      := 1

(cAlias)->(DbSetOrder(nInd))

for nX := 1 to len(aCols)
	cCamposAlt := "" //Reinicializa campos alterados
	lExitChave := .F.

	//Se o registro esta deletado, pula
	if aCols[nX][len(aHeader)+1]
		loop
	endIf

	//Monta a chave
	for nY := 1 to len(aChave)
		if nY == 1 .And. !Empty(cCompChave)
			cChave := cCompChave
		endIf
		nPos := PLRETPOS(aChave[nY],aHeader)
		if nPos > 0 
			if Empty(aCols[nX][nPos])
				lExitChave := .T.
			else
				cChave += aCols[nX][nPos]
			endIf	
		endIf	
	next

	//Se algum campo da chave estiver vazio, nao incluo o registro
	if lExitChave //IMPORTANTE: Analisar se tem algum Alias que pode vir com Chave vazia
		loop
	endIf
	
	//Procura o registro 
	if nOpc == K_Alterar .And. (cAlias)->(MsSeek(xFilial(cAlias)+cChave))
		for nY := 1 to len(aCamposAlt) 
			nPos := PLRETPOS(aCamposAlt[nY],aHeader)
			if nPos > 0 
				if Valtype(&(cAlias+"->"+aCamposAlt[nY])) == "C"
					cBase := Alltrim(&(cAlias+"->"+aCamposAlt[nY]))
					cAlt  := Alltrim(aCols[nX][nPos])
					iif(cBase <> cAlt .Or. cAlt <> cBase,cCamposAlt += ","+aCamposAlt[nY],cCamposAlt += "")
				else
					iif( &(cAlias+"->"+aCamposAlt[nY]) <> aCols[nX][nPos],cCamposAlt += ","+aCamposAlt[nY],cCamposAlt += "")
				endIf
			endIf	
		next
		if !Empty(cCamposAlt)
			PLHTGrvPed(cCodTraAlt,cChave,cCamposAlt,cAlias)
		endIf
	//Nao encontrou o registro, e uma inclusao
	else
		PLHTGrvPed(cCodTraInc,cChave,"",cAlias)
	endIf
next	

//Se for uma transacao prioritaria, ja realizo o envio
VerifPrior(cCodTraInc)
restArea(aArea)

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATPrior
Faz o envio para o HAT de pedidos prioritarios

@author  Renan Sakai 
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATPrior(cEmp,cFil,cCodtra)
Local aRet := {}

RpcSetType(3)
RpcSetEnv(cEmp,cFil,,,'PLS')

aRet := PLHATEndPo(cCodtra)
PLHTPosGen(aRet[1],aRet[2],aRet[3],aRet[4],aRet[5])

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATBCI
Realiza a gestao do cadastro de protocolos de faturamento do prestador

@author  Renan Sakai 
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATBCI(nOpc,cCodOpe,cCodLdp,cCodPeg)

	PLHTGrvPed(_billing_BCI_alt,cCodOpe+cCodLdp+cCodPeg,"","BCI")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATB4D
Atualiza a BCI do HAT com os dados do recurso de glosa

@author  Lucas Nonato
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATB4D(cProtoc)

	PLHTGrvPed(_glossProtocol_B4D_alt, cProtoc, "", "B4D")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLHTGrvPed
Funcao padrao para a gravacao fisica de um Pedido

@author  Renan Sakai
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHTGrvPed(cCodTra,cChave,cCamposAlt,cAlias,nRecno)
Local aCampos  := {}
Local lFindBNV := .F.
Default cChave     := ""
Default cCamposAlt := ""
Default cAlias     := ""
Default nRecno     := 0

if PLHTACTRA(cCodtra)

	BNV->(DbSetOrder(2)) //BNV_FILIAL+BNV_CODTRA+BNV_ALIAS+BNV_CHAVE
	if BNV->(MsSeek(xFilial("BNV")+cCodTra+cAlias+cChave))
		while Alltrim(BNV->(BNV_FILIAL+BNV_CODTRA+BNV_ALIAS+BNV_CHAVE)) == Alltrim(xFilial("BNV")+cCodTra+cAlias+cChave) .And. !BNV->(Eof())
			if BNV->BNV_STATUS == "0"
				lFindBNV := .T.
				Exit
			endIf
			BNV->(DbSkip())	
		endDo
	endIf

	// Importante: esta tratativa de nao gerar pedido repetido com BNV_STATUS = 0
	// deve ser removida se implementado ajuste para gravar o campo BNV_CAMPOS
	if !lFindBNV
		//Monto o array para registrar o pedido
		aadd( aCampos,{ "BNV_FILIAL", xFilial("BNV") })
		aadd( aCampos,{ "BNV_CODIGO", GetSXENum( "BNV","BNV_CODIGO" ) })
		aadd( aCampos,{ "BNV_CODTRA", cCodtra })
		aadd( aCampos,{ "BNV_CHAVE" , cChave })
		aadd( aCampos,{ "BNV_CAMPOS", "" }) //Mandar sempre todos os campos para o HAT, posteriormente iremos checar os campos alterados
		aadd( aCampos,{ "BNV_STATUS", "0" })
		aadd( aCampos,{ "BNV_ALIAS" , cAlias })    
		aadd( aCampos,{ "BNV_DATCRI", Date() })
		aadd( aCampos,{ "BNV_HORCRI", Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2) })
		aadd( aCampos,{ "BNV_IDINT" , nRecno })
		BNV->(ConfirmSX8())

		PLS274GRV( K_Incluir, aCampos )
	endIf
endIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} VerifPrior
Verfica se uma acao e prioritaria e ja realiza o envio

@author  Renan Sakai 
@version P12
@since    16.10.18
/*/
//-------------------------------------------------------------------
Static Function VerifPrior(cCodtra)

BNN->(DbSetOrder(1))//BNN_FILIAL+BNN_CODTRA
if BNN->(MsSeek(xFilial("BNN")+cCodtra)) .And. BNN->BNN_PRIORI == "1"
	StartJob("PLHATPrior",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cCodtra)
endIf

Return

//

//-------------------------------------------------------------------
/*/{Protheus.doc} PLHTACTRA
description Verifica se a transação está ativa
@author  karine.limp
@since   2020-12-01
@version 1.0
/*/
//-------------------------------------------------------------------
function PLHTACTRA(cCodtra)
	local aActiveTransactions := PLHTRACT()
return aScan(aActiveTransactions, cCodTra) > 0

//-------------------------------------------------------------------
/*/{Protheus.doc} PLHTRACT
description Retorna as transações ativas
@author  karine.limp
@since   2020-12-01
@version 1.0
/*/
//-------------------------------------------------------------------
function PLHTRACT()
	local aActiveTransactions := {}
	local cIniFile := PLSMUDSIS("\plshat.ini")
	local aActiveIni := StrTokArr2(GetPvProfString( "CONFIG", "activeIntegration" , "", cIniFile ), ",")
	local nInt := 1

    // * Considero todas as transações ativas caso não tenha a config no INI
    if empty(aActiveIni)
        aActiveTransactions := { _billing_BCI_alt, _glossProtocol_B4D_alt }
    else

        for nInt := 1 to len(aActiveIni)
            do case
                case aActiveIni[nInt] == "billing_BCI"
                    aAdd(aActiveTransactions, _billing_BCI_alt)
				case aActiveIni[nInt] == "_glossProtocol_B4D_alt"
                    aAdd(aActiveTransactions, _glossProtocol_B4D_alt)	
            endCase
        next nInt

    endIf
return aActiveTransactions
//--------------------------------------------------------------------
