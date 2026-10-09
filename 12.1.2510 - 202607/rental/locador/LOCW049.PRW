#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW049.PRW
ITUP BUSINESS - TOTVS RENTAL
API - Lista de Minutas a serem baixadas
@TYPE WSRESTFUL
@AUTHOR DENNIS CALABREZ
@SINCE 22/01/2026
/*/
WSRESTFUL LOCW049 DESCRIPTION "Retorna Lista de Minutas a serem baixadas"

	WSMETHOD POST DESCRIPTION "<h2>Metodo que Retorna Lista de Minutas a serem baixadas.</h2>" WSSYNTAX "/LOCW049"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW049
ITUP BUSINESS - TOTVS RENTAL
Método para Lista de Minutas a serem baixadas
@TYPE WSMETHOD
@AUTHOR DENNIS CALABREZ
@SINCE 22/01/2026
/*/
WSMETHOD POST WSSERVICE LOCW049
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cDados		:= ""
Local cRet          := ""
Local cMsg          := ""
Local cBody         := DecodeUtf8(::GetContent())
Local aBindParam    := {}
Local aBindPar      := {}
Local lLog          := .F.
Local cQuery        :=  ""
Local cQry          := ""
Local cPer          := ""
Local cCli          := ""
Local cCpf          := ""
Local cMail         := ""
Local cMinu         := ""
Local Locx341       := SuperGetMv("MV_LOCX314",.F.,.F.)

