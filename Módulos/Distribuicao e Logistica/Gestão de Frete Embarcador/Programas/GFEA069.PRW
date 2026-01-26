#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "fileio.ch"

Static cLastFolder

// SonarQube - CA1003: Uso não permitido de chamada de API em LOOP
Static s_APRTAB := SuperGetMv("MV_APRTAB",,"1")
 
#DEFINE NFILIAL 1
#DEFINE NCDEMIT 2 // Obrigatório
#DEFINE NNRTAB  3 // Obrigatório
#DEFINE NNRNEG  4 // Se não informado, aplicará a todas as negociações
#DEFINE NCDFXTV 5 // Se não informado, aplicará a todas as faixas
#DEFINE NNRROTA 6 // Se não informado, aplicará a todas as rotas
#DEFINE NCDCOMP 7 // Obrigatório
#DEFINE NEMICOM 8 // Opcional. Se informado, é tarifa por emitente(GUC) e busca por gu3_idfed ou gu3_cdemit, senão é tarifa sem emitente(GV1)
#DEFINE NNRCID 9
#DEFINE NNATUR 10
#DEFINE NVLFIXN 11 // Opcional. Será validado o tipo do componente com o que foi preenchido
#DEFINE NPCNORM 12 // Opcional. Será validado o tipo do componente com o que foi preenchido
#DEFINE NVLUNIN 13 // Opcional. Será validado o tipo do componente com o que foi preenchido
#DEFINE NVLFRAC 14 // Opcional. Será validado o tipo do componente com o que foi preenchido
#DEFINE NVLMINN 15 // Opcional. Será validado o tipo do componente com o que foi preenchido
#DEFINE NPCLIM  16 // Opcional. Será validado o tipo do componente com o que foi preenchido. Padrão não usado mas se o cliente habilitar ficará disponível
#DEFINE NVLLIM  17 // Opcional. Será validado o tipo do componente com o que foi preenchido
#DEFINE NVLFIXE 18 // Opcional. Será validado o tipo do componente com o que foi preenchido
#DEFINE NPCEXTR 19 // Opcional. Será validado o tipo do componente com o que foi preenchido
#DEFINE NVLUNIE 20 // Opcional. Será validado o tipo do componente com o que foi preenchido
#DEFINE NCALCEX 21 // Opcional. Será validado o tipo do componente com o que foi preenchido
#DEFINE NDELETA 22 // Se preenchido, indica que o usuário deseja remover o componente ao invés de inserir/atualizar.
#DEFINE NEMIBKP 23 // Se preenchido, indica que o usuário deseja remover o componente ao invés de inserir/atualizar.
#DEFINE NQTDOBR 03 // Quantidade obrigatórioa
#DEFINE ALERTAATR "Alerta: O atributo para cálculo do componente não permite alterações no campo "


/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA069
Tabela de Frete

@author Siegklenes Rolland Beulke
@since 16/06/2016
@version 1.0
-------------------------------------------------------------------*/
Function GFEA069()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GUC")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA069")   // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription('Tarifas de Frete por Emitente de Transporte')	//"Consulta do Cálculo de Frete"
	oBrowse:Activate()
	
Return

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"		 ACTION "AxPesqui"        OPERATION 1  ACCESS 0
	ADD OPTION aRotina TITLE "Importar Tarifas"  ACTION "GFEA069MDT()"    OPERATION 3  ACCESS 0
	ADD OPTION aRotina TITLE "Modelo importação" ACTION "GFEA069MDI()"    OPERATION 3  ACCESS 0
Return aRotina

