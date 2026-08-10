#Include "OGA360.CH"
#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} OG360LQVND
Função para realizar a liquidação dos títulos de venda
@type function
@version P12
@author rafael.voltz
@since 14/08/2020
/*/
Function OG360LQVND( cLqdGerada, cCond, cCliLqdDe,cCliLjaDe,cCliLqdPara,cljaLqdPara, cTp, cNaturez, nMoedaOR, cPrefix,cBco,cAg,cConta,dDtVencto,cEmit,nVrOpg,nAcrescLq,nDecrescLq,cQuery,oGridNKK, nRecLiquid)
	// -- Variaveis Local --
	Local nX		:= 1
	Local lContinua	:= .T.
	Local nVrLqdAux	:= 0
	Local cAliasQry := ""
	Local nAtuMod   := nModulo
	Local aItens 	:= {}
	Local aCab 		:= {}
	Local cFilSQL 	:= ""
	Local cTitcSld  := ""

	// VariÃ¡veis utilizadas para o controle de erro da rotina automÃ¡tica
    Private lMsErroAuto := .F.
    Private lAutoErrNoFile := .F.
    
    aSaveLines := FWSaveRows() 		// Salva a posição de todos os Grids
	For nX:= 1 To oGridNKK:Length()
	
		oGridNKK:GoLine( nX )
		
	    IF oGridNKK:IsDeleted()
	       Loop
	    EndIF
	    // Vr. do Titulo a Liquidar = Vr. fixado a Liquidar + Vr. do Frete + Vr. Seguro + Vr. Despesa //
		nVrLqdAux := oGridNKK:GetValue('NKK_VRLQDF') + oGridNKK:GetValue('NKK_FRELQD') + oGridNKK:GetValue('NKK_SEGLQD') + oGridNKK:GetValue('NKK_DSPLQD')
		
		//Como n. Posso Acrescer ou decrescer no titulo e somente na Liquidação entao o vr. a liquidar entao:
		// Se tenho q decrescer -> Tenho q Adicionar no Vr. a Liquidar para no final lançar o decrescimo na liquidação de forma acumulada um unico
		// 		decrescimo de todos os titulos;
		// Se tenho q Acrescer	-> Tenho q Decrescer no Vr. a Liquidar para no Final Lancar o acrescimo  na Liquidacao de forma acumulada um unico
		//      Acrescimo.
		nVrLqdAux += oGridNKK:GetValue('NKK_DECRES') - oGridNKK:GetValue('NKK_ACRESC')
		//Encontrando o Recno do Titulo
		nRecnoTIT := 0
		nRecnoTIT := OG360RgTIT( oGridNKK:GetValue('NKK_TABLQD'), oGridNKK:GetValue('NKK_CPOTIT'),oGridNKK:GetValue('NKK_CHVTIT')  )
			
		IF SE1->(DbGoto( nRecnoTIT ) )
			cMensagem := STR0101 + '[' + SE1->E1_NUM + '/' + SE1->E1_PARCELA + ']' //'TÍtulo não encontrado. O título selecionado pode ter sido exlcuido por outro processo. Titulo/Parcela:'
			lContinua:= .f.
			Exit
		EndIF
		IF lContinua .and.  SE1->E1_SALDO <  nVrLqdAux	
			cAux := '[' + SE1->E1_NUM + '/' + SE1->E1_PARCELA + '/' + SE1->E1_PREFIXO + '/' + SE1->E1_CLIENTE + '-' + SE1->E1_LOJA + ']'
			cMensagem := STR0102 //'Saldo do Titulo está menor do que o Vr. a ser Liquidado pela OP/OR informado na Aba Entregas. Titulo pode ter sido baixado por outro processo. Clique em Refresh TitS/Entregas. em ações do Browse de Entregas e tente confirmar novamente.Pref/Tít/Parc/Forn: '
			cMensagem += cAux
			lContinua := .f. 
			Exit
		EndIF
			
		If lContinua    // Se titulo foi encontrado e o Vr. é suficiente para Baixar defino o filtro das NF para liquidar
		    IF SE1->E1_SALDO <>  nVrLqdAux	
			   cTitcSld = SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
			EndIf

			If nX > 1
				cFilSQL += " OR "
			EndIf
			cFilSQL += " ( "
			cFilSQL += " E1_FILIAL  = '" + SE1->E1_FILIAL + "' AND "
			cFilSQL += " E1_PREFIXO = '" + SE1->E1_PREFIXO + "' AND E1_NUM  = '" + SE1->E1_NUM + "' AND "
			cFilSQL += " E1_PARCELA = '" + SE1->E1_PARCELA + "' AND E1_TIPO = '" + SE1->E1_TIPO + "' AND "
			cFilSQL += " E1_CLIENTE = '" + SE1->E1_CLIENTE + "' AND E1_LOJA = '" + SE1->E1_LOJA + "' )"      
		EndIF
	nExt NX
	FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids

	If lContinua
		If !Empty(cFilSQL) //acrescenta no filtro
			cFilSQL := " (" + cFilSQL + ") AND E1_SITUACA IN ('0','F','G') AND E1_SALDO > 0 AND LTRIM(E1_NUMLIQ) = '' "
		EndIf
		//------------------------------------------------------------
		//Gera o numero(E1_NUM) para a liquidação que será gerada
		//------------------------------------------------------------
		cAliasQry := GetNextAlias()
		cQuery := " SELECT MAX(E1_NUM) AS NUM"
		cQuery += " FROM " + RetSQLName("SE1") + " SE1"
		cQuery += " WHERE E1_FILIAL  = '" + FwxFilial('SE1') + "' "
		cQuery += " AND E1_PREFIXO = '"+cPrefix+"' "
		cQuery += " AND E1_TIPO = '"+cTp+"' "
		cQuery += " AND D_E_L_E_T_ = '' "
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.) 
		If !(cAliasQry)->(Eof()) .AND. !EMPTY((cAliasQry)->NUM)
			cLqdGerada := SOMA1( AllTrim((cAliasQry)->NUM))
		Else
			cLqdGerada := SOMA1("0")
			cLqdGerada := Alltrim(PADL(cLqdGerada,TamSx3("E1_NUMLIQ")[1] ,"0"))
		EndIf
		(cAliasQry)->(dbCloseArea())	

		//------------------------------------------------------------
		//Monta as parcelas de acordo com a condição de pagamento
		//------------------------------------------------------------
		aItens := {}
		If !Empty(cCond)
			aParcelas := Condicao( nVrOpg, cCond,, dDataBase) //condição do OGA360 é somente a vista então não gera mais que uma parcela, usado aqui apenas para pegar a data vencimento correto
			For nX := 1 to Len(aParcelas)
				//Dados das parcelas a serem geradas
				Aadd(aItens,{	{"E1_PREFIXO",cPrefix},; 
								{'E1_NUM', cLqdGerada},;
								{'E1_PARCELA', CVALTOCHAR( nX )},;
								{"E1_EMITCHQ" , "** Liqd. Originação **" },; //Emitente do cheque
								{"E1_VENCTO" , aParcelas[nX,1]},; //Data boa
								{"E1_VLCRUZ" , aParcelas[nX,2]},; //Valor do cheque/titulo
								{"E1_ACRESC" , nAcrescLq },; //Acrescimo
								{"E1_DECRESC" , nDecrescLq }; //Decrescimo
							}) 		
			Next nX
		EndIf
		//------------------------------------------------------------
		//Monta o cabeçalho da liquidação
		//------------------------------------------------------------	
		aCab := {}
		aAdd(aCab, {"cCondicao",    cCond}) //Condição de pagamento
		aAdd(aCab, {"cNatureza",    cNaturez}) //Natureza
		aAdd(aCab, {"E1_TIPO",      cTp}) //Tipo
		aAdd(aCab, {"cCliente",     cCliLqdPara}) //Cliente
		aAdd(aCab, {"cLoja",        cljaLqdPara}) //Loja
		aAdd(aCab, {"nMoeda",       nMoedaOR}) //Moeda
		aAdd(aCab, {"AUTMRKPIX",    .F.}) //Pix

		nModulo := 6
		lContinua := Fina460(/*nPosArotina*/,aCab,aItens,3,cTitcSld,/*xNumLiq*/,/*xRotAutoVa*/,/*xOutMoe*/,/*xTxNeg*/,/*xTpTaxa*/,/*xFunOrig*/,/*xTxCalJur*/,cFilSQL)
		nModulo := nAtuMod

		If lMsErroAuto .OR. !lContinua
			MostraErro()
			lContinua := .F.
		Else
			//conferencia do titulo liquidado
			cAliasQry := GetNextAlias()
			cQuery := " SELECT SE1.R_E_C_N_O_ AS RECNO, E1_NUM AS NUM, E1_NUMLIQ AS NUMLIQ "		
			cQuery += " FROM " + RetSQLName("SE1") + " SE1"
			cQuery += " WHERE SE1.D_E_L_E_T_ = '' AND E1_FILIAL = '"+FWxFilial("SE1")+"' "
			cQuery += " AND E1_PREFIXO = '"+cPrefix+"' AND E1_TIPO='"+cTp+"' "
			cQuery += " AND E1_CLIENTE='"+cCliLqdPara+"' AND E1_LOJA='"+cljaLqdPara+"' AND E1_NUM='"+cLqdGerada+"' "
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.) 
			If !(cAliasQry)->(Eof()) .and. aLLTRIM((cAliasQry)->(NUM)) == cLqdGerada
				nRecLiquid := (cAliasQry)->(RECNO)                        
			Else
				AgrHelp(STR0013, STR0099,STR0100)  //"Houve um erro na identificação do registro da liquidação do título."          //"Por favor, configura os dados do título a ser liquidado."
				lContinua := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())	
		EndIf
	EndIf

Return lContinua
