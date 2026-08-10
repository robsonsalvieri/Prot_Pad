#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH" 

Function WsMat241; Return                      

WSSTRUCT InternalMovimentHeader
	WSDATA CompanyCode	 	As String  Optional	//Empressa
	WSDATA BranchCode	 	As String  Optional	//Filial
	WSDATA DocumentNumber 	As String  Optional	//Documento
	WSDATA MovimentType 	As String			//TM
	WSDATA CostCenter 		As String  Optional	//Centro de Custo
	WSDATA IssueDate		As String			//Data de Emissão
	WSDATA IdMensagem 		As String  Optional	//Identificacao da mensagem
	WSDATA OriBoletim		As String  Optional //Origem movimento
	WSDATA Operacao 		As Integer Optional	//Tpo de operacao: 3- Inclusao; 6- Estorno
ENDWSSTRUCT                            

WSSTRUCT  InternalMovimentItem
	WSDATA ProductCode		As String		   //Cod. Produto
	WSDATA Quantity			As Float		   //Quantidade
	WSDATA LedgerAccount	As String Optional //Conta Contabil
	WSDATA ProductionOrder	As String Optional //Ordem de Produção
	WSDATA WareHouse		As String Optional //Armazem
	WSDATA QtySecMeasure 	As Float  Optional //Qtde 2UM
	WSDATA Cost			 	As Float  Optional //Custo
	WSDATA CostCurr2	 	As Float  Optional //Custo moeda2
	WSDATA CostCurr3	 	As Float  Optional //Custo moeda3
	WSDATA WMSRule			As String Optional //Regra WMS
	WSDATA SequenceID		As String Optional //Sequencia
	WSDATA Lot				As String Optional //Lote
	WSDATA Sublot			As String Optional //Sublote
	WSDATA Adress			As String Optional //Endereco
	WSDATA SeriesNO			As String Optional //Numero de Serie
	WSDATA AccountingItem	As String Optional //Item Contabil
	WSDATA ValueClass		As String Optional //Classe Valor
	WSDATA ProjectCode		As String Optional //Cod. Projeto (PMS)
	WSDATA TaskCode			As String Optional //Cod. Tarefa (PMS)
	WSDATA ServiceOrder		As String Optional //Ordem de Servico (MNT)
	WSDATA ServiceCode		As String Optional //Cod. Servico (WMS)
	WSDATA IdBoletim    	As String Optional //Detalhe do boletim enviado pelo PIMS
	WSDATA NrBoletim		As String Optional //Nr. Boletim do Pims
	WSDATA CostCenter 		As String Optional	//Centro de Custo
ENDWSSTRUCT

WSSTRUCT InternalMoviment
	WSDATA IMHeader			As InternalMovimentHeader
	WSDATA IMItens			As Array Of InternalMovimentItem
ENDWSSTRUCT

WSSERVICE MtInternalMoviment DESCRIPTION "'Serviço para inclusão de movimentos internos." NAMESPACE "http:webservices.microsiga.com.br/mtinternalmoviment.apw" //"Serviço de consulta e atualização das ordens de produção "
WSDATA Moviment 			As InternalMoviment
WSDATA WSNull				As String

WSMETHOD PutInternalMoviment DESCRIPTION "Método de inclusão de movimentos internos" //"Método de inclusão de movimentos internos"
ENDWSSERVICE

WSMETHOD PutInternalMoviment WSRECEIVE Moviment WSSEND WSNull WSSERVICE MtInternalMoviment
Local aCab  		:= {}
Local aItens		:= {}
Local aErro 		:= {}
Local cTM           := ""
Local cErro 		:= ""
Local cOK           := "Operação efetuada com sucesso!"
Local lRetorno 		:= .T.
Local lPIMSINT 		
Local nX    		:= 0 

PRIVATE oIMHeader       := Moviment:IMHeader
PRIVATE aIMItens        := Moviment:IMItens
PRIVATE lMsErroAuto		:= .F.
PRIVATE lAutoErrNoFile	:= .T.        

If !Empty(oIMHeader:CompanyCode) .And. !Empty(oIMHeader:BranchCode)// Empresa e Filial
	RPCSetType(3)  // Nao utilizar licensa
	RpcSetEnv(oIMHeader:CompanyCode,oIMHeader:BranchCode)
EndIf

lPIMSINT:= SuperGetMV("MV_PIMSINT",.F.,.F.) //Indica se Existe Integração Protheus x PIMS Graos 

