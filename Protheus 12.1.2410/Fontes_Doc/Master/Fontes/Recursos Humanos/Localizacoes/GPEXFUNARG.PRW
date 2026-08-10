#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEXFUNARG.CH"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.		    	       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³   Data   ³     FNC   ³  Motivo da Alteracao 	    		   	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Glaucia M.  |19/11/2011³ARG11.6-RH ³gatilho para atualizacao de RA_SALARIO, etc.³±±
±±³Silvia Tag. |06/12/2011³ARG11.6-RH ³Funcao para geracao dos dias de ferias      ³±±
±±³Marcelo F.  |24/01/2012³ARG11.6-RH ³Atualizacao para Funcao de geracao dos dias ³±±
±±³            |          ³           ³dias de ferias para inclusao de funcionario.³±±
±±³Glaucia M.  |13/02/2012³ARG11.6-RH ³Validacao ChkDtRec, campo RA_DTREC		   ³±±
±±³Glaucia M.  |15/02/2012³ARG11.6-RH ³Criacao de Consulta Especifica para os	   ³±±
±±³			   |		  ³REQ006	  ³campos: RA_ATIV, RA_COND e RA_MODALID       ³±±
±±³			   |		  ³			  ³Funcoes:fS10ARG, fS10Pesq e fS10Ordem       ³±±
±±³Glaucia M.  |22/02/2012³ARG11.6-RH ³Validacao fAliquARG para os	campos:        ³±±
±±³			   |		  ³REQ006	  ³RA_ATIV, RA_COND e RA_MODALID       		   ³±±
±±³Glaucia M.  |22/01/2013³000689/2013³fDiasFerArg: Tratamento para considerar     ³±±
±±³			   |		  ³     TGJMGL³RA_DTREC (se vazio RA_ADMISSA), no calculo  ³±±
±±³			   |		  ³     	  ³de dias de direito de ferias.               ³±±
±±³			   |		  ³     	  ³Criacao rotina fAnosRec, para substituir o  ³±±
±±³			   |		  ³     	  ³uso de fCalAntig.                           ³±±
±±³Glaucia M.  |07/02/2013³001501/2013³fDiasFerArg: Tratamento para considerar     ³±±
±±³			   |		  ³     TGMQ59³somente de calculo de dias proporcionais    ³±±
±±³			   |		  ³     	  ³baseado RA_DTREC (se vazio RA_ADMISSA), qdo ³±±
±±³			   |		  ³     	  ³esta rotina for chamada via GPEM042.        ³±±
±±³M. Silveira |26/12/2013³THYVGM     ³Ajuste na fAliquARG para verificar se campos³±±
±±³			   |		  ³TIEBGY  	  ³usados na query estao preenchidos.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SalarioAntig	³ Autor ³ 				           ³ Data ³ 19/11/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gatilho para alterar Salario do funcionário, conforme preenchimento  ³±±
±±³			 ³RA_ORISDO, RA_ADMISSA, RA_CODCONV, RA_FUNCAO, RA_DTREC			   ³±±
±±³			 ³RA_ORISDO = 1- Nao ha alteracao em RA_SALARIO			               ³±±
±±³			 ³RA_ORISDO = 2- RA_SALARIO igual a RJ_SALARIO						   ³±±
±±³			 ³RA_ORISDO = 3- Calcula Antiguidade e busca na tabela S027 o salario e³±±
±±³			 ³				altera RA_SALARIO	  								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA010 					                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SalarioAntig()     

Local aArea		:= GetArea()
Local cOrisdo 	:= alltrim(M->RA_ORISDO)
Local cFuncao	:= alltrim(M->RA_CODFUNC)
Local cConvenio	:= alltrim(M->RA_CODCONV)
Local nReturn	:= M->RA_SALARIO
Local dReconhec 
Local nAntig	
Local cFiltro, cFilRCC
Local cMsg:=""   
Local cTamConv	
Local cTamFuncao

