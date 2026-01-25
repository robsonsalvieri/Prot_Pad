#INCLUDE "PROTHEUS.CH"	

Static __lLogIntP := IIF(SuperGetMv("MV_GFELPR",,'1') == '2',.F., .T.)//Indica se será gerado ou não o log da integração com o ERP Protheus

// Constante usada na função AddToLog()
#DEFINE _LOG_END   2
	
// ----------------------------------------------------------------------------
// Funções relacionadas a integração entre Protheus x GFE				
// ----------------------------------------------------------------------------

 
//-----------------------------------------------------
/* GFECHVNFE
Atualiza a Chave NF-e no Documento de Carga

@param
	cFil		: F2_FILIAL
	cSerie		: F2_SERIE
	cNumDoc		: F2_DOC
	cF2Tipo		: F2_TIPO
	cCGC		: A2_CGC
	cCod		: A2_COD
	cCodLoja	: A2_LOJA
	cChaveNFE	: F2_CHVNFE
	
@author Israel A. Possoli
@version P11
@since 21/05/2014
*/
//------------------------------------------------------
Function GFECHVNFE(cFil, cSerie, cNumDoc, cF2Tipo, cCGC, cCod, cCodLoja, cChaveNFE, cAutSef, cTipo)
	Local aRet[2]
	Local aChaveGW1[7]
	Local cGW1_AUTSEF := "0"
	Default cChaveNFE := ""
	Default cAutSef := "T"
	
	aRet[1] := .T.
	aRet[2] := ""
	
	If Empty(cChaveNFE)
		aRet[1] := .F.
		aRet[2] := "Chave NF-e não informada"
		
		Return (aRet)
	EndIf
	
	// Verifica se existe algum Documento de Carga com a chave NF-e informada
	dbSelectArea("GW1")
	dbSetOrder(12)
	If dbSeek(cChaveNFE)
		aRet[1] := .F.
		aRet[2] := "Já existe um documento de carga com a chave NF-e: " + cChaveNFE + ". Filial: " + GW1->GW1_FILIAL + ", Serie: " + GW1->GW1_SERDC + ", Nr: " + GW1->GW1_NRDC
	Else
		aChaveGW1 := GFESF2TGW1(cFil, cSerie, cNumDoc, cF2Tipo, cCGC, cCod, cCodLoja, cTipo)
	
		If aChaveGW1[6]
			// Define a situação da autornização no Sefaz
			Do Case
				Case cAutSef== "T" //transmitida
					cGW1_AUTSEF := "0" //Nao informado
				
				Case cAutSef == "S" //NF Autorizada
					cGW1_AUTSEF := "1" //Autorizado
				
				Case cAutSef == "D" //NF Uso Denegado
					cGW1_AUTSEF := "2" //Nao-autorizado
				
				Case cAutSef == "N" //NF Não-autorizada
					cGW1_AUTSEF := "2" //Nao-autorizado
					
				otherwise
					cGW1_AUTSEF := "0" //Nao informado
			EndCase
					
			dbSelectArea("GW1")
			dbSetOrder(1)
			dbSeek(aChaveGW1[1] + aChaveGW1[2] + aChaveGW1[3] + aChaveGW1[4] + aChaveGW1[5])
			aRet[1] := .T.
			aRet[2] := "Documento de carga: Filial: " + GW1->GW1_FILIAL + ", Série: " + GW1->GW1_SERDC + ", Nr: " + GW1->GW1_NRDC
			
			RecLock("GW1", .F.)
				GW1->GW1_AUTSEF := cGW1_AUTSEF
				GW1->GW1_DANFE  := cChaveNFE
			MsUnlock()
		Else
			aRet[1] := .F.
			aRet[2] := aChaveGW1[7]
		EndIf
	EndIf
Return (aRet)


//-----------------------------------------------------
/* GFESF2TGW1
Retorna a chave do Documento de Carga (GW1) com base em um Documento de Saída (SF2)

@param
	cFil		: F2_FILIAL
	cSerie		: F2_SERIE
	cNumDoc		: F2_DOC
	cF2Tipo		: F2_TIPO
	cCGC		: A2_CGC
	cCod		: A2_COD
	cCodLoja	: A2_LOJA
	
@return
	aRet[1]		: Filial (GW1_FILIAL)
	aRet[2]		: Tipo Documento de Carga (GW1_CDTPDC)
	aRet[3]		: Emissor (GW1_EMISDC)
	aRet[4]		: Série	(GW1_SERDC)
	aRet[5]		: Número (GW1_NRDC)
	aRet[6]		: Sucesso .T./.F.
	aRet[7]		: Mensagem de Erro
	
@author Israel A. Possoli
@version P11
@since 21/05/2014
*/
//------------------------------------------------------
Function GFESF2TGW1(cFil, cSerie, cNumDoc, cF2Tipo, cCGC, cCod, cCodLoja, cTipo)
	Local aRet[7]
	Local lNumProp  := SuperGetMv("MV_EMITMP",.F.,"1") == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"
	Local cAliasGW1 := ""
	Local cCDTPDC   := ""
	Local cEmisDC   := ""
	Local aDocCarga := {}
	Default cTipo := "S"

	aRet[1] := ""
	aRet[2] := ""
	aRet[3] := ""
	aRet[4] := ""
	aRet[5] := ""
	aRet[6] := .F.
	aRet[7] := ""
	
	// Define o Tipo de Documento de Carga (GW1_CDTPDC)
	cCDTPDC := Posicione("SX5", 1, xFilial("SX5") + "MQ" + AllTrim(cF2Tipo) + cTipo, "X5_DESCRI")
	If Empty(cCDTPDC)
		cCDTPDC := Posicione("SX5", 1, xFilial("SX5") + "MQ" + AllTrim(cF2Tipo), "X5_DESCRI")
	EndIf
	
	// Define o Emissor do Documento de Carga (GW1_EMISDC)
	If lNumProp
		If cTipo == "S"
			cEmisDc := GFEM011COD(,,,.T.,cFil)
		Else
			If cF2Tipo $ "D|B"
				cEmisDC := GFEM011COD(cCod,cCodLoja,1,,)
			Else
				cEmisDC := GFEM011COD(cCod,cCodLoja,2,,)
			EndIf				
		EndIF
	Else
		dbSelectArea("GU3")
		dbSetOrder(11) // GU3_FILIAL + GU3_IDFED
		If dbSeek(xFilial("GU3") + cCGC)
			cEmisDc := GU3->GU3_CDEMIT
		EndIf
	EndIf
	
	// Acerta o tamanho dos campos
	cFil	:= PadR(cFil, TamSx3("GW1_FILIAL")[1])
	cSerie	:= PadR(cSerie, TamSx3("GW1_SERDC")[1])
	cNumDoc	:= PadR(cNumDoc, TamSx3("GW1_NRDC")[1])
	cEmisDC	:= PadR(cEmisDC, TamSx3("GW1_EMISDC")[1])
	cCDTPDC := SubStr(cCDTPDC, 1, TamSx3("GW1_CDTPDC")[1])
	
	// Ponto de entrada MOBLY
	If  ExistBlock("GFEXIN01")
		aDocCarga 	:= ExecBlock("GFEXIN01",.F.,.F.,{cFil, cSerie, cNumDoc, cEmisDC, cCDTPDC })
		cFil	 := aDocCarga[1] 
		cSerie  := aDocCarga[2]
		cNumDoc := aDocCarga[3]
		cEmisDC := aDocCarga[4]
		cCDTPDC := aDocCarga[5]
	EndIf
	
	// Busca o Documento de Carga pelo índice 1 (Chave completa)
	dbSelectArea("GW1")
	dbSetOrder(1) // GW1_FILIAL + GW1_CDTPDC + GW1_EMISDC + GW1_SERDC + GW1_NRDC
	If dbSeek(cFil + cCDTPDC + cEmisDC + cSerie + cNumDoc)
		aRet[1] := GW1->GW1_FILIAL
		aRet[2] := GW1->GW1_CDTPDC
		aRet[3] := GW1->GW1_EMISDC
		aRet[4] := GW1->GW1_SERDC
		aRet[5] := GW1->GW1_NRDC
		aRet[6] := .T.
		aRet[7] := "Documento de Carga: Filial: " + GW1->GW1_FILIAL + ", Série: " + GW1->GW1_SERDC + ", Nr: " + GW1->GW1_NRDC
	Else
		// Busca por nota atraves de dados da nota + destinatário
		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1.GW1_FILIAL, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GW1.GW1_NRDC
			FROM %Table:GW1% GW1
			WHERE GW1.GW1_FILIAL = %Exp:cFil%
			AND GW1.GW1_CDTPDC = %Exp:cCDTPDC%
			AND GW1.GW1_NRDC = %Exp:cNumDoc%
			AND GW1.GW1_SERDC = %Exp:cSerie%
			AND GW1.GW1_CDDEST = %Exp:cEmisDC%
			AND GW1.%NotDel%
		EndSql
		If (cAliasGW1)->(!Eof())
			aRet[1] := (cAliasGW1)->GW1_FILIAL
			aRet[2] := (cAliasGW1)->GW1_CDTPDC
			aRet[3] := (cAliasGW1)->GW1_EMISDC
			aRet[4] := (cAliasGW1)->GW1_SERDC
			aRet[5] := (cAliasGW1)->GW1_NRDC
			aRet[6] := .T.
			aRet[7] := "Documento de Carga: Filial: " + (cAliasGW1)->GW1_FILIAL + ", Série: " + (cAliasGW1)->GW1_SERDC + ", Nr: " + (cAliasGW1)->GW1_NRDC
		EndIf
		(cAliasGW1)->(dbCloseArea())
	EndIf

