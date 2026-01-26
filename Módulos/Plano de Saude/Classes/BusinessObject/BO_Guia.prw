#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "PLSMGER.CH"

class BO_Guia
		
	method new() Constructor
	method verificaLib(oGuia, cNumLib, lInterc)
	method getDescProcedimento(cCodPro, cDesPro, cCodPad)
	method getDadIntercambio(cMatric)
	method getDadTabela(cCodPad, cCodPro, dDtPro, cCodOpe, cCodRda, cCodEsp, cSubEsp, cCodLocal, cLocal, cOpeOri, cCodPla, cTipAte)
	method getPartic(aTpPar, cSeqMov, cCodPad, cCodPro, nVlrApr, cCodRda)
	method preeNraOpe(cNumLib)
	method baixaLib(aItens, cOrigem,cNumLib, lInter, lEvolu, cMatric, cLocalExec, cHora, cViaCartao, cTipoMat, cNomUsrCar, cTipoGrv,;
			 		dDatPro, dDatNasUsr, lResInt, lHonor, lIncAutIE, cOpeMov, cCodRda, cCodRdaPro, cCodLoc, cCodLocPro, cCodEsp,  cLibEsp,;
			 		cAuditoria, cNumImp, lLoadRda, lRdaProf, lIncNeg, cTipo, cCodPRFExe, cEspSol, cEspExe, lForBlo, lNMudFase, lEvoSADT)
	method addExcLib(cIdenBD5, cNumLib)
	method verificaProc(aItens, cCodPad_Novo, cCodPro_Novo)
	method checkInt(cGuiPr)
	
endClass

method new() class BO_Guia
return self

method addExcLib(cIdenBD5, cNumLib) class BO_GUIA

	if ! empty(cNumLib)
		PLSSALLIB(cIdenBD5, cNumLib)
	endif
	
return

method verificaProc(aItens, cCodPad_Novo, cCodPro_Novo) class BO_GUIA

	local nFor, cCodPad, cCodPro, lRetorno := .T.
	
	for nFor := 1 to len(aItens) 
		cCodPad := PLSRETDAD(aItens[nFor],"CODPAD")
		cCodPro := PLSRETDAD(aItens[nFor],"CODPRO")
		
		if cCodPad = cCodPad_Novo .and. cCodPro = cCodPro_Novo
			lRetorno := .F.
		endIf
	next

return lRetorno

/*/{Protheus.doc} baixaLib
Metodo que realiza a baixa deuma liberação
@author PLSREAM
@since 13/10/2016
@version P12
/*/
method baixaLib(aItens, cOrigem,cNumLib, lInter, lEvolu, cMatric, cLocalExec, cHora, cViaCartao, cTipoMat, cNomUsrCar, cTipoGrv,;
			 	dDatPro, dDatNasUsr, lResInt, lHonor, lIncAutIE, cOpeMov, cCodRda, cCodRdaPro, cCodLoc, cCodLocPro, cCodEsp,  cLibEsp,;
			 	cAuditoria, cNumImp, lLoadRda, lRdaProf, lIncNeg, cTipo, cCodPRFExe, cEspSol, cEspExe, lForBlo, lNMudFase, lEvoSADT, cTipGui) class BO_GUIA

Local cCodEspPro := cCodEsp
Local aRdaProf := {}
Local aDadUsr  := {}
Local aRetFun  := {}
Local aDadRda  := {}
Local aRetLib  := {}
Local aItensLOri := {}
Local aAutItens	:= {}

Local cTpLibToAut
Local cSeqMov
Local cCodPad
Local cCodPro
Local cDescri
Local nQtdSol
Local nQtdAut
Local cTpProc
Local cDente 
Local cFace  
Local cStProc
Local nLastPos			
Local lAprovLib := .F.
Local nRecBEALIB
Local cGuiaOri	
Local nPos
Local nFor
Local aHeader := {}
Local aCabDF  := {}