If !(cOrisdo $ ('1')) .and. !EMPTY(cFuncao)
	
	if cOrisdo $ ('2')
		dbSelectArea("SRJ")
		dbSetOrder(1) 
		dbSeek( xFilial("SRJ") + cFuncao )
		If !eof("SRJ") 
		    If !empty(SRJ->RJ_SALARIO) 
		    	nReturn:=SRJ->RJ_SALARIO  
		    	
			Else
				cMsg	:=Oemtoansi(STR0001)+CRLF 						//"La funcion asociada al empleado está con sueldo VACIO, por favor averiguar. "
				cMsg	:=+cMsg+Oemtoansi(STR0002)						//El Sueldo no será cambiado."
				alert(cMsg)  
			Endif		
		Else 
			cMsg	:= OemtoAnsi(STR0007)+CRLF 							//"A função associada ao empregado não existe, por favor averiguar."
			cMsg	:= cMsg + OemtoAnsi(STR0002)            			//"El Sueldo no será cambiado." 
			Alert(cMsg) 
		EndIf
	ElseIf cOrisdo $ ('3') 
		If empty(cConvenio)
			cMsg	:=Oemtoansi(STR0003)+CRLF    						//"El campo Convenio asociado al empleado está VACIO."
			cMsg	:=+cMsg+Oemtoansi(STR0002)        					//"El Sueldo no será cambiado." 
			alert(cMsg)
		ElseIf empty(M->RA_ADMISSA) .AND. empty(M->RA_DTREC)
			cMsg	:=Oemtoansi(STR0004)+CRLF   						//"Fecha Ingreso o Fecha Reconocimiento deberán ser llenados obligatoriamente. "
			cMsg	:=+cMsg+Oemtoansi(STR0002)			         		//"El Sueldo no será cambiado."
			Alert(cMsg)  
		Else
			dReconhec := IIF (!EMPTY(M->RA_DTREC),M->RA_DTREC, M->RA_ADMISSA)
			nAntig	:= (ddatabase - dReconhec)/365
		
	    	cTamConv	:= GetSx3Cache("RA_CODCONV", "X3_TAMANHO")
	    	cTamFuncao	:= GetSx3Cache("RA_CODFUNC", "X3_TAMANHO")
	    	
	    	If (cTamConv > 3) .or. (cTamFuncao >5)
	    		alert(OemtoAnsi(STR0005)) 								//"Tamanho do campo RA_CODCONV ou RA_CODFUNC, não estão compatíveis com a especificao da tabela S027. Entre em contato com Administrador de dados."                                                                                                                                                                                                                                                                                                                                                                   
	    	Else
		       	
		       	cConvenio	:= IIf (len(cConvenio)<3, cConvenio+space(cTamConv-(len(cConvenio))), cConvenio)	
 	      		cFuncao		:= IIf (len(cFuncao)<3, cFuncao+space(cTamFuncao-(len(cFuncao))), cFuncao) 
		   	    	
		    	cFiltro:=cConvenio+cFuncao
		    	cFilRCC:=xFilial("RCC")
		    	DbSelectArea("RCC")
				DbSetOrder(1)      
				DbSeek(xFilial()+"S027")
				Do While cFilRCC == RCC_FILIAL .and. RCC_CODIGO == "S027"    
					If (SubStr(RCC_CONTEU,1,8) == cFiltro ) 
						cAnosDe		:= VAL(AllTrim(SubStr(RCC_CONTEU,9,5)))
						cAnosAte	:= VAL(AllTrim(SubStr(RCC_CONTEU,14,5)))
						If (nAntig >= cAnosDe) .and. (nAntig <= cAnosAte)
							nReturn := VAL(AllTrim(SubStr(RCC_CONTEU,19,12)))	
						Endif
					EndIf
					DbSkip()	
				EndDo    
            EndIf
		EndIf	
	     
	Endif
	
ElseIF cOrisdo $ ('2/3') .AND. EMPTY(cFuncao)
	cMsg	:= OemtoAnsi(STR0006)+CRLF 							//"El empleado no posee función asociada. Por favor llenar el campo función."
	cMsg	:= cMsg + OemtoAnsi(STR0002)            			//"El Sueldo no será cambiado." 
	Alert(cMsg) 
EndIf

RestArea(aArea)

