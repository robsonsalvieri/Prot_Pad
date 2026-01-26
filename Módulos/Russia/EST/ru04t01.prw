#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU04T01.CH"

#DEFINE NO_VAT "1"

/*/{Protheus.doc} RU04T01001_ProcLoc(aDataTrans,aParam310,aTransfer)
    function for mata311 (based on function A310ProcLoc)

    @type Function
    @params aDataTrans	Array   Array with data for transfer  
            aParam310	Array   Array with selected questions
            aTransfer	Array	Array with tranfsfer document info
    @return lRet		Logical	Result of process
    @author Artem nIkitenko
    @since 24/05/2024
    @version 12.1.2310
*/
Function RU04T01001_ProcLoc(aDataTrans,aParam310,aTransfer)
// Variable with the origin branch
Local cFilOri      := cFilAnt

Local cPedido   := ""
Local cWhile    := ""
Local cSerie    := ""

Local aCabec    := {}
Local aItens    := {}
Local aPvlNfs   := {}
Local aBloqueio := {{"","","","","","","",""}}
Local aNotas    := {}
Local aSeries   := {}
Local aNfs      := {}
Local aNotaGera := {}
Local aSX5      := {}
Local aParams   := {}

Local nItemNf   := 0
Local nSaveSX8  := 0
Local nAchoSerie:= 0
Local nPrcVen   := 0
Local nI        := 1
Local nX        := 1
Local ny        := 1
Local lRet      := .T.
Local lRegTransf	:= IsInCallStack("MATA311") //Checks if it came from the transfer registration routine

// Array with generated notes
Local aNotaFeita:= {}
// Checks if there is a point for handling items
Local lExecItens:=ExistBlock("M310ITENS")           
Local aBackItens:={}
Local lExecCabec:=ExistBlock("M310CABEC")
Local aBackCabec:={}
Local cChavSA2:=''
Local cNoVATCode := RU04T01002()	//Search No VAT Code
Local lMostraErro   := .F.
Local oModel as Object

Private lMsErroAuto := .F.
Private cNumb     := ""

Default aTransfer := {}