Return (aRet)

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} -()
Função utilizada em Integração.
Generico

@parametros
cSituacao: Situação a ser atribuida
1=Nao Enviado
2=Pendente
3=Rejeitado
4=Atualizado
5=Pendente Desatualizacao
6=Nao se Aplica
dData: Data a ser atribuida
tpAcaoInt: Tipo de integração, influencia em quais campos a situação e data serão atribuidos. 
1 = Fiscal, 
2 = Despesas, 
3 = Ambos

@sample

@author Ana Claudia da Silva
@since 02/09/2015
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEAIntGW3(cSituacao, dData, tpAcaoInt,cFatu)
	Local aRet      := {.T., {}}
	Local aRetAux   := {.T.,""}
	Local cProg     := "1"

	// 1=Nao Enviado;2=Pendente;3=Rejeitado;4=Atualizado;5=Pendente Desatualizacao;6=Nao se Aplica

	If cSituacao == "5" //Desatualização do Documento de Frete

		//Desatualização do Documento de Frete no Protheus. Nova integração.
		//Uso do RecLock pelo confronto do retorno de erro do MsExecAuto com o model
		aRetAux := GFEXIDcEnt(tpAcaoInt,"5")

		If aRetAux[1]
			RecLock("GW3", .F.)
			If tpAcaoInt == "1" // Fiscal
				GW3->GW3_SITFIS := "1" //1=Nao Enviado
				GW3->GW3_MOTFIS := ""
				GW3->GW3_DTFIS := SToD("        ")
			ElseIf tpAcaoInt == "2" .And. !(GW3->GW3_TPDF == "3" .And. GW3->GW3_VLDF == 0) // Recebimento
				GW3->GW3_SITREC := "1"
				GW3->GW3_MOTREC := ""
				GW3->GW3_DTREC := SToD("        ")
			EndIf
			GW3->( MsUnlock() )
			Return {.T., {}}
		Else
			RecLock("GW3", .F.)
			If tpAcaoInt == "1" // Fiscal
				GW3->GW3_SITFIS := "4" // 4=Atualizado
				GW3->GW3_MOTFIS := aRetAux[2]
			ElseIf tpAcaoInt == "2" // Recebimento
				GW3->GW3_SITREC := "4"
				GW3->GW3_MOTREC := aRetAux[2]
			EndIf
			GW3->( MsUnlock() )
			Return {.F., {,,,,,aRetAux[2]}}
		EndIf
	EndIf

	If IsInCallStack("GFEA115AIN")
		cProg = "2"
	EndIf

	If cSituacao == "2"
		// Fiscal
		If tpAcaoInt $ "1;3" .And. GW3->GW3_SITFIS != '6'
		
			aRetAux := GFEXIDcEnt("1","2")
			RecLock("GW3", .F.)
			If !aRetAux[1] //Retorno Falso					
				GW3->GW3_SITFIS := "3" //Situação Rejeitado
				GW3->GW3_MOTFIS := aRetAux[2] + CRLF + "Ultima tentativa de integração: " + DtoC(Date()) + " " + Time()
				GW3->GW3_DTFIS  := SToD(Space(8))
			Else //Retorno Verdadeiro
				GW3->GW3_SITFIS := "4" //Situação Atualizado
				GW3->GW3_MOTFIS := " "
			EndIf
			GW3->GW3_DTFIS := dData
			GW3->( MsUnlock() )
		EndIf

		// Recebimento
		If tpAcaoInt $ "2;3" .And. GW3->GW3_SITREC != '6'

			aRetAux := GFEXIDcEnt("2","2")
			RecLock("GW3", .F.)
			If !aRetAux[1] //Retorno Falso
				GW3->GW3_SITREC := "3" //Situação Rejeitado
				GW3->GW3_MOTREC := AllTrim(aRetAux[2]) + CRLF + "Ultima tentativa de integração: " + DtoC(Date()) + " " + Time()
				GW3->GW3_DTREC  := SToD(Space(8))
			Else //Retorno Verdadeiro
				GW3->GW3_SITREC := "4" //Situação Atualizado
				GW3->GW3_MOTREC := " "
			EndIf
			GW3->GW3_DTREC := dData
			GW3->( MsUnlock() )
			
		EndIf	
		
	EndIf
		
	If !IsInCallStack("GFEA065")
		//Quando a integração não ocorreu, é necessário retornar falso e a mensagem de erro
		If tpAcaoInt == "3"
			If GW3->GW3_SITFIS == "3" //Situação Rejeitado
				aRet := {.F., {,,,,,GW3->GW3_MOTFIS,,,}}
			EndIf
		EndIf
		If tpAcaoInt $ "2;3;5"
			If GW3->GW3_SITREC == "3" //Situação Rejeitado
				aRet := {.F., {,,,,,GW3->GW3_MOTREC,,,}}
			EndIf
		EndIf
	EndIf
		
	Return aRet