Return (nReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fDiasFerArg   ³ Autor ³  Equipe RH	           ³ Data ³ 06/12/12   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a quantidade de dias de ferias, que o funcionário tem direito³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpL1 - Se será considerado Ano Civil.						       ³±±
±±³			 ³ExpD2 - Data de Inicial para verificacao dos Dias de Direito. 	   ³±±
±±³			 ³ExpD3 - Data de Final para verificacao dos Dias de Direito.   	   ³±±
±±³			 ³ExpN4 - Dias de Direito do periodo, indicado entre ExpD2 e ExpD3.    ³±±
±±³			 ³ExpN5 - Dias de Proporcionais Ferias.                                ³±±
±±³			 ³ExpL6 - Se é apenas calculo de dias proporcionais para rescisao.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Pre-Requi.³Tabela S011 - prenchida. RA_CODCONV preenchido. Tabela RGM preenchida³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Numero total de dias ferias do funcionario.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA010 - GPEM120 - GPEM031 - GPEM042                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function fDiasFerArg(lAnoCivil,dDtIni,dDtFim,nDias, nDiasProp, lRescisao, dFchReingr)

Local nAfastFunc	:= 0
Local nAnos			:= 0
Local aAfast		:= {}
Local lRet			:= .F.
Local cCodTab       := ""
Local dDataRec		:= IIf (!Empty(SRA->RA_DTREC), SRA->RA_DTREC, SRA->RA_ADMISSA)
Local dFchIngres	:= SRA->RA_ADMISSA
Local nHabilFunc	:= 0

DEFAULT nDias 		:= 0
DEFAULT nDiasProp	:= 0 
DEFAULT lRescisao	:= .F.
DEFAULT dFchReingr	:= CToD("  /  /    ")

If !Empty(dFchReingr)
	dDataRec	:= dFchReingr
	dFchIngres	:= dFchReingr
EndIf

If Year(dDataRec) == Year(dDtFim)   
   nAnos   := 1
Else
   nAnos	:= fAnosRec(dDataRec, dDtFim)
Endif           

// Obtem dias de falta
fBuscaACM(FGETCODFOL("0054"),,dDtIni,dDtFim,"H",,@nAfastFunc)
nAfastFunc *= -1
// Obtem dias de afastamento
fRetAfas(dDtIni,dDtFim,"F",,,,@aAfast)
aEval(aAfast,{ |X| nAfastFunc += If(X[7]="2",X[2],0) })

If !Empty(SRA->RA_CODCONV) .And. ;
	fPosReg("RGM",1,xFilial("RGM")+SRA->RA_CODCONV) .And. ;
	!Empty(RGM->RGM_TABFER)
	cCodTab := RGM->RGM_TABFER
Endif

If !Empty(cCodTab) 
	nPosTab := fPosTab("S011",cCodTab,"=",4,nAnos,"<=",6)
	nDias := If(nPosTab>0,FTABELA("S011",nPosTab,7),0)
				
	If !lRescisao .And. Year(dDataRec) == Year(dDtFim)  
		//Verifica se o empregado foi admitido antes de 01/07,
		//caso sim os dias de direito passam a ser integral
		If Month(dFchIngres) <= 6 
		    nDiasProp    := nDias
		Else //Cálculo de días proporcionales
			nHabilFunc	:= CalcDiaHab(dFchIngres, dDtFim)
			nDiasProp	:= Round(nHabilFunc/20, 0)
			nDias		:= nDiasProp
		EndIf
	Else    
		
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula dias de ferias proporcionais.                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		nDiasTot	:= Min(dDtFim - dDtIni + 1, 365)
		nDiasProp	:= nDias/365 * nDiasTot
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ChkDtRec	³ Autor ³ Equipe RH             ³ Data ³ 13.02.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica Data Reconhecimento / Data Nascimento			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION ChkDtRec(dDtNas,dDtRec)
Local cAlias := Alias()

If dDtNas >= dDtRec 
	Help(" ",1,"HELP",OemtoAnsi(STR0009),OemtoAnsi(STR0008),1,0)			//"Data Inválida"	## "A data de reconhecimento não poderá ser menor, que a data de nascimento."
	dbSelectArea( cAlias )
	Return (.F.)
Endif

dbSelectArea( cAlias )

Return (.T.)

/*/{Protheus.doc} fS10ARG
Consulta padrao para os campos RA_ATIV, RA_COND, RA_MODALID
@author  Equipe RH
@since   15/02/2012
@param cCampo, caractere, "1" - O retorno da consulta padrão campo RA_ATIV, "2" - campo RA_COND e "3" - campo RA_MODALID 
/*/
Function fS10ARG(cCampo)
Local aArea			:= GetArea()
Local oDlgSXB		:= Nil   
Local oListBox		:= Nil
Local aAliquotas	:= {} 
Local lRet			:= .F.
Local oCmbOrdem		:= Nil
Local aOrdem		:= {OemtoAnsi(STR0010),OemtoAnsi(STR0011)} 						//"Código"###"Descrição"
Local nOrdem		:= 1  
Local cPesq			:= Space(40)
Local bPesq			:= {||fS10Pesq(@oCmbOrdem,@aAliquotas,@oListBox,cPesq)}
Local lMultGroup 	:= .F.
Local cQuery		:= ""
Local cGrupos		:= ""
Local bOk			:= ""   
Local cTitulo		:= ""

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Local lIsDBOracl	:= AllTrim(Upper(TCGetDB())) == "ORACLE"  //.T. = Oracle ó .F. = Otros manejadores
Local cExpSubstr	:= "SUBSTR"

aAdvSize	:= MsAdvSize(.T.,.T.,380)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 030 , .T. , .F.  } )  			//1- Cabecalho
aAdd( aObjCoords , { 000 , 000 , .T. , .T. , .T.  } )		//2- ListBox
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

//Divisao em 2 Linhas o cabecalho
aAdv1Size		:= aClone(aObjSize[1])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//LINHA1
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//LINHA2
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords)//,,.T. )   

//Divisao em colunas LINHA1 em duas colunas
aAdv2Size		:= aClone(aObj1Size[1])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 1 , 1 }
aAdd( aObj2Coords , { 260, 000 , .F. , .T. } )				//1-Coluna1
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )			//3-Coluna2
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )

If !lIsDBOracl //Si el manejador de BD no es Oracle
	cExpSubstr := "SUBSTRING"
EndIf

If cCampo =="1" 
	cQuery := "	SELECT DISTINCT(" + cExpSubstr + "(RCC_CONTEU,1,3)) CODIGO, " + cExpSubstr + "(RCC_CONTEU,4,6) FECHADE, "
	cQuery += " " + cExpSubstr + "(RCC_CONTEU,10,6) FECHAHASTA, " + cExpSubstr + "(RCC_CONTEU,16,45) DESCRICAO "
	cQuery += "	FROM " + RetSQLName("RCC") + " RCC "
	cQuery += "	WHERE RCC.RCC_FILIAL  = '"  + xFilial("RCC") + "' AND "		
	cQuery += "		RCC.D_E_L_E_T_ = ' ' AND "
	cQuery += "		RCC_CODIGO IN ('S005') AND "
	cQuery += "		" + cExpSubstr + "(RCC_CONTEU,1,3) " 
	cQuery += " 	IN ( "
	cQuery += "		SELECT DISTINCT(" + cExpSubstr + "(RCC_CONTEU,1,3)) "
	cQuery += "		FROM " + RetSQLName("RCC") + " RCC1 "
	cQuery += "			WHERE RCC_CODIGO IN ('S010') AND "
	cQuery += "			RCC1.D_E_L_E_T_ = ' ' )"  
	bOk		:= {||	M->RA_ATIV := aAliquotas[oListBox:nAt][1], oDlgSXB:End(),lRet := .T.  }
	cTitulo := OemToAnsi(STR0016)																		//"Código de Atividades (S005)"