If cOrigem <> "2" .and. !Empty(cNumLib) .and. !lEvolu .and. !lInter
BEA->( DbSetOrder(1) )
If BEA->( MsSeek(xFilial("BEA")+cNumLib) )

	lIncNeg := getNewPar("MV_PLSINEG", .T.)
	
	If ValType("lIncNeg") == "U"
		lIncNeg := .F.
	Endif
	
	
	//Busca Array com os dados do usuário.
	aRetFun := PLSUSUATE(@cMatric,cLocalExec,cHora,cViaCartao,cTipoMat,cNomUsrCar,cTipoGrv,aItens,;
	   		             {},{},{},dDatPro,dDatNasUsr,lResInt,lHonor,lIncAutIE,.f.)

	aDadUsr	  := aRetFun[8]
			
	aRetFun := PLSREDATE(cOpeMov,cCodRda,cCodRdaPro,@cCodLoc,@cCodLocPro,@cCodEsp,@cCodEspPro,dDatPro,;
	   				     aItens,{},{},{},aDadUsr,cLibEsp,cAuditoria,cOrigem,;
					     cNumImp,lLoadRda,lRdaProf,lIncNeg)
					     
	aDadRda 	:= aRetFun[6]				     	
	aRdaProf  	:= aRetFun[7]
				
	aRetLib := PLSRETAULI(cMatric,cNumLib,Iif(cTipo=='2' ,'A','L'),cCodRdaPro,cCodLocPro,cCodEspPro,cCodPRFExe,cLocalExec,.T.,aRdaProf,aDadUsr,cTipo,cEspSol,cEspExe)

	aSlvRtLb := aClone(aRetLib)
	
	If GetNewPar('MV_PLTREXC','0') == '1' .and. !aRetLib[1]
		aRetLib := PLSRETAULI(cMatric,cNumLib,'L',cCodRda,cCodLoc,cCodEsp,cCodPRFExe,cLocalExec,.T.,aDadRda,aDadUsr,cTipo,cEspSol,cEspExe)
		If ! aRetLib[1]
			aRetLib := aClone(aSlvRtLb)
		Endif
	Endif
	
	For nFor := 1 To Len(aItens)
		cSeqMov := PLSRETDAD(aItens[nFor],"SEQMOV")
		cCodPad := PLSRETDAD(aItens[nFor],"CODPAD")
		cCodPro := PLSRETDAD(aItens[nFor],"CODPRO")
		cDescri	:= PLSRETDAD(aItens[nFor],"DESCRI","")
		nQtdSol := PLSRETDAD(aItens[nFor],"QTD",0)
		nQtdAut := PLSRETDAD(aItens[nFor],"QTDAUT",0)
		cTpProc	:= PLSRETDAD(aItens[nFor],"TPPROC","")
		cDente  := PLSRETDAD(aItens[nFor],"DENTE","")
		cFace   := PLSRETDAD(aItens[nFor],"FACE","")
		cStProc := PLSRETDAD(aItens[nFor],"STPROC","")

		AaDd( aAutItens,{ cSeqMov,;		//[1]  cSeqMov  -> Sequencia do evento
						  cCodPad,;		//[2]  cCodPad  -> Tipo Codigo Procedimento
						  cCodPro,;		//[3]  cCodPro  -> Codigo do Procedimento
						  nQtdSol,;		//[4]  nQtdSol  -> Quantidade do Procedimento
						  0,;			//[5]  zero     -> Sera a diferenca entre qual quantidade tinha sido liberada (saldo) - a quantidade que foi solicitada na autorizacao corrente
						  .T.,;			//[6]  Status(L)-> Valor logico se este item sera retirado da liberacao original ou nao
						  0,;			//[7]  Recno    -> Recno do registro BE2 relacionado a liberacao original
						  .F.,;			//[8]  lColsDel -> Indica se um item do aCols que foi solicitado nao podera ser autorizado ou nao
						  nQtdAut,;		//[9]  nQtdAut	-> Quantidade Autorizada
						  .F.,;			//[10] XXX 		-> Indica se um item ja foi executado anteriormente
						  .F.,;			//[11] XXX 		-> Indica se um item existe na liberacao
						  .F.,;			//[12] XXX 		-> Indica se o item pode ser executado pelo executante
						  cTpProc,;		//[13] cTpProc	-> Tipo do procedimento
						  cDescri,;  	//[14] cDescri	-> Descricao do procedimento
						  cDente,;   	//[15] cDente	-> Dente
						  cFace,;		//[16] cFace	-> Face
						  cStProc} )	//[17] cStatus	-> Status
			  
	Next
	
	For nFor := 1 To Len(aAutItens)
	
		cSeqMov   := aAutItens[nFor,1]
		cCodPad   := aAutItens[nFor,2]
		cCodPro   := aAutItens[nFor,3]
		nQtdSol   := aAutItens[nFor,4]
		nQtdAut   := aAutItens[nFor,9]
		cDente    := aAutItens[nFor,15]
		cFace     := aAutItens[nFor,16]
		cStProc   := aAutItens[nFor,17]
		
		// Verifica se o procedimento foi encontrado e se e permitido para o executante
		// So e possivel a verificacao da sequancia quando o array de itens nao foi
		// alterado no portal.
		// Caso seja necessario a verificacao da sequencia qdo o procedimento e excluido
		// sera necessario alteracao no java script que faz a exclusao no portal.
		If Len(aRetLib[4]) ==  Len(aAutItens) .and. Len(aAutItens) != 1
			nPos := Ascan( aRetLib[4],{|x| x[2]+x[3]+x[4]+x[24]+x[25] == cSeqMov+cCodPad+cCodPro+cDente+cFace } )
		Else
			nPos := Ascan( aRetLib[4],{|x| x[3]+x[4]+x[24]+x[25] == cCodPad+cCodPro+cDente+cFace } )
		EndIf

		If nPos > 0 .And. aRetLib[4,nPos,10] == "1"
		// Se for um procedimento de solicitacao de internacao
			If aRetLib[4,nPos,13] > 0 .And. Empty(aRetLib[4,nPos,11])
			
				AaDd(aItensLOri,{cSeqMov,cCodPad,cCodPro,0,cDente,cFace})
				
				// Comun a todos os casos
				nLastPos			:= Len(aItensLOri)

				aAutItens[nFor,7] 	:= aRetLib[4,nPos,12] //Recno
				aAutItens[nFor,8]	:= .T.	//Se a quantidade for maior que a solicitada
				
				lAprovLib         	:= .T.
				nRecBEALIB        	:= aRetLib[7]
				cGuiaOri          	:= aRetLib[8]
				
				// Verificando o saldo
				If nQtdSol > aRetLib[4,nPos,13]
					aAutItens[nFor,5] := 0
					aAutItens[nFor,6] := .T. 		//Item nao sera excluido da liberacao original

					If aRetLib[4,nPos,13] == 0
						aAutItens[nFor,10] := .T. 	//Para controlar se o item ja foi executado anteriormente
					EndIf
				Else
					// Quantidade e a mesma
					If nQtdSol == aRetLib[4,nPos,13]
						aAutItens[nFor,5] := 0 		//nao existe mais saldo na liberacao original
						aAutItens[nFor,6] := .T. 	//Item sera retirado da liberacao original

						aItensLOri[nLastPos,4] 	:= 0
					Else
						aAutItens[nFor,5] 		:= aRetLib[4,nPos,13] - nQtdSol 	//Saldo que ficou na liberacao original
						aAutItens[nFor,6] 		:= .F. 									//Item nao sera excluido da liberacao original
						
						aItensLOri[nLastPos,4] 	:= aRetLib[4,nPos,13] - nQtdSol 	//Saldo que ficou na liberacao original
					Endif
				EndIf
			Else
				lAprovLib			:= .T.
				aAutItens[nFor,10]	:= .T. 	//Para controlar se o item ja foi executado anteriormente
				nRecBEALIB          := aRetLib[7]
				cGuiaOri            := aRetLib[8]
			endIf
		Else
			lAprovLib 	:= .T.
			nRecBEALIB	:= aRetLib[7]
			cGuiaOri  	:= aRetLib[8]
			
		    If nPos <> 0 .And. Len(aRetLib[4,nPos,14]) >= 2
				aAutItens[nFor,12]	:= .T. 	//Se o item pode ser executado pelo executante
			Else
				aAutItens[nFor,11]	:= .T. 	//Para controlar se o item existe na liberacao
			EndIf
		EndIf
	Next

	//Caso seja Autorizacao a partir de liberacao verifica se sera total ou parcial
	If lAprovLib
	
		aRetAux := PLSXVLDCAL(dDatPro,cOpeMov,.F.,cCodPad,cCodPro)
		cAno 	:= aRetAux[4]
		cMes 	:= aRetAux[5]
		aTrb 	:= aRetAux[2]
		
		cTpLibToAut := ""
		
		BEA->( DbGoTo(nRecBEALIB) )

		dDataSol := BEA->BEA_DATSOL
		cHoraSol := BEA->BEA_HORSOL
		cCidPri  := BEA->BEA_CID
		cCDPFSO  := BEA->BEA_CDPFSO
		cOpeSol  := BEA->BEA_OPESOL
		
		BE2->( DbSetOrder(1) )
		//Caso existe no be2 e nao existe na matriz e o salvo for maior que zero e parcial
		If BE2->(MsSeek(xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
		
			While ! BE2->(Eof()) .And. BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == ;
					xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

				If Ascan(aItensLOri,{|x| AllTrim(x[1]+x[2]+x[3]+x[5]+x[6]) == BE2->(BE2_SEQUEN+BE2_CODPAD)+AllTrim( BE2->BE2_CODPRO )+AllTrim( BE2->BE2_DENREG )+AllTrim( BE2->BE2_FADENT ) } ) == 0 .And. BE2->BE2_SALDO > 0
					cTpLibToAut := "P"       //se tem algum item da pre-autorizacao(liberacao) que nao foi analisado e parcial
					exit
				EndIf

			BE2->(DbSkip())
			EndDo
			
		EndIf
	
		//Verifico se existe algum item para ser executado em outro momento
		If Empty(cTpLibToAut)
			For nFor := 1 To Len(aAutItens)
			
				If !aAutItens[nFor,6]   		//pelo menos um NAO vai autorizar
					
					cTpLibToAut := "P"       	//Parcial
					exit
					
				elseIf aAutItens[nFor,6]     	//autorizou
			
					If aAutItens[nFor,5] > 0 	//pelo menos um ainda tem saldo portando e parcial
						cTpLibToAut := "P"
						exit
					Else                      	//por enquanto todos autorizam e nao tem mais saldo
						cTpLibToAut := "T"
					endIf
					
				endIf
				
			Next
			
		Endif
				
		// Monta o Cabecalho
		Store Header "BE2" TO aHeader For .T.

		If cTipo == "4"
			B04->(dbsetorder(1))
			Store Header "BYS" TO aCabDF For .T.
		EndIf
			
		aVetTrab := {}
		aCols    := {}
		
		PLSA090MDA(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),"",aHeader,aVetTrab,aCols)
		
		// Grava os valores para fazer a exclusao da liberacao
		aHeaderLib  := aClone(aHeader)
		aVetTrabLib := aClone(aVetTrab)
		aColsLib	:= aClone(aCols)
		aCols    	:= {}
		aVetTrab 	:= {}
		
		Begin Transaction
		
			// Posiciona na liberacao original
			BEA->( DbGoTo( nRecBEALIB ) )
			
			If cTpLibToAut = "T"
				PLSATUCS()
			EndIf
			
			for nPos := 1 To Len(aAutItens)
				
				If aAutItens[nPos,8] .And. aAutItens[nPos,7] > 0
					
					BE2->( DbGoTo(aAutItens[nPos,7]) )
					
					nRecBE2 := aAutItens[nPos,7]

					nSaldo  := aAutItens[nPos,5]
					cStaLib := iIf(nSaldo == 0,"2","1")
					
					PLSATUSS( nil,.t.,.t.,nSaldo,cStaLib,,,,,nRecBE2)	

				endIf
											
			next 
				
			End Transaction
		Endif	
	EndIf
Endif

return 

/*/{Protheus.doc} verificaLib
Metodo que verifica se é uma liberação
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
method verificaLib(oGuia, cNumLib, lInterc) class BO_GUIA
local lAchou    	:= .F.
local nRecBEA   	:= 0
local cAliasTrb		:= "" 
local cNrlBor 		:= ""
local cGuiOri 		:= ""
local cNraOpe 		:= ""
local cSenha 		:= ""
Local lTratGuiPre 	:= GetNewPar("MV_PLTRPRE",.F.) //Igual ao PLSXMOV

BEA->( DbSetOrder(1) )
lAchou := IIF( EmpTy(cNumLib), .F., BEA->( MsSeek(xFilial("BEA")+padr(alltrim(cNumLib),18)) ) )

if !lAchou

	BEA->( DbSetOrder(14) )
	lAchou := IIF( EmpTy(cNumLib), .F., BEA->( MsSeek(xFilial("BEA")+padr(alltrim(cNumLib),9)) ) )
		
	if !lAchou 
		
		if lTratGuiPre .AND. ! EmpTy(cNumLib)

			cAliasTrb	:= GetNextAlias()
			
			BeginSql Alias cAliasTrb
				SELECT BEA.R_E_C_N_O_ FROM %table:BEA% BEA
				 WHERE BEA_FILIAL = %exp:xFilial("BEA")%
				   AND BEA_GUIPRE = %exp:cNumLib%
				   AND BEA.%NotDel%
			Endsql

			if !(cAliasTrb)->(Eof())
			
				lAchou := .t.
				nRecBEA  := (cAliasTrb)->R_E_C_N_O_
				
			endif
			
		endif
				
	endif
		
endif

if lAchou

	if nRecBEA != 0
		BEA->(DbGoto((cAliasTrb)->R_E_C_N_O_))
		(cAliasTrb)->(DbCloseArea())
	endif
	
	//se esta eh uma liberacao
	if BEA->BEA_LIBERA == '1' 		
	
		cNrlBor :=  BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
	
	//mas por engano o prestador pode ter enviado o nro da autorizacao ao invez do nro da liberacao	  				
	else	
		cNrlBor := BEA->BEA_NRLBOR  		
	endif
		
	cGuiOri := BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)

	if lInterc
		 cNraOpe :=  BEA->BEA_NRAOPE 
	endif

	cSenha := BEA->BEA_SENHA   
					
endif 	
		
return {cNrlBor, cGuiOri, cNraOpe, cSenha }
//-------------------------------------------------------------------
/*/{Protheus.doc} preeNraOpe
Metodo que verifica se é uma liberação
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method preeNraOpe(cNumLib) class BO_GUIA
local cNraOpe := ""

if alltrim( GETNEWPAR("MV_PLSUNI","1") ) == "1"
	
	nOrdBEA := BEA->(IndexOrd())
	nRecBEA := BEA->(Recno())
	BEA->(DbSetOrder(14))
	If  BEA->(MsSeek(xFilial("BEA")+cNumLib)) .And. !Empty(BEA->BEA_NRAOPE)
		cNraOpe := BEA->BEA_NRAOPE 
	Else
		cNraOpe := cNumLib 
	Endif
	BEA->(DbGoTo(nRecBEA))
	BEA->(DbSetOrder(nOrdBEA))
	
Else

	cNraOpe :=  cNumLib 
	
Endif
	
return cNraOpe
//-------------------------------------------------------------------
/*/{Protheus.doc} BO_Guia
Somente para compilar a classe
@author Karine Riquena Limp
@since 25/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function BO_Guia
Return

method getDescProcedimento(cCodPro, cDesPro, cCodPad) class BO_Guia

	local cGrpEmpInt
	local cSpaceUsuAtu
	local cDescProcedimento
		
	BR8->( DbSetOrder(1) ) //BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN
	BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro))
		
	If !Empty(cDesPro) .and. alltrim(cCodPro) == alltrim(GetNewPar("MV_PLPSPXM","99999994"))
		cDescProcedimento := UPPER(cDesPro)
	Else
		cDescProcedimento := BR8->BR8_DESCRI
	Endif
	
return AllTrim(cDescProcedimento)

method getDadIntercambio(cMatric) class BO_Guia

	local cGrpEmpInt
	local cSpaceUsuAtu
	local cInterc
	local cTipInt
	local aDadInt := {}
	
	
	cGrpEmpInt := GetNewPar("MV_PLSGEIN","0050")		
	cSpaceUsuAtu	:= Iif(Len(AllTrim(cMatric)) == 16,"",Space(TamSx3("BD6_MATRIC")[1] - Len(AllTrim(cMatric))))
	
	BA1->( DbSetOrder(2) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
	BA1->( DbGotop() )
	
	
	If BA1->( MsSeek( xFilial("BA1")+AllTrim(cMatric)+cSpaceUsuAtu))
		
		BA3->( DbSetOrder(1) )
		if BA3->( MsSeek( xFilial("BA3") + BA1->( BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
				
			cOpeOri  := BA1->BA1_OPEORI
			cMatAnt  := BA1->BA1_MATANT
			cCodPla  := BA3->BA3_CODPLA
			cModPag  := BA3->BA3_MODPAG
			cTipoUsr := BA3->BA3_TIPOUS
				
			cInterc	 :=  If(BA3->BA3_CODEMP==cGrpEmpInt,"1","0")
				
			aadd(aDadInt, cInterc)
			
			BT5->(DbSetOrder(1))
				
			if BT5->(MsSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP)))  
				cTipInt := If(BA3->BA3_CODEMP==cGrpEmpInt,BT5->BT5_TIPOIN,"")
				aadd(aDadInt, cTipInt)
			endif
		endif
	endif
	
return IIf( Empty(aDadInt), {"0"}, aDadInt)

method getDadTabela(cCodPad, cCodPro, dDtPro, cCodOpe, cCodRda, cCodEsp, cSubEsp, cCodLocal, cLocal, cOpeOri, cCodPla, cTipAte)  class BO_Guia

	local aCodTab  := {}
	local aRetorno := {}
	DEFAULT cCodLocal := ""
	DEFAULT cLocal := ""
	Default ctipAte := ""

	aCodTab := PLSRETTAB(cCodPad,cCodPro,dDtPro,; 
						 cCodOpe,cCodRda,cCodEsp,cSubEsp,cCodLocal + cLocal,; 
						 dDtPro,"1",cOpeOri,cCodPla,"2","1"; 
						 ,,,,,,,,,,,,cTipAte ) 
				   		
	If aCodTab[1]
		//objProcedimento:setCodTab(aCodTab[3]) //BD6->BD6_CODTAB
		aadd(aRetorno, aCodTab[3])
		//objProcedimento:setAliaTb(aCodTab[4]) //BD6->BD6_ALIATB
		aadd(aRetorno, aCodTab[4])
	EndIf
	
return aRetorno

method getPartic(aTpPar, cSeqMov, cCodPad, cCodPro, nVlrApr, cCodRda)  class BO_Guia

	local nJk
	local aPartic := {}

	For nJk:=1 To Len(aTpPar)
		If (Empty(aTpPar[nJk,11]) .and. !Empty(aTpPar[nJk,12]))
			BAQ->(dbSetOrder(7))
			BAQ->(MsSeek(xFilial("BAQ")+AllTrim(aTpPar[nJk,12])))
			aTpPar[nJk,11] := BAQ->BAQ_CBOS
		EndIf
		aadd(aPartic, {aTpPar[nJk,1],; 					//[1]
						cSeqMov,;							//[2]
						cCodPad+cCodPro,;					//[3]
						nVlrApr,;							//[4]
						aTpPar[nJk,5],;					//[5]
						aTpPar[nJk,4],;					//[6]
						aTpPar[nJk,6],;					//[7]
						0,;									//[8]
						Iif(Len(aTpPar[nJk]) >=9,aTpPar[nJk,9],''),; //[9] BD7_CDPFPR
						cCodRda,; //[10]
						"",; //[11]
						aTpPar[nJk,12],; //[12]
						aTpPar[nJk,13],; //[13]
						aTpPar[nJk,11]}) //[14]
						
						/*aTpPar[nJk,2],;						//[10] BD7_CODRDA
						aTpPar[nJk,3]})						//[11]
						Iif(Len(aTpPar[nJk]) >=10,aTpPar[nJk,10],''),;//[12] BD7_ESPEXE
						Iif(Len(aTpPar[nJk]) >=11,aTpPar[nJk,11],{})} )//unidade que posso incluir, se vazio posso todas*/
	Next
	
return aPartic

//-------------------------------------------------------------------
/*/{Protheus.doc} checkInt
Método que verifica se a guia enviada no campo Guia Principal é uma internação
@author Rodrigo Morgon
@since 15/01/2018
@version P12
/*/
//-------------------------------------------------------------------
method checkInt(cGuiPr) class BO_Guia

local cGuiInt := ""

BE4->(DbSetOrder(2)) //BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
if BE4->(MsSeek(xFilial("BE4") + cGuiPr))
    cGuiInt := BE4->(BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO)
endif

return cGuiInt
	
	
