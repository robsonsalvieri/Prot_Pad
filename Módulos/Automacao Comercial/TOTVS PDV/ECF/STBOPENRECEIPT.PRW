#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STBOPENRECEIPT.CH"

//-------------------------------------------------------------------
/*/ {Protheus.doc} STBOpenReceipt
Function Abre cupom

@param   cCliCode		Codigo do Cliente
@param   cCliStore		Loja do Cliente	
@param   lPrintCNPJ		Imprime CNPJ		 

@author  Varejo
@version P11.8
@since   14/03/2013
@return  lRet 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBOpenReceipt( cCliCode, cCliStore, lPrintCNPJ )

Local cCNPJCli 	:= "" 				//CNPJ do Cliente
Local aRet 		:= {}  			//Retorno da função
Local lInfoEnd 	:= .T. 			//informa endereço 
Local lRet 		:= .T.   			//Retorno	
Local lVldSerie := .T.				//Validou serie
Local cDoc		:= ""				//Documento
Local cContDoc	:= ""				//Contador de documento
Local cHora 	:= Left(Time(),TamSX3("L1_HORA")[1])	//Hora
Local cHoraECF	:= ""				// Hora ECF
Local nTamDocEcf:= 6				//Tamnho do Numero do Cupom ( 6 ou 9 digitos)
Local lAutomato     :=  If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default cCliCode 		:= ""
Default cCliStore 	:= ""
Default lPrintCNPJ 	:= .T.

ParamType 1 Var cCliCode		AS Character		Default ""
ParamType 2 Var cCliStore		AS Character	Default ""
ParamType 3 Var lPrintCNPJ		AS Logical		Default .T.

If  !STBIsPaf()
	lPrintCNPJ				:=  LJAnalisaLeg(30)[1] //Verificar se é São Paulo?		
	lVldSerie				:= LJAnalisaLeg(20)[1] .Or.  SuperGetMV( "MV_LJGRVVB", ,.F. )  //Valida a Serie?
	lInfoEnd				:= LJAnalisaLeg(58)[1]  //RS Informa o Endereço?
Else
	lVldSerie := lVldSerie .Or. SuperGetMV( "MV_LJGRVVB", ,.F. ) 
EndIf

//O +1 no doc eh preciso pois como nao abriu o cupom ainda
//nao gerou o novo COO e estava trazendo o COO da venda anterior.
cDoc	:=	STBRetCup()
nTamDocEcf := STBLenReceipt(cDoc)

//Quando TamDoc diferente do padrao 6, valida se o campo contdoc esta preparado para evitar erro de gravacao
If nTamDocEcf > 6 .AND. TamSX3("L1_CONTDOC")[1] < nTamDocEcf
	lRet := .F.
	STFMessage("STBOPENRECEIPT","POPUP", STR0002 + CHR(13) + STR0003) //"Impressora Fiscal retornou documento com tamanho maior que o dicionário de dados(L1_CONTDOC)."  ## "Não será possível realizar vendas." 	
	STFShowMessage("STBOPENRECEIPT")
EndIf

If lRet
	cDoc		:=  StrZero(Val(cDoc)+1,nTamDocEcf)
	cContDoc	:=	STBRetCoD()
	cContDoc	:=  StrZero(Val(cContDoc)+1,nTamDocEcf)
	
	If STBHomolPaf()
		//FI_FILIAL+DTOS(FI_DTMOVTO)+FI_PDV+FI_NUMREDZ
		DbSelectArea("SFI")
		DbSetOrder(1)//FI_FILIAL+DTOS(FI_DTMOVTO)+FI_PDV+FI_NUMREDZ
		If DbSeek(xFilial("SFI") + DTOS(dDataBase))
			 lRet := .F.
			 //JA Emitiu z
			 STFMessage("STBOPENRECEIPT","POPUP", STR0001)	//"Não será possivel realizar vendas. Redução Z já foi emitida."
			 STFShowMessage("STBOPENRECEIPT")
		EndIf
	Else
		lRet := !FindFunction("STWActivePrinter") .Or. STWActivePrinter(.T.) .Or. lAutomato
	EndIf
	
	If lRet .AND. !lAutomato
	
		aRet := STFFireEvent(	ProcName(0)		,;	// Nome do processo
						"STOpenReceipt"			,;	// Nome do evento
						{cCNPJCli				,;	// 01 - CPF|CNPJ do Cliente
						cCliCode 				,; 	// 02 - Codigo do cliente
						cCliStore				,;	// 03 - Loja do cliente
						lPrintCNPJ				,;	// 04 - Indica se for impresso o CPF/CNPJ no Cupom	
						lVldSerie				,;	// 05 - Define se Valida a Serie
						lInfoEnd		 		})	// 06 - Informa o endereço               
		
		lRet := Len(aRet) == 0 .OR. (ValType(aRet[1]) == "N" .AND. aRet[1] == 0)
	
	EndIf
EndIf

//Se Conseguiu Abrir Cupom atualiza Cesta de Venda
If lRet
	
	// "02" - Impresso a Abertura do Cupom
	STDSPBasket( "SL1" , "L1_SITUA"		, "02"	)
	// Numero do documento  					
	STDSPBasket( "SL1" , "L1_DOC"		, cDoc )
	// Numero cupom fiscal
	STDSPBasket( "SL1" , "L1_NUMCFIS"	, cDoc )
	// Serie do PDV
	STDSPBasket( "SL1" , "L1_SERPDV"	, STFGetStat("SERPDV") )	
	// TODO: do PAF segunda PAF
	STDSPBasket( "SL1" , "L1_CONTDOC"	, cContDoc )
	 
	If STFGetCfg("lPafEcf") 
		STWPrinterStatus('1',@cHoraECF)
		STDSPBasket( "SL1" , "L1_HORA"	, Left(cHoraECF,TamSX3("LI_HORA")[1]  ) 	)
	Else
		STDSPBasket( "SL1" , "L1_HORA"	, cHora )
	EndIf
	
	STISetRecTit(.F.) // Se abriu a venda seta que não é um recebimento
EndIf


									
Return lRet