ElseIf cCampo =="2"	
	If(empty(M->RA_ATIV) .OR. TYPE("M->RA_ATIV")<>"C")
		cMsg	:= OemToAnsi(STR0012)+CRLF																//"O campo Código de Atividade está vazio."                                                                                                                                                                                                                                                                                                                                                                                                                                                                           "O campo Código de Atividade está vazio."+CRLF 	 			//"O campo Código de Atividade está vazio."
		cMsg	:=+cMsg+OemtoAnsi(STR0013)										 						//"E não será possível preencher este campo."
		MsgAlert(cMsg)  
		Return(.F.)
	Else
		cQuery := " SELECT DISTINCT(" + cExpSubstr + "(RCC_CONTEU,1,2)) CODIGO, " + cExpSubstr + "(RCC_CONTEU,3,6) FECHADE, "
		cQuery += " "+ cExpSubstr + "(RCC_CONTEU,9,6) FECHAHASTA, " + cExpSubstr + "(RCC_CONTEU,15,45) DESCRICAO " 
		cQuery += "	FROM " + RetSQLName("RCC") + " RCC "
		cQuery += "	WHERE RCC.RCC_FILIAL  = '"  + xFilial("RCC") + "' AND "		
		cQuery += "		RCC.D_E_L_E_T_ = ' ' AND "
		cQuery += "		RCC_CODIGO IN ('S006')  AND "
		cQuery += " 	" + cExpSubstr + "(RCC_CONTEU,1,2) "
		cQuery += " 	IN ( "
		cQuery += " 		SELECT DISTINCT(" + cExpSubstr + "(RCC_CONTEU,4,2)) "
		cQuery += "			FROM " + RetSQLName("RCC") + " RCC1 "
		cQuery += " 				WHERE RCC_CODIGO IN ('S010')  AND " + cExpSubstr + "(RCC_CONTEU,1,3) = '" + M->RA_ATIV + "' AND "
		cQuery += " 				RCC1.D_E_L_E_T_ = ' ' ) "
		bOk		:= {||	M->RA_COND := aAliquotas[oListBox:nAt][1], oDlgSXB:End(),lRet := .T.  }
		cTitulo := OemToAnsi(STR0017)																	//"Condição de Contratação (S006)"
	 Endif
	 	
ElseIf cCampo =="3"

	If(empty(M->RA_ATIV) .OR. TYPE("M->RA_ATIV")<>"C") .OR.   (empty(M->RA_COND) .OR. TYPE("M->RA_COND")<>"C")
		cMsg	:=OemToAnsi(STR0014)+CRLF 	 															//"O campo Código de Atividade ou Código de Condição estão vazios."
		cMsg	:=+cMsg+OemtoAnsi(STR0013)							 									//"E não será possível preencher este campo."
		MsgAlert(cMsg)
		Return(.F.)
	Else                 
		cQuery := " SELECT DISTINCT(" + cExpSubstr + "(RCC_CONTEU,1,3)) CODIGO, " + cExpSubstr + "(RCC_CONTEU,4,6) FECHADE, "
		cQuery += " " + cExpSubstr + "(RCC_CONTEU,10,6) FECHAHASTA, " + cExpSubstr + "(RCC_CONTEU,16,48) DESCRICAO "
		cQuery += "	FROM " + RetSQLName("RCC") + " RCC "
		cQuery += "	WHERE RCC.RCC_FILIAL  = '"  + xFilial("RCC") + "' AND "		
		cQuery += "		RCC.D_E_L_E_T_ = ' ' AND "
		cQuery += "		RCC_CODIGO IN ('S008') AND "  
		cQuery += " 	" + cExpSubstr + "(RCC_CONTEU,1,3) "
		cQuery += " 	IN ( "
		cQuery += " 		SELECT DISTINCT(" + cExpSubstr + "(RCC_CONTEU,6,3)) "
		cQuery += "			FROM " + RetSQLName("RCC") + " RCC1 "
		cQuery += " 				WHERE RCC_CODIGO IN ('S010')  AND " + cExpSubstr + "(RCC_CONTEU,1,3) = '" + M->RA_ATIV + "' AND "
		cQuery += "					" + cExpSubstr + "(RCC_CONTEU,4,2) = '" + M->RA_COND + "' AND "
		cQuery += " 				RCC1.D_E_L_E_T_ = ' ' ) "
		bOk		:= {||	M->RA_MODALID := aAliquotas[oListBox:nAt][1], oDlgSXB:End(),lRet := .T.  }
		cTitulo := OemToAnsi(STR0018)																	//"Modalidade de Contratação (S008)"
	Endif
Else
    cMsg	:=OemToAnsi(STR0020)+CRLF 																		//"A consulta padrão deste campo, está com parâmetros inexistentes." 
    cMsg	:=+cMsg+OemtoAnsi(STR0021)																		//"Procure o Administrador do Sistema." 
    MsgAlert(cMsg)
    Return()