aadd(aCab, {"D3_DOC"		, PadR(Moviment:IMHeader:DocumentNumber,TamSX3("D3_DOC")[1])	, Nil } ) //Documento
aadd(aCab, {"D3_TM"			, PadR(Moviment:IMHeader:MovimentType,TamSX3("D3_TM")[1])		, Nil } ) //TM 
aadd(aCab, {"D3_CC"			, PadR(Moviment:IMHeader:CostCenter,TamSX3("D3_CC")[1])		, Nil } ) //Centro de Custo
aadd(aCab, {"D3_EMISSAO"	, cTod(Moviment:IMHeader:IssueDate)								, Nil } ) //Data de Emissão

dbSelectArea("SB1")
dbSetOrder(1)
For nX := 1 To Len(Moviment:IMItens)                                                  
	If !Empty(Moviment:IMItens[nX]:ProductCode)
		aAdd(aItens,{})
		dbSeek(xFilial("SB1")+Moviment:IMItens[nX]:ProductCode)
	
		//-- Preenche campos obrigatorios
		aAdd(aTail(aItens), {"D3_COD"		, PadR(Moviment:IMItens[nX]:ProductCode,Len(SB1->B1_COD))	, Nil }) //Cod. Produto,
	 	aAdd(aTail(aItens), {"D3_QUANT"		, Moviment:IMItens[nX]:Quantity				, Nil }) //Quantidade
	 	aAdd(aTail(aItens), {"D3_UM"		, SB1->B1_UM								, Nil }) //Unidade de Medida
		If !Empty(Moviment:IMItens[nX]:WareHouse)
			aAdd(aTail(aItens), {"D3_LOCAL"	, Moviment:IMItens[nX]:WareHouse			, Nil }) //Armazem
		Else
			aAdd(aTail(aItens), {"D3_LOCAL"	, SB1->B1_LOCPAD			, Nil }) //Armazem
		EndIf
	 	
		//-- Preenche campos opcionais
		If !Empty(Moviment:IMItens[nX]:QtySecMeasure)
			aAdd(aTail(aItens), {"D3_QTSEGUM"	, Moviment:IMItens[nX]:QtySecMeasure		, Nil }) //Qtde 2UM
		EndIf
		If !Empty(Moviment:IMItens[nX]:Cost)
			aAdd(aTail(aItens), {"D3_CUSTO1"	, Moviment:IMItens[nX]:Cost					, Nil }) //Custo 
		EndIf
		If !Empty(Moviment:IMItens[nX]:CostCurr2)
			aAdd(aTail(aItens), {"D3_CUSTO2"	, Moviment:IMItens[nX]:CostCurr2	    	, Nil }) //Custo moeda2
		EndIf
		If !Empty(Moviment:IMItens[nX]:CostCurr3)
			aAdd(aTail(aItens), {"D3_CUSTO3"	, Moviment:IMItens[nX]:CostCurr3			, Nil }) //Custo moeda3
		EndIf
		If !Empty(Moviment:IMItens[nX]:LedgerAccount)
			aAdd(aTail(aItens), {"D3_CONTA"		, Moviment:IMItens[nX]:LedgerAccount		, Nil }) //Conta Contabil
		EndIf
		If !Empty(Moviment:IMItens[nX]:ProductionOrder)
			aAdd(aTail(aItens), {"D3_OP"		, Moviment:IMItens[nX]:ProductionOrder		, Nil }) //Ordem de Produção
		EndIf
		If !Empty(Moviment:IMItens[nX]:WMSRule)
			aAdd(aTail(aItens), {"D3_REGWMS"	, Moviment:IMItens[nX]:WMSRule				, Nil }) //Regra WMS
		EndIf
		If !Empty(Moviment:IMItens[nX]:SequenceID)
			aAdd(aTail(aItens), {"D3_NUMSEQ"	, Moviment:IMItens[nX]:SequenceID			, Nil }) //Sequencia
		EndIf
		If !Empty(Moviment:IMItens[nX]:Lot)
			aAdd(aTail(aItens), {"D3_LOTECTL"	, Moviment:IMItens[nX]:Lot					, Nil }) //Lote
		EndIf
		If !Empty(Moviment:IMItens[nX]:Sublot)
			aAdd(aTail(aItens), {"D3_NUMLOTE"	, Moviment:IMItens[nX]:Sublot				, Nil }) //Sublote
		EndIf
		If !Empty(Moviment:IMItens[nX]:Adress)
			aAdd(aTail(aItens), {"D3_LOCALIZ"	, Moviment:IMItens[nX]:Adress				, Nil }) //Endereco
		EndIf
		If !Empty(Moviment:IMItens[nX]:SeriesNO)
			aAdd(aTail(aItens), {"D3_NUMSERI"	, Moviment:IMItens[nX]:SeriesNO				, Nil }) //Numero de Serie
		EndIf
		If !Empty(Moviment:IMItens[nX]:AccountingItem)
			aAdd(aTail(aItens), {"D3_ITEMCTA"	, Moviment:IMItens[nX]:AccountingItem		, Nil }) //Item Contabil
		EndIf
		If !Empty(Moviment:IMItens[nX]:ValueClass)
			aAdd(aTail(aItens), {"D3_CLVL"		, Moviment:IMItens[nX]:ValueClass			, Nil }) //Classe Valor
		EndIf
		If !Empty(Moviment:IMItens[nX]:ProjectCode)
			aAdd(aTail(aItens), {"D3_PROJPMS"	, Moviment:IMItens[nX]:ProjectCode			, Nil }) //Cod. Projeto (PMS)
		EndIf
		If !Empty(Moviment:IMItens[nX]:TaskCode)
			aAdd(aTail(aItens), {"D3_TASKPMS"	, Moviment:IMItens[nX]:TaskCode				, Nil }) //Cod. Tarefa (PMS)
		EndIf
		If !Empty(Moviment:IMItens[nX]:ServiceOrder)
			aAdd(aTail(aItens), {"D3_ORDEM"		, Moviment:IMItens[nX]:ServiceOrder			, Nil }) //Ordem de Servico (MNT)
		EndIf
		If !Empty(Moviment:IMItens[nX]:ServiceCode)
			aAdd(aTail(aItens), {"D3_SERVIC"	, Moviment:IMItens[nX]:ServiceCode			, Nil }) //Cod. Servico (WMS)
		EndIf
		If !Empty(Moviment:IMItens[nX]:NrBoletim)
			aAdd(aTail(aItens), {"D3_NRBPIMS"	, Moviment:IMItens[nX]:NrBoletim	   		, Nil }) //Nr. Boletim do Pims
		EndIf
		If !Empty(Moviment:IMItens[nX]:CostCenter)
			aAdd(aTail(aItens), {"D3_CC"    	, PadR(Moviment:IMItens[nX]:CostCenter,TamSX3("D3_CC")[1]), Nil }) //Centro de Custo
		EndIf
	EndIf