Static Function ProcImp()
	Local cFile 		:= cGetFile( "Arquivos separados por Ponto-e-Virgula (*.CSV) |*.csv|","Escolher arquivo",,cLastFolder,.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)
	Local aCabecalho
	Local nX,nY,nZ,nQ
	Local aStrGUC 		:= GUC->(dbStruct())
	Local nColunas
	Local aColunas    	:= {}
	Local aLinhas     	:= {}
	Local aErro       	:= {}
	Local aData       	:= Array(21)
	Local aDadosAgrup 	:= {}
	Local aCol        	:= {{"GUC_FILIAL",,,,},;
					     	{"GUC_CDEMIT",,,,},;
					     	{"GUC_NRTAB" ,,,,},;
					     	{"GUC_NRNEG" ,,,,},;
					     	{"GUC_CDFXTV",,,,},;
					     	{"GUC_NRROTA",,,,},;
					     	{"GUC_CDCOMP",,,,},;
					     	{"GUC_EMICOM",,,,},;
					     	{"GUC_NRCID",,,,},;
						 	{"GUC_NATUR",,,,},;
						 	{"GUC_VLFIXN",,,,},;
					     	{"GUC_PCNORM",,,,},;
					     	{"GUC_VLUNIN",,,,},;
					     	{"GUC_VLFRAC",,,,},;
					     	{"GUC_VLMINN",,,,},;
					     	{"GUC_PCLIM" ,,,,},;
					     	{"GUC_VLLIM" ,,,,},;
					     	{"GUC_VLFIXE",,,,},;
					     	{"GUC_PCEXTR",,,,},;
					     	{"GUC_VLUNIE",,,,},;
					     	{"GUC_CALCEX",,,,},; 	//Posição 5 é a posição da coluna no arquivo
					     	{"GUC_DELETA","C",5,0,},;
					     	{"GUC_EMIBKP","C",255,0,}}//Adicionado dinamicamente
	Local nObrEnc 		:= 0
	Local lErroVal
	Local cLinhaErro 	:= ""
	Local oModelGV6
	Local oModelGV1
	Local oModelGUC
	Local cQuery
	Local cAlQuery
	Local cMsg 			:= ""
	Local nReg
	Local lExc			:= .F.
	
	Private oVwProc
	Private aErros 		:= {}
	
	For nX := 1 To Len(aStrGUC)
		nY := aScan(aCol,{|x| x[1] == aStrGUC[nX,1]})
		If nY > 0
			aCol[nY,2] := aStrGUC[nX,2]
			aCol[nY,3] := aStrGUC[nX,3]
			aCol[nY,4] := aStrGUC[nX,4]
		EndIf
	Next nX
	
	If !Empty(cFile)
		cLastFolder := SubStr(cFile,1,Rat(If(isSRVunix(),"/","\"),cFile) )
		CursorWait()
		If !File(cFile)
			MsgAlert("Arquivo informado não existe.")
			Return
		EndIf
		
		If UPPER(right(AllTrim(cFile),4)) != ".CSV"
			MsgAlert("Arquivo deve possuir a extensão .CSV")
			CursorArrow()
			Return
		EndIf
		
		oProcess:setRegua1(4)
		oProcess:incRegua1(OemToAnsi("Realizando leitura do arquivo..."))
		
		FT_FUSE(cFile)
		
		FT_FGOTOP()
		
		While !FT_FEOF()
	
			aAdd(aLinhas,StrTran(FT_FREADLN(),"'","",,))
			FT_FSKIP()
		EndDo

		FT_FUSE()
		
		If Len(aLinhas) <= 2
			MsgAlert("Arquivo aparenta estar vazio ou não possui informações para importação")
			CursorArrow()
			Return
		EndIf
		
		aCabecalho := StrToKarr(aLinhas[1],";")
		nColunas := Len(aCabecalho)
		
		If nColunas <= 3
			MsgAlert("Arquivo aparenta estar vazio ou não possui informações para importação")
			CursorArrow()
			Return
		EndIf
		
		For nX := 1 To nColunas
			aCabecalho[nX] := UPPER(AllTrim(aCabecalho[nX]))
			If aCabecalho[nX] $ "GUC_CDEMITGUC_NRTABGUC_CDCOMP"
				nObrEnc++
			EndIf
			nY := aScan(aCol,{|x| x[1] == aCabecalho[nX] })
			If nY != 0
				aCol[nY,5] := nX
			EndIf
		Next nX
		
		If nObrEnc < NQTDOBR
			MsgAlert("As colunas GUC_CDEMIT,GUC_NRTAB e GUC_CDCOMP são obrigatórias e não foram localizadas no arquivo.")
			CursorArrow()
			Return
		EndIf

		oVwProc := GFEViewProc():New()
		
		dbSelectarea("GVA")
		GVA->(dbSetOrder(1))
		
		dbSelectarea("GV9")
		GV9->(dbSetOrder(1))
		
		dbSelectarea("GV7")
		GV7->(dbSetOrder(1))
		
		dbSelectarea("GV8")
		GV8->(dbSetOrder(1))
		
		dbSelectarea("GV2")
		GV2->(dbSetOrder(1))
		oProcess:setRegua2(Len(aLinhas)-1)
		oProcess:incRegua1(OemToAnsi("Validando as linhas do arquivo"))
		For nX := 3 To Len(aLinhas)
			oProcess:incRegua2(OemToAnsi("Linha " + cValToChar(nX-2)))
			lErroVal := .F.
			If Len(StrTokArr2(aLinhas[nX],";")) == 0
				Loop
			Endif
			aColunas := StrTokArr2(aLinhas[nX],";",.T.)
		
			If Len(aColunas) != nColunas
				aAdd(aErros,{nX,"possui uma quantidade de colunas diferente do cabeçalho.Verifique."})
				lErroVal := .T.
				Loop
			ElseIf Len(aColunas) < 1
				aAdd(aErros,{nX,"arquivo aparenta estar vazio ou não possui caracter separador de colunas(;)."})
				lErroVal := .T.
				Loop
			EndIf
			
			If Empty(aColunas[aCol[NCDEMIT,5]])
				aAdd(aErros,{nX,"o código do emitente é obrigatório."})
				lErroVal := .T.
			EndIf
			
			If Empty(aColunas[aCol[NNRTAB,5]])
				aAdd(aErros,{nX,"o número da tabela é obrigatória."})
				lErroVal := .T.
			EndIf
			
			If Empty(aColunas[aCol[NCDCOMP,5]])
				aAdd(aErros,{nX,"o código do componente é obrigatório."})
				lErroVal := .T.
			Else
				aColunas[aCol[NCDCOMP,5]] := PadR(UPPER(aColunas[aCol[NCDCOMP,5]]),aCol[NCDCOMP,3])
				If !GV2->(msSeek(xFilial("GV2") + aColunas[aCol[NCDCOMP,5]]))
					aAdd(aErros,{nX,"o componente " + AllTrim(aColunas[aCol[NCDCOMP,5]]) + " não foi localizado."})
					lErroVal := .T.
				EndIf
			EndIf
			
			If !Empty(aCol[NEMICOM,5]) .And. !Empty(aColunas[aCol[NEMICOM,5]])
				aAdd(aColunas,aColunas[aCol[NEMICOM,5]])//EMIBKP
				aColunas[aCol[NEMICOM,5]] := UPPER(aColunas[aCol[NEMICOM,5]])
				If Len(aColunas[aCol[NEMICOM,5]]) >= 11
					GU3->(dbSetOrder(11)) //IDFED
					aColunas[aCol[NEMICOM,5]] := StrTran(StrTran(StrTran(StrTran(aColunas[aCol[NEMICOM,5]],".",""),"/",""),"-","")," ","")
					aColunas[aCol[NEMICOM,5]] := PadR(aColunas[aCol[NEMICOM,5]],Len(GU3->GU3_IDFED))
					If !GU3->(msSeek(xFilial("GU3") + aColunas[aCol[NEMICOM,5]] ))
						aColunas[aCol[NEMICOM,5]] := PadR(aColunas[aCol[NEMICOM,5]],aCol[NEMICOM,3])
						GU3->(dbSetOrder(1))
						If !GU3->(msSeek(xFilial("GU3") + aColunas[aCol[NEMICOM,5]]))
							aAdd(aErros,{nX,"o destinatário " + AllTrim(aColunas[aCol[NEMICOM,5]]) + " não foi localizado."})
							lErroVal := .T.
						Else
							aColunas[aCol[NEMICOM,5]] := GU3->GU3_CDEMIT
						EndIf
					Else
						aColunas[aCol[NEMICOM,5]] := GU3->GU3_CDEMIT
					EndIf
				ElseIf Alltrim(aColunas[aCol[NEMICOM,5]]) != "*"
					GU3->(dbSetOrder(1))
					If !GU3->(msSeek(xFilial("GU3") + aColunas[aCol[NEMICOM,5]]))
						aAdd(aErros,{nX,"o destinatário " + AllTrim(aColunas[aCol[NEMICOM,5]]) + " não foi localizado."})
						lErroVal := .T.
					Else
						aColunas[aCol[NEMICOM,5]] := GU3->GU3_CDEMIT
					EndIf
				EndIf
				aColunas[aCol[NEMICOM,5]] := PadR(aColunas[aCol[NEMICOM,5]],aCol[NEMICOM,3])
			Else
				aAdd(aColunas,"")//EMIBKP
			EndIf
			aCol[NEMIBKP,5] := Len(aColunas)
			
			If !lErroVal
			
				// Ajuste dos dados do arquivo
				If !Empty(aCol[NFILIAL,5]) 
					aColunas[aCol[NFILIAL,5]] := "'" + PadR(aColunas[aCol[NFILIAL,5]],aCol[NFILIAL,3]) + "'"
				EndIf
				If !Empty(aCol[NCDEMIT,5]) 
					aColunas[aCol[NCDEMIT,5]] := "'" + PadR(aColunas[aCol[NCDEMIT,5]],aCol[NCDEMIT,3]) + "'"
				EndIf
				If !Empty(aCol[NNRTAB ,5]) 
					aColunas[aCol[NNRTAB ,5]] := "'" + PadR(aColunas[aCol[NNRTAB ,5]],aCol[NNRTAB ,3]) + "'"
				EndIf
				If !Empty(aCol[NNRNEG ,5]) 
					aColunas[aCol[NNRNEG ,5]] := "'" + PadR(aColunas[aCol[NNRNEG ,5]],aCol[NNRNEG ,3]) + "'"
				EndIf
				If !Empty(aCol[NCDFXTV,5]) 
					If AllTrim(aColunas[aCol[NCDFXTV,5]]) == "*" 
						aColunas[aCol[NCDFXTV,5]] := "'" + aColunas[aCol[NCDFXTV,5]] + "'"
					Else
						aColunas[aCol[NCDFXTV,5]] := "'" + PadL(aColunas[aCol[NCDFXTV,5]],aCol[NCDFXTV,3],"0") + "'"
					EndIf
				EndIf
				If !Empty(aCol[NNRROTA,5])
					If aColunas[aCol[NNRROTA,5]] == "*" 
						aColunas[aCol[NNRROTA,5]] := "'" + aColunas[aCol[NNRROTA,5]] + "'"
					Else
						aColunas[aCol[NNRROTA,5]] := "'" + PadL(aColunas[aCol[NNRROTA,5]],aCol[NNRROTA,3],"0") + "'"
					EndIf
				EndIf
				If !Empty(aCol[NCDCOMP,5]) 
					aColunas[aCol[NCDCOMP,5]] := "'" + PadR(aColunas[aCol[NCDCOMP,5]],aCol[NCDCOMP,3]) + "'"
				EndIf
				If !Empty(aCol[NEMICOM,5]) 
					aColunas[aCol[NEMICOM,5]] := "'" + PadR(aColunas[aCol[NEMICOM,5]],aCol[NEMICOM,3]) + "'"
				EndIf
				If !Empty(aCol[NCALCEX,5]) 
					aColunas[aCol[NCALCEX,5]] := "'" + PadR(aColunas[aCol[NCALCEX,5]],aCol[NCALCEX,3]) + "'"
				EndIf
				If !Empty(aCol[NDELETA,5]) 
					aColunas[aCol[NDELETA,5]] := "'" + PadR(aColunas[aCol[NDELETA,5]],aCol[NDELETA,3]) + "'"
				EndIf
				If !Empty(aCol[NEMIBKP,5]) 
					aColunas[aCol[NEMIBKP,5]] := "'" + AllTrim(aColunas[aCol[NEMIBKP,5]]) + "'"
				EndIf
				If !Empty(aCol[NNRCID,5]) 
					aColunas[aCol[NNRCID,5]] := "'" + AllTrim(aColunas[aCol[NNRCID,5]]) + "'"
				EndIf
				If !Empty(aCol[NNATUR,5]) 
					aColunas[aCol[NNATUR,5]] := "'" + AllTrim(aColunas[aCol[NNATUR,5]]) + "'"
				EndIf
				
				For nY := 1 To Len(aCol)
					If !Empty(aCol[nY,5])
						If ValType(aColunas[aCol[nY,5]]) != aCol[nY,2]
							If aCol[nY,2] == "N"
								If AllTrim(aColunas[aCol[nY,5]]) == ""
									aColunas[aCol[nY,5]] := "0"
								Else
									cErro := ""
									bError := ErrorBlock({|e|GFEConout("Error", e:Description),.T.})
									BEGIN SEQUENCE
									aColunas[aCol[nY,5]] := GetDToVal(aColunas[aCol[nY,5]])
									END SEQUENCE
									ErrorBlock(bError)
									If !Empty(cErro)
										aAdd(aErros,{nX,"coluna do campo " + aCol[nY,1] + " possui conteúdo inválido."})
										lErroVal := .T.
									Else
										aColunas[aCol[nY,5]] := Str(aColunas[aCol[nY,5]],aCol[nY,3],aCol[nY,4])
										If At("*",aColunas[aCol[nY,5]]) > 0
											aColunas[aCol[nY,5]] := "'" + cValToChar(aColunas[aCol[nY,5]]) + "'"
											aAdd(aErros,{nX,"coluna do campo " + aCol[nY,1] + " possui conteúdo maior que o suportado pelo campo"})
											lErroVal := .T.
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
						&(SubStr(aCol[nY,1],5) + " := " + aColunas[aCol[nY,5]])
					Else
						If aCol[nY,2] == "N"
							&(SubStr(aCol[nY,1],5) + " := 0")
						Else
							&(SubStr(aCol[nY,1],5) + " := '" + Space(aCol[nY,3]) + "'")
						EndIf
					EndIf
				Next nY
				If !GVA->( msSeek( xFilial("GVA") + CDEMIT + NRTAB ) )
					aAdd(aErros,{nX,"não foi possível localizar a tabela " + NRTAB + " do transportador " + CDEMIT})
					lErroVal := .T.
				EndIf
				
				If !lErroVal 
					If (nY := aScan(aDadosAgrup,{|x| x[1] == FILIAL .And. x[2] == CDEMIT .And. x[3] == NRTAB .And. x[4] == NRNEG .And. x[5] == CDFXTV .And. x[6] == NRROTA })) == 0
						aAdd(aDadosAgrup,{FILIAL,CDEMIT,NRTAB,NRNEG,CDFXTV,NRROTA,{},{}})
						nY := Len(aDadosAgrup)
					EndIf
					aAdd(aDadosAgrup[nY,7],aClone(aColunas))
					aAdd(aDadosAgrup[nY,8],nX)
				EndIf
				
				//e validar a permisão de alteração, existente no model GFEA061A. caso passe, utilizar o estilo de atribuição do GFEX061(nova negociação)
				//somente a parte do model para carregar e testar se foi possível carregar o valor.
				//usar a GFEViewProc():New() para indicar o que deu certo e o que deu erro. uso pode ser olhado na GFEA058
			EndIf
		Next nX
		//Montagem e adição de dados
		
		oProcess:setRegua2(Len(aDadosAgrup))
		oProcess:incRegua1(OemToAnsi("Atualizando as possíveis combinações de tarifas"))
		If Empty(aErros)
			For nX := 1 To Len(aDadosAgrup)
				oProcess:incRegua2(OemToAnsi("Grupo " + cValToChar(nX)))
				lErroVal := .F.
				FILIAL := aDadosAgrup[nX,1]
				CDEMIT := aDadosAgrup[nX,2]
				NRTAB  := aDadosAgrup[nX,3]
				NRNEG  := aDadosAgrup[nX,4]
				CDFXTV := aDadosAgrup[nX,5]
				NRROTA := aDadosAgrup[nX,6]
			
				If !Empty(NRNEG) //Negociação, rota e faixa específicas
					If !GV9->( msSeek( xFilial("GV9") + CDEMIT + NRTAB + NRNEG) )
						aAdd(aErros,{aDadosAgrup[nX,8,1],"não foi possível localizar a negociação " + NRNEG + " da tabela " + NRTAB + " e transportador " + CDEMIT})
						lErroVal := .T.
					Else
						If !Empty(CDFXTV) .And. CDFXTV <> "*"
							If !GV7->( msSeek( xFilial("GV7") + CDEMIT + NRTAB + NRNEG + CDFXTV) )
								aAdd(aErros,{aDadosAgrup[nX,8,1],"não foi possível localizar a faixa " + CDFXTV + " da negociação " + NRNEG + ", tabela " + NRTAB + " e transportador " + CDEMIT})
								lErroVal := .T.
							EndIf
						EndIf
						
						If !Empty(NRROTA) .And. NRROTA <> "*"
							If !GV8->( msSeek( xFilial("GV8")  + CDEMIT + NRTAB + NRNEG + NRROTA) )
								aAdd(aErros,{aDadosAgrup[nX,8,1],"não foi possível localizar a rota " + NRROTA + " da negociação " + NRNEG + ", tabela " + NRTAB + " e transportador " + CDEMIT})
								lErroVal := .T.
							EndIf
						EndIf
					EndIf
				EndIf
				
				If !lErroVal
				
					cQuery := "SELECT GV6.R_E_C_N_O_ GV6_RECNO,GV9.R_E_C_N_O_ GV9_RECNO, GV9_SIT FROM " + RetSqlName("GV6") + " GV6" 
					cQuery += " INNER JOIN " + RetSqlName("GV9") + " GV9 ON GV9.D_E_L_E_T_ = ' '"
					cQuery += " AND GV9_FILIAL = GV6_FILIAL"
					cQuery += " AND GV9_CDEMIT = GV6_CDEMIT"
					cQuery += " AND GV9_NRTAB  = GV6_NRTAB"
					cQuery += " AND GV9_NRNEG  = GV6_NRNEG"
					cQuery += " WHERE GV6.D_E_L_E_T_ = ' '"
					cQuery += " AND GV6_FILIAL = '" + xFilial("GV6") + "'"
					cQuery += " AND GV6_CDEMIT = '" + CDEMIT + "'"
					cQuery += " AND GV6_NRTAB  = '" + NRTAB  + "'"
					
					If !Empty(NRNEG)
						cQuery += "AND GV6_NRNEG  = '" + NRNEG  + "'"
					EndIf
					
					If !Empty(CDFXTV) .And. CDFXTV <> "*"
						cQuery += "AND GV6_CDFXTV = '" + CDFXTV + "'"
					EndIf
					
					If !Empty(NRROTA) .And. NRROTA <> "*"
						cQuery += "AND GV6_NRROTA = '" + NRROTA + "'"
					EndIf
					
					cAlQuery := MpSysOpenQuery(ChangeQuery(cQuery),cAlQuery)
					
					If (cAlQuery)->(Eof())
						aAdd(aErros,{aDadosAgrup[nX,8,1],"não foi possível localizar uma combinação de negociação " + NRNEG + ", faixa " + CDFXTV + " e rota " + NRROTA + " para a tabela " + NRTAB + " e transportador " + CDEMIT})
						lErroVal := .T.
					EndIf
					
				EndIf
				
				If !lErroVal
					nReg := 0
					While !(cAlQuery)->(Eof())
						oProcess:incRegua2(OemToAnsi("Grupo " + cValToChar(nX) + " combinação " + cValToChar(++nReg)))
						lErroVal := .F.
						
						If (cAlQuery)->GV9_SIT == "2" .And. s_APRTAB $ "1S"
							aAdd(aErros,{aDadosAgrup[nX,8,1],"Não poderão ser alterados os dados da tarifa pois a tabela de frete já foi aprovada."})
							lErroVal := .T.
						EndIf
						
						If !lErroVal
							GV9->(dbGoto((cAlQuery)->GV9_RECNO))

							If CDFXTV == "*" .And. NRROTA == "*"
								oModelGV6 := FwLoadModel("GFEA061A")
								oModelGV6:SetOperation(MODEL_OPERATION_UPDATE)

								If oModelGV6:Activate()
									lExc := .F.
									
									oModelGUC := oModelGV6:GetModel("DETAIL_GUC")
									For nZ := 1 To oModelGUC:Length()
										oModelGUC:GoLine(nZ)
										If !oModelGUC:IsDeleted() .And. oModelGUC:GetValue("GUC_CDCOMP") == CDCOMP .And.  oModelGUC:GetValue("GUC_EMICOM") == EMICOM
											Exit
										EndIf
									Next nZ
												
									If nZ > oModelGUC:Length() // Não encontrou
										If !Empty(DELETA) .And. !(AllTrim(DELETA) $ ".F..NOT.NÃO.N.NO")
											oVwProc:Add("Não foi localizado a linha com o componente " + AllTrim(CDCOMP) + " e destinatário " + AllTrim(EMICOM) + " para realizar a remoção.")
										ElseIf !Empty(oModelGUC:GetValue("GUC_CDCOMP",1)) //Nova linha.
											oModelGUC:AddLine(.T.)
										EndIf
									ElseIf !Empty(DELETA) .And. !(AllTrim(DELETA) $ ".F..NOT.NÃO.N.NO")
										lExc := .T.
										oModelGUC:DeleteLine(,.T.)
									EndIf

									If !lExc
										GV2->(dbSeek(xFilial("GV2") + CDCOMP))
													
										aValores := {}
										cMsg := ""
													
										aAdd(aValores,{"GUC_CDCOMP",CDCOMP})
										aAdd(aValores,{"GUC_EMICOM",EMICOM})
										aAdd(aValores,{"GUC_NRCID",NRCID})
										aAdd(aValores,{"GUC_NATUR",NATUR})
													
										If !Empty(aCol[NVLFIXN,5])
											If GFEA61FWHN("GUC_VLFIXN",AllTrim(GV2->GV2_ATRCAL))
												aAdd(aValores,{"GUC_VLFIXN",VLFIXN})
											ElseIf VLFIXN != 0
												cMsg += ALERTAATR + "GUC_VLFIXN" + CRLF 
											EndIf
										EndIf
												
										If !Empty(aCol[NPCNORM,5])
											If GFEA61FWHN("GUC_PCNORM",AllTrim(GV2->GV2_ATRCAL))
												aAdd(aValores,{"GUC_PCNORM",PCNORM})
											ElseIf PCNORM != 0
												cMsg += ALERTAATR + "GUC_PCNORM" + CRLF
											EndIf
										EndIf
													
										If !Empty(aCol[NVLUNIN,5])
											If GFEA61FWHN("GUC_VLUNIN",AllTrim(GV2->GV2_ATRCAL))
												aAdd(aValores,{"GUC_VLUNIN",VLUNIN})
											ElseIf VLUNIN != 0
												cMsg += ALERTAATR + "GUC_VLUNIN" + CRLF
											EndIf
										EndIf
													
										If !Empty(aCol[NVLFRAC,5])
											If GFEA61FWHN("GUC_VLFRAC",AllTrim(GV2->GV2_ATRCAL))
												aAdd(aValores,{"GUC_VLFRAC",VLFRAC})
											ElseIf VLFRAC != 0
												cMsg += ALERTAATR + "GUC_VLFRAC" + CRLF
											EndIf
										EndIf
													
										If !Empty(aCol[NVLMINN,5])
											If GFEA61FWHN("GUC_VLMINN",AllTrim(GV2->GV2_ATRCAL))
												aAdd(aValores,{"GUC_VLMINN",VLMINN})
											ElseIf VLMINN != 0
												cMsg += ALERTAATR + "GUC_VLMINN" + CRLF
											EndIf
										EndIf
													
										If !Empty(aCol[NVLLIM,5])
											If GFEA61FWHN("GUC_VLLIM" ,AllTrim(GV2->GV2_ATRCAL))
												aAdd(aValores,{"GUC_VLLIM" ,VLLIM})
											ElseIf VLLIM != 0
												cMsg += ALERTAATR + "GUC_VLLIM" + CRLF
											EndIf
										EndIf
													
										If !Empty(aCol[NVLFIXE,5])
											If GFEA61FWHN("GUC_VLFIXE",AllTrim(GV2->GV2_ATRCAL))
												aAdd(aValores,{"GUC_VLFIXE",VLFIXE})
											ElseIf VLFIXE != 0
												cMsg += ALERTAATR + "GUC_VLFIXE" + CRLF
											EndIf
										EndIf
													
										If !Empty(aCol[NPCEXTR,5])
											If GFEA61FWHN("GUC_PCEXTR",AllTrim(GV2->GV2_ATRCAL))
												aAdd(aValores,{"GUC_PCEXTR",PCEXTR})
											ElseIf PCEXTR != 0
												cMsg += ALERTAATR + "GUC_PCEXTR" + CRLF
											EndIf
										EndIf
													
										If !Empty(aCol[NVLUNIE,5])
											If GFEA61FWHN("GUC_VLUNIE",AllTrim(GV2->GV2_ATRCAL))
												aAdd(aValores,{"GUC_VLUNIE",VLUNIE})
											ElseIf VLUNIE != 0
												cMsg += ALERTAATR + "GUC_VLUNIE" + CRLF
											EndIf
										EndIf
													
										If !Empty(aCol[NCALCEX,5])
											If GFEA61FWHN("GUC_CALCEX",AllTrim(GV2->GV2_ATRCAL))	
												If Empty(CALCEX)
													CALCEX := "1"
												EndIf
												aAdd(aValores,{"GUC_CALCEX",CALCEX})
											EndIf
										EndIf
													
										If !Empty(cMsg)
											oVwProc:Add(cMsg)
										EndIf
													
										lErroVal := .NOT.SetData(oModelGUC,aValores,aDadosAgrup[nX,8,nY])
									EndIf

									If !lErroVal
										If oModelGV6:VldData()
											oModelGV6:CommitData()
										EndIf
									EndIf
								EndIf
							Else
								GV6->(dbGoto((cAlQuery)->GV6_RECNO))
								oModelGV6 := FwLoadModel("GFEA061F")
								oModelGV6:SetOperation(MODEL_OPERATION_UPDATE)
								
								oProcess:setRegua2(Len((aDadosAgrup[nX,7])))
								If oModelGV6:Activate()
									For nY := 1 To Len(aDadosAgrup[nX,7])
										oProcess:incRegua2(OemToAnsi("Grupo " + cValToChar(nX) + " combinação " + cValToChar(nReg)))
										aColunas := aClone(aDadosAgrup[nX,7,nY])
										For nQ := 1 To Len(aCol)
											If !Empty(aCol[nQ,5])
												&(SubStr(aCol[nQ,1],5) + " := " + cValToChar(aColunas[aCol[nQ,5]]))
											EndIf
										Next nQ
										DELETA := AllTrim(UPPER(DELETA))
										If !Empty(DELETA) .And. !(AllTrim(DELETA) $ ".F..NOT.NÃO.N.NO")
											oVwProc:Add("Removendo componente " + CDCOMP + " " + If(Empty(EMIBKP),"da"," para o destinatário " + EMIBKP + "(" + AllTrim(EMICOM) + ") na") + " negociação " + GV6->GV6_NRNEG + ", faixa " + GV6->GV6_CDFXTV + " e rota " + GV6->GV6_NRROTA + " para a tabela " + GV6->GV6_NRTAB + " e transportador " + GV6->GV6_CDEMIT)
										Else
											oVwProc:Add("Atualizando componente " + CDCOMP + " " + If(Empty(EMIBKP),"da"," para o destinatário " + EMIBKP + "(" + AllTrim(EMICOM) + ") na") + " negociação " + GV6->GV6_NRNEG + ", faixa " + GV6->GV6_CDFXTV + " e rota " + GV6->GV6_NRROTA + " para a tabela " + GV6->GV6_NRTAB + " e transportador " + GV6->GV6_CDEMIT)
											GV2->(dbSeek(xFilial("GV2") + CDCOMP))
										EndIf
											
										oModelGV1 := oModelGV6:GetModel("DETAIL_GV1")
										If Empty(EMICOM)
										
											For nZ := 1 To oModelGV1:Length()
												oModelGV1:GoLine(nZ)
												If !oModelGV1:IsDeleted() .And. oModelGV1:GetValue("GV1_CDCOMP") == CDCOMP
													Exit
												EndIf
											Next nZ
											
											If nZ > oModelGV1:Length() // Não encontrou
												If !Empty(DELETA) .And. !(AllTrim(DELETA) $ ".F..NOT.NÃO.N.NO")
													oVwProc:Add("Não foi localizado a linha com o componente " + CDCOMP + " para realizar a remoção.")
													Loop
												ElseIf !Empty(oModelGV1:GetValue("GV1_CDCOMP",1)) //Nova linha.
													oModelGV1:AddLine(.T.)
												EndIf
											ElseIf !Empty(DELETA) .And. !(AllTrim(DELETA) $ ".F..NOT.NÃO.N.NO")
												oModelGV1:DeleteLine(,.T.)
												Loop
											EndIf
											
											aValores := {}
											cMsg := ""
											
											aAdd(aValores,{"GV1_CDCOMP",CDCOMP})
											
											If !Empty(aCol[NVLFIXN,5])
												If GFEA61FWHN("GV1_VLFIXN",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GV1_VLFIXN",VLFIXN})
												ElseIf VLFIXN != 0
													cMsg += ALERTAATR + "GV1_VLFIXN" + CRLF 
												EndIf
											EndIf
										
											If !Empty(aCol[NPCNORM,5])
												If GFEA61FWHN("GV1_PCNORM",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GV1_PCNORM",PCNORM})
												ElseIf PCNORM != 0
													cMsg += ALERTAATR + "GV1_PCNORM" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NVLUNIN,5])
												If GFEA61FWHN("GV1_VLUNIN",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GV1_VLUNIN",VLUNIN})
												ElseIf VLUNIN != 0
													cMsg += ALERTAATR + "GV1_VLUNIN" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NVLFRAC,5])
												If GFEA61FWHN("GV1_VLFRAC",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GV1_VLFRAC",VLFRAC})
												ElseIf VLFRAC != 0
													cMsg += ALERTAATR + "GV1_VLFRAC" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NVLMINN,5])
												If GFEA61FWHN("GV1_VLMINN",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GV1_VLMINN",VLMINN})
												ElseIf VLMINN != 0
													cMsg += ALERTAATR + "GV1_VLMINN" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NVLLIM,5])
												If GFEA61FWHN("GV1_VLLIM" ,AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GV1_VLLIM" ,VLLIM})
												ElseIf VLLIM != 0
													cMsg += ALERTAATR + "GV1_VLLIM" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NVLFIXE,5])
												If GFEA61FWHN("GV1_VLFIXE",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GV1_VLFIXE",VLFIXE})
												ElseIf VLFIXE != 0
													cMsg += ALERTAATR + "GV1_VLFIXE" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NPCEXTR,5])
												If GFEA61FWHN("GV1_PCEXTR",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GV1_PCEXTR",PCEXTR})
												ElseIf PCEXTR != 0
													cMsg += ALERTAATR + "GV1_PCEXTR" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NVLUNIE,5])
												If GFEA61FWHN("GV1_VLUNIE",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GV1_VLUNIE",VLUNIE})
												ElseIf VLUNIE != 0
													cMsg += ALERTAATR + "GV1_VLUNIE" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NCALCEX,5])
												If GFEA61FWHN("GV1_CALCEX",AllTrim(GV2->GV2_ATRCAL))	
													If Empty(CALCEX)
														CALCEX := "1"
													EndIf
													aAdd(aValores,{"GV1_CALCEX",CALCEX})
												ElseIf !Empty(CALCEX)
													cMsg += ALERTAATR + "GV1_CALCEX" + CRLF
												EndIf
											EndIf
											
											If !Empty(cMsg)
												oVwProc:Add(cMsg)
											EndIf
											
											lErroVal := .NOT.SetData(oModelGV1,aValores,aDadosAgrup[nX,8,nY])
											
										Else
										
											oModelGUC := oModelGV6:GetModel("DETAIL_GUC")
											For nZ := 1 To oModelGUC:Length()
												oModelGUC:GoLine(nZ)
												If !oModelGUC:IsDeleted() .And. oModelGUC:GetValue("GUC_CDCOMP") == CDCOMP .And.  oModelGUC:GetValue("GUC_EMICOM") == EMICOM
													Exit
												EndIf
											Next nZ
											
											If nZ > oModelGUC:Length() // Não encontrou
												If !Empty(DELETA) .And. !(AllTrim(DELETA) $ ".F..NOT.NÃO.N.NO")
													oVwProc:Add("Não foi localizado a linha com o componente " + AllTrim(CDCOMP) + " e destinatário " + AllTrim(EMICOM) + " para realizar a remoção.")
													Loop
												ElseIf !Empty(oModelGUC:GetValue("GUC_CDCOMP",1)) //Nova linha.
													oModelGUC:AddLine(.T.)
												EndIf
											ElseIf !Empty(DELETA) .And. !(AllTrim(DELETA) $ ".F..NOT.NÃO.N.NO")
												oModelGUC:DeleteLine(,.T.)
												Loop
											EndIf
											
											aValores := {}
											cMsg := ""
											
											aAdd(aValores,{"GUC_CDCOMP",CDCOMP})
											aAdd(aValores,{"GUC_EMICOM",EMICOM})
											aAdd(aValores,{"GUC_NRCID",NRCID})
											aAdd(aValores,{"GUC_NATUR",NATUR})
											
											If !Empty(aCol[NVLFIXN,5])
												If GFEA61FWHN("GUC_VLFIXN",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GUC_VLFIXN",VLFIXN})
												ElseIf VLFIXN != 0
													cMsg += ALERTAATR + "GUC_VLFIXN" + CRLF 
												EndIf
											EndIf
										
											If !Empty(aCol[NPCNORM,5])
												If GFEA61FWHN("GUC_PCNORM",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GUC_PCNORM",PCNORM})
												ElseIf PCNORM != 0
													cMsg += ALERTAATR + "GUC_PCNORM" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NVLUNIN,5])
												If GFEA61FWHN("GUC_VLUNIN",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GUC_VLUNIN",VLUNIN})
												ElseIf VLUNIN != 0
													cMsg += ALERTAATR + "GUC_VLUNIN" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NVLFRAC,5])
												If GFEA61FWHN("GUC_VLFRAC",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GUC_VLFRAC",VLFRAC})
												ElseIf VLFRAC != 0
													cMsg += ALERTAATR + "GUC_VLFRAC" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NVLMINN,5])
												If GFEA61FWHN("GUC_VLMINN",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GUC_VLMINN",VLMINN})
												ElseIf VLMINN != 0
													cMsg += ALERTAATR + "GUC_VLMINN" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NVLLIM,5])
												If GFEA61FWHN("GUC_VLLIM" ,AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GUC_VLLIM" ,VLLIM})
												ElseIf VLLIM != 0
													cMsg += ALERTAATR + "GUC_VLLIM" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NVLFIXE,5])
												If GFEA61FWHN("GUC_VLFIXE",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GUC_VLFIXE",VLFIXE})
												ElseIf VLFIXE != 0
													cMsg += ALERTAATR + "GUC_VLFIXE" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NPCEXTR,5])
												If GFEA61FWHN("GUC_PCEXTR",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GUC_PCEXTR",PCEXTR})
												ElseIf PCEXTR != 0
													cMsg += ALERTAATR + "GUC_PCEXTR" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NVLUNIE,5])
												If GFEA61FWHN("GUC_VLUNIE",AllTrim(GV2->GV2_ATRCAL))
													aAdd(aValores,{"GUC_VLUNIE",VLUNIE})
												ElseIf VLUNIE != 0
													cMsg += ALERTAATR + "GUC_VLUNIE" + CRLF
												EndIf
											EndIf
											
											If !Empty(aCol[NCALCEX,5])
												If GFEA61FWHN("GUC_CALCEX",AllTrim(GV2->GV2_ATRCAL))	
													If Empty(CALCEX)
														CALCEX := "1"
													EndIf
													aAdd(aValores,{"GUC_CALCEX",CALCEX})
												ElseIf !Empty(CALCEX)
													cMsg += ALERTAATR + "GUC_CALCEX" + CRLF
												EndIf
											EndIf
											
											If !Empty(cMsg)
												oVwProc:Add(cMsg)
											EndIf
											
											lErroVal := .NOT.SetData(oModelGUC,aValores,aDadosAgrup[nX,8,nY])
										
										EndIf
										
									Next nY
									
									nZ := 0
									nQ := oModelGV1:Length()
									For nY := 1 To nQ
										If Empty(oModelGV1:GetValue("GV1_CDCOMP",nY)) .Or. oModelGV1:IsDeleted(nY)
											nZ++
										EndIf
									Next nY
									
									If nQ == nZ
										oVwProc:Add("Não há componentes de frete gerais na tarifa.")
										aAdd(aErros,{aDadosAgrup[nX,8,1],"Não há componentes de frete gerais na tarifa."})
										lErroVal := .T.
									EndIf
								
									If !lErroVal
										If oModelGV6:VldData()
											oModelGV6:CommitData()
										Else
											aErro := oModelGV6:GetErrorMessage()
											oVwProc:Add("Não foi possível alterar a tarifa. Motivo: " + aErro[6])
											aAdd(aErros,{aDadosAgrup[nX,8,1],"Não foi possível alterar a tarifa.Motivo: " + aErro[6]})
											aSize(aErro,0)
										EndIf
									EndIf
										
								Else
									aErro := oModelGV6:GetErrorMessage()
									oVwProc:Add("Não foi possível alterar a tarifa. Motivo: " + aErro[6])
									aAdd(aErros,{aDadosAgrup[nX,8,1],"Não foi possível alterar a tarifa.Motivo: " + aErro[6]})
									aSize(aErro,0)
								EndIf
								
								oModelGV6:DeActivate()
								FreeObj(oModelGV6)
							EndIf
						EndIf
						
						(cAlQuery)->(dbSkip())
					EndDo
					(cAlQuery)->(dbCloseArea())
				EndIf
			Next nX
		EndIf
		nY := 0
		For nX := 1 To Len(aErros)
			If nY != aErros[nX,1]
				nY := aErros[nX,1]
				cLinhaErro := "Erro(s) na linha " + cValToChar(nY)
				oVwProc:AddErro( cLinhaErro + ": " + aErros[nX,2] )
			Else
				oVwProc:AddErro( Space(Len(cLinhaErro + ": ")) + aErros[nX,2] )
			EndIf
		Next nX
		CursorArrow()
		If Len(aErros) == 0
			oVwProc:Add("")
			oVwProc:Add("O arquivo foi importado com sucesso!")
		EndIf
		oVwProc:Show("Importação de tarifas", "Tarifas", "Erros", "Um ou mais linhas do arquivo não foram importadas com sucesso. Clique em 'Erros' para mais detalhes.")
		FreeObj(oVwProc)
	EndIf
	aSize(aColunas   ,0)
	aSize(aLinhas    ,0)
	aSize(aErro      ,0)
	aSize(aData      ,0)
	aSize(aDadosAgrup,0)
	aSize(aCol       ,0)