//-----------------------------------------------------
/*/ Integração de Documentos de Frete como Documento de Entrada

@author Ana Claudia da Silva
@since 02/09/2015
@version 1.0
*/
//------------------------------------------------------

Function GFEXIDcEnt(nInt,cSituacao)

	Local cMsg := ""
	Local lIntGFE := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cERPGFE := SuperGetMV("MV_ERPGFE",,"2")
	Local aRet := {}
	
	Private _oGFEXFBFL := GFEXFBFLog():New()

	If lIntGFE .And. cIntGFE2 $ "1S" .And. cERPGFE == "2"
	
		_oGFEXFBFL:setSaveLog(__lLogIntP)
		_oGFEXFBFL:setAgrFrt(GW3->GW3_NRDF)

		Do Case

			Case cSituacao == "2"
				If !AtuDocInt(nInt,@cMsg) //Atualização Doc. Frete Fiscal/Recebimento
					aRet := {.F.,cMsg}
				Else
					aRet := {.T.,""}
				EndIf

			Case cSituacao == "5"
				If !DesAtDcInt(nInt,@cMsg) //Desatualização Doc. Frete Fiscal/Recebimento
					aRet := {.F.,cMsg}
				Else
					aRet := {.T.,""}
				EndIf

			Otherwise

				Return aRet

		EndCase
		
		_oGFEXFBFL:SaveLog()

	Else

		aRet := {.F.,"Verifique os parâmetros de integração do GFE (MV_INTGFE, MV_INTGFE2 e MV_ERPGFE)."}

	EndIf

Return aRet
//-----------------------------------------------------
/*/	Atualização do documento de frete no Protheus

@param nInt = "1"(Integração de Documentos de Frete como Documento de Entrada)
= "2"(Integração de Documentos de Frete como Nota de Conhecimento)

cMsg
@author Ana Claudia da Silva
@since 02/09/2015
@version 1.0
*/
//------------------------------------------------------