Endif	
			
	cQuery := ChangeQuery(cQuery)
	If Select("RCCQRY") <> 0
		DbSelectArea("RCCQRY")
		DbCloseArea()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"RCCQRY",.F.,.T.)		
	
	While RCCQRY->(!Eof()) 
		If AScan(aAliquotas,{|x| x[1] == RCCQRY->CODIGO }) <= 0
			Aadd(aAliquotas,{	RCCQRY->CODIGO,  RCCQRY->FECHADE, RCCQRY->FECHAHASTA,RCCQRY->DESCRICAO })
  		EndIf
		RCCQRY->(dbSkip())
	EndDo

If Len(aAliquotas) <= 0  
	cMsg	:=OemToAnsi(STR0015)+CRLF 	 															//"Não existem Aliquotas Gerais (S010), que atendam a condição:"			
	cMsg	:=+cMsg+OemToAnsi(STR0016)+" x "+OemToAnsi(STR0017)+" x "+ OemToAnsi(STR0018)+"."			//"Código de Atividades (S005)" ### "Condição (S006)" ### "Modalidade (S008)"	
	MsgAlert(cMsg)  
	Return(.F.)   
EndIf

//Tela de consulta
oDlgSXB := TDialog():New(aAdvSize[7],0,aAdvSize[6],aAdvSize[5],cTitulo,,,,,,,,oMainWnd,.T.) 
	
@ aObj1Size[1,1], aObj1Size[1,2] MSCOMBOBOX oCmbOrdem VAR nOrdem  ITEMS aOrdem SIZE 250,010 OF oDlgSXB ON CHANGE fS10Ordem(oCmbOrdem,@aAliquotas,@oListBox) PIXEL
@ aObj2Size[2,1], aObj2Size[2,2] BUTTON OemToAnsi(STR0019) SIZE 041, 011 OF oDlgSXB PIXEL Action Eval(bPesq)  			//"Buscar"
@ aObj1Size[2,1], aObj1Size[2,2] MSGET cPesq SIZE 250, 010 OF oDlgSXB PIXEL Valid (Eval(bPesq))
	