Private oJson   := Nil


	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
    	If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			lLog := if(len(aEmp)==4, aEmp[4], aEmp[3]=="Empresa já existente.")
			If lLog
				cRet := xAbreEnv1(aEmp[1],aEmp[2])
				If Empty(oJson:dDtIni) .or. Empty(oJson:dDtFim) .or. Empty(oJson:matricula)
					cRet := "400 - "
					cMsg := "Datas de inicio e fim, AS e Matricula tem que ser obrigatoriamente informadas"
				EndIf
				
				If Empty(cRet)
					cQuery := "SELECT FPF_MINUTA,FPF_AS, FPF_PROJET,FPF_DATA,FPF_FROTA,FPF_TURNO,FPF_HORAI,FPF_HORAF, "
					cQuery += "FPQ_MAT, FPQ_OBS, FPF_STATUS, FPF_TURNO, FPF_NOMPF, FPF_CPF, FPF_EMAIL "
					cQuery += "FROM "+RetSqlName("FPF")+" FPF "
					cQuery += "INNER JOIN "+RetSqlName("FPQ")+" FPQ ON FPF.FPF_AS = FPQ.FPQ_AS  "
					cQuery += "AND FPF.FPF_PROJET = FPQ.FPQ_PROJET AND "
					cQuery += "FPF.FPF_FILIAL = FPQ.FPQ_FILIAL "
					cQuery += "AND FPQ_FILIAL = '" +xFilial("FPQ") + "' "
					cQuery += "AND FPQ.D_E_L_E_T_ = ' ' AND FPQ_MAT = ? "
					aadd(aBindParam,Alltrim(oJson:matricula))
					cQuery += "WHERE FPF_DATA BETWEEN ? AND ? AND FPF.D_E_L_E_T_ = ' ' AND FPF_STATUS = '2' "
					cQuery += "AND FPF_FILIAL = '" +xFilial("FPF") + "' "

					aadd(aBindParam,oJson:dDtIni)
					aadd(aBindParam,oJson:dDtFim)
				
			
					cQuery += "GROUP BY FPF_MINUTA,FPF_AS, FPF_PROJET,FPF_DATA,FPF_FROTA,FPF_TURNO,FPF_HORAI,FPF_HORAF, "
					cQuery += "FPQ_MAT, FPQ_OBS, FPF_STATUS,  FPF_TURNO, FPF_NOMPF, FPF_CPF, FPF_EMAIL  "
					cQuery += "ORDER BY FPF_MINUTA "
					cQuery := CHANGEQUERY(cQuery)

					MPSysOpenQuery(cQuery,"TRBFPF",,,aBindParam)

					cQry := "SELECT FPF_NOMPF,FPF_CPF,FPF_EMAIL, FPF_MINUTA "
					cQry += "FROM "+RetSqlName("FPF")+" FPF "					
					cQry += "WHERE FPF_DATA BETWEEN ? AND ? AND FPF.D_E_L_E_T_ = ' ' AND FPF_STATUS = '2' "
					cQry += "AND FPF_FILIAL = '" +xFilial("FPF") + "' "
					cQry += "ORDER BY FPF_MINUTA "

					aadd(aBindPar,oJson:dDtIni)
					aadd(aBindPar,oJson:dDtFim)

					MPSysOpenQuery(cQry,"TRBFP",,,aBindPar)
					//Quando informado Cliente pessoa física no json vai preenchar apenas as minutas que não foram preenchidas
					While TRBFP->(!EoF()) 
						If !Empty(TRBFP->FPF_NOMPF)
							cCli  := Alltrim(TRBFP->FPF_NOMPF)
							cCpf  := Alltrim(TRBFP->FPF_CPF)
							cMail := Alltrim(TRBFP->FPF_EMAIL)
							cMinu := Alltrim(TRBFP->FPF_MINUTA)
						EndIf
						TRBFP->(dbSkip())
					EndDo

					cDados += ', "Minutas": ['			

					If TRBFPF->(!EoF()) 
						While TRBFPF->(!EoF()) 
							//Período
							cPer := ""
							cPer += '"periodo": ['
							FPF->(dbSetOrder(5))
							If FPF->(dbSeek(xFilial("FPF")+TRBFPF->FPF_DATA+TRBFPF->FPF_FROTA))
								While !FPF->(Eof()) .and. FPF->FPF_DATA == STOD(TRBFPF->FPF_DATA);
									 .and. FPF->FPF_FROTA  == TRBFPF->FPF_FROTA .and. FPF->FPF_STATUS == "2"

									cPer += '{ "minuta": "'+ALLTRIM(FPF->FPF_MINUTA)+'", '
									cPer += '"turno" : "'+Alltrim(FPF->FPF_TURNO)+'", '  
									cPer += '"hora_ini" : "'+Alltrim(Transform(FPF->FPF_HORAI,"@R 99:99"))+'", '  
									cPer += '"hora_fim" : "'+Alltrim(Transform(FPF->FPF_HORAF,"@R 99:99"))+'"} '  

									FPF->(dbSkip())
									If !FPF->(Eof())
										cPer += ", "
									Else
										cPer += " "	
									EndIf
								EndDo
							EndIf
							cPer += '] '					
							
							cDados += ' { ' 
							cDados += '"id" : "'+Alltrim(TRBFPF->FPF_MINUTA)+'", '
							cDados += '"data" : "'+Alltrim(TRBFPF->FPF_DATA)+'", '
							//Cliente
							cDados += '"cliente" : {'
							cDados += '"nome" : "'+Alltrim(Posicione("FP0",1,xFilial("FP0")+TRBFPF->FPF_PROJET,"FP0_CLINOM"))+'", '
							cDados += '"cnpj" : "'+Alltrim(Posicione("FP0",1,xFilial("FP0")+TRBFPF->FPF_PROJET,"FP0_CLICGC"))+'" '                          
							cDados += ' }, ' 	
							//Cliente Pessoa Fisica
							If cMinu <> Alltrim(TRBFPF->FPF_MINUTA)
								cDados += '"clientePF" : {'
								cDados += '"nome" : "'+cCli+'", '
								cDados += '"cpf" : "'+cCpf+'", '
								cDados += '"email" : "'+cMail+'" '
								cDados += ' }, ' 	
							Else
								cDados += '"clientePF" : {'
								cDados += '"nome" : "", '
								cDados += '"cpf" : "", '
								cDados += '"email" : "" '
								cDados += ' }, ' 							
							EndIf																	
							//Maquina
							cDados += '"maquina" : {'
							cDados += '"nome" : "'+Alltrim(Posicione("ST9",1,xFilial("ST9")+TRBFPF->FPF_FROTA,"T9_NOME"))+'", '
							cDados += '"modelo" : "'+Alltrim(Posicione("ST9",1,xFilial("ST9")+TRBFPF->FPF_FROTA,"T9_DESMOD"))+'", '                        
							cDados += '"serie" : "'+Alltrim(TRBFPF->FPF_FROTA)+'" '  
							cDados += ' }, '  
							//Localidade
							cDados += '"localidade" : {'
							cDados += '"endereco" : "'+Alltrim(Posicione("FP1",1,xFilial("FP1")+TRBFPF->FPF_PROJET,"FP1_ENDORI"))+'", '
							cDados += '"cidade" : "'+Alltrim(Posicione("FP1",1,xFilial("FP1")+TRBFPF->FPF_PROJET,"FP1_MUNORI"))+'", '                        
							cDados += '"estado" : "'+Alltrim(Posicione("FP1",1,xFilial("FP1")+TRBFPF->FPF_PROJET,"FP1_ESTORI"))+'", '  
							cDados += '"cep" : "'+Alltrim(Posicione("FP1",1,xFilial("FP1")+TRBFPF->FPF_PROJET,"FP1_CEPORI"))+'" '  
							cDados += ' }, '                          

							//dados adicionais
							cDados += '"dados adicionais" : {'	
							If TRBFPF->FPF_STATUS == "2"
								cDados += '"status" : "confirmada", '
							EndIf
																																			
							cDados += '"observacao" : "'+Alltrim(TRBFPF->FPQ_OBS)+'", '                          
							cDados += '"MV_LOCX314" : "'+Locx341+'" ' 
							cDados += ' }, ' 

							cDados += cPer
							cDados += '}'

							TRBFPF->(DbSkip())

							If !TRBFPF->(Eof())
								cDados += ','
							EndIf

						EndDo
					Else
						cRet := "204 - "
						cMsg := " A requisicao foi bem-sucedida, mas nao ha conteudo para retornar no corpo da resposta, verifique os parametros"
					EndIf

					cDados += "]"
				EndIf
			Else
				cRet := "401 - "
				cMsg := "Credenciais de autenticacao invalidas ou ausentes, verifique o CNPJ da empresa Protheus"				
			EndIf	
        EndIf
	End Sequence

	ErrorBlock(bError)
	If Empty(cRet)
		cRet := "200 - "
		cMsg := "Recurso encontrado"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+cMsg+'" '+cDados+'}')) )
	
Return .T.