/* Variables used for parameters
	mv_par01 // From Product
	mv_par02 // Ate Product
	mv_par03 // From branch
	mv_par04 // Until branch
	mv_par05 // From Warehouse
	mv_par06 // Until Warehouse
	mv_par07 // Of Type
	mv_par08 // Ate Type
	mv_par09 // From Group
	mv_par10 // Ate Group
	mv_par11 // Filter Categories 1 Yes 2 No
	mv_par12 // Break information 1 Per product 2 Per Warehouse
	mv_par13 // TES code used in outflow NFs
	mv_par14 // Indicates how the document should be generated
	mv_par15 // TES code used in incoming NFs
	mv_par16 // Payment condition code
	mv_par17 // Suggests price 1 Tab 2 STD Cost 3 Ult Pr 4 CM
*/
/* Array with data to transfer
	[1] Origin branch
	[2] Source product
	[3] Source store
	[4] Origin quantity
	[5] Origin quantity 2nd UM
	[6] Target branch
	[7] Destination store
	[8] Customer at Origin
	[9] Store at Origin
	[10] Supplier at destination
	[11] Store at destination
	[12] Document at source
	[13] Document series at source
	[14] Information about Third Party Power
	[14] Identified Power 3
	[15] Customer/Supplier Power 3
	[16] Loja Poder 3
	[17] Origin Batch
	[18] Source Sub-Batch
	[19] Expiration Date
	[20] Address
	[21] Serial Number
*/
// Scan array to perform recordings
For nX :=1 to Len(aDataTrans)
	If nX == 1 .Or. (aDataTrans[nX,1] # aDataTrans[nX-1,1])
		// Update to the source branch
		cFilant:=aDataTrans[nX,1]
		// Get series for invoice from this branch
		aSX5    := LocXSx5NF(,,,.T.,.T.)
		If Len(aSX5) > 0
			cNumb := aSX5[1]
			cSerie  := aSX5[2]
			// If you selected number
			If !Empty(cNumb)
				Aadd(aSeries,{cFilAnt,cSerie,cNumb})
			EndIf
		Else 
			Aviso(STR0001,STR0003,{"Ok"}) //##ATTENTION ## Operation canceled
			lRet := .F.		
		EndIf	
	EndIf
Next nX

If lRet .And. Pergunte('MT468C',.T.)

	// Set up processing ruler                             
	ProcRegua(Len(aDataTrans)*2)

	aParams := {Space(Len(SC9->C9_PEDIDO))				,; //Order from
				Replicate(Char(255),Len(SC9->C9_PEDIDO)),; //Order to
				Space(Len(SA1->A1_COD))					,; //Client from
				Replicate(Char(255),Len(SA1->A1_COD))	,; //Client to
				Space(Len(SA1->A1_LOJA))				,; //Store
				Replicate(Char(255),Len(SA1->A1_LOJA))	,; //Store from
				Space(Len(SB1->B1_GRUPO))				,; //Group from
				Replicate(Char(255),Len(SB1->B1_GRUPO))	,; //Group to
				Space(Len(SA1->A1_AGREG))				,; //Aggregator from
				Replicate(Char(255),Len(SA1->A1_AGREG))	,; //Aggregator to
				mv_par01								,; //lType
				mv_par02								,; //lAglutina
				mv_par03								,; //lGeraLanc
				2										,; //lInvert
				mv_par04								,; //lAtuaSC7
				mv_par05								,; //nSepara
				0										,; //nMinValue
				2										,; //proforma invoice
				Space(Len(SC5->C5_TRANSP))				,; //Transporter
				Replicate(Char(255),Len(SC5->C5_TRANSP)),; //Transporter until
				2										,; //Reset to the same note
				mv_par06								,; //Invoice Requested by
				mv_par07								,; //Currency for billing
				mv_par08								} //Account for?

	// Processes generation of outflow documents               
	// Sort array to group by origin and destination branch
	aSort(aDataTrans,,,{|x,y| x[1]+x[6]+x[2]+x[3] < y[1]+y[6]+y[2]+y[3] })
	// Scan array to perform recordings
	While (nI <= Len(aDataTrans))
		
		// Variable for automatic routine
		lMsErroAuto := .F.
		// Updates to the originating branch
		cFilant:=aDataTrans[nI,1]
		// Array for generating notes
		aNotas   := {}
		// Arrays with items and locks
		aPvlNfs  := {}
		aBloqueio:= {}
		// Order header
		aCabec   := {}
		// Order Items
		aItens   := {}
		// Variable that controls numbering
		nSaveSX8 := GetSx8Len()
		//Variable for processing
		cWhile:=aDataTrans[nI,1]+aDataTrans[nI,6]
		// Get series for this branch's notes
		nAchoSerie:=ASCAN(aSeries,{|x| x[1] == cFilAnt})
		// If you selected series for this branch
		If nAchoSerie > 0
			// Updates to the target branch
			cFilant:=aDataTrans[nI,6]
			// Check if the number and series have already been registered
			dbSelectArea("SF1")
			dbSetOrder(1)
			If MsSeek(xFilial("SF1")+aSeries[nAchoSerie,3]+aSeries[nAchoSerie,2]+aDataTrans[nI,10]+aDataTrans[nI,11])
				Aviso(STR0001,STR0002,{"Ok"}) //##ATTENTION ##The number entered for this transfer already has a document registered with same number. Please, enter a new number. 
				Exit
			EndIf
			// Updates to the originating branch
			cFilant:=aDataTrans[nI,1]
			// Series for generating the note
			cSerie:=aSeries[nAchoSerie,2]
			// Number for generating the note
			cNumb:=aSeries[nAchoSerie,3]
			// Order header
			cPedido := GetSxeNum("SC5","C5_NUM")
			RollBAckSx8()
			aadd(aCabec,{"C5_NUM",cPedido,Nil})
			aadd(aCabec,{"C5_TIPO","N",Nil})
			aadd(aCabec,{"C5_CLIENTE",aDataTrans[nI,8],Nil})
			aadd(aCabec,{"C5_LOJACLI",aDataTrans[nI,9],Nil})
			aadd(aCabec,{"C5_LOJAENT",aDataTrans[nI,9],Nil})
			If lRegTransf
				SA1->(DbSetOrder(1))
				If SA1->(DbSeek(xFilial("SA1")+aDataTrans[nI,8]+aDataTrans[nI,9]))
					aadd(aCabec,{"C5_CONDPAG",SA1->A1_COND,Nil})
				EndIf
			Else
				aadd(aCabec,{"C5_CONDPAG",aParam310[16],Nil})
			Endif
			// Entry point to CHANGE sales order header data
			If lExecCabec
				aBackCabec:=ACLONE(aCabec)
				aCabec:=ExecBlock("M310CABEC",.F.,.F.,{"MATA410",aCabec,aParam310})
				If ValType(aCabec) # "A"
					aCabec:=ACLONE(aBackCabec)
				EndIf
			EndIf			
			// Item counter
			cC6_ITEM := Strzero(0, TamSX3("C6_ITEM")[1])
			// ATTENTION - VARIABLES CREATED DUE TO BREAK IN BILLING
			aNotaFeita:={}
			aNotaGera :={}
			While (nI <= Len(aDataTrans)) .And. (aDataTrans[nI,1]+aDataTrans[nI,6] == cWhile)
				// Increase processing rule
				IncProc()
				aLinha := {}
				// Get the selling price of the product
				If aParam310[17] == 1
					SA1->(dbSetOrder(1))
					SA1->(dbSeek(xFilial("SA1")+aDataTrans[nI,8]+aDataTrans[nI,9]))
					nPrcVen := MaTabPrVen(SA1->A1_TABELA,aDataTrans[nI,2],aDataTrans[nI,4],aDataTrans[nI,8],aDataTrans[nI,9],1,dDataBase)
				// Get price - standard cost
				ElseIf aParam310[17] == 2
					If RetArqProd(aDataTrans[nI,2])
						nPrcVen := Posicione("SB1",1,xFilial("SB1")+aDataTrans[nI,2],"B1_CUSTD")
					Else
						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFilial("SB1")+aDataTrans[nI,2]))
						nPrcVen := RetFldProd(SB1->B1_COD,"B1_CUSTD")
					EndIf
				// Get price - last purchase price
				ElseIf aParam310[17] == 3
					If RetArqProd(aDataTrans[nI,2])
						nPrcVen := Posicione("SB1",1,xFilial("SB1")+aDataTrans[nI,2],"B1_UPRC")
					Else
						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFilial("SB1")+aDataTrans[nI,2]))
						nPrcVen := RetFldProd(SB1->B1_COD,"B1_UPRC")
					EndIf	
				// Get price - average unit cost of the warehouse
				ElseIf aParam310[17] == 4
					SB2->(dbSetOrder(1))
					If SB2->(MsSeek(xFilial("SB2")+aDataTrans[nI,2]+aDataTrans[nI,3]))
						nPrcVen:=SB2->B2_CM1
					EndIf
				EndIf
				// If no value was found, it assumed 1
				If QtdComp(nPrcVen,.T.) == QtdComp(0,.T.)
					nPrcVen := 1
				EndIf
				aadd(aLinha,{"C6_ITEM"   ,Soma1(cC6_ITEM),Nil})
				aadd(aLinha,{"C6_PRODUTO",aDataTrans[nI,2],Nil})
				aadd(aLinha,{"C6_LOCAL"  ,aDataTrans[nI,3],Nil})
				aadd(aLinha,{"C6_QTDVEN" ,aDataTrans[nI,4],Nil})
				aadd(aLinha,{"C6_PRCVEN" ,A410Arred(nPrcVen,"C6_PRCVEN"),Nil})
				aadd(aLinha,{"C6_PRUNIT" ,A410Arred(nPrcVen,"C6_PRUNIT"),Nil})
				aadd(aLinha,{"C6_VALOR"  ,A410Arred((aDataTrans[nI,4]*A410Arred(nPrcVen,"C6_PRUNIT")),"C6_VALOR"),Nil})
				If lRegTransf
					aadd(aLinha,{"C6_TES"    ,aDataTrans[nI,22],Nil}) 
				Else
					aadd(aLinha,{"C6_TES"    ,aDataTrans[nI,23],Nil})   
				Endif
				aadd(aLinha,{"C6_CF"    ,cNoVATCode,Nil})

				// Check whether batch traceability is used
				If Rastro(aDataTrans[nI,2],"L")
					aadd(aLinha,{"C6_LOTECTL",aDataTrans[nI,17],Nil})
					aadd(aLinha,{"C6_DTVALID",aDataTrans[nI,19],Nil})
				EndIf
				// Check whether sublot traceability is used
				If Rastro(aDataTrans[nI,2],"S")                        
					aadd(aLinha,{"C6_LOTECTL",aDataTrans[nI,17],Nil})
					aadd(aLinha,{"C6_NUMLOTE",aDataTrans[nI,18],Nil})
					aadd(aLinha,{"C6_DTVALID",aDataTrans[nI,19],Nil})
				EndIf         
				// Check if you use location
				If Localiza(aDataTrans[nI,2])
					aadd(aLinha,{"C6_LOCALIZ",aDataTrans[nI,20],Nil})
					aadd(aLinha,{"C6_NUMSERI",aDataTrans[nI,21],Nil})
				EndIf	
				aadd(aItens,aLinha)
				// Increment counters
				nI++
			End
			
			// Entry point to CHANGE sales order data
			If lExecItens
				aBackItens:=ACLONE(aItens)
				aItens:=ExecBlock("M310ITENS",.F.,.F.,{"MATA410",aItens})
				If ValType(aItens) # "A"
					aItens:=ACLONE(aBackItens)
				EndIf
			EndIf
			// Inclusion of order
			MATA410(aCabec,aItens,3)
			// Automatic routine error check
			If lMsErroAuto
				lMostraErro	:=.T.
			Else
				// Confirm SX8
				While ( GetSx8Len() > nSaveSX8 )
					ConfirmSX8()
				Enddo
				// Order release
				Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
				// Check released items
				Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
				// If you have items released, please invoice
				If Empty(aBloqueio) .And. !Empty(aPvlNfs)
					nItemNf  := a460NumIt(cSerie)
					aadd(aNotas,{})
					// Make breaks according to the number of items
					For nX := 1 To Len(aPvlNfs)
						If Len(aNotas[Len(aNotas)])>=nItemNf
							aadd(aNotas,{})
						EndIf
						aadd(aNotas[Len(aNotas)],aClone(aPvlNfs[nX]))
					Next nX
					// Generates notes according to the break
					For nX := 1 To Len(aNotas)

						aNfs := {}
						For nY := 1 To Len(aNotas[nX])
							//Writes record number from table SC9
							dbSelectArea("SC9")
							dbSetOrder(1)
							If dbSeek(xFilial("SC9")+aNotas[nX,nY,1]+aNotas[nX,nY,2]+aNotas[nX,nY,3]+aNotas[nX,nY,6])
								Aadd( aNfs , SC9->(Recno()) )
							EndIf
						Next nY
							
						// Generate outflow document
						If Len(aNfs) > 0
							MsAguarde({|| a468nFatura("SC9",aParams,@aNFs,,.F.,,@aNotaGera,.T.,cSerie,cNumb)},STR0004)	//## ????
						EndIf	
					
						If Len(aNotaGera) > 0
							AADD(aNotaFeita,aNotaGera[1,2]) // Document
						EndIf	

					Next nX

					// Scans generated outgoing invoices to generate incoming invoices
					For nX:=1 to Len(aNotaFeita)
						dbSelectArea("SD2")
						dbSetOrder(3)
						If dbSeek(xFilial("SD2")+PadR(aNotaFeita[nX],TamSX3("D2_DOC")[1])+cSerie+aDataTrans[nI-1,8]+aDataTrans[nI-1,9])
							
							aadd(aTransfer,{aDataTrans[nI-1,6],aNotaFeita[nX],cSerie})//Procloc mod
							// Inflow invoice header
							aCabec   := {}
							aadd(aCabec,{"F1_TIPO"   ,"N"})
							aadd(aCabec,{"F1_FORMUL" ,"N"})
							aadd(aCabec,{"F1_DOC"    ,aNotaFeita[nX]})
							aadd(aCabec,{"F1_SERIE"  ,cSerie})
							aadd(aCabec,{"F1_EMISSAO",dDataBase})
							aadd(aCabec,{"F1_FORNECE",aDataTrans[nI-1,10]})
							aadd(aCabec,{"F1_LOJA"   ,aDataTrans[nI-1,11]})
							aadd(aCabec,{"F1_ESPECIE",aParam310[20]})
							If lRegTransf
								oModel:=FWModelActive()
								cChavSA2:=oModel:GetModel('NNTDETAIL'):GetValue('NNT_FILDES')//cNNT_FILDES
								SA2->(DbSetOrder(1))
								If SA2->(DbSeek(xFilial("SA2")+cChavSA2))
									aadd(aCabec,{"F1_COND"   ,SA2->A2_COND})
								Endif
							Else
								aadd(aCabec,{"F1_COND"   ,aParam310[16]})
							Endif
							aadd(aCabec,{"F1_TIPODOC","10"})
							aadd(aCabec,{"F1_MOEDA"		,1})
							aadd(aCabec,{"F1_TXMOEDA"	,1})

							// Entry point to CHANGE sales order header data
							If lExecCabec
								aBackCabec:=ACLONE(aCabec)
								aCabec:=ExecBlock("M310CABEC",.F.,.F.,{"MATA101N",aCabec,aParam310})
								If ValType(aCabec) # "A"
									aCabec:=ACLONE(aBackCabec)
								EndIf
							EndIf							
							// Inflow invoice items
							aItens   := {}
							While !Eof() .And. xFilial("SD2")+aNotaFeita[nX]+cSerie+aDataTrans[nI-1,8]+aDataTrans[nI-1,9] == D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA
								// Increase processing rule
								IncProc()
								aLinha := {}
								aadd(aLinha,{"D1_COD",aDataTrans[nI-1,25],Nil})
								aadd(aLinha,{"D1_QUANT",SD2->D2_QUANT,Nil})
								aadd(aLinha,{"D1_VUNIT",SD2->D2_PRCVEN,Nil})
								aadd(aLinha,{"D1_TOTAL",SD2->D2_TOTAL,Nil})
								aadd(aLinha,{"D1_LOCAL",aDataTrans[nI-1,7],Nil})
								aadd(aLinha,{"D1_EMISSAO",dDataBase,Nil})
								aadd(aLinha,{"D1_DTDIGIT",dDataBase,Nil})
								// Check document generation
								If lRegTransf
									aAdd(aLinha,{"D1_TES",aDataTrans[nX,24],Nil})
								Else
									aAdd(aLinha,{"D1_TES",aParam310[15],Nil})
								Endif
								aadd(aLinha,{"D1_CF",cNoVATCode,Nil})
								// Check whether traceability is used
								cFilAnt:= aDataTrans[nX,6]
								If Rastro(SD2->D2_COD,"L")
									aadd(aLinha,{"D1_LOTECTL",SD2->D2_LOTECTL,Nil})
									aadd(aLinha,{"D1_DTVALID",SD2->D2_DTVALID,Nil})
								EndIf
								If Rastro(SD2->D2_COD,"S")                           
									aadd(aLinha,{"D1_LOTECTL",SD2->D2_LOTECTL,Nil})
									aadd(aLinha,{"D1_NUMLOTE",SD2->D2_NUMLOTE,Nil})
									aadd(aLinha,{"D1_DTVALID",SD2->D2_DTVALID,Nil})
								EndIf
								aadd(aItens,aLinha)
								cFilAnt:= aDataTrans[nX,1]
								dbSelectArea("SD2")
								dbSkip()
							End
							// If you have items and header defined
							If Len(aItens) > 0 .And. Len(aCabec) > 0
								// Updates to the target branch
								cFilant:=aDataTrans[nI-1,6]
								// Reinitializes environment for the inspector
								If MaFisFound()
									MaFisEnd()
								EndIf

								// Entry point to CHANGE sales order data
								If lExecItens
									aBackItens:=ACLONE(aItens)
									aItens:=ExecBlock("M310ITENS",.F.,.F.,{"MATA101N",aItens})
									If ValType(aItens) # "A"
										aItens:=ACLONE(aBackItens)
									EndIf
								EndIf
								// Inflow invoice creation

								MATA101N(aCabec,aItens,3,.T.)
								// Automatic routine error check
								If lMsErroAuto
									lMostraErro	:=.T.
								EndIf
								// Automatic routine error check
								cFilAnt:=aDataTrans[nI-1,1]
							EndIf
						EndIf
					Next nX
				EndIf
			EndIf
		Else
			// Branch XX did not have an outgoing invoice series selected for generation
			Help(" ",1,"A310SERERR",,cFilAnt,1,10)
			// Variable for processing
			cWhile:=aDataTrans[nI,1]
			// Scans all items with this source branch
			While (nI <= Len(aDataTrans)) .And. aDataTrans[nI,1] == cWhile
				// Increase processing rule
				IncProc()
				nI++
			End
		EndIf	
	End