oListBox := TWBrowse():New(aObjSize[2,1], aObjSize[2,2] ,aObjSize[2,3], aObjSize[2,4],,{UPPER(OemToAnsi(STR0010)),UPPER(OemToAnsi(STR0022)),UPPER(OemToAnsi(STR0023)),UPPER(OemToAnsi(STR0011))},,oDlgSXB,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"CODIGO"###"DATA DE"###"DATA ATE"###"DESCRICAO"
oListBox:bLDblClick := bOk
		
fS10Ordem(@oCmbOrdem,@aAliquotas,@oListBox)		
		
oDlgSXB:bInit := {|| EnchoiceBar(oDlgSXB, bOK, {||oDlgSXB:End()},,)}
oDlgSXB:lCentered := .T.
oDlgSXB:Activate(,,,.T.)

If lRet .AND. (INCLUI .OR. ALTERA)
	VAR_IXB := ""
	if cCampo=="1"
		VAR_IXB := M->RA_ATIV
	ElseIf cCampo=="2"
		VAR_IXB := M->RA_COND	
	ElseIf cCampo=="3"
		VAR_IXB := M->RA_MODALID	
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fS10Pesq		³ Autor ³  Equipe RH	           ³ Data ³ 15/02/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza a pesquisa na listagem de Atividades, Condicao ou Modalidade ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Parametro ³ExpO1 - Objeto do combo de ordenacao  							   ³±±
±±³			 ³ExpA2 - Array de aliquotas S010  									   ³±±
±±³			 ³ExpO3 - Objeto da listbox		  									   ³±±
±±³			 ³ExpC4 - Texto para pesquisa										   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEXFUNARG - fS10ARG 		                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fS10Pesq(oCmbOrdem,aAliquotas,oListBox,cPesq)

Local nPos		:= 0 
Local nOrdem	:= oCmbOrdem:nAt
Local nSize		:= 0

cPesq := AllTrim(Upper(cPesq))
nSize := Len(cPesq)

If nOrdem == 1		//Por codigo
	nPos := aScan(aAliquotas,{|x| Left(AllTrim(Upper(x[1])),nSize) == cPesq })
ElseIf nOrdem == 2	//Por Descricao
	nPos := aScan(aAliquotas,{|x| Left(AllTrim(Upper(x[4])),nSize) == cPesq })
EndIf

If nPos > 0
	oListBox:nAt := nPos
	oListBox:Refresh()
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fS10Ordem		³ Autor ³  Equipe RH	           ³ Data ³ 15/02/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza a pesquisa na listagem de Atividades, Condicao ou Modalidade ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Parametro ³ExpO1 - Objeto do combo de ordenacao 							       ³±±
±±³			 ³ExpA2 - Array de aliquotas S010			   						   ³±±
±±³			 ³ExpO3 - Objeto da listbox		  									   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEXFUNARG - fS10ARG 		                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fS10Ordem(oCmbOrdem,aAliquotas,oListBox)

Local nOrdem := oCmbOrdem:nAt

If nOrdem == 1 
	//Ordena pelo codigo
	ASort(aAliquotas,,,{|x,y| x[1] < y[1] })
ElseIf nOrdem == 2
	//Ordena por Descrição
	ASort(aAliquotas,,,{|x,y| x[4] < y[4] })
EndIf

oListBox:SetArray(aAliquotas)
oListBox:bLine := {||{	aAliquotas[oListBox:nAt][1],;
						aAliquotas[oListBox:nAt][2],; 
						aAliquotas[oListBox:nAt][3],;
						aAliquotas[oListBox:nAt][4]}} 
oListBox:GoTop()
oListBox:Refresh()

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fAliquARG		³ Autor ³  Equipe RH	           ³ Data ³ 22/02/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza validacao do cadastro de funcionario, onde a combinacao dos  ³±±
±±³			 ³campos RA_ATIV, RA_COND e RA_MODALID devem existir na tabela S010.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Pre-Requis³E obrigatorio que a tabelas S010 exista					 		   ³±±
±±³			 ³E estejam conforme layout definido na especificação deste Requisito  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpC1 - "1" - O retorno da validacao campo RA_ATIV			   	   ³±±
±±³			 ³		- "2" - O retorno da validacao campo RA_COND			  	   ³±±
±±³			 ³		- "3" - O retorno da validacao campo RA_MODALID		   		   ³±±
±±³			 ³		- "4" - O retorno da validacao no momento confirma GPEA010	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA010  			 		                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fAliquARG(cCampo)

Local lRet 	:= .F.
Local cMsg	:=""  
Local cQuery:=""
Local lTab	:= .T.
Local lAtivi
Local lCondi
Local lModal
Local lIsDBOracl := AllTrim(Upper(TCGetDB())) == "ORACLE"  //.T. = Oracle ó .F. = Otros manejadores
Local cExpSubstr := "SUBSTR"

lAtivi := ( Type("M->RA_ATIV")<>"C" .Or. Empty(M->RA_ATIV) )
lCondi := ( Type("M->RA_COND")<>"C" .Or. Empty(M->RA_COND) )
lModal := ( Type("M->RA_MODALID")<>"C" .Or. Empty(M->RA_MODALID) )

If !lIsDBOracl //Si el manejador de BD no es Oracle
	cExpSubstr := "SUBSTRING"
EndIf

//Valida adequadamente cada campo para impedir erro na execucao da query   
If lAtivi 
	lTab := .F.
ElseIf cCampo == "4" .And. ( lAtivi .Or. lCondi .Or. lModal )
	lTab := .F.
ElseIf cCampo == "2" .And. lCondi
	lTab := .F.
ElseIf cCampo $ "34" .And. ( lCondi .Or. lModal )
	lTab := .F.
EndIf

If !lTab
	cMsg	:=OemToAnsi(STR0024)+CRLF 	//"Campos: Atividade, Condição e Modalidade são obrigatórios."
	cMsg	:=+cMsg+OemtoAnsi(STR0025)	//"Por favor averiguar."
	MsgAlert(cMsg)  
	Return(lRet)
Endif

cQuery := " SELECT COUNT(RCC_CODIGO) TOTALS10 "
cQuery += "	FROM " + RetSQLName("RCC") + " RCC "
cQuery += "	WHERE RCC.RCC_FILIAL  = '"  + xFilial("RCC") + "' AND "		
cQuery += "		RCC.D_E_L_E_T_ = ' ' AND "
cQuery += "		RCC_CODIGO IN ('S010') AND "
cQuery += " 	" + cExpSubstr + "(RCC_CONTEU,1,3) = '" + M->RA_ATIV + "' "

If cCampo $ "2" .and. !empty(M->RA_COND)
	cQuery += "		AND " + cExpSubstr + "(RCC_CONTEU,4,2) = '" + M->RA_COND + "' "
ElseiF cCampo $ ("34") .and. !empty(M->RA_COND).and. !empty(M->RA_MODALID)
	cQuery += "		AND " + cExpSubstr + "(RCC_CONTEU,4,2) = '" + M->RA_COND + "' "
	cQuery += "		AND " + cExpSubstr + "(RCC_CONTEU,6,3) = '" + M->RA_MODALID + "' " 	
Endif
			
	cQuery := ChangeQuery(cQuery)
	If Select("RCCQRY2") <> 0
		DbSelectArea("RCCQRY2")
		DbCloseArea()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"RCCQRY2",.F.,.T.)		
	
	If RCCQRY2->TOTALS10 <> 0  
		If RCCQRY2->TOTALS10 > 1 .and. cCampo $('34')
			cMsg	:=OemToAnsi(STR0026)+CRLF 	 															//"Tabela Aliquotas Gerais (S010), possui mais de um registro com a mesma combinacao de: Atividade, Condição e Modalidade."                                                                                                                                                                                                                                                                                                                                                                                           
			cMsg	:=+cMsg+OemtoAnsi(STR0027)							 									//"Por favor verifique a tabela Aliquotas Gerais (S010)."                                                                                                                                                                                                                                                                                                                                                                                                                                                             
			MsgAlert(cMsg) 
		Else
			if cCampo $ ("1") .AND. !EMPTY(M->RA_COND)
				M->RA_COND=""
			Endif
			If cCampo $ ("12") .and. !EMPTY(M->RA_MODALID)
				M->RA_MODALID=""
			Endif
			lRet:=.T.
		Endif                                                       
	Else
		cMsg	:=OemToAnsi(STR0015)+CRLF 	 																//"Não existem Aliquotas Gerais (S010), que atendam a condição:"			
		cMsg	:=+cMsg+OemToAnsi(STR0016)+" x "+OemToAnsi(STR0017)+" x "+ OemToAnsi(STR0018)+"."			//"Código de Atividades (S005)" ### "Condição (S006)" ### "Modalidade (S008)"	
		MsgAlert(cMsg)
	EndIf

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fAnosRec		³ Autor ³  Equipe RH	           ³ Data ³ 23/01/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula e retorna o numero de anos de Data de reconhecimento do fun- ³±±
±±³			 ³cionario, baseado nos parametros recebidos.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpD1 - Data de Inicio para contagem de Anos do funcionário.         ³±±
±±³			 ³ExpD2 - Data de Final para contagem de Anos do funcionário. 	  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Numero total de anos, baseado nos parametros ExpD1 e ExpD2.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEXFUNARG - funçao: fDiasFerArg   	                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fAnosRec(dDataIni, dDataFim)
Local nTempo		:= DateDiffMonth( dDataIni, dDataFim)
Local nTotTempo		:= 0
Local nTotalAnos	:= 0

