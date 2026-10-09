#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"
#include "FWEVENTVIEWCONSTS.CH"

/*/{PROTHEUS.DOC} LOCW053.PRW
ITUP BUSINESS - TOTVS RENTAL
API -Receber dados da IA para checklist
@TYPE FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 09/03/2026
/*/
WSRESTFUL LOCW053 DESCRIPTION "Receber dados da IA para checklist"

	WSMETHOD POST DESCRIPTION "<h2>Metodo para Receber dados da IA para checklist.</h2>" WSSYNTAX "/LOCW053"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW052
ITUP BUSINESS - TOTVS RENTAL
API -Receber dados da IA para checklist
@TYPE FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 09/03/2026
/*/
WSMETHOD POST WSSERVICE LOCW053
Local bError    := {||}
Local cRet      := ""
Local cBody     := DecodeUtf8(::GetContent())
Local aEmp      := {}
Local cFonte    := "LOCW053.PRW"
Local aInfo     := GetAPOInfo(cFonte)
Local lLog      := .F.
Local nX        := 0
Local nCont     := 0
Local aRetorno  := {}
Local aFiles    := {}
Local aSx5      := {}
Local cRetorno  := ""
Local lRet      := .T.
Local cEventID 	:= "097"
Local cMessagem	:= " "

Private lMsErroAuto := .F.
Private cMsErroAuto := ""
Private oJson       := Nil

	If FWJsonDeserialize(cBody, @oJson)
		
		aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
		lLog := if(len(aEmp)==4, aEmp[4], aEmp[3]=="Empresa ja existente.")

		If lLog .And. !Empty(oJson:cnpj_empresa )

			cRet := xAbreEnv1(aEmp[1], aEmp[2])

			If Empty(cRet)
				ST9->(dbSetOrder(1))
				ST9->(dbSeek(xFilial("ST9") + oJson:Bem))
				If ST9->(EOF()) .Or. Empty(oJson:Bem )
					aadd(aRetorno, {oJson:CodCheck, "400", "Bem nao encontrado ou não informado, verificar o Bem informado"})
					lRet := .F.
				Else
					aFiles := oJson:files
					//BUSCA NA SX5 NA TABELA E3 O EVENTO 097
					aSx5 := FWGetSX5("E3", cEventID)
					aRetorno := {}
					If len(aFiles) > 0
						For nX := 1 to len(aFiles)

							//VALIDAÇÕES
							If Empty(oJson:CodCheck )
								aadd(aRetorno, {oJson:CodCheck , "400", "Campo' CodCheck' e obrigatorio"})
							ElseIf Empty(aFiles[nX]:ID_topico)
								aadd(aRetorno, {aFiles[nX]:ID_topico , "400", "Campo' ID_topico' e obrigatorio"})
								lRet := .F.
							ElseIf Empty(aFiles[nX]:ID_Item)
								aadd(aRetorno, {aFiles[nX]:ID_Item , "400", "Campo' ID_Item' e obrigatorio"})
								lRet := .F. 
							ElseIf Empty(aFiles[nX]:Status_IA)
								aadd(aRetorno, {aFiles[nX]:Status_IA , "400", "Campo' Status_IA' e obrigatorio"})
								lRet := .F.     
							ElseIf Empty(aFiles[nX]:Obs_IA)
								aadd(aRetorno, {aFiles[nX]:Obs_IA , "400", "Campo' Obs_IA' e obrigatorio"})
								lRet := .F.  	
							ElseIf Empty(aFiles[nX]:desc_statu)
								aadd(aRetorno, {aFiles[nX]:desc_statu , "400", "Campo' desc_statu' e obrigatorio"})
								lRet := .F. 												                                                                  
							Else    

								FPX->(dbSetOrder(2))
								FPX->(dbSeek(xFilial("FPX") + oJson:CodCheck + aFiles[nX]:ID_topico + aFiles[nX]:ID_Item))
								
								If FPX->(EOF())
									aadd(aRetorno, {oJson:CodCheck , "400", "nao encontrado"})
									lRet := .F.
								Else
									If lRet
										aadd(aRetorno, {oJson:CodCheck, "200", "CheckList alterado"})
										FPX->(dbGoto(RecNo()))
										FPX->(RecLock("FPX",.F.))
										FPX->FPX_STATIA := aFiles[nX]:Status_IA
										FPX->FPX_OBSIA  := aFiles[nX]:Obs_IA
										FPX->(MsUnlock())	
										If Len(aSx5) > 0//SE EXISTIR O EVENTO 097 EXECUTA O EVENT VIEWER
											If aFiles[nX]:Status_IA < "4" .And. FPX->FPX_RESPOS == "C "
												cMessagem += "Imagen verificada do checklist: "+alltrim(oJson:CodCheck) + CHR(13)+CHR(10)
												cMessagem += " Topico: " + aFiles[nX]:ID_topico + CHR(13)+CHR(10)
												cMessagem += " Identificador do item: " + aFiles[nX]:ID_Item + CHR(13)+CHR(10)
												cMessagem += " Descricao Item: " + POSICIONE("FPX",1,XFILIAL("FPX") + alltrim(oJson:CodCheck)+ aFiles[nX]:ID_topico + aFiles[nX]:ID_Item ,"FPX_NOMITE")+ CHR(13)+CHR(10)
												cMessagem += " Bem: " + alltrim(oJson:Bem) + CHR(13)+CHR(10) 
												cMessagem += " Nome Bem: " + POSICIONE("ST9",1,XFILIAL("ST9") + alltrim(oJson:Bem) ,"T9_NOME") +CHR(13)+CHR(10) 
												cMessagem += " Filial Contrato: " +  alltrim(oJson:FilContrato) + CHR(13)+CHR(10)
												cMessagem += " Tipo da operacao: " +  alltrim(oJson:type) + CHR(13)+CHR(10)
												cMessagem += " Observação da IA: " +  aFiles[nX]:Obs_IA + CHR(13)+CHR(10)
												cMessagem += " Status da IA: " +  aFiles[nX]:Status_IA + CHR(13)+CHR(10)
												cMessagem += " Descrição Status IA: " +  aFiles[nX]:desc_statu + CHR(13)+CHR(10)
												EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,"","Dados da IA para checklist",cMessagem,.T.)											
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
						Next
					Else
						aadd(aRetorno, { "", "401", "CheckList sem imagens analisadas. Informar um CheckList com imagens recebidas da I.A."})
					EndIf
				EndIf 
			EndIf
		Else
			aadd(aRetorno, { "", "401", "Credenciais invalidas, verifique o CNPJ cadastrado no Protheus"})
		EndIf
	Else
		aadd(aRetorno, { "", "401", "Formato do json invalido, verifique formatacao do frontend"})	
	EndIf

	ErrorBlock(bError)

	If empty(cRet) 
		nX := 0
		cRetorno := '"Resultado": ['
		For nX := 1 to len(aRetorno)
            If nCont > 0
                cRetorno += ','
            EndIf			
			cRetorno += '{'
			cRetorno += '"CheckList":"'+ aRetorno[nX,1] + '",'
			cRetorno += '"Status":"'    + aRetorno[nX,2] + '",'
			cRetorno += '"Descricao":"' + aRetorno[nX,3] + '"'
			cRetorno += '}'
			nCont++
		Next
		cRetorno += "],"
		cRetorno += '"Compilado":"'
		cRetorno += DtoS(aInfo[4])+'-'+aInfo[5]+'"'

		If empty(cRetorno) .or. file("\SYSTEM\L052E3.TXT")
			cRetorno := "422 - Nao foi processado nenhum checklist"
		EndIf
	EndIf

	If empty(cRet)
		cRet := "Processado."
	EndIf

	::SetResponse( Alltrim( FWhttpEncode( '{"Retorno":"'+cRet+'",'+ cRetorno +'}' ) ) )

Return .T.