Return

Function GFEA069MDT()
	oProcess := MsNewProcess():New({|| ProcImp()}, "Importação", "Iniciando processo...")
	oProcess:Activate()
Return

Static Function SetData(oModel, aCampos,nPosErro)
	Local oModPai := oModel:GetModel()
	Local nX
	
	For nX := 1 To Len(aCampos)
		If !oModel:SetValue(aCampos[nX,1],aCampos[nX,2])
			aErro := oModPai:GetErrorMessage()
			oVwProc:Add("Não foi possível alterar a tarifa. Campo: " + aErro[4] + " Motivo: " + aErro[6])
			aAdd(aErros,{nPosErro,"Não foi possível alterar a tarifa. Campo: " + aErro[4] + " Motivo: " + aErro[6]})
			aSize(aErro,0)
			Return .F.
		EndIf
	Next nX
	
Return .T.
//Modelo de importação
Function GFEA069MDI()
	Local oStructGUC := FwFormStruct(1,"GUC")
	Local cFile
	Local cConteudo := ""
	Local nX
	Local aData
	Local nFields := 0
	Local nMinus := 0
	Local aStru := GUC->(dbStruct())
	Pergunte("GFEA069",.F.)
	If !GUC->(Eof())
		SetMVValue("GFEA069","MV_PAR01",GUC->GUC_FILIAL)
		SetMVValue("GFEA069","MV_PAR02",GUC->GUC_CDEMIT)
		SetMVValue("GFEA069","MV_PAR03",GUC->GUC_NRTAB)
		SetMVValue("GFEA069","MV_PAR04",GUC->GUC_NRNEG)
		SetMVValue("GFEA069","MV_PAR05",GUC->GUC_CDFXTV)
		SetMVValue("GFEA069","MV_PAR06",GUC->GUC_NRROTA)
	EndIf
	If Pergunte("GFEA069",.T.)
		cFile := cGetFile( "Arquivos separados por Ponto-e-Virgula (*.CSV) |*.csv|","Salvar Como...",,cLastFolder,.F.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)
		If !Empty(cFile)
			cLastFolder := SubStr(cFile,1,Rat(If(isSRVunix(),"/","\"),cFile) )
			If UPPER(right(AllTrim(cFile),4)) != ".CSV"
				cFile := AllTrim(cFile) + ".csv"
			EndIf
			CursorWait()
			
			//Nome físico do campo
			For nX := 1 To Len(oStructGUC:aFields)
				If aScan(aStru,{|x|x[1] == oStructGUC:aFields[nX,MODEL_FIELD_IDFIELD]}) > 0
					cConteudo += oStructGUC:aFields[nX,MODEL_FIELD_IDFIELD] + ";"
					nFields++
				EndIf
			Next nX
			cConteudo += "GUC_DELETA;"
			cConteudo := Left(cConteudo,Len(cConteudo)-1)
			cConteudo += CHR(13) + CHR(10)
			
			//Nome lógico
			For nX := 1 To Len(oStructGUC:aFields)
				If aScan(aStru,{|x|x[1] == oStructGUC:aFields[nX,MODEL_FIELD_IDFIELD]}) > 0
					cConteudo += oStructGUC:aFields[nX,MODEL_FIELD_TITULO] + ";"
				EndIf
			Next nX
			cConteudo += "Excluir?;"
			cConteudo := Left(cConteudo,Len(cConteudo)-1)
			cConteudo += CHR(13) + CHR(10)
			
			aData := Array(nFields)
			For nX := 1 To Len(aData)
				If aScan(aStru,{|x|x[1] == oStructGUC:aFields[nX-nMinus,MODEL_FIELD_IDFIELD]}) > 0 .And. Posicione("SX3",1,"GUC"+oStructGUC:aFields[nX-nMinus,MODEL_FIELD_IDFIELD],"X3_PROPRI") != "U"
					If oStructGUC:aFields[nX-nMinus,MODEL_FIELD_IDFIELD] == "GUC_FILIAL"
						aData[nX] := MV_PAR01
					ElseIf oStructGUC:aFields[nX-nMinus,MODEL_FIELD_IDFIELD] == "GUC_CDEMIT"
						aData[nX] := MV_PAR02
					ElseIf oStructGUC:aFields[nX-nMinus,MODEL_FIELD_IDFIELD] == "GUC_NRTAB"
						aData[nX] := MV_PAR03
					ElseIf oStructGUC:aFields[nX-nMinus,MODEL_FIELD_IDFIELD] == "GUC_NRNEG"
						aData[nX] := MV_PAR04
					ElseIf oStructGUC:aFields[nX-nMinus,MODEL_FIELD_IDFIELD] == "GUC_CDFXTV"
						aData[nX] := MV_PAR05
					ElseIf oStructGUC:aFields[nX-nMinus,MODEL_FIELD_IDFIELD] == "GUC_NRROTA"
						aData[nX] := MV_PAR06
					ElseIf oStructGUC:aFields[nX-nMinus,MODEL_FIELD_TIPO] == "N"
						aData[nX] := 0.0
					ElseIf oStructGUC:aFields[nX-nMinus,MODEL_FIELD_TIPO] == "D"
						aData[nX] := "  /  /    "
					ElseIf oStructGUC:aFields[nX-nMinus,MODEL_FIELD_TIPO] == "L"
						aData[nX] := ".F."
					Else
						aData[nX] := ""
					EndIf
				Else
					nMinus--
					nX--
				EndIf
			Next nX
			
			aAdd(aData,"N")// Posição do delete
			
			For nX := 1 To Len(aData)
				cConteudo += cValToChar(aData[nX]) + ";'"
			Next nX

			cConteudo := Left(cConteudo,Len(cConteudo)-1)
			MemoWrite(cFile,cConteudo)
			shellExecute("Open", cFile,"" ,"" , 1 )
			CursorArrow()
		EndIf
	EndIf
Return