EndIf
// Restores original branch
cFilAnt:=cFilOri
// Shows error in automatic routine
If lMostraErro
	MostraErro()
EndIf
Return lRet


/*/{Protheus.doc} RU04T01002_SearchNoVatCode
    function for search for zero VAT code

    @type Function
    @params None
    @return cRet	Character VAT CODE without VAT
    @author Alexandra Velmozhnaya
    @since 26/06/2024
    @version 12.1.2310
*/
Function RU04T01002_SearchNoVatCode()
	Local cRet as Character
	Local cQuery as Character
	Local cAliasF31 as Character
	Local aArea As Array

	//Initializing
	cRet := ""
	aArea := GetArea()
	cAliasF31 := GetNextAlias()

	cQuery:= "SELECT F31_CODE AS F31CODE FROM " + RetSqlName("F30") + " AS F30 "
	cQuery+= "LEFT JOIN "+ RetSqlName("F31") +" AS F31 ON F30_CODE = F31_RATE "
	cQuery+= "WHERE F30.D_E_L_E_T_ ='' AND F31.D_E_L_E_T_ = '' AND F30_EXEMPT = '" + NO_VAT + "'  ORDER BY F31.R_E_C_N_O_ DESC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasF31,.T.,.T.)
	dbSelectArea(cAliasF31)
	dbGotop()
	cRet := (cAliasF31)->F31CODE

	(cAliasF31)->(DbCloseArea())
	RestArea(aArea)

Return cRet
                   
//Merge Russia R14 
                   
                   