Next 

If oIMHeader:operacao == 6   
	SD3->(DbSetOrder(2))
	If SD3->(dbSeek(xFilial("SD3")+Alltrim(Moviment:IMHeader:DocumentNumber),.F.))
		aCab	:= {}
		aItens  := {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua o estorno do movimento de estoque³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MSEXECAUTO({|x,y,z|MATA241(x,y,z)},aCab,aItens,6)
	EndIf	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Execucao da rotina automatica de Movimentos Internos Mod 2 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSEXECAUTO({|x,y,z|MATA241(x,y,z)},aCab,aItens,3)
EndIf 

If lMsErroAuto                                                     
	aErro := GetAutoGRLog() 
	For nX := 1 To Len(aErro)
	   	cErro += alltrim(aErro[nX])+Chr(13)+Chr(10)
	Next nX 
	cErro := StrTran(cErro,"<","")
	SetSoapFault("PutInternalMoviment",cErro)
	lRetorno := .F.
	
	If lPIMSINT //-- Retorno de erro na movimentacao.
		PIMSxResposta(cErro, .F., "", cTod(Moviment:IMHeader:IssueDate))
	EndIf
		         	
ElseIf lPIMSINT .And. SuperGetMv("MV_CUSMED",.F.,"M") <> "O" //-- Retorno de sucesso na movimentacao.
	PIMSxResposta(cOk, .T., SD3->D3_DOC, SD3->D3_EMISSAO)
ElseIf lPIMSINT .And. oIMHeader:operacao == 6 .And. (Alltrim(oIMHeader:MovimentType) > '500') //--Retorno de sucesso na requisacao de materiais.
	PIMSxResposta(cOk, .T., SD3->D3_DOC, SD3->D3_EMISSAO)
EndIf	   

RestInter()
RpcClearEnv()
Return(lRetorno)