nTotTempo := (nTotTempo + nTempo)
nTotalAnos := (nTotTempo / 12)

//# Acrescenta 1 nos Meses
If (nTotTempo - INT(nTotTempo)) > 0
	If !lTruncMes
		nTotTempo += 1
	EndIf
EndIf

//# Acrescenta 1 nos Anos
If ( ((nTotTempo/12) - INT(nTotTempo/12)) * 12 ) >= 12
	nTotalAnos += 1
EndIf

Return(nTotalAnos)


/*/{Protheus.doc} CUILReing
	Verifica si el CUIL existe en otra matrícula con estatus demitido, para calcular fecha de reingreso.
	@type  Function
	@author oscar.lopez
	@since 26/08/2025
	@version version
	@param cCUIL, caracter, CUIL de reingreso del empleado
	@return lRet, lógico, Retorna valor .T. si se realizan las validaciones de manera correcta, de lo contrario .F.
	@example
		dFchRein := CUILReing(M->RA_CIC, M->RA_ADMISSA)
	/*/
Function CUILReing(cCUILEmp, dFchIngres)

	Local cQuery		:= ""
	Local cAliasSRA		:= ""
	Local nParQry		:= 1
	Local nDiasLab		:= 0
	Local nTotDiaLab	:= 0
	Local oQuerySRA		:= Nil
	Local dFchIngAnt	:= CToD("  /  /    ") // Fecha Ingreso Anterior
	Local dFchResAnt	:= CToD("  /  /    ") // Fecha Rescisión Anterior
	Local dFchReingr	:= CToD("  /  /    ") // Fecha de Reingreso

	// Log
	Local aLogs			:= {}
	Local aLogTitle		:= {}
	Local cSucursal		:= AllTrim(GetSx3Cache("RA_FILIAL"	, "X3_TITULO"))
	Local cMatricula	:= AllTrim(GetSx3Cache("RA_MAT"		, "X3_TITULO"))
	Local cFchIngres	:= AllTrim(GetSx3Cache("RA_ADMISSA"	, "X3_TITULO"))
	Local cFchRescis	:= AllTrim(GetSx3Cache("RA_DEMISSA"	, "X3_TITULO"))
	Local cSituacion	:= AllTrim(GetSx3Cache("RA_SITFOLH"	, "X3_TITULO"))
	Local cFchReingr	:= AllTrim(GetSx3Cache("RA_OPCAO"	, "X3_TITULO"))

	Default cCUILEmp	:= ""
	Default dFchIngres	:= CToD("  /  /    ")

	If !Empty(cCUILEmp) .And. !Empty(dFchIngres)
		Begin Sequence
			cQuery += " SELECT RA_FILIAL, RA_MAT, RA_ADMISSA, RA_DEMISSA, RA_SITFOLH"
			cQuery += " FROM ?"
			cQuery += " WHERE RA_CIC = ?"
			cQuery += " AND D_E_L_E_T_ = ?"
			cQuery += " ORDER BY RA_ADMISSA ASC, RA_MAT"

			oQuerySRA := FwExecStatement():New(cQuery)

			// Parámetros
			oQuerySRA:SetUnsafe(nParQry++, RetSqlName("SRA"))
			oQuerySRA:SetString(nParQry++, cCUILEmp)
			oQuerySRA:SetString(nParQry++, " ")					// D_E_L_E_T_

			// Ejecuta el query y retorna el alias creado
			cAliasSRA := oQuerySRA:OpenAlias()
			DbSelectArea(cAliasSRA)
			(cAliasSRA)->(DbGoTop())
			If (cAliasSRA)->(!EoF())
				While (cAliasSRA)->(!EoF())

					dFchIngAnt := SToD((cAliasSRA)->RA_ADMISSA)
					dFchResAnt := SToD((cAliasSRA)->RA_DEMISSA)

					cInfoLog := cSucursal + ": " + (cAliasSRA)->RA_FILIAL + " "
					cInfoLog += cMatricula + ": " + (cAliasSRA)->RA_MAT + " "
					cInfoLog += cSituacion + ": " + (cAliasSRA)->RA_SITFOLH + " "
					cInfoLog += cFchIngres + ": " + DToC(dFchIngAnt) + " "
					cInfoLog += cFchRescis + ": " + DToC(dFchResAnt) + " "

					// Si el empleado no cuenta con situación D - Despedido o Fecha de rescisión, no se consideran días laborados
					If (cAliasSRA)->RA_SITFOLH <> "D" .Or. Empty((cAliasSRA)->RA_DEMISSA)
						cInfoLog += STR0030 + PadL("-", 5, " ") // "Días laborados: "
						AAdd(aLogs, {cInfoLog})
						(cAliasSRA)->(DbSkip())
						Loop
					EndIf

					// Se resta a la fecha de rescisión la fecha de ingreso, y se suma un día para ajustar la resta de fechas.
					nDiasLab := (dFchResAnt - dFchIngAnt) + 1
					nTotDiaLab += nDiasLab

					cInfoLog += STR0030 + PadL(AllTrim(Str(nDiasLab)), 5, " ") // "Días laborados: "
					AAdd(aLogs, {cInfoLog})
					(cAliasSRA)->(DbSkip())
				EndDo

				If MsgYesNo(STR0029, STR0028) // "Se identifica que el CUIL indicado ya cuenta con información en otra matrícula con estatus demitido, ¿desea realizar el cálculo de la fecha de reingreso?" # "Aviso"
					If nTotDiaLab > 0
						dFchReingr := dFchIngres - nTotDiaLab
					EndIf
					AAdd(aLogTitle, STR0031 + TRANSFORM(cCUILEmp, AllTrim(GetSx3Cache("RA_CIC", "X3_PICTURE")))) // "Matrículas procesadas con CUIL "
					AAdd(aLogs, {STR0032 + PadL(AllTrim(Str(nTotDiaLab)), 5, " ")}) // "Total Días Laborados: "
					AAdd(aLogs, {cFchReingr + "(RA_OPCAO): " + DToC(dFchReingr)})
					fMakeLog(aLogs, aLogTitle,,,,STR0033) // "RESUMEN"
				EndIf
			EndIf
			FWFreeObj(oQuerySRA)
		End Sequence
	EndIf

