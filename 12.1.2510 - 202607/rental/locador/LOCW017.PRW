#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"
#include "FWEVENTVIEWCONSTS.CH"
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Aprovmulta  ³ Autor ³ Dennis Calabrez ³ Data ³30.01.2025                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo Aprovação de Multas no APP                                         ³±±
±±³Descricao ³ 															                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL Aprovmulta DESCRIPTION " Metodo Aprovação de Multas no APP "

	WSMETHOD POST DESCRIPTION "<h2> Metodo Aprovação de Multas no APP .</h2>" WSSYNTAX "/Aprovmulta"

END WSRESTFUL



WSMETHOD POST WSSERVICE Aprovmulta
	
Local cDtIni		:= DtoC(Date())
Local cHrIni		:= Time()
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local oJson			:= Nil
Local cRet			:= ""
Local cBody			:= DecodeUtf8(::GetContent())
Local cEventID 	:= "101"
Local cMessagem	:= " "
Local aSx5      :=  {}

	//conout("INICIO-Consumido o WebService ReagendaOS - Data e Hora Inicial "+cDtIni+" - "+cHrIni)
	
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence
		If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
				//cRet := xAbreEnv1(aEmp[1],oJson:FilBem)
				cRet := xAbreEnv1(aEmp[1])
				If Empty(cRet)
					//BUSCA NA SX5 NA TABELA E3 O EVENTO 101 - DSERLOCA-10510 Dennis Calabrez 24/03/2026
					aSx5 := FWGetSX5("E3", cEventID) 				
					TRX->(DbSetOrder(1))
					TRX->(DbGoTop())   
					If TRX->(DbSeek(xFilial("TRX")+ oJson:num_multa))  				
						RecLock("TRX", .F.)
							TRX->TRX_CODMO := oJson:cod_mot
							TRX->TRX_FIC := oJson:id_fic
						TRX->(MsUnlock())
						If Len(aSx5) > 0//SE EXISTIR O EVENTO 101 EXECUTA O EVENT VIEWER - DSERLOCA-10510 - Dennis Calabrez 24/03/2026
							cMessagem += "Nome do Cliente: "+Posicione("FP0",1,xFilial("FP0") + TRX->TRX_PROJET ,"FP0_CLINOM") + CHR(13)+CHR(10)
							cMessagem += " Código/Loja: " + Posicione("FP0",1,xFilial("FP0") + TRX->TRX_PROJET  ,"FP0_CLI")+"/"+Posicione("FP0",1,xFilial("FP0") + TRX->TRX_PROJET ,"FP0_LOJA") + CHR(13)+CHR(10)
							cMessagem += " Código Multa: " + oJson:num_multa+ CHR(13)+CHR(10)
							cMessagem += " Código Motorista: " + oJson:cod_mot +CHR(13)+CHR(10) 
							cMessagem += " Nome Motorista: " + Posicione("DA4",1,xFilial("DA4") + oJson:cod_mot ,"DA4_NOME") +CHR(13)+CHR(10) 
							EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,"","Disparo de Multa via LOCW017",cMessagem,.T.)											
						EndIf							
					EndIf	
				EndIf
			endif
		EndIf
	End Sequence


	If Empty(cRet)
		cRet := "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" }')) )
	
	//conout("TERMINO-Consumido o WebService RetCCsMovVeiculo - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.

Function xVerEmp3(cCNPJ)
Local aRet 	   		:= {"","",""}
Local cNextEmp		:= ""
Local cNextFil		:= ""
	
	//cCNPJ 		:= Replace(Replace(Replace(cCNPJ,".",""),"/",""),"-","")
	//cRaizCNPJ	:= Replace(Replace(Replace(cRaizCNPJ,".",""),"/",""),"-","")
	
	ConOut("Verificando Empresa")

	aEmpSM0	:= FWLoadSM0()
	nPosEmp := aScan(aEmpSM0,{|x| Alltrim(x[18]) == Alltrim( cCNPJ ) })
	if nPosEmp > 0 
		aRet[1] := aEmpSM0[nPosEmp][1]
		aRet[2] := aEmpSM0[nPosEmp][2]
	endif
	DbCloseAll()
	RpcClearEnv()

	//Se não existe
	If Empty(aRet[1])
		aRet[1] := cNextEmp
		aRet[2] := cNextFil
		aRet[3] := "Não existe empresa."
	Else
		aRet[3] := "Empresa já existente."
	EndIf
	
Return (aRet)

Function xAbreEnv3(cEmp,cFil)
Local cEnvLog	:= ""
Local cRet		:= ""
Local lRetEmp	:= .F.
Local bError    := {||}

	ConOut("Abrindo Ambiente")
	
	// Salva bloco de código do tratamento de erro
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
	
	Begin Sequence

		RpcClearEnv() 
		RpcSetType(3) 
		lRetEmp := RpcSetEnv(cEmp,cFil,,,"FAT",GetEnvServer(),{""})

	End Sequence
	ErrorBlock(bError)
	
Return (cRet)