Function AtuDocInt(nInt,cMsg,nOpc)

	Local aDocFrete := {}
	Local aItensDoc := {}
	Local aNotasFis := {}
	Local lErro := .F.
	Local aForLoj := GFEA055GFL(GW3->GW3_EMISDF)
	Local aCliLoj := GFEA055DEV(GW3->GW3_CDDEST,"C") // "C" -> Solicita o codigo do cadastro de clientes (SA1)	
	Local cF1_DOC := GW3->GW3_NRDF
	Local aErro := {}
	Local nX := 0
	Local cCpdGFE	:= ""
	Local cNtfGfe   := SuperGetMv("MV_NTFGFE",,"")
	Local cFilAtu
	Local aCustFis 	:= {}
	Local aCustRec 	:= {}
	Local cTpCte 	:= ""
	Local cOpcInteg := ""
	Local aCidades	    := {}
	Local aCidadesUF    := {}
	Local lCpoTES 	:= GFEA065INP()
	Local lInteg	:= .F.
	Local cCNPJCli := AllTrim(Posicione("GU3",1,XFILIAL("GU3")+GW3->GW3_CDDEST,"GU3_IDFED"))
	Local lISSxMun := SuperGetMV("MV_ISSXMUN",.F.,.F.)
	Local cTpImp   := Posicione("GVT", 1, xFilial("GVT") + GW3->GW3_CDESP, "GVT_TPIMP")
	Default cMsg 	:= ""

	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.
	Private aHeader := {}
	Private cOperPE := ""
	Private ctpNfMat	   := ""
	Private lTemF1GFE      := .F.

	If Empty(aForLoj[1])
		cMsg := "Fornecedor não cadastrado no Protheus."
		lErro := .T.
	EndIf

	cOpcInteg := GW3->GW3_ACINT

	If !lErro
		If Empty(aForLoj[2])
			aForLoj[2] := "01"
		EndIf

		cF1_DOC := SubStr(cF1_DOC,1,TamSx3("F1_DOC")[1])

		/* Array com dados da Cidade e UF da Origem e Destino dos TRECHOS - Ato Cotepe 48
		   aCidadesUF[1][1] - Cidade Origem do Transporte
		   aCidadesUF[1][2] - UF Origem do Transporte
		   aCidadesUF[1][3] - Cidade Destino do Transporte
		   aCidadesUF[1][4] - UF Destino do Transporte   */

		If GFXCP12131("GW3_MUNINI") .And. GFXCP12131("GW3_UFINI") .And. GFXCP12131("GW3_MUNFIM") .And. GFXCP12131("GW3_UFFIM") .And. ;
		   !(Empty(GW3->GW3_MUNINI) .And. Empty(GW3->GW3_UFINI) .And. Empty(GW3->GW3_MUNFIM) .And. Empty(GW3->GW3_UFFIM))   			   					   
		  
			aAdd(aCidadesUF, { Substr(GW3->GW3_MUNINI, 3,7), GW3->GW3_UFINI, Substr(GW3->GW3_MUNFIM, 3,7), GW3->GW3_UFFIM })
		Else			
			aCidades := (GFEWSCITY( GW3->GW3_FILIAL, GW3->GW3_EMISDF, GW3->GW3_CDESP, GW3->GW3_SERDF, GW3->GW3_NRDF, DTOS(GW3->GW3_DTEMIS), GW3->GW3_TPDF))
			aAdd(aCidadesUF,{Substr(aCidades[1][1], 3,7), Posicione("GU7", 1, xFilial("GU7") + aCidades[1][1], "GU7_CDUF"), Substr(aCidades[1][2], 3,7), Posicione("GU7", 1, xFilial("GU7") + aCidades[1][2], "GU7_CDUF") })
		EndIf

		//		BEGIN TRANSACTION
		If nInt == "2" .And. (Empty(cOpcInteg) .Or. cOpcInteg $ "2") //Recebimento/Pré-CT
		
			//Notas Fiscais do Conhecimento de Frete
			GetNotasFis(@aNotasFis,,aForLoj,cF1_DOC)

			//Parametros para geração do Conhecimento no MATA116
			ParamMt116 ( 2,@aDocFrete,aForLoj,cF1_DOC,aCidadesUF, cOpcInteg )
			
			If (cOpcInteg $ "2") .And. !Empty(GW3->GW3_CTE) 
                If GW3->GW3_TPCTE == "0" 
                    cTpCte = "N" 
                ElseIF GW3->GW3_TPCTE == "1" 
                    cTpCte = "C" 
                ElseIF GW3->GW3_TPCTE == "2" 
                    cTpCte = "A" 
                ElseIF GW3->GW3_TPCTE == "3" 
                    cTpCte = "S" 
                EndIf 
                
                aAdd(aDocFrete,{"F1_TPCTE" ,cTpCte ,nil}) //Tipo CTE 
            EndIf

			//Notas Fiscais do Conhecimento de Frete
			GetNotasFis(@aNotasFis,,aForLoj,cF1_DOC)

			//Geração do Conhecimento no MATA116
			If !Empty(aNotasFis)

				_oGFEXFBFL:NovoLogInP("MATA116") //Log de integração com ERP Protheus
				                    
				AddToLog("LOG DE INTEGRAÇÃO MATA116 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA116 - Iniciado em "###", as "
				AddToLog('Atualização' + CRLF + CRLF)
				AddToLog('Documento de Frete' + CRLF)

				If  ExistBlock("GFEA0654")
					aCustRec := ExecBlock("GFEA0654",.F.,.F., {aDocFrete, aNotasFis, cOperPE})
					aDocFrete := aCustRec[1][1]
					aNotasFis := aCustRec[1][2]
				EndIf
				
				For nX := 1 To Len(aDocFrete)
					AddToLog(aDocFrete[nx,1] + " - " + cValToChar(aDocFrete[nx,2]) + CRLF)						
				Next nX
				
				If !Empty(aNotasFis)
				
					AddToLog(CRLF + 'Itens' + CRLF)
					 
					For nX := 1 To Len(aNotasFis[1])
						AddToLog(aNotasFis[1,nX,1] + " - " + cValToChar(aNotasFis[1,nX,2]) + CRLF)
				    next nX
				EndIf
				
				If cOpcInteg != "4"
					MSExecAuto( { |x,y| MATA116(x,y) }, aDocFrete, aNotasFis )
				Else
					MSExecAuto( { |x,y| MATA116(x,y,,.T.) }, aDocFrete, aNotasFis )
				EndIf
				
				lInteg := .T.
			Else
				lErro := .T.
				cMsg := "Notas Fiscais não selecionadas."
			EndIf
		Else
			//Cabeçalho do Documento de Entrada
			Aadd(aDocFrete, {"F1_DOC"     , cF1_DOC                     , Nil } )
			Aadd(aDocFrete, {"F1_SERIE"   , GW3->GW3_SERDF              , Nil } )
			Aadd(aDocFrete, {"F1_FORNECE" , aForLoj[1]                  , Nil } )
			Aadd(aDocFrete, {"F1_LOJA"    , aForLoj[2]                  , Nil } )
			Aadd(aDocFrete, {"F1_EMISSAO" , GW3->GW3_DTEMIS             , Nil } )

			//Ponto de entrada da CROWN EMBALAGENS
			If  ExistBlock("GFEA0653")
				cCpdGFE :=  ExecBlock("GFEA0653",.F.,.F.,{3}) // Ponto de entrada para alterar a cond. de pagamento
			EndIf

			If Empty(cCpdGFE)
				If lCpoTES
					cCpdGFE := GW3->GW3_CPDGFE
				else
					cCpdGFE := SuperGetMv("MV_CPDGFE",,"1")
				Endif
			EndIf
			//Fim do Ponto de entrada da CROWN EMBALAGENS

			Aadd(aDocFrete, {"F1_COND"    , cCpdGFE                     , Nil } )
			
			Aadd(aDocFrete, {"F1_RECBMTO" , GW3->GW3_DTFIS              , Nil } )
			Aadd(aDocFrete, {"F1_CHVNFE"  , GW3->GW3_CTE                , Nil } )

			if cOpcInteg == "4" // Pré Ct-e
				Aadd(aDocFrete, {"F1_TIPO"    , "C"                     , Nil } )
			Else // Fiscal ou Pré Nota
				Aadd(aDocFrete, {"F1_TIPO"    , "N"                           , Nil } )
			Endif
			Aadd(aDocFrete, {"F1_FORMUL"  , "N"                         , Nil } )
			Aadd(aDocFrete, {"F1_ESPECIE" , GW3->GW3_CDESP              , Nil } )
			Aadd(aDocFrete, {"F1_ORIGEM"  , "GFEA065"                   , Nil } )    
			Aadd(aDocFrete, {"F1_VALPEDG" , GW3->GW3_PEDAG              , Nil } )
			    
			If !(cOpcInteg $ "3") .And. !Empty(GW3->GW3_CTE) 
				If GW3->GW3_TPCTE == "0"
					cTpCte = "N"
				ElseIF GW3->GW3_TPCTE == "1"
					cTpCte = "C"
				ElseIF GW3->GW3_TPCTE == "2"
					cTpCte = "A"
				ElseIF GW3->GW3_TPCTE == "3"
					cTpCte = "S"
				EndIf
				aAdd(aDocFrete,{"F1_TPCTE" ,cTpCte ,nil}) //Tipo CTE
			EndIf
		  	AAdd(aDocFrete, {"F1_TPFRETE" , "C"							 , Nil } ) //Tipo Frete integração realizada pelo MATA103/MATA140, enviar a informação como CIF

			// Validação abaixo apenas quando o Doc. Carga relacionado seja do Tipo Saída pois pode existir o cadastro de um fornecer como cliente.
			cAliasGW1 := GetNextAlias()
			BeginSql Alias cAliasGW1
				SELECT GW4.R_E_C_N_O_ RECNOGW3
				FROM %Table:GW4% GW4
				INNER JOIN %Table:GW1% GW1
				ON GW1_FILIAL = GW4_FILIAL
				AND GW1_EMISDC = GW4_EMISDC
				AND GW1_SERDC = GW4_SERDC
				AND GW1_NRDC = GW4_NRDC
				AND GW1_CDTPDC = GW4_TPDC
				AND GW1.%NotDel%
				INNER JOIN %Table:GV5% GV5
				ON GV5_FILIAL = %xFilial:GV5%
				AND GV5_CDTPDC = GW1_CDTPDC
				AND GV5_SENTID IN ('2')
				AND GV5.%NotDel%
				WHERE GW4.GW4_FILIAL = %Exp:GW3->GW3_FILIAL%
				AND GW4_EMISDF = %Exp:GW3->GW3_EMISDF%
				AND GW4_CDESP = %Exp:GW3->GW3_CDESP%
				AND GW4_SERDF = %Exp:GW3->GW3_SERDF%
				AND GW4_NRDF = %Exp:GW3->GW3_NRDF%
				AND GW4_DTEMIS = %Exp:GW3->GW3_DTEMIS%
				AND GW4.%NotDel%
			EndSql
			If (cAliasGW1)->(!Eof()) .And. Len(aCliLoj) > 0

				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT SA1.R_E_C_N_O_ RECNOSA1
					FROM %Table:SA1% SA1
					WHERE SA1.A1_FILIAL = %xFilial:SA1%
					AND SA1.A1_COD = %Exp:aCliLoj[1][1]%
					AND SA1.A1_LOJA = %Exp:aCliLoj[1][2]%
					AND SA1.A1_CGC = %Exp:cCNPJCli%
					AND SA1.%NotDel%
				EndSql
				If (cAliasQry)->(!Eof())
					AAdd(aDocFrete, {"F1_CLIDEST" , PADR(aCliLoj[1][1], TamSX3("F1_CLIDEST") [1]), Nil } )
					AAdd(aDocFrete, {"F1_LOJDEST" , PADR(aCliLoj[1][2], TamSX3("F1_LOJDEST") [1]), Nil } )
				EndIf
				(cAliasQry)->(dbCloseArea())

			EndIf
			(cAliasGW1)->(dbCloseArea())

			/* Origem x Destino do transporte - Ato Cotepe 48 */
			Aadd(aDocFrete, {"F1_EST"     , aCidadesUF[1][2]    , Nil } )
			Aadd(aDocFrete, {"F1_ESTDES"  , aCidadesUF[1][4]    , Nil } )				
			Aadd(aDocFrete, {"F1_MUORITR" , aCidadesUF[1][1]    , Nil } )
			Aadd(aDocFrete, {"F1_UFORITR" , aCidadesUF[1][2]    , Nil } )
			Aadd(aDocFrete, {"F1_MUDESTR" , aCidadesUF[1][3]    , Nil } )
			Aadd(aDocFrete, {"F1_UFDESTR" , aCidadesUF[1][4]    , Nil } )
			Aadd(aDocFrete, {"E2_NATUREZ" , cNtfGfe    			, Nil } )
			
			If lISSxMun .And. cTpImp == "2" //"2=ISS"
   				Aadd(aDocFrete, {"F1_INCISS" , aCidadesUF[1][1]    , Nil } )
			EndIf
			//Itens do Documento de Entrada
			GetItensDoc(@aItensDoc,aForLoj,cF1_DOC,3, cOpcInteg)

			//Utilizado para que não seja atribuida a filial do usuário logado
			// dentro do módulo de compras
			cFilAtu := cFilAnt
			cFilAnt := GW3->GW3_FILIAL
			If GFXCP12137('GW3_FILTOM') .AND. !Empty(GW3->GW3_FILTOM)
				cFilAnt := GW3->GW3_FILTOM
			Endif


			If  ExistBlock("GFEA0655")
				aCustFis := ExecBlock("GFEA0655",.F.,.F.,{aDocFrete, aItensDoc, cOperPE})
				aDocFrete := aCustFis[1][1]
				aItensDoc := aCustFis[1][2]
			EndIf
			
			If cOpcInteg $ "3"
				_oGFEXFBFL:NovoLogInP("MATA140") //Log de integração com ERP Protheus
				AddToLog("LOG DE INTEGRAÇÃO MATA140 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA140 - Iniciado em "###", as "
			Else
				_oGFEXFBFL:NovoLogInP("MATA103") //Log de integração com ERP Protheus
				AddToLog("LOG DE INTEGRAÇÃO MATA103 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA103 - Iniciado em "###", as "
			EndIf
			                    
			AddToLog('Atualização' + CRLF + CRLF)
			AddToLog('Documento de Entrada' + CRLF)

			For nX := 1 To Len(aDocFrete)
				AddToLog(aDocFrete[nx,1] + " - " + cValToChar(aDocFrete[nx,2]) + CRLF)						
			Next nX
			
			If !Empty(aItensDoc)
			
				AddToLog(CRLF + 'Itens' + CRLF)
				 
				For nX := 1 To Len(aItensDoc[1])
					AddToLog(aItensDoc[1,nX,1] + " - " + cValToChar(aItensDoc[1,nX,2]) + CRLF)
			    next nX
			EndIf

			If cOpcInteg $ "3"
				//Se for Pré Nota executar o MATA140
				MSExecAuto( { |x,y,z| MATA140(x,y,z) }, aDocFrete,aItensDoc,3 )
			Else
				//Inclusão do Documento de Entrada no MATA103
				MSExecAuto( { |x,y,z| MATA103(x,y,z) }, aDocFrete,aItensDoc,3 )
			EndIf
			
			lInteg := .T.
			
			cFilAnt := cFilAtu

		EndIf

		If lInteg
			If lMsErroAuto
				If !lTemF1GFE
					aErro := GetAutoGrLog()
					cMsg := ""
		
					For nX := 1 To Len(aErro)
						cMsg += aErro[nX] + CRLF
					Next nX
		
					lErro := .T.
					//				DisarmTransaction()
					
					AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
					AddToLog(cMsg + CRLF) 
				Else 
					AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
				EndIf 
			Else
				AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
			EndIf
			
			AddToLog("LOG DE INTEGRAÇÃO - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO - Finalizado em "###", as "
		EndIf
		//		END TRANSACTION
	EndIf

	If nInt == "1"
		cTipInt := "Fiscal"
	Else
		cTipInt := "Recebimento"
	EndIf

	If IsInCallStack("GFEA065")
		If lErro
			MsgInfo("Documento de Frete não enviada para atualização. Verificar motivo no campo 'Mot Rej "+SubStr(cTipInt,1,3)+"'.")
		Else
			MsgInfo("Documento de Frete atualizado no "+cTipInt+".")
		EndIf
	EndIf

Return !lErro

//-----------------------------------------------------
/*/	Desatualização do documento de frete no Protheus

@param nInt = "1"(Integração de Documentos de Frete como Documento de Entrada)
= "2"(Integração de Documentos de Frete como Nota de Conhecimento)

cMsg
@author Ana Claudia da Silva
@since 02/09/2015
@version 1.0
*/
//------------------------------------------------------

Function DesAtDcInt(nInt,cMsg)

	Local aDocFrete := {}
	Local aItensDoc := {}
	Local aNotasFis := {}
	Local lErro     := .F.
	Local lErroDc   := .F.
	Local aForLoj   := GFEA055GFL(GW3->GW3_EMISDF)
	Local cF1_DOC   := SubStr(GW3->GW3_NRDF,1,TamSx3("F1_DOC")[1])
	Local cTipInt   := ""
	Local aErro := {}
	Local nX := 0
	Local cCpdGFE := ""
	Local cOpcInteg := ""
	Local lCpoTES := GFEA065INP()
	Local aAreaSF1
	Local cTipo := ""
    Local aCidadesUF    := {}
    Local lInteg	:= .F.
	Local cFilAtu 	:= ""
	Default cMsg    := ""

	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	Private aHeader        := {}
	Private ctpNfMat	   := ""
	Private lTemF1GFE      := .F.

	If Empty(aForLoj[1])
		cMsg := "Fornecedor não cadastrado no Protheus."
		lErro := .T.
	EndIf

	If !lErro

		If Empty(aForLoj[2])
			aForLoj[2] := "01"
		EndIf

		aAreaSF1 := SF1->(GetArea())
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		If SF1->(dbSeek(xFilial("SF1") + cF1_DOC + PadR(GW3->GW3_SERDF, TamSX3("F1_SERIE")[1]) + aForLoj[1] + aForLoj[2]))
			If (nInt > '0') .And. !Empty(nInt)
				cOpcInteg := cValToChar(nInt)
				If cOpcInteg $ '3'
					If !Empty(SF1->F1_STATUS)
						cOpcInteg := '1' //Documento já classificado, enviar pelo MATA103
						cTipo := SF1->F1_TIPO
					EndIf
				EndIf
			EndIf
		Else
			//Documento não localizado para exclusão
			lErro := .T.
			lErroDc := .T.
			cMsg := "O documento de Frete não foi localizado no ERP para desatualização."
		EndIf
		RestArea(aAreaSF1)
		aSize(aAreaSF1,0)
	EndIf

	If !lErro
		/* Array com dados da Cidade e UF da Origem e Destino dos TRECHOS - Ato Cotepe 48
		   aCidadesUF[1][1] - Cidade Origem do Transporte
		   aCidadesUF[1][2] - UF Origem do Transporte
		   aCidadesUF[1][3] - Cidade Destino do Transporte
		   aCidadesUF[1][4] - UF Destino do Transporte   */		   
	If GFXCP12131("GW3_MUNINI") .And. GFXCP12131("GW3_UFINI") .And. GFXCP12131("GW3_MUNFIM") .And. GFXCP12131("GW3_UFFIM") .And. ;
	   !(Empty(GW3->GW3_MUNINI) .And. Empty(GW3->GW3_UFINI) .And. Empty(GW3->GW3_MUNFIM) .And. Empty(GW3->GW3_UFFIM))   			   					   
		  
		aAdd(aCidadesUF, { Substr(GW3->GW3_MUNINI, 3,7), GW3->GW3_UFINI, Substr(GW3->GW3_MUNFIM, 3,7), GW3->GW3_UFFIM })
	Else			
		aCidades := (GFEWSCITY( GW3->GW3_FILIAL, GW3->GW3_EMISDF, GW3->GW3_CDESP, GW3->GW3_SERDF, GW3->GW3_NRDF, DTOS(GW3->GW3_DTEMIS), GW3->GW3_TPDF))
		aAdd(aCidadesUF,{Substr(aCidades[1][1], 3,7), Posicione("GU7", 1, xFilial("GU7") + aCidades[1][1], "GU7_CDUF"), Substr(aCidades[1][2], 3,7), Posicione("GU7", 1, xFilial("GU7") + aCidades[1][2], "GU7_CDUF") })
	EndIf

		If nInt == "2" .And. (Empty(cOpcInteg) .Or. cOpcInteg $ "2;4") //Recebimento/Pré-ct
		
			//Notas Fiscais do Conhecimento de Frete
			GetNotasFis(@aNotasFis,,aForLoj,cF1_DOC)
		
			//Parametros para exclusão do Conhecimento no MATA116
			ParamMt116 ( 1,@aDocFrete,aForLoj,cF1_DOC,aCidadesUF )
			
			//Exclusão do Conhecimento no MATA116
			If !Empty(aNotasFis)
			
				_oGFEXFBFL:NovoLogInP("MATA116") //Log de integração com ERP Protheus
				                    
				AddToLog("LOG DE INTEGRAÇÃO MATA116 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA116 - Iniciado em "###", as "
				AddToLog('Desatualização' + CRLF + CRLF)
				AddToLog('Documento de Frete' + CRLF)

				For nX := 1 To Len(aDocFrete)
					AddToLog(aDocFrete[nx,1] + " - " + cValToChar(aDocFrete[nx,2]) + CRLF)						
				Next nX
				
				If !Empty(aNotasFis)
				
					AddToLog(CRLF + 'Itens' + CRLF)
					 
					For nX := 1 To Len(aNotasFis[1])
						AddToLog(aNotasFis[1,nX,1] + " - " + cValToChar(aNotasFis[1,nX,2]) + CRLF)
				    next nX
				EndIf
				
				If cOpcInteg != "4"
					MSExecAuto( { |x,y| MATA116(x,y) }, aDocFrete,aNotasFis )
				Else
					MSExecAuto( { |x,y| MATA116(x,y,,.T.) }, aDocFrete,aNotasFis )
				EndIf
				
				lInteg := .T.
			Else
				lErro := .T.
				cMsg := "Notas Fiscais não selecionadas."
			EndIf
		Else //Fiscal
			//Cabeçalho do Documento de Entrada
			Aadd(aDocFrete, {"F1_DOC"     , cF1_DOC                  , Nil } )
			Aadd(aDocFrete, {"F1_SERIE"  , PadR(GW3->GW3_SERDF, TamSX3("F1_SERIE")[1]), Nil } )
			Aadd(aDocFrete, {"F1_FORNECE" , aForLoj[1]               , Nil } )
			Aadd(aDocFrete, {"F1_LOJA"    , aForLoj[2]               , Nil } )
			Aadd(aDocFrete, {"F1_EMISSAO" , GW3->GW3_DTEMIS          , Nil } )
			//Ponto de entrada CROWN EMBALAGENS
			If  ExistBlock("GFEA0653")
				cCpdGFE :=  ExecBlock("GFEA0653",.F.,.F.,{5}) // Ponto de entrada para alterar a cond. de pagamento
			EndIf
			If Empty(cCpdGFE)
				If lCpoTES
					cCpdGFE := GW3->GW3_CPDGFE
				else
					cCpdGFE := SuperGetMv("MV_CPDGFE",,"1")
				Endif
			EndIf
			//Fim do Ponto de entrada da CROWN EMBALAGENS
			Aadd(aDocFrete, {"F1_COND"    , cCpdGFE                  , Nil } )
			Aadd(aDocFrete, {"F1_EST"     , Posicione("GU7",1,XFILIAL("GU7")+Posicione("GU3",1,xFilial("GU3")+GW3->GW3_EMISDF,"GU3_NRCID") ,"GU7_CDUF") } )
			Aadd(aDocFrete, {"F1_RECBMTO" , GW3->GW3_DTFIS           , Nil } )
			Aadd(aDocFrete, {"F1_CHVNFE"  , GW3->GW3_CTE             , Nil } )
			If !Empty(cTipo)
				Aadd(aDocFrete, {"F1_TIPO"    , cTipo           , Nil } )
			Else
				Aadd(aDocFrete, {"F1_TIPO"    , "N"                      , Nil } )
			EndIf
			Aadd(aDocFrete, {"F1_FORMUL"  , "N"                      , Nil } )
			Aadd(aDocFrete, {"F1_ESPECIE" , GW3->GW3_CDESP           , Nil } )
			Aadd(aDocFrete, {"F1_ORIGEM"  , "GFEA065"                , Nil } )
			AAdd(aDocFrete, {"F1_TPFRETE" , "C"						 , Nil } ) //Tipo Frete integração realizada pelo MATA103/MATA140, enviar a informação como CIF
			
			//Itens do Documento de Entrada
			GetItensDoc(@aItensDoc,aForLoj,cF1_DOC,5, cOpcInteg)
			
			//Utilizado para que não seja atribuida a filial do usuário logado
			// dentro do módulo de compras
			cFilAtu := cFilAnt
			cFilAnt := GW3->GW3_FILIAL
			If GFXCP12137('GW3_FILTOM') .AND. !Empty(GW3->GW3_FILTOM)
				cFilAnt := GW3->GW3_FILTOM
			Endif
			
			If cOpcInteg $ "3"	// Pré Nota
				_oGFEXFBFL:NovoLogInP("MATA140") //Log de integração com ERP Protheus
				AddToLog("LOG DE INTEGRAÇÃO MATA140 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA140 - Iniciado em "###", as "
			Else
				_oGFEXFBFL:NovoLogInP("MATA103") //Log de integração com ERP Protheus
				AddToLog("LOG DE INTEGRAÇÃO MATA103 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO MATA103 - Iniciado em "###", as "
			EndIf

			AddToLog('Desatualização' + CRLF + CRLF)
			AddToLog('Documento de Entrada' + CRLF)

			For nX := 1 To Len(aDocFrete)
				AddToLog(aDocFrete[nx,1] + " - " + cValToChar(aDocFrete[nx,2]) + CRLF)						
			Next nX
			
			If !Empty(aItensDoc)
			
				AddToLog(CRLF + 'Itens' + CRLF)
				 
				For nX := 1 To Len(aItensDoc[1])
					AddToLog(aItensDoc[1,nX,1] + " - " + cValToChar(aItensDoc[1,nX,2]) + CRLF)
			    next nX
			EndIf
			
			If cOpcInteg $ "3"	// Pré Nota
				//Exclusão do Documento de Entrada no MATA140
				MSExecAuto( { |x,y,z| MATA140(x,y,z) }, aDocFrete,aItensDoc,5 )
			Else // Documento Fiscal
				//Exclusão do Documento de Entrada no MATA103
				MSExecAuto( { |x,y,z| MATA103(x,y,z) }, aDocFrete,aItensDoc,5 )
			EndIf
			
			lInteg := .T.
			cFilAnt := cFilAtu

		EndIf

		If lInteg
			If lMsErroAuto
				IF lTemF1GFE
					aErro := GetAutoGrLog()
					cMsg := ""
					For nX := 1 To Len(aErro)
						cMsg += aErro[nX] + CRLF
					Next nX
					lErro := .T.
					//				DisarmTransaction()
					AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
					AddToLog(cMsg + CRLF) 
				Else
					AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
				EndIf
			Else
				AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
			EndIf
			
			AddToLog("LOG DE INTEGRAÇÃO - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO - Finalizado em "###", as "
		EndIf
		//		END TRANSACTION
	EndIf

	If nInt == "1"
		cTipInt := "Fiscal"
	Else
		cTipInt := "Recebimento"
	EndIf

	If IsInCallStack("GFEA065")
		If lErro
			If lErroDc
				MsgInfo(cMsg)
			Else
				MsgInfo("Documento de Frete não enviado para desatualização. Verificar motivo no campo 'Mot Rej "+SubStr(cTipInt,1,3)+"'.")
			EndIf
		Else
			MsgInfo("Documento de Frete desatualizado no "+cTipInt+".")
		EndIf
	EndIf

Return !lErro


//---------------------------------------------------
/* Retorna o Código correspondente no GFE
@author Felipe Machado de Oliveira
@version P11
@since 09/09/2013
@param cCod = Codigo ERP (cliente ou fornecedor)
		cLoja = Loja ERP (cliente ou fornecedor)
		nForCli = 1=Cliente 2=Fornecedor
		lFilial = Se .T. retorna o codigo da Filial
		cFilPar = Filial que deseja retornar o código (se lFilial == .T.)
/*/
//---------------------------------------------------
Function GFEXINTCOD(cCod,cLoja,nForCli,lFilial,cFilPar)
	Local lNumProp 	:= GFEXIEMITM()
	Local aRetFil   := {}
	Local cAliasGU3 := Nil
	Local cAliasGW0 := Nil
	Local cInSc     := ''
	Local cInSCAux  := ''
	Local cCodGFE   := ''
	Local cCgc      := ''
	Local cFilBkp   := cFilAnt
	Local nCont     := 0
	Local nFCont    := 0
	Local nPosIni   := 0
	Local nPosFim   := 0
	
	Default cCod    := ''
	Default cLoja   := ''
	Default nForCli := 0
	Default lFilial := .F.
	Default cFilPar := ''

	If !lFilial .And. lNumProp
		If nForCli == 1 // Cliente
			If Type("M->A1_CGC") != "U" .And. !Empty(M->A1_CGC)
				cCgc    := M->A1_CGC
			ElseIf !Empty(SA1->A1_CGC)
				cCgc    := SA1->A1_CGC
			EndIf
		ElseIf nForCli == 2 // Fornecedor
			If Type("M->A2_CGC") != "U" .And. !Empty(M->A2_CGC)
				cCgc    := M->A2_CGC
			ElseIf !Empty(SA2->A2_CGC)
				cCgc    := SA2->A2_CGC
			EndIf
		EndIf	
		/* Quando a filial é cadastrada pelo GFEA015 pela ação relacionada "Cadastrar Filial", 
		   pra não ficar um registro sem COD + LOJA no GFE, é retornado este cadastro para o primeiro 
		   Cliente ou Fornecedor cadastrado */
		If !Empty(cCgc)
			cCgc := PadR( cCgc,TamSx3("GU3_IDFED")[1] )
			cAliasGU3 := GetNextAlias()
			BeginSql Alias cAliasGU3
				SELECT GU3.GU3_CDEMIT
				FROM %Table:GU3% GU3
				WHERE GU3.GU3_FILIAL = %xFilial:GU3%
				AND GU3.GU3_IDFED = %Exp:cCgc%
				AND GU3.GU3_CDERP = ' '
				AND GU3.GU3_CDCERP = ' '
				AND GU3.GU3_ORIGEM = '2'
				AND GU3.GU3_EMFIL = '1'
				AND GU3.GU3_FORN = '2'
				AND GU3.GU3_CLIEN = '2'
				AND GU3.GU3_TRANSP = '2'
				AND GU3.GU3_AUTON = '2'
				AND GU3.%NotDel%
			EndSql
			If (cAliasGU3)->(!Eof())
				cCodGFE := (cAliasGU3)->GU3_CDEMIT
				lFilial := .T.
			EndIf
			(cAliasGU3)->(dbCloseArea())
		EndIf
	EndIf
	
	If lFilial
		If lNumProp
			cAliasGW0 := GetNextAlias()
			BeginSql Alias cAliasGW0
				SELECT GW0.GW0_CHAR01
				FROM %Table:GW0% GW0
				WHERE GW0.GW0_FILIAL = %Exp:Space(TamSx3("F2_FILIAL")[1])%
				AND GW0.GW0_TABELA = %Exp:PadR("FILIALEMIT",TamSx3("GW0_TABELA")[1])%
				AND GW0.GW0_CHAVE = %Exp:PadR(cFilPar,TamSx3("GW0_CHAVE")[1])%
				AND GW0.%NotDel%
			EndSql
			If (cAliasGW0)->(!Eof())
				cCodGFE := PadR( (cAliasGW0)->GW0_CHAR01,TamSx3("GW1_EMISDC")[1] )
			EndIf
			(cAliasGW0)->(dbCloseArea())
		EndIf
		
		If Empty(cCodGFE)
			aRetFil := FWLoadSM0()
			nFCont := Len(aRetFil)
			For nCont:= 1 to nFCont 
				if aRetFil[nCont][1] == cEmpAnt
					cFilAnt := AllTrim(aRetFil[nCont][2])
					If (FwGetTamFilial == 2 .And. Alltrim(cFilPar) == AllTrim(xFilial("SF2")) .And. ; 
						Alltrim(cEmpAnt) == AllTrim(aRetFil[nCont][1])) .Or. (FwGetTamFilial > 2 .And. ;
						Alltrim(cFilPar) == AllTrim(xFilial("SF2")))
						
						cCodGFE	 := aRetFil[nCont][18]
						cInSCAux := aRetFil[nCont][22] // Dentro deste campo tem a inscrição estadual, cnpj e UF.
						Exit
					EndIf
				EndIf
			next
			
			cFilAnt	:= cFilBkp
			
			If lNumProp
				If !Empty(cInScAux)
					nPosIni := At("_",cInscAux)
					nPosFim := RAt("_",cInscAux)
					If nPosIni > 0
						cInSc := IIf( nPosIni == nPosFim,Substr(cInscAux,nPosIni+1),Substr(cInscAux,nPosIni+1,nPosFim-(nPosIni+1)))
						If !Empty(cInSc)
							cAliasGU3 := GetNextAlias()
							BeginSql Alias cAliasGU3
								SELECT GU3.GU3_CDEMIT,
										GU3.GU3_IE
								FROM %Table:GU3% GU3
								WHERE GU3.GU3_FILIAL = %xFilial:GU3%
								AND GU3.GU3_IDFED = %Exp:PadR(cCodGFE,TamSx3("GU3_IDFED")[1])%
								AND GU3.GU3_IE = %Exp:cInSc%
								AND GU3.%NotDel%
							EndSql
							If (cAliasGU3)->(!Eof())
								cCodGFE := (cAliasGU3)->GU3_CDEMIT
							EndIf
							(cAliasGU3)->(dbCloseArea())
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf Empty(cCodGFE)
		cAliasGU3 := GetNextAlias()
		BeginSql Alias cAliasGU3
			SELECT GU3.GU3_CLIEN,
					GU3.GU3_FORN,
					GU3.GU3_CDEMIT
			FROM %Table:GU3% GU3
			WHERE GU3.GU3_FILIAL = %xFilial:GU3%
			AND GU3.GU3_CDERP = %Exp:cCod%
			AND GU3.GU3_CDCERP = %Exp:cLoja%
			AND GU3.%NotDel%
		EndSql
		Do While (cAliasGU3)->(!Eof())
			If nForCli == 1
				If (cAliasGU3)->GU3_CLIEN == "1"
					cCodGFE := (cAliasGU3)->GU3_CDEMIT
					Exit
				EndIf
			ElseIf nForCli == 2
				If (cAliasGU3)->GU3_FORN == "1"
					cCodGFE := (cAliasGU3)->GU3_CDEMIT
					Exit
				EndIf
			EndIf
			
			If Empty(cCodGFE)
				(cAliasGU3)->( dbSkip() )
			EndIF
		EndDo
		(cAliasGU3)->(dbCloseArea())
	EndIf
Return cCodGFE
//---------------------------------------------------
/*/{Protheus.doc} GFEXIEMITM
Função que verifica o controle do codigo de emitente  (GU3)
@author	Katia 
@version	1.0
@since		12/07/2017
@sample    Esta função tem por objetivo verificar a 
regra utilizada para o controle da Numeração do Codigo
do Emitente entre TMS x GFE (MV_EMITMP)
/*/
//----------------------------------------------------
Function GFEXIEMITM()

Return (SuperGetMv("MV_EMITMP",.F.,"1") == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1")

/*/{Protheus.doc} AddToLog
Registra o texto de log recebido na variável de log
Caso a variável exceda o limite estabelecido, o conteúdo é gravado em arquivo
@author silvana.torres
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cTexto, characters, descricao
@param nPosicao, numeric, descricao
@param lTime, logical, descricao
@type function
/*/
Static Function AddToLog(cTexto, nPosicao, lTime)
Default lTime	:= .T.
Default nPosicao := _LOG_END

	If !__lLogIntP
		Return
	EndIf
	
	_oGFEXFBFL:setPosicao(nPosicao)
	_oGFEXFBFL:setTime(lTime)
	_oGFEXFBFL:setSaveLog(__lLogIntP)
	_oGFEXFBFL:setTexto(cTexto)
Return NIL
//---------------------------------------------------
/*/{Protheus.doc} GFEXINPROP
Função que busca o código do proprietário do veículo
@author	SQUAD GFE
@version	1.0
@since		09/10/2019
@return cCodProp, Characters, código do proprietário
@param cFornec, characters, Código do fornecedor
@param cLojForn, characters, Loja do fornecedor
@type function
@sample    Esta função tem por objetivo buscar o código
 proprietário do véiculo
/*/
//----------------------------------------------------
FUNCTION GFEXINPROP(cFornec,cLojForn)
Local aAreaAnt := GetArea()
Local cCodProp  := ""
Local cAliasQry := Nil
	If !Empty(cFornec+cLojForn)
		If 	GFEXIEMITM()
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT GU3.GU3_CDEMIT
				FROM %Table:GU3% GU3
				WHERE GU3.GU3_FILIAL = %xFilial:GU3%
				AND GU3.GU3_CDERP = %Exp:cFornec%
				AND GU3.GU3_CDCERP = %Exp:cLojForn%
				AND GU3.GU3_SIT = '1'
				AND (GU3.GU3_AUTON = '1' OR GU3.GU3_TRANSP = '1')
				AND GU3.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				cCodProp := (cAliasQry)->GU3_CDEMIT
			EndIf
			(cAliasQry)->(dbCloseArea())
		Else
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT SA2.A2_CGC
				FROM %Table:SA2% SA2
				WHERE SA2.A2_FILIAL = %xFilial:SA2%
				AND SA2.A2_COD = %Exp:cFornec%
				AND SA2.A2_LOJA = %Exp:cLojForn%
				AND SA2.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				cCodProp := (cAliasQry)->A2_CGC
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return cCodProp
