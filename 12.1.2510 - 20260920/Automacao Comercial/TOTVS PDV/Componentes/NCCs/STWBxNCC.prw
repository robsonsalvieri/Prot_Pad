#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 

//-------------------------------------------------------------------
/*/ {Protheus.doc} STWBxNCC
Realiza a baixa das NCCs selecionadas 

@param   	
@author  	Varejo
@version 	P11.85
@since   	05/03/2013
@return  	lRet - Retorna se realizou a baixa
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STWBxNCC()

Local aNCCs         := STDGetNCCs("1")                  // NCC selecionadas
Local aParam        := {}                               // Array com os parametros que serao passados para o STBRemoteExecute
Local cL1Doc        := STDGPBasket("SL1","L1_DOC")      // Valor do campo L1_DOC
Local cL1Serie      := STDGPBasket("SL1","L1_SERIE")    // Valor do campo L1_SERIE
Local cSerEst       := ""								// Serie da estacao, essa informação sera gravada no prefixo da E1
Local cMvLjPref		:= SuperGetMV("MV_LJPREF")			// Regra para gravacao do E1_PREFIXO
Local cL1Oper       := STDGPBasket("SL1","L1_OPERADO")  // Valor do campo L1_DOC
Local cL1Cliente    := STDGPBasket("SL1","L1_CLIENTE")  // Valor do campo L1_CLIENTE
Local cL1Loja       := STDGPBasket("SL1","L1_LOJA")	    // Valor do campo L1_LOJA
Local dL1EmisNf     := STDGPBasket("SL1","L1_EMISNF")   // Valor do campo L1_EMISNF
Local oTotal        := STFGetTot()                      // Recebe o objeto do model para recuperar os valores
Local nValorUsado   := STDGetNCCs("2")                  // Valor total das NCCs utilizadas
Local lOnLine       := .F.
Local cMVLjNCCBC    := SuperGetMv("MV_LJNCCBC")
Local aProfile      := {}

/*
	nNccGerada = Valor da NCC gerada ((Total da venda - Desconto total) - Valor total das NCCs utilizadas
*/
Local nNccGerada    := oTotal:GetValue("L1_VLRTOT") - nValorUsado
Local nL1Credit     := nValorUsado
Local uResult       := Nil
Local nTPCompNCC	:= SuperGetMV("MV_LJCPNCC",,1)		// Tratamento para compensacao de NCC 1 - INCLUSAO DE NOVO TITULO |2 - ALTERACAO DO SALDO |3 - BAIXA TOTAL DA NCC |4 - SALDO DA NCC COM TROCO
Local aSe1Num		:= STWNumTit() //Retorna o que sera gravado no E1_NUM e E1_SERIE

//Tratamento para geração de NCC
If nTPCompNCC == 2
	If nValorUsado > oTotal:GetValue("L1_VLRTOT") 
		nNccGerada := nValorUsado - oTotal:GetValue("L1_VLRTOT")
	Else
		nNccGerada := 0
	EndIf
EndIf

cL1Doc := aSe1Num[1] 
cL1Serie := aSe1Num[2]

//Como no PDV eu ainda não tenho a SF2 pego a serie da SL1
If AllTrim(Upper(cMvLjPref)) == "SF2->F2_SERIE"	
	cSerEst  := cL1Serie
Else
	cSerEst := &(cMvLjPref)
EndIf	

LjGrvLog( "L1_NUM: " + cL1Doc, "Baixa NCC", /*xVar*/ ) //Grava Log =====================================================================

STBRemoteExecute( "STFCOMMUOK", NIL, NIL, .F., @lOnLine )

LjGrvLog( "L1_NUM: " + cL1Doc, "NCC Gerada PDV", nNccGerada ) //Grava Log =====================================================================
LjGrvLog( "L1_NUM: " + cL1Doc, "MV_LJNCCBC", cMVLjNCCBC ) //Grava Log =====================================================================
LjGrvLog( "L1_NUM: " + cL1Doc, "Comunicação STFCOMMUOK ", lOnLine ) //Grava Log =====================================================================

If !lOnline .AND. cMVLjNCCBC == "3" // MV_LJNCCBC = 1 - Online apenas

	STFMessage(ProcName(),"STOP","Falha de comunicação. Não será possível utilizar a Nota de Crédito.") // "Falha de comunicação. Não será possível utilizar a Nota de Crédito."
	STFShowMessage(ProcName())
	
Else	
	
	If !lOnline .AND. cMVLjNCCBC == "2" // Solicita senha do supervisor para liberacao de NCC offline.
	
		aProfile := STFProFile(36) 
	
	EndIf
	
	If Len(aProfile) == 0 .OR. aProfile[1]
		
		aParam 	:= {aNCCs    , nValorUsado, nNccGerada, cL1Doc	 ,;
				   cSerEst	 , cL1Serie   , cL1Oper	  , dL1EmisNf,;
				   cL1Cliente, cL1Loja	  , nL1Credit , !lOnLine}
		
		STBRemoteExecute("STWBOBxNCC", aParam,,.T., @uResult)
		
		LjGrvLog( "L1_NUM: " + cL1Doc, "Conseguiu dar baixa na NCC PDV ", uResult ) //Grava Log =====================================================================		
		
	EndIf

	
EndIf

Return


//-------------------------------------------------------------------
/*/ {Protheus.doc} STWNumTit
Funcao para decidir se na geracao da compensacao da NCC (SE1) sera
utilizado do L1_DOC ou L1_DOCPED para o E1_NUM 

@param   	
@author  	Varejo
@version 	P12
@since   	28/11/2013
@return  	lRet - Retorna se realizou a baixa
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWNumTit()
Local cMvLjE1Num := SuperGetMV("MV_LJE1NUM",,"1") //Permite configurar como sera gerado o numero do tiulo da venda (campo E1_NUM)
Local cE1Num := "" //Numero para geracao do titulo na baixa da NCC
Local cE1Ser := "" //Serie para geracao do titulo na baixa da NCC

Do Case
	Case cMvLjE1Num == "1" //Opcao 1: Default - Comportamento Padrao do Sistema (para manter o legado)
		
		cE1Num := If(Empty(STDGPBasket("SL1","L1_DOCPED")),STDGPBasket("SL1","L1_DOC"),STDGPBasket("SL1","L1_DOCPED"))
		cE1Num := If(Empty(cE1Num) .And. !Empty(STDGPBasket("SL1","L1_DOCRPS")),STDGPBasket("SL1","L1_DOCRPS"),cE1Num)
		cE1Ser := If(Empty(STDGPBasket("SL1","L1_SERPED")),STDGPBasket("SL1","L1_SERIE"),STDGPBasket("SL1","L1_SERPED"))
		cE1Ser := If(Empty(cE1Ser) .And. !Empty(STDGPBasket("SL1","L1_SERRPS")),STDGPBasket("SL1","L1_SERRPS"),cE1Ser)
			
	Case cMvLjE1Num == "2" //Opcao 2: Considera o Numero do Orcamento ou Numero do Orcamento Pai quando existir Pedido (L1_NUM)
		
		cE1Num := STDGPBasket("SL1","L1_NUM") 			//Numero do orcamento
		cE1Ser := STDGPBasket("SL1","L1_SERIE")
		
EndCase

Return {cE1Num,cE1Ser}