Return dFchReingr

/*/{Protheus.doc} CalcDiaHab
	Obtiene la cantida de días habiles para argentina entre las fechas indicadas
	@type  Static Function
	@author oscar.lopez
	@since 02/10/2025
	@version 1.0
	@param dFchIni, fecha, Fecha inicio
	@param dFchFin, fecha, Fecha fin
	@return nRet, numero, Cantidad de días habiles entre las fechas indicadas
	@example
	nDias := CalcDiaHab(dFchIni, dFchFin)
/*/
Static Function CalcDiaHab(dFchIni, dFchFin)

	Local nRet		:= 0
	Local nDiaSem	:= 0
	Local cFecha	:= ""
	Local aFeriados	:= {}

	Default dFchIni	:= CToD("  /  /    ")
	Default dFchFin	:= CToD("  /  /    ")

	aFeriados := ObtDiasFer(dFchIni, dFchFin)

	While dFchIni <= dFchFin
		nDiaSem := Dow(dFchIni)
		cFecha	:= DToS(dFchIni)
		// Se consideran como habiles los días que no son Sabado, Domingo o Feriado
		If  !(nDiaSem == 7 .Or. nDiaSem == 1 .Or. Ascan(aFeriados, cFecha) > 0)
			nRet++
		EndIf
		dFchIni++
	Enddo

Return nRet

/*/{Protheus.doc} ObtDiasFer
	Lee de tabla SP3 los días feriados que se encuentran entre la fecha de inicio y la fecha final.
	@type  Static Function
	@author oscar.lopez
	@since 02/10/2025
	@version 1.0
	@param dFchIni, fecha, Fecha inicio
	@param dFchFin, fecha, Fecha fin
	@return aRet, arreglo, Arreglo con los días de vacaciones dentro de las fechas indicadas
	@example
	aFer := ObtDiasFer(dFchIni, dFchFin)
/*/
Static Function ObtDiasFer(dFchIni, dFchFin)

	Local aRet		:= {}
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cAliasSP3	:= ""
	Local nParQry	:= 1
	Local oQrySP3	:= Nil

	Default dFchIni	:= CToD("  /  /    ")
	Default dFchFin	:= CToD("  /  /    ")

	cQuery := " SELECT P3_DATA "
	cQuery += " FROM ? "
	cQuery += " WHERE P3_FILIAL = ? "
	cQuery += " AND P3_DATA BETWEEN ? AND ? "
	cQuery += " AND D_E_L_E_T_ = ? "

	oQrySP3 := FwExecStatement():New(cQuery)
	oQrySP3:SetUnsafe(nParQry++, RetSqlName("SP3"))
	oQrySP3:SetString(nParQry++, FWxFilial("SP3"))
	oQrySP3:SetString(nParQry++, DToS(dFchIni))		// Fecha inicio
	oQrySP3:SetString(nParQry++, DToS(dFchFin))		// Fecha fin
	oQrySP3:SetString(nParQry++, " ")				// D_E_L_E_T_

	cAliasSP3 := oQrySP3:OpenAlias()
	DbSelectArea(cAliasSP3)
	(cAliasSP3)->(DbGoTop())

	While (cAliasSP3)->(!EoF())
		AAdd(aRet, (cAliasSP3)->P3_DATA)
		(cAliasSP3)->(DbSkip())
	EndDo
	(cAliasSP3)->(DbCloseArea())

	FWFreeObj(oQrySP3)
	FWRestArea(aArea)

Return aRet
