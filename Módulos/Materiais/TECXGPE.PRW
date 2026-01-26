#Include "TOTVS.CH"
#include "TECXGPE.CH"

Static aInsPer    := {}
Static cAdcIns    := "" //RA_ADCINS
Static cAdcPeri   := "" //RA_ADCPERI
Static cCodigoTec := ""
Static cInicioProc:= "Inicio Processamento - " //Inicio do processamento para o Log
Static cTime      := ""
Static nHrsPeri   := 0 //RA_PERICUL     
Static nHrsIns    := 0
Static dDataFim   := StoD("")
Static dDataIni   := StoD("")
Static cSRACC     := ""
Static lGsLog     := .F.
Static lSRAChange := .F.
Static lQryInsPer := .F.
Static lAltPeri   := .F.
Static lAltIns    := .F.
Static xGsMultFil := "Falso"
Static oLogGs     := Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecInsPer
Retorna um array com os dias para pagamento de Insalubridade ou Periculosidade de acordo com um período.

@param	cRot, string, Roteiro de cálculo
        cPeriodo, string, Período de cálculo

@return aRet, array, Array com as informações para pagamento

Exemplo de retorno:
aRet := {; 
            {"1", 01/04/25, 30/04/25, "1", 30, ""},; 
            {"2", 01/04/25, 15/04/25, "2", 20, "2"},;
            {"2", 16/04/25, 30/04/25, "3", 20, "2"};
            {X,Y,Z,W,K,I};
            }

onde:
X - Tipo de Adicional - "1" para periculosidade e "2" para insalubridade
Y - Data inicial da alocação
Z - Data final da alocação
W - Base de cálculo do adicional - retornar o código conforme opções disponíveis no cadastro de sindicato - Imagem A para Periculosidade e Imagem B para Insalubridade
K - Percentual do adicional - retornar o valor cadastrado no sindicato associado a CCT do funcionário - Imagem C
I - Grau de insalubridade - apenas quando o tipo de adicional for "2", informar o grau da insalubridade, sendo: "2" - Insalubridade mínima; "3" - Insalubridade média, "4" - Insalubridade máxima

@author jack.junior
@since	24/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TecInsPer(cRot, cPeriodo)
    Local aArea      := GetArea()
    Local aRet       := {}
    Local cAliasAgen := ""
    Local cCodTec    := ""
    Local cMsg       := ""
    Local cSindica   := ""
    Local lPerCCT    := .F.
    Local nX         := 0
    Local oQry       := Nil

    Default cRot     := ""
    Default cPeriodo := ""

    If !lQryInsPer
        lQryInsPer := .T.

        dDataIni := RCH->RCH_DTINI  //Variável Private RH 
        dDataFim := RCH->RCH_DTFIM  //Variável Private RH 

        //Ajusta as datas do periodo de acordo com periodo de ponto:
        UpdateDate()

        lPerCCT  := cAdcPeri == "2" //Igual a 2-Sim / Caso Periculosidade seja da SRA
        lInsCCT  := cAdcIns <> "1"  //Diferente de 1-Não / Caso Insalubridade seja da SRA
        cCodTec  := cCodigoTec
        cSindica := SRA->RA_SINDICA

        If !Empty(cCodTec)

            If lGsLog //Abre LOG:
                //Instancia um novo Objeto GsLog
                oLogGs := GsLog():new()

                oLogGs:addLog("Id001", Replicate("*",45))
                oLogGs:addLog("Id001", cInicioProc) //"Inicio Processamento - DATA-HORA"
                oLogGs:addLog("Id001", Replicate(" ",4)+"->")
            EndIf

            //Verifica admissão e demissão e ajusta as datas do periodo:
            cMsg := CheckAdmDem(cCodTec, SRA->RA_DEMISSA, SRA->RA_ADMISSA, @dDataIni, @dDataFim)

            If !Empty(dDataIni) .And. !Empty(dDataFim)

				// Realiza a Query das Agendas (caso não tenha cadastro SRA+CCT):
				If !lPerCCT .Or. !lInsCCT
					oQry := TecQryInPe(cCodTec, dDataIni, dDataFim, .T.)
					If !Empty(oQry) .And. ValType(oQry) == 'O'
						cAliasAgen := oQry:OpenAlias()
					EndIf
				EndIf

				// Retorna as Configurações para Periculosidade:
				aRetPer := TecPer(cCodTec, cSindica, dDataIni, dDataFim, lPerCCT, cAliasAgen)
				
				// Retorna as Configurações Para Insalubridade:
				aRetIns := TecIns(cCodTec, cSindica, dDataIni, dDataFim, lInsCCT, cAliasAgen)

				// Uni os Arrays para envio ao RH:
				aRet := mergeInsPer(aRetPer,aRetIns)

				// Fechamento da query e restauração:
				If !lPerCCT .Or. !lInsCCT
					(cAliasAgen)->(DbCloseArea())
					RestArea(aArea)
					
					oQry:Destroy()
					FwFreeObj(oQry)
				EndIf
			Else
				If lGsLog
					oLogGs:addLog("Id001", Replicate(" ",4)+cMsg)
				EndIf
            EndIf

            If lGsLog
                oLogGs:addLog("Id001", Replicate(" ",4)+Replicate("-",39))
                For nX := 1 To Len(aRet)
                    lInsalu := aRet[nX][1] == "2"
                    cCampo := IIF(lInsalu, "WY_BCALIN", "WY_BCALPE")
                    cBaseCalc := aRet[nX][4]
                    cDescCombo := AllTrim(X3Combo(cCampo,cBaseCalc))
                    oLogGs:addLog("Id001", Replicate(" ",6)+STR0012+": " + IIF(lInsalu, STR0020, STR0021)) //"Tipo de adicional: " "Insalubridade" "Periculosidade"
                    oLogGs:addLog("Id001", Replicate(" ",6)+STR0013+": " + DtoC(aRet[nX][2])) //"Data inicial: " 
                    oLogGs:addLog("Id001", Replicate(" ",6)+STR0014+": " + DtoC(aRet[nX][3])) //"Data final: " 
                    oLogGs:addLog("Id001", Replicate(" ",6)+STR0015+": "  + cDescCombo) //"Base de cálculo do adicional: "
                    oLogGs:addLog("Id001", Replicate(" ",6)+STR0016+": "  + AllTrim(Transform(aRet[nX][5], "@E 999,999.99"))+" %") //"Percentual do adicional: " 
                    If lInsalu
                        cGrauIns := aRet[nX][6]
                        oLogGs:addLog("Id001", Replicate(" ",6)+STR0017+": " + AllTrim(X3Combo("TFF_GRAUIN",cGrauIns))) //"Grau de insalubridade: " 
                    EndIf
                    oLogGs:addLog("Id001", Replicate(" ",6)+"Quantidade de dias: "+": "  + alltrim(str(aRet[nX][7]))) //"Quantidade de dias: " 
                    
                    If nX != Len(aRet)
                        oLogGs:addLog("Id001", Replicate(" ",4)+Replicate("-",39))
                    EndIf
                Next nX
                oLogGs:addLog("Id001", Replicate(" ",4)+Replicate("-",39))
            EndIf
            
            If lGsLog //Fecha Log e salva arquivo:
                oLogGs:addLog("Id001", Replicate(" ",4)+"<- ")
                oLogGs:addLog("Id001", Replicate(" ",4)+"Tempo de duração: "+ElapTime(ctime,time()))
                oLogGs:addLog("Id001", "Fim Processamento - " + FWTimeStamp(2)) //"Fim Processamento - DATA-HORA"
                oLogGs:addLog("Id001", Replicate("*",45))

                //O log é gerado na pasta /system/gestaoservicos do ambiente - Nome Exemplo: D MG 01 +InsalubridadePericulosidade+d mg 01 000053+20250530
                oLogGs:printLog("Id001", FwCodFil()+"-"+STR0010+"-"+cCodTec+"-"+DtoS(Date()))
            EndIf
        EndIf

    Else
        aRet := aClone(aInsPer)
    EndIf

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecPer
Retorna os dias que o Atendente tem direito à Periculosidade pelos dias trabalhados.

@return aRet

@author jack.junior
@since	24/09/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TecPer(cCodTec, cSindica, dDataIni, dDataFim, lPerCCT, cAliasAgen)
	Local aConfigABR  := {}
    Local aConfigERRO := {}
	Local aConfigTGY  := {}
    Local aConfPer    := {}
    Local aDataConfig := {}
    Local aRet        := {}
    Local cBaseCalc   := ""
    Local cCodCCT     := ""
    Local cFimConf    := ""
    Local cIniConf    := ""
    Local cMsg        := ""
    Local cPostoRef   := ""
    Local cTFFPer     := ""
    Local dDataRef    := stod("")
    Local lStop       := .F.
    Local nPercen     := 0
	
	If lPerCCT
		nPercen := 0
		/*Preenche a Periculosidade de acordo com a CCT
		para todo o Período se RA_ADCPERI for "sim":*/
		If !Empty(cSindica)
			//1- RCE_FILIAL+RCE_CODIGO
			cCodCCT := Posicione("RCE",1,xFilial("RCE",SRA->RA_FILIAL) + cSindica,"RCE_CCT")
			//1- WY_FILIAL+WY_CODIGO
			cBaseCalc := Posicione("SWY",1,xFilial("SWY",SRA->RA_FILIAL) + cCodCCT,"WY_BCALPE")
			//1- WY_FILIAL+WY_CODIGO
			nPercen := Posicione("SWY",1,xFilial("SWY",SRA->RA_FILIAL) + cCodCCT,"WY_PERPE")

			If nPercen > 0
				//Tipo, DataIni, DataFim, BaseCalculo, Percentual, GrauInsalubridade, Referencia de dias para proprocionalizar o pagamento
				AADD(aRet, {"1", ;      //Tipo 1-Periculosidade
                            dDataIni, ; // Data Inicial da Configuração
                            dDataFim, ; // Data Final da Configuração
                            cBaseCalc,; // Base de cálculo
                            nPercen, ;  // Percentual
                            "", ;       // Grau de insalubridade
                            30, ;       // Referencia de dias para proprocionalizar o pagamento
                            SRA->RA_CC})// Centro de Custo               
			EndIf
		EndIf
	Else	
        (cAliasAgen)->(DbGoTop())
		If (cAliasAgen)->(!Eof())
			While (cAliasAgen)->(!Eof()) .And. !lStop

				cPostoRef := (cAliasAgen)->(ABQ_CODTFF)
				lContinua := .T.
				nPos 	  := 0
				cIniConf  := ""
				cFimConf  := ""
                dDataRef  := sTod((cAliasAgen)->(TDV_DTREF))

				//Verifica se o posto da Agenda já esta salvo no array:
				If Len(aConfigTGY) > 0
					nPos := Ascan(aConfigTGY, {|x| x[9] == cPostoRef})
					If nPos > 0
						lContinua := .F.
					EndIf
				EndIf

                If lContinua
                    //Verifica se já foi adicionada agenda de manutenção do mesmo dia:
                    If Len(aConfigABR) > 0
                        nPos := Ascan(aConfigABR, {|x| x[9] == cPostoRef .And. x[2] == dDataRef .And. x[3] == dDataRef})
                        If nPos > 0
                            lContinua := .F.
                        EndIf
                    EndIf
                EndIf

                If lContinua
                    //Verifica se o posto ja foi verificado e deu erro:
                    If Len(aConfigERRO) > 0
                        nPos := Ascan(aConfigERRO, {|x| x[9] == cPostoRef})
                        If nPos > 0
                            lContinua := .F.
                        EndIf
                    EndIf
                EndIf

				//Verifica se paga Periculosidade:
				If lContinua
					//1- TFF_FILIAL+TFF_COD
					cTFFPer := Posicione("TFF",1,(cAliasAgen)->(ABQ_FILTFF) + cPostoRef,"TFF_PERICU")
					If cTFFPer <> '1'
						lContinua := .T.
					Else
						lContinua := .F.
					EndIf					
				EndIf

				If lContinua

					//Verifica se é agenda efetiva (tem TGY):
					If isAgenEfe(cCodTec, cPostoRef, dDataRef, dDataIni, dDataFim, @cIniConf, @cFimConf, @lStop)
						aDataConfig := {sToD(cIniConf),;             //01-DataIni
										"",;                 		 //02-GrauInsalubridade
										(cAliasAgen)->(ABS_FILIAL),; //03-Filial ABS
										(cAliasAgen)->(ABS_LOCAL),;  //04-Local ABS
										(cAliasAgen)->(ABS_BASEOP),; //05-Base Operacional
										(cAliasAgen)->(ABS_ESTADO),; //06-Estado
										(cAliasAgen)->(ABS_CODMUN),; //07-Municipio
										(cAliasAgen)->(RJ_FILIAL),;  //08-Filial SRJ
										(cAliasAgen)->(RJ_FUNCAO),;  //09-Função
										(cAliasAgen)->(ABS_CCUSTO),; //10-Centro de Custo
										(cAliasAgen)->(ABS_FILCC)}   //11-Filial Centro de Custo
						//Inicia Nova Configuração de Periculosidade se houver:
						aConfPer := OpenConfig(aDataConfig, "1")
						//Fecha a configuração de Periculosidade:
						CloseConfig(@aConfPer, sToD(cFimConf), @aConfigTGY, cCodTec, cPostoRef, @aConfigERRO)						
					Else
						aDataConfig := {dDataRef,;//01-DataIni
										"",;                 		 //02-GrauInsalubridade
										(cAliasAgen)->(ABS_FILIAL),; //03-Filial ABS
										(cAliasAgen)->(ABS_LOCAL),;  //04-Local ABS
										(cAliasAgen)->(ABS_BASEOP),; //05-Base Operacional
										(cAliasAgen)->(ABS_ESTADO),; //06-Estado
										(cAliasAgen)->(ABS_CODMUN),; //07-Municipio
										(cAliasAgen)->(RJ_FILIAL),;  //08-Filial SRJ
										(cAliasAgen)->(RJ_FUNCAO),;  //09-Função
										(cAliasAgen)->(ABS_CCUSTO),; //10-Centro de Custo
										(cAliasAgen)->(ABS_FILCC)}   //11-Filial Centro de Custo
						//Inicia Nova Configuração de Periculosidade se houver:
						aConfPer := OpenConfig(aDataConfig, "1")
						//Fecha a configuração de Periculosidade:
						CloseConfig(@aConfPer, dDataRef, @aConfigABR, cCodTec, cPostoRef, @aConfigERRO)
					EndIf

				EndIf
					
				(cAliasAgen)->(DbSkip())
			EndDo

			// Junta as Configurações de EFETIVO e MANUTENÇÕES:
			aRet := mergeConfs(aConfigTGY, aConfigABR)
		Else
            If lGsLog
			    cMsg := STR0001+" "+cCodTec+" "+STR0002+" "+DtoC(dDataIni)+" "+STR0003+" "+DtoC(dDataFim)+"." //"Não foram encontradas agendas atendidas para o Atendente X entre Y e Z."
                oLogGs:addLog("Id001", Replicate(" ",4)+cMsg)
			EndIf
		EndIf

		If Len(aRet) > 0
			aRet := JoinRanges(aRet)
		EndIf
	EndIf

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecIns
Retorna os dias que o Atendente tem direito à Insalubridade pelos dias trabalhados.

@return aRet

@author jack.junior
@since	24/09/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TecIns(cCodTec, cSindica, dDataIni, dDataFim, lInsCCT, cAliasAgen)
	Local aConfigABR  := {}
    Local aConfigERRO := {}
	Local aConfigTGY  := {}
	Local aConfIns    := {}
    Local aDataConfig := {}
    Local aRet        := {}
    Local cBaseCalc   := ""
    Local cCodCCT     := ""
    Local cFimConf    := ""
    Local cIniConf    := ""
    Local cMsg        := ""
    Local cPostoRef   := ""
	Local cTFFGrauIn  := ""
    Local cTFFIns     := ""
    Local dDataRef    := stod("")
    Local lStop       := .F.
    Local nPercen     := 0
	
	If lInsCCT
		nPercen := 0
		/*Preenche a Insalubridade de acordo com a CCT
		para todo o Período se RA_ADCINS for diferente de "não":*/
		If !Empty(cSindica)
			//1- RCE_FILIAL+RCE_CODIGO
			cCodCCT := Posicione("RCE",1,xFilial("RCE",SRA->RA_FILIAL) + cSindica,"RCE_CCT")
			//1- WY_FILIAL+WY_CODIGO
			cBaseCalc := Posicione("SWY",1,xFilial("SWY",SRA->RA_FILIAL) + cCodCCT,"WY_BCALIN")
			If cAdcIns == "2" //2=Insalubridade Mínima;
				nPercen := Posicione("SWY",1,xFilial("SWY",SRA->RA_FILIAL) + cCodCCT,"WY_PINSMI")
			ElseIf cAdcIns == "3" //3=Insalubridade Média;
				nPercen := Posicione("SWY",1,xFilial("SWY",SRA->RA_FILIAL) + cCodCCT,"WY_PINSME")
			ElseIf cAdcIns == "4" //4=Insalubridade Máxima;
				nPercen := Posicione("SWY",1,xFilial("SWY",SRA->RA_FILIAL) + cCodCCT,"WY_PINSMA")
			EndIf

			If nPercen > 0
				AADD(aRet, {"2", ;      //Tipo 2-Periculosidade
                            dDataIni, ; // Data Inicial da Configuração
                            dDataFim, ; // Data Final da Configuração
                            cBaseCalc, ;// Base de cálculo
                            nPercen, ;  // Percentual
                            cAdcIns, ;  // Grau de insalubridade
                            30, ;       // Referencia de dias para proprocionalizar o pagamento
                            SRA->RA_CC})// Centro de Custo           
			EndIf
		EndIf
	Else	
        (cAliasAgen)->(DbGoTop())
		If (cAliasAgen)->(!Eof())
			While (cAliasAgen)->(!Eof()) .And. !lStop

				cPostoRef := (cAliasAgen)->(ABQ_CODTFF)
				lContinua := .T.
				nPos 	  := 0
				cIniConf  := ""
				cFimConf  := ""
                dDataRef  := sTod((cAliasAgen)->(TDV_DTREF))

				//Verifica se o posto da Agenda já esta salvo no array:
				If Len(aConfigTGY) > 0
					nPos := Ascan(aConfigTGY, {|x| x[9] == cPostoRef})
					If nPos > 0
						lContinua := .F.
					EndIf
				EndIf

                If lContinua
                    //Verifica se já foi adicionada agenda de manutenção do mesmo dia:
                    If Len(aConfigABR) > 0
                        nPos := Ascan(aConfigABR, {|x| x[9] == cPostoRef .And. x[2] == dDataRef .And. x[3] == dDataRef})
                        If nPos > 0
                            lContinua := .F.
                        EndIf
                    EndIf
                EndIf

                If lContinua
                    //Verifica se o posto ja foi verificado e deu erro:
                    If Len(aConfigERRO) > 0
                        nPos := Ascan(aConfigERRO, {|x| x[9] == cPostoRef})
                        If nPos > 0
                            lContinua := .F.
                        EndIf
                    EndIf
                EndIf

				//Verifica se paga Periculosidade:
				If lContinua
					//1- TFF_FILIAL+TFF_COD
					cTFFIns := Posicione("TFF",1,(cAliasAgen)->(ABQ_FILTFF) + (cAliasAgen)->(ABQ_CODTFF),"TFF_INSALU")
					cTFFGrauIn := Posicione("TFF",1,(cAliasAgen)->(ABQ_FILTFF) + (cAliasAgen)->(ABQ_CODTFF),"TFF_GRAUIN")
					If cTFFIns <> '1'
						lContinua := .T.
					Else
						lContinua := .F.
					EndIf					
				EndIf

				If lContinua

					//Verifica se é agenda efetiva (tem TGY):
					If isAgenEfe(cCodTec, cPostoRef, dDataRef, dDataIni, dDataFim, @cIniConf, @cFimConf, @lStop)
						aDataConfig := {sToD(cIniConf),;			 //01-DataIni
										cTFFGrauIn,;				 //02-GrauInsalubridade
										(cAliasAgen)->(ABS_FILIAL),; //03-Filial ABS
										(cAliasAgen)->(ABS_LOCAL),;  //04-Local ABS
										(cAliasAgen)->(ABS_BASEOP),; //05-Base Operacional
										(cAliasAgen)->(ABS_ESTADO),; //06-Estado
										(cAliasAgen)->(ABS_CODMUN),; //07-Municipio
										(cAliasAgen)->(RJ_FILIAL),;  //08-Filial SRJ
										(cAliasAgen)->(RJ_FUNCAO),;  //09-Função
										(cAliasAgen)->(ABS_CCUSTO),; //10-Centro de Custo
										(cAliasAgen)->(ABS_FILCC)}   //11-Filial Centro de Custo
						//Inicia Nova Configuração de Periculosidade se houver:
						aConfIns := OpenConfig(aDataConfig, "2")
						//Fecha a configuração de Periculosidade:
						CloseConfig(@aConfIns, sToD(cFimConf), @aConfigTGY, cCodTec, cPostoRef, @aConfigERRO)						
					Else
						aDataConfig := {dDataRef,;//01-DataIni
										cTFFGrauIn,;				 //02-GrauInsalubridade
										(cAliasAgen)->(ABS_FILIAL),; //03-Filial ABS
										(cAliasAgen)->(ABS_LOCAL),;  //04-Local ABS
										(cAliasAgen)->(ABS_BASEOP),; //05-Base Operacional
										(cAliasAgen)->(ABS_ESTADO),; //06-Estado
										(cAliasAgen)->(ABS_CODMUN),; //07-Municipio
										(cAliasAgen)->(RJ_FILIAL),;  //08-Filial SRJ
										(cAliasAgen)->(RJ_FUNCAO),;  //09-Função
										(cAliasAgen)->(ABS_CCUSTO),; //10-Centro de Custo
										(cAliasAgen)->(ABS_FILCC)}   //11-Filial Centro de Custo
						//Inicia Nova Configuração de Periculosidade se houver:
						aConfIns := OpenConfig(aDataConfig, "2")
						//Fecha a configuração de Periculosidade:
						CloseConfig(@aConfIns, dDataRef, @aConfigABR, cCodTec, cPostoRef, @aConfigERRO)
					EndIf

				EndIf
					
				(cAliasAgen)->(DbSkip())
			EndDo

			// Junta as Configurações de EFETIVO e MANUTENÇÕES:
			aRet := mergeConfs(aConfigTGY, aConfigABR)
		Else
            If lGsLog
			    cMsg := STR0001+" "+cCodTec+" "+STR0002+" "+DtoC(dDataIni)+" "+STR0003+" "+DtoC(dDataFim)+"." //"Não foram encontradas agendas atendidas para o Atendente X entre Y e Z."
                oLogGs:addLog("Id001", Replicate(" ",4)+cMsg)
			EndIf
		EndIf

		If Len(aRet) > 0
			aRet := JoinRanges(aRet)
		EndIf
	EndIf

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecQryInPe
Realiza a query dos dias trabalhados de um funcionário em um período

@param	cFilFun, string, Filial do Funcionário
        cMatFun, string, Matrícula do Funcionário
        dIniDate, date, Data inicial da pesquisa
        dEndDate, date, Data final da pesquisa
        lInPeOnly, logical, se pesquisa apenas postos com Insalubridade ou Periculosidade

@return oQuery, objetct, Objeto da query

@author jack.junior
@since	24/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TecQryInPe(cCodTec, dIniDate, dEndDate, lInPeOnly)
Local cQuery    := ""
Local nQuery    := 1
Local oQuery    := Nil

Default lInPeOnly := .T.

If !Empty(cCodTec) .And. !Empty(dIniDate) .And. !Empty(dEndDate)

    cQuery := "SELECT TDV.TDV_CODABB, "
    cQuery +=        "TDV.TDV_DTREF, "
    cQuery +=        "ABS.ABS_FILIAL, "
    cQuery +=        "ABS.ABS_LOCAL, "
    cQuery +=        "ABS.ABS_BASEOP, "
    cQuery +=        "ABS.ABS_ESTADO, "
    cQuery +=        "ABS.ABS_CODMUN, "
    cQuery +=        "ABS.ABS_FILCC, "
    cQuery +=        "ABS.ABS_CCUSTO, "
    cQuery +=        "SRJ.RJ_FILIAL, "
    cQuery +=        "SRJ.RJ_FUNCAO, "
    If !lInPeOnly
        cQuery +=    "ABB.ABB_TIPOMV, "
        cQuery +=    "ABB.ABB_DTINI, "
        cQuery +=    "ABB.ABB_HRINI, "
        cQuery +=    "ABB.ABB_DTFIM, "
        cQuery +=    "ABB.ABB_HRFIM, "
    EndIf
    cQuery +=        "ABQ.ABQ_CODTFF, ABQ.ABQ_FILTFF "
    // Agendas
    cQuery += " FROM ? ABB "
    // TDV - TDV_FILIAL+TDV_CODABB
    cQuery += " INNER JOIN ? TDV ON "
    If !xGsMultFil
        cQuery += " TDV.TDV_FILIAL = ? "
    Else
        cQuery += " ? "
    EndIf
    cQuery += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "
    cQuery += " AND TDV.TDV_DTREF BETWEEN ? AND ? "
    cQuery += " AND TDV.D_E_L_E_T_ = ' ' "
    // Regra de Apontamento TFF - ABQ_FILIAL+ABQ_CONTRT+ABQ_ITEM+ABQ_ORIGEM
    cQuery += " INNER JOIN ? ABQ ON "
    If !xGsMultFil
        cQuery += " ABQ.ABQ_FILIAL = ? "
    Else
        cQuery += " ? "
    EndIf
    cQuery += " AND ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL"
    cQuery += " AND ABQ.D_E_L_E_T_  = ' ' "
    // Função SRJ - RJ_FILIAL+RJ_FUNCAO
    cQuery += " INNER JOIN ? SRJ ON "
    If !xGsMultFil
        cQuery += " SRJ.RJ_FILIAL = ? "
    Else
        cQuery += " ? "
    EndIf    
	cQuery += " AND SRJ.RJ_FUNCAO = ABQ.ABQ_FUNCAO "
    cQuery += " AND SRJ.D_E_L_E_T_=' ' "
    // Cadastro de Local - ABS_FILIAL+ABS_LOCAL
    cQuery += " INNER JOIN ? ABS ON "
    If !xGsMultFil
        cQuery += " ABS.ABS_FILIAL = ? "
    Else
        cQuery += " ? "
    EndIf
    cQuery += " AND ABS.ABS_LOCAL = ABB.ABB_LOCAL "
    cQuery += " AND ABS.D_E_L_E_T_=' ' "
    // Agendas (WHERE)
    cQuery += " WHERE " 
    If !xGsMultFil
        cQuery += " ABB.ABB_FILIAL = ? AND "
    EndIf
    cQuery += " ABB.ABB_CODTEC  = ? "
    cQuery += " AND ABB.ABB_CHEGOU = 'S' AND ABB.ABB_ATENDE = '1' "
    If lInPeOnly
        cQuery += " AND ABB.ABB_ATIVO = '1' "
    EndIf
    cQuery += " AND ABB.ABB_LOCAL <> ' ' "
    cQuery += " AND ABB.ABB_ADIENV = 'F' "
    cQuery += " AND ABB.D_E_L_E_T_ = ' ' "
    // Agendas (ORDER BY)
    cQuery += " ORDER BY TDV.TDV_DTREF"

    cQuery := ChangeQuery(cQuery)

    oQuery := FwExecStatement():New(cQuery)

    // Agendas
    oQuery:SetUnsafe( nQuery++, RetSQLName("ABB") )
    // TDV - Data de referencia
    oQuery:SetUnsafe( nQuery++, RetSQLName("TDV") )
    If !xGsMultFil
        oQuery:SetString( nQuery++, xFilial("TDV") )
    Else
        oQuery:SetUnsafe( nQuery++, FWJoinFilial("ABB" , "TDV" , "ABB", "TDV", .T.) )
    EndIf   
    oQuery:SetDate( nQuery++, dIniDate )
    oQuery:SetDate( nQuery++, dEndDate )
    // Regra de Apontamento TFF
    oQuery:SetUnsafe( nQuery++, RetSQLName("ABQ") )
    If !xGsMultFil
        oQuery:SetString( nQuery++, xFilial("ABQ") )
    Else
        oQuery:SetUnsafe( nQuery++, FWJoinFilial("ABB" , "ABQ" , "ABB", "ABQ", .T.) )
    EndIf
    // Função
    oQuery:SetUnsafe( nQuery++, RetSQLName("SRJ") )
    If !xGsMultFil
        oQuery:SetString( nQuery++, xFilial("SRJ") )
    Else
        oQuery:SetUnsafe( nQuery++, FWJoinFilial("ABQ" , "SRJ" , "ABQ", "SRJ", .T.) )
    EndIf
    // Local
    oQuery:SetUnsafe( nQuery++, RetSQLName("ABS") )
    If !xGsMultFil
        oQuery:SetString( nQuery++, xFilial("ABS") )
    Else
        oQuery:SetUnsafe( nQuery++, FWJoinFilial("ABB" , "ABS" , "ABB", "ABS", .T.) )
    EndIf
    // Agendas (WHERE)

    If !xGsMultFil
        oQuery:SetString( nQuery++, xFilial("ABB") )
    EndIf
    oQuery:SetString( nQuery++, cCodTec )
EndIf

Return oQuery

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CloseConfig
Fecha a configuração para envio ao RH definindo Data fim, Base de cálculo e Percentual da Insalubridade 
ou Periculosidade e populando o Array de retorno

@param	aConfig, array, Array da configuração (Por Referencia)
        dEndDate, date, Data final da configuração
        aRet, array, Retorno da configuração (Por Referencia)

@author jack.junior
@since	24/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CloseConfig(aConfig, dEndDate, aRet, cCodTec, cPosto, aErro)
Local cMsg := ""

Default aConfig := {}
Default cPosto := ""

//Fecha a Configuração de Insalubridade:
If Len(aConfig) > 0
    //Preenche a data final da configuração de Insalubridade
    aConfig[3] := dEndDate

    //Popula no array a base de calculo e percentual da Insalubridade
    lRet := SetCalcData(@aConfig,@cMsg,aConfig[1],cPosto)
    If lRet
        If aConfig[1] == "3" // Gratificação Por Função
            AADD(aRet, {aConfig[2], ; // Data Inicial da Configuração
                        aConfig[3], ; // Data Final da Configuração
                        aConfig[4], ; // Função
                        aConfig[5], ; // Código da CCT
                        0, ;          // Referencia de dias para proprocionalizar o pagamento
                        aConfig[14] })// Centro de Custo
        Else //Insalubridade/Periculosidade
            AADD(aRet, {aConfig[1], ; // Tipo (1-Insalubridade / 2-Periculosidade)
                        aConfig[2], ; // Data Inicial da Configuração
                        aConfig[3], ; // Data Final da Configuração
                        aConfig[4], ; // Base de cálculo
                        aConfig[5], ; // Percentual
                        aConfig[6], ; // Grau de insalubridade (apenas para Insalubridade)
                        0, ;          // Referencia de dias para proprocionalizar o pagamento
                        aConfig[14], ;// Centro de Custo
                        cPosto})      // Posto (Código TFF)
        EndIf
    Else
        If aConfig[1] <> "3" // Gratificação Por Função
            AADD(aErro, {aConfig[1], ; // Tipo (1-Insalubridade / 2-Periculosidade)
                        aConfig[2], ; // Data Inicial da Configuração
                        aConfig[3], ; // Data Final da Configuração
                        aConfig[4], ; // Base de cálculo
                        aConfig[5], ; // Percentual
                        aConfig[6], ; // Grau de insalubridade (apenas para Insalubridade)
                        0, ;          // Referencia de dias para proprocionalizar o pagamento
                        aConfig[14], ;// Centro de Custo
                        cPosto})      // Posto (Código TFF)
        EndIf
        If lGsLog .And. !Empty(cMsg) .And. aConfig[1] == "3" // Gratificação Por Função
            GsLogGPE(aRet,cCodTec,cMsg,aConfig[1])
        EndIf
    EndIf
EndIf

aConfig := {}

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetCalcData
Pesquisa na CCT a base de cálculo e Percentual da insalubridade ou periculosidade e seta no array do parametro.

@return lRet - True caso o percentual seja maior que 0

@author jack.junior
@since	24/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function SetCalcData(aConfig,cMsg,cType,cPosto)
Local cAliasCCT  := ""
Local cBaseOp    := ""
Local cCodCCT    := ""
Local cCodFunc   := ""
Local cEstado    := ""
Local cFilCCT    := ""
Local cFilFunc   := ""
Local cFilLocal  := ""
Local cLocal     := ""
Local cMunicipio := ""
Local cQry       := ""
Local cTipo      := ""
Local cWhereAA0  := ""
Local cWhereREI  := ""
Local cWhereRI4  := ""
Local cWhereRUK  := ""
Local lRet       := .F.
Local oQuery     := Nil

Default aConfig := {}

If Len(aConfig) > 0

    If cType == "1"
        cTipo := STR0021 //"Periculosidade"
    ElseIf cType == "2"
        cTipo := STR0020 //"Insalubridade"
    ElseIf cType == "3"
        cTipo := STR0011 //"GratificacaoFuncao"
    Endif

    cFilLocal	:= aConfig[7]
    cLocal		:= aConfig[8]
    cBaseOp		:= aConfig[9]
    cEstado     := aConfig[10]
    cMunicipio  := aConfig[11]
    cFilFunc	:= aConfig[12]
    cCodFunc 	:= aConfig[13]

    If !xGsMultFil
        cWhereAA0 := "AA0.AA0_FILIAL = '" + xFilial("AA0") + "'"
        cWhereREI := "REI.REI_FILIAL = '" + xFilial("REI") + "'"
        cWhereRI4 := "RI4.RI4_FILIAL = '" + xFilial("RI4") + "'"
        cWhereRUK := "RUK.RUK_FILIAL = '" + xFilial("RUK") + "'"
    Else
        cWhereAA0 := FWJoinFilial("AA0" , "ABS" , "AA0", "ABS", .T.)
        cWhereREI := FWJoinFilial("REI" , "AA0" , "REI", "AA0", .T.)
        cWhereRI4 := FWJoinFilial("RI4" , "REI" , "RI4", "REI", .T.)
        cWhereRUK := FWJoinFilial("RUK" , "RI4" , "RUK", "RI4", .T.)
    Endif

    If !Empty(aConfig[9]) //Verifica se tem Base operacional:

        cQry := " SELECT COALESCE(RI4.RI4_FILCCT,'') RI4_FILCCT, "
        cQry += " COALESCE(RI4.RI4_CODCCT,'') RI4_CODCCT "
        cQry += "FROM ? ABS "
        // Base Operacional -- AA0_FILIAL+AA0_CODIGO
        cQry += " INNER JOIN ? AA0 ON ? AND "
        cQry +=     " AA0.AA0_CODIGO = ABS.ABS_BASEOP AND "
        cQry +=     " AA0.D_E_L_E_T_ = ' '"
        // CCT X Base Operacional -- REI_FILIAL+REI_FILAA0+REI_CODAA0                                                                                                                                REI_FILIAL+REI_FILAA0+REI_CODAA0
        cQry += " INNER JOIN ? REI ON ? AND "
        cQry +=     " REI.REI_FILAA0 = AA0.AA0_FILIAL AND "
        cQry +=     " REI.REI_CODAA0 = AA0.AA0_CODIGO AND "
        cQry +=     " REI.D_E_L_E_T_ = ' ' "
        // CCT x Funções -- RI4_FILCCT+RI4_CODCCT
        cQry += " INNER JOIN ? RI4 ON ? AND "
        cQry +=     " RI4.RI4_FILCCT = REI.REI_FILCCT AND "
        cQry +=     " RI4.RI4_CODCCT = REI.REI_CODCCT AND "
        cQry +=     " RI4.RI4_FILSRJ = ? AND "
        cQry +=     " RI4.RI4_CODSRJ = ? AND "
        cQry +=     " RI4.D_E_L_E_T_ = ' '"
        // Municípios x CCT -- RUK_FILIAL+RUK_FILCCT+RUK_CODCCT+RUK_ESTADO+RUK_CODMUN
        cQry += " INNER JOIN ? RUK ON ? AND "
        cQry +=     " RUK.RUK_FILCCT = RI4.RI4_FILCCT AND "
        cQry +=     " RUK.RUK_CODCCT = RI4.RI4_CODCCT AND "
        cQry +=     " RUK.RUK_ESTADO = ABS.ABS_ESTADO AND "
        cQry +=     " RUK.RUK_CODMUN = ABS.ABS_CODMUN AND "
        cQry +=     " RUK.D_E_L_E_T_ = ' '"
        // Local de Atendimento -- ABS_FILIAL+ABS_LOCAL
        cQry += " WHERE ABS.ABS_FILIAL = ? AND "
        cQry +=     " ABS.ABS_LOCAL  = ? AND "
        cQry +=     " ABS.ABS_BASEOP = ? AND "
        cQry +=     " ABS.D_E_L_E_T_ = ' '"

        cQry := ChangeQuery(cQry)

        oQuery := FwExecStatement():New(cQry)

        oQuery:setUnsafe( 1, RetSqlName( "ABS" ) )
        oQuery:setUnsafe( 2, RetSqlName( "AA0" ) )
        oQuery:setUnsafe( 3, cWhereAA0 )
        oQuery:setUnsafe( 4, RetSqlName( "REI" ) )
        oQuery:setUnsafe( 5, cWhereREI )
        oQuery:setUnsafe( 6, RetSqlName( "RI4" ) )
        oQuery:setUnsafe( 7, cWhereRI4 )
        oQuery:setString(  8, cFilFunc )
        oQuery:setString(  9, cCodFunc )
        oQuery:setUnsafe( 10, RetSqlName( "RUK" ) )
        oQuery:setUnsafe( 11, cWhereRUK )
        oQuery:setString( 12, cFilLocal )
        oQuery:setString( 13, cLocal )
        oQuery:setString( 14, cBaseOp )

    Else
        cQry := " SELECT COALESCE(RI4.RI4_FILCCT,'') RI4_FILCCT, "
        cQry += " COALESCE(RI4.RI4_CODCCT,'') RI4_CODCCT "
		cQry += " FROM ? RI4 "
        // Municípios x CCT -- RUK_FILIAL+RUK_FILCCT+RUK_CODCCT+RUK_ESTADO+RUK_CODMUN
        cQry += " INNER JOIN ? RUK ON ? "
        cQry +=     " AND RUK.RUK_FILCCT = RI4.RI4_FILCCT "
        cQry +=     " AND RUK.RUK_CODCCT = RI4.RI4_CODCCT "
        cQry +=     " AND RUK.RUK_ESTADO = ? "
        cQry +=     " AND RUK.RUK_CODMUN = ? "
        cQry +=     " AND RUK.D_E_L_E_T_ = ' ' "
        // CCT x Funções -- RI4_FILSRJ+RI4_CODSRJ
        cQry += " WHERE RI4.RI4_FILIAL = ? "
        cQry +=     " AND RI4.RI4_FILSRJ = ? "
        cQry +=     " AND RI4.RI4_CODSRJ = ? "
        cQry +=     " AND RI4.D_E_L_E_T_ = ' ' "

        cQry := ChangeQuery(cQry)

        oQuery := FwExecStatement():New(cQry)

        oQuery:SetUnsafe( 1, RetSqlName( "RI4" ) )
        oQuery:SetUnsafe( 2, RetSqlName( "RUK" ) )
        oQuery:SetUnsafe( 3, cWhereRUK )
        oQuery:setString( 4, cEstado )
        oQuery:setString( 5, cMunicipio )
        oQuery:SetString( 6, xFilial("RI4") )
        oQuery:setString( 7, cFilFunc )
        oQuery:setString( 8, cCodFunc )

    EndIf

    cAliasCCT := oQuery:OpenAlias()

    If !(cAliasCCT)->(EOF())
        cFilCCT := (cAliasCCT)->RI4_FILCCT
        cCodCCT := (cAliasCCT)->RI4_CODCCT
    Else
        cMsg := cTipo+":"+STR0024+": "+cCodFunc //"Função não cadastrada em uma Convenção Coletiva de Trabalho."
        If cType <> "3"
            If lGsLog
                cMsg := cTipo+": ERRO - Posto "+cPosto+" dia de:"+dtoc(aConfig[2])+" dia ate:"+dtoc(aConfig[3])+" "+STR0024+": "+cCodFunc //"Função não cadastrada em uma Convenção Coletiva de Trabalho."
                oLogGs:addLog("Id001", Replicate(" ",4)+cMsg)
			EndIf
        EndIf
    EndIf

    (cAliasCCT)->(DbCloseArea())
    oQuery:Destroy()
    FwFreeObj(oQuery)

    If !Empty(cCodCCT)
        If aConfig[1] == "3"
            aConfig[5] := cCodCCT
            lRet := .T.
        Else
            //CCT - WY_FILIAL+WY_CODIGO
            cQry := " SELECT SWY.WY_BCALPE, SWY.WY_PERPE, SWY.WY_BCALIN, SWY.WY_PINSMI, SWY.WY_PINSME, SWY.WY_PINSMA "
            cQry += " FROM ? SWY "
            cQry += " WHERE SWY.WY_FILIAL = ? "
            cQry +=     " AND SWY.WY_CODIGO = ? "
            cQry +=     " AND SWY.D_E_L_E_T_ = ' ' "

            cQry := ChangeQuery(cQry)

            oQuery := FwExecStatement():New(cQry)

            oQuery:SetUnsafe( 1, RetSqlName( "SWY" ) )
            oQuery:setString( 2, cFilCCT )
            oQuery:setString( 3, cCodCCT )

            cAliasCCT := oQuery:OpenAlias()

            If !(cAliasCCT)->(EOF())
                If cType == "1" //Tipo 1 - Periculosidade
                    aConfig[4] := (cAliasCCT)->(WY_BCALPE) //BaseCalculo
                    aConfig[5] := (cAliasCCT)->(WY_PERPE)  //Percentual
                ElseIf cType == "2" //Tipo 2 - Insalubridade
                    aConfig[4] := (cAliasCCT)->(WY_BCALIN) //BaseCalculo
                    If aConfig[6] == "2" //2=Minima
                        aConfig[5] := (cAliasCCT)->(WY_PINSMI)  //Percentual
                    ElseIf aConfig[6] == "3" //3=Media
                        aConfig[5] := (cAliasCCT)->(WY_PINSME)  //Percentual
                    ElseIf aConfig[6] == "4" //4=Maxima
                        aConfig[5] := (cAliasCCT)->(WY_PINSMA)  //Percentual
                    EndIf
                EndIf
            EndIf

            (cAliasCCT)->(DbCloseArea())
            oQuery:Destroy()
            FwFreeObj(oQuery)

            //Se houver percentual para base de Cálculo maior que 0:
            If aConfig[5] > 0
                lRet := .T.
            Else
                cMsg := STR0022+" "+cTipo+" "+STR0023+"." //"Valor de percentual da" Periculosidade ou Insalubridade "zerado"

                If cType <> "3"
                    If lGsLog
                        cMsg := cTipo+": ERRO - Posto "+cPosto+" dia de:"+dtoc(aConfig[2])+" dia ate:"+dtoc(aConfig[3])+" "+STR0022+" "+cTipo+" "+STR0023+"." //"Valor de percentual da" Periculosidade ou Insalubridade "zerado"
                        oLogGs:addLog("Id001", Replicate(" ",4)+cMsg)
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
EndIf


Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OpenConfig
Forma um array de configuração para envio ao RH - pagamento de insalubridade/periculosidade

@param	cType, string, Tipo de configuração "1"=Periculosidade / "2"=Insalubridade / "3"=Função/CCT
        aData, array, Array com os dados para compor a configuração
        Exemplo:{sToD(cAliasAgen->(TDV_DTREF)),; //01-DataIni
                 cAliasAgen->(TFF_GRAUIN),;      //02-GrauInsalubridade
                 cAliasAgen->(ABS_FILIAL),;      //03-Filial ABS
                 cAliasAgen->(ABS_LOCAL),;       //04-Local ABS
                 cAliasAgen->(ABS_BASEOP),;      //05-Base Operacional
                 cAliasAgen->(ABS_ESTADO),;      //06-Estado
                 cAliasAgen->(ABS_CODMUN),;      //07-Municipio
                 cAliasAgen->(RJ_FILIAL),;       //08-Filial SRJ
                 cAliasAgen->(RJ_FUNCAO)}        //09-Função
                 cAliasAgen->(ABS_CCUSTO),;      //10-Centro de Custo
                 cAliasAgen->(ABS_FILCC)}        //11-Filial Centro de Custo

@return aConfig, array, Array formado da configuração

@author jack.junior
@since	24/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function OpenConfig(aData, cType)
Local aConfig := {}
Local cCC     := ""

If Len(aData) > 0

    //Verifica se Filial do CC é a mesma da SRA ou se CC compartilhada, e se o CC da ABS está preenchido:
    If (Empty(aData[11]) .Or. aData[11] == SRA->RA_FILIAL) .And. !Empty(aData[10])
        cCC := aData[10]
    Else
        cCC := cSRACC
    EndIf


    If cType == "3"
        //Configuração da função/CCT 
        aConfig := {cType, ;    // 01-Tipo-"3"=Função/0CCT
                    aData[1], ; // 02-DataIni
                    Nil, ;      // 03-DataFim
                    aData[9], ; // 04-Codigo da Função
                    "", ;       // 05-CCT codigo
                    cType, ;    // 06-GrauInsalubridade - Apenas tipo "2"
                    aData[3], ; // 07-Filial ABS
                    aData[4], ; // 08-Local ABS
                    aData[5], ; // 09-Base Operacional
                    aData[6],;  // 10-Estado
                    aData[7], ; // 11-Municipio
                    aData[8],;  // 12-Filial SRJ
                    aData[9],;  // 13-Função
                    cCC}        // 14-Centro de Custo
    Else
        //Configuração da Periculosidade/Insalubridade
        aConfig := {cType, ;     // 01-Tipo-"1"=Periculosidade / "2"=Insalubridade
                    aData[1], ; // 02-DataIni
                    Nil, ;      // 03-DataFim
                    Nil, ;      // 04-BaseCalculo
                    0, ;        // 05-Percentual
                    IIF(cType=="2",aData[2],""), ; //06-GrauInsalubridade - Apenas tipo "2"
                    aData[3], ; // 07-Filial ABS
                    aData[4], ; // 08-Local ABS
                    aData[5], ; // 09-Base Operacional
                    aData[6],;  // 10-Estado
                    aData[7], ; // 11-Municipio
                    aData[8],;  // 12-Filial SRJ
                    aData[9],;  // 13-Função
                    cCC}        // 14-Centro de Custo
    EndIf
EndIf

Return aConfig

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JoinRanges
Função para unir intervalos contínuos com dados de configuração iguais

@param	aData, array, Array com os dados da configuração

@return aResult, array, Array formatado da configuração

@author jack.junior
@since	25/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function JoinRanges(aData)
Local aResult   := {}
Local lUnicIn   := .F.
Local lUnicPer  := .F.
Local nI        := 0
Local nJ        := 0
Local nX        := 0
Local nResIn    := 0
Local nResPer   := 0
Local nQtdDias  := 0

//Ordena por Tipo (insalubridade/Periculosidade) e Data Inicial/Final:
ASort(aData,,, {|x, y| x[1] < y[1] .Or. (x[1] == y[1] .And. x[2] < y[2]) .Or. (x[1] == y[1] .And. x[2] == y[2] .And. x[3] < y[3]) })

nI := 1
While nI <= Len(aData)
    // Tenta agrupar com próximos registros válidos
    nJ := nI + 1

    If !Empty(aData[nI])
        While nJ <= Len(aData)
            
            If !Empty(aData[nJ])
                // Verifica se tem a mesma configuração:
                If aData[nI][1] == aData[nJ][1] .And.;  // Tipo
                    aData[nI][4] == aData[nJ][4] .And.; // Base cálculo
                    aData[nI][5] == aData[nJ][5] .And.; // Percentual
                    aData[nI][6] == aData[nJ][6] .And.; // Insalubridade
                    (aData[nI][3] == aData[nJ][2] .Or. (aData[nJ][2]-aData[nI][3] == 1) ) // Data final atual = inicial do próximo ou Data final um dia antes da inicial do próximo

                    // Junta os períodos e remove o que juntou:
                    aData[nI][3] := aData[nJ][3]
                    aData[nJ] := {}
                EndIf
            EndIf

            nJ++ // Avança para verificar o próximo
        EndDo
    EndIf

    nI++ // Avança para verificar o próximo
EndDo

For nX := 1 To Len(aData)
    If !Empty(aData[nX])
        nQtdDias := (aData[nX,3]-aData[nX,2]) +1
        nQtdDias := IIF(nQtdDias>31,31,nQtdDias)
        aData[nX,7] := nQtdDias //Referencia de dias para proprocionalizar o pagamento

        AAdd(aResult, aData[nX])
    EndIf
Next nX

For nX := 1 To Len(aResult)
    If aResult[nX][1] == "1"
        If nResIn > 0
            lUnicIn := .F.
        Else
            nResIn := nX
            lUnicIn := .T.
        EndIf
    endIf
    If aResult[nX][1] == "2"
        If nResPer > 0
            lUnicPer := .F.
        Else
            nResPer := nX
            lUnicPer := .T.
        EndIf
    endIf
Next nX

If lUnicPer
    If aResult[nResPer][2] == dDataIni .AND. aResult[nResPer][3] == dDataFim
        aResult[nResPer][7] := 30
    EndIf
EndIf

If lUnicIn
    If aResult[nResIn][2] == dDataIni .AND. aResult[nResIn][3] == dDataFim
        aResult[nResIn][7] := 30
    EndIf
EndIf

Return aResult

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCodTec
Retorna o código do técnico AA1 de acordo com a matricula e filial SRA

@param	cFil, string, Filial do Funcionário
        cMat, string, Matrícula do Funcionário

@return cCodTec, string, Código do Técnico

@author jack.junior
@since	26/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetCodTec(cFil, cMat)
Local cAliasTrb := ""
Local cCodTec   := ""
Local cQuery    := ""
Local oQuery    := Nil

If !Empty(cMat)
    cQuery := " SELECT AA1_CODTEC "
    cQuery += " FROM ? AA1 "
    cQuery += " WHERE AA1.AA1_FILIAL = ? "
    cQuery += " AND AA1.AA1_FUNFIL = ? "
    cQuery += " AND AA1.AA1_CDFUNC = ? "
    cQuery += " AND AA1.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    oQuery := FwExecStatement():New(cQuery)

    oQuery:SetUnsafe( 1, RetSQLName("AA1") )
    oQuery:SetString( 2, xFilial("AA1",cFil) )
    oQuery:SetString( 3, cFil )
    oQuery:SetString( 4, cMat )

    cAliasTrb := oQuery:OpenAlias()

    If (cAliasTrb)->(!EOF())
        cCodTec := (cAliasTrb)->AA1_CODTEC
    EndIf

    (cAliasTrb)->(DbCloseArea())

    oQuery:Destroy()
    FwFreeObj(oQuery)
EndIf

Return cCodTec

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckDateTGY
Verifica se o atendente tem uma TGY além do range de configuração de Periculosidade ou Insalubridade e ajusta a data.

@param	cCodTec, string, Filial do Funcionário
        cCodTFF, string, Matrícula do Funcionário
        dLimite, date, Data limite que pode chegar (Máximo ou mínimo)
        dAtual, date, Data atual da configuração
        cTipo, string, "ASC" - verifica ascendentemente a data em relação a TGY
                       "DESC" - verifica descendentemente a data em relação a TGY

@return cCodTec, string, Código do Técnico

@author jack.junior
@since	26/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CheckDateTGY(cCodTec, cCodTFF, dLimite, dAtual, cTipo)
Local cAliasTGY := ""
Local cQuery    := ""
Local dFimTGY   := sToD("")
Local dIniTGY   := sTod("")
Local dNewDate  := sTod("")
Local lDo       := .T.
Local oQuery    := Nil
Local nQuery    := 1

Default cTipo := "ASC"

If !Empty(cCodTFF) .And. !Empty(dLimite) .And. !Empty(dAtual)
    cQuery := " SELECT TGY.TGY_DTINI, TGY.TGY_ULTALO "
    cQuery += " FROM ? TGY "
    cQuery += " WHERE TGY.TGY_ULTALO <> ' '
    If !xGsMultFil
        cQuery += " AND TGY.TGY_FILIAL = ? "
    EndIf
    cQuery += " AND TGY.TGY_ATEND = ? "
    cQuery += " AND TGY.TGY_CODTFF = ? "
    cQuery += " AND TGY.TGY_DTINI <= ? "
    cQuery += " AND TGY.TGY_ULTALO >= ? "
    cQuery += " AND TGY.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    oQuery := FwExecStatement():New(cQuery)

    oQuery:SetUnsafe( nQuery++, RetSQLName("TGY") )
    If !xGsMultFil
        oQuery:SetString( nQuery++, xFilial("TGY") )
    EndIf
    oQuery:SetString( nQuery++, cCodTec )
    oQuery:SetString( nQuery++, cCodTFF )
    oQuery:SetDate( nQuery++, dAtual )
    oQuery:SetDate( nQuery++, dAtual )

    cAliasTGY := oQuery:OpenAlias()

    If (cAliasTGY)->(!EOF())
        dIniTGY := sToD((cAliasTGY)->TGY_DTINI)
        dFimTGY := sTod((cAliasTGY)->TGY_ULTALO)
        dNewDate := dAtual
        WHILE lDo
            If cTipo == "DESC"
                //dLimite mínimo que pode chegar pra tras
                //dAtual inicial da configuração atual
                If ((dNewDate >= dIniTGY) .And. dNewDate-1 >= dLimite)
                    dNewDate--
                Else
                    lDo := .F.
                EndIf
            ElseIf cTipo == "ASC"
                //dLimite maximo que pode chegar para frente
                //dAtual final da configuração atual
                If (dNewDate <= dFimTGY .And. dNewDate+1 <= dLimite)
                    dNewDate++
                Else
                    lDo := .F.
                EndIf
            EndIf
        EndDo
    EndIf

    (cAliasTGY)->(DbCloseArea())

    oQuery:Destroy()
    FwFreeObj(oQuery)
EndIf

Return dToS(dNewDate)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecAlocFun
Retorna um array com os dias de alocação em certa Função/CCT

@param	cPeriodo, string, Período de cálculo

@return aRet, array, Array com as informações

Exemplo de retorno:
aRet := {; 
            {01/04/25, 30/04/25, "00002", "00000001"},; 
            {01/04/25, 15/04/25, "00003", "00000001"},;
            {16/04/25, 30/04/25, "00002", "00000001"};
            {X,Y,Z,W};
        }

onde:
X - Data inicial da alocação
Y - Data final da alocação
Z - Função SRA
W - Código da CCT

@author jack.junior
@since	27/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TecAlocFun(cPeriodo)
Local aArea         := GetArea()
Local aConfFun      := {} 
Local aDataConfig   := {}
Local aRet          := {}
Local cAliasAgen    := ""
Local cCodTec       := ""
Local cDate         := ""
Local cFilFun       := ""
Local cFimConf      := ""
Local cIniConf      := ""
Local cMatFun       := ""
Local cMsg          := ""
Local cPostoRef     := ""
Local cFuncaoRef    := ""
Local oQry          := Nil

dDataIni := RCH->RCH_DTINI  //Variável Private RH 
dDataFim := RCH->RCH_DTFIM  //Variável Private RH 

UpdateDate()

VarStaticIni()

cFilFun  := SRA->RA_FILIAL  //Posicionado SRA no RH 
cMatFun  := SRA->RA_MAT     //Posicionado SRA no RH 
cCodTec  := cCodigoTec

If !Empty(cCodTec)
    //Verifica admissão e demissão e ajusta as datas do periodo:
    cMsg := CheckAdmDem(cCodTec, SRA->RA_DEMISSA, SRA->RA_ADMISSA, @dDataIni, @dDataFim)

    If !Empty(dDataIni) .And. !Empty(dDataFim)

        oQry := TecQryInPe(cCodTec, dDataIni, dDataFim, .F.)

        If !Empty(oQry) .And. ValType(oQry) == 'O'
            cAliasAgen := oQry:OpenAlias()

            If (cAliasAgen)->(!Eof())
                While (cAliasAgen)->(!Eof())

                    If cPostoRef != (cAliasAgen)->(ABQ_CODTFF) .And. (Empty(cPostoRef) .Or. checkNewTFF(cFuncaoRef,;
                                                                                                        (cAliasAgen)->(RJ_FILIAL)+(cAliasAgen)->(RJ_FUNCAO),;
                                                                                                        (cAliasAgen)->(TDV_DTREF),;
                                                                                                        (cAliasAgen)->(ABB_TIPOMV),;
                                                                                                        Stod((cAliasAgen)->(ABB_DTINI)),;
                                                                                                        (cAliasAgen)->(ABB_HRINI),;
                                                                                                        Stod((cAliasAgen)->(ABB_DTFIM)),;
                                                                                                        (cAliasAgen)->(ABB_HRFIM)))

                        //Ajusta as Datas finais da configuração caso tenha TGY:
                        If !Empty(cFimConf)
                            If Stod((cAliasAgen)->(TDV_DTREF))-Stod(cFimConf) > 1
                                cDate := CheckDateTGY(cCodTec, cPostoRef, Stod((cAliasAgen)->(TDV_DTREF))-1, Stod(cFimConf), "ASC")
                                If !Empty(cDate)
                                    cFimConf := cDate
                                EndIf
                            EndIf
                        EndIf

                        //Fecha a configuração de Função/CCT:
                        CloseConfig(@aConfFun, sToD(cFimConf), @aRet, cCodTec)

                        //Verifica TGY da primeira configuração:
                        If Empty(cPostoRef) .And. sToD((cAliasAgen)->(TDV_DTREF)) > dDataIni
                            //Verifica a TGY:
                            cIniConf := CheckDateTGY(cCodTec, (cAliasAgen)->(ABQ_CODTFF), dDataIni, Stod((cAliasAgen)->(TDV_DTREF)), "DESC")
                            If Empty(cIniConf)
                                cIniConf := (cAliasAgen)->(TDV_DTREF)
                            EndIf
                        Else //Ajusta as datas Iniciais das configurações de acordo com a TGY:
                            If Len(aRet) > 0 .And. (StoD((cAliasAgen)->(TDV_DTREF))-aRet[Len(aRet)][2]) > 1
                                cIniConf := CheckDateTGY(cCodTec, (cAliasAgen)->(ABQ_CODTFF), aRet[Len(aRet)][2]+1, Stod((cAliasAgen)->(TDV_DTREF)), "DESC")
                                If Empty(cIniConf)
                                    cIniConf := (cAliasAgen)->(TDV_DTREF)
                                EndIf
                            Else
                                cIniConf := (cAliasAgen)->(TDV_DTREF)
                            EndIf
                        EndIf

                        cPostoRef := (cAliasAgen)->(ABQ_CODTFF)
                        cFuncaoRef := (cAliasAgen)->(RJ_FILIAL)+(cAliasAgen)->(RJ_FUNCAO)

                        aDataConfig := {sToD(cIniConf),;             //01-DataIni
                                        (cAliasAgen)->(ABQ_CODTFF),; //02-GrauInsalubridade
                                        (cAliasAgen)->(ABS_FILIAL),; //03-Filial ABS
                                        (cAliasAgen)->(ABS_LOCAL),;  //04-Local ABS
                                        (cAliasAgen)->(ABS_BASEOP),; //05-Base Operacional
                                        (cAliasAgen)->(ABS_ESTADO),; //06-Estado
                                        (cAliasAgen)->(ABS_CODMUN),; //07-Municipio
                                        (cAliasAgen)->(RJ_FILIAL),;  //08-Filial SRJ
                                        (cAliasAgen)->(RJ_FUNCAO),;  //09-Função
                                        (cAliasAgen)->(ABS_CCUSTO),; //10-Centro de Custo
                                        (cAliasAgen)->(ABS_FILCC)}   //11-Filial Centro de Custo

                        aConfFun := OpenConfig(aDataConfig, "3")
                    EndIf

                    cFimConf := (cAliasAgen)->(TDV_DTREF)

                    (cAliasAgen)->(DbSkip())
                EndDo

                //Ajusta as Datas finais da configuração caso tenha TGY:
                If !Empty(cFimConf)
                    If dDataFim-Stod(cFimConf) > 0
                        cDate := CheckDateTGY(cCodTec, cPostoRef, dDataFim, Stod(cFimConf), "ASC")
                        If !Empty(cDate)
                            cFimConf := cDate
                        EndIf
                    EndIf
                EndIf

                //Fecha as configurações dos ultimos registros se houver:
                CloseConfig(@aConfFun, sToD(cFimConf), @aRet, cCodTec)
            Else
                cMsg := STR0001+" "+cCodTec+" "+STR0002+" "+DtoC(dDataIni)+" "+STR0003+" "+DtoC(dDataFim)+"." //"Não foram encontradas agendas atendidas para o Atendente X entre Y e Z."
            EndIf

            (cAliasAgen)->(DbCloseArea())
            RestArea(aArea)
            
            oQry:Destroy()
            FwFreeObj(oQry)

        EndIf

        If Len(aRet) > 0
            aRet := RangesJoin(aRet)
        EndIf

    EndIf
    
    If lGsLog
        GsLogGPE(aRet,cCodTec,cMsg,"3")
    EndIf
EndIf

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RangesJoin
Função para unir intervalos contínuos com dados de configuração iguais

@param	aData, array, Array com os dados da configuração

@return aResult, array, Array formatado da configuração

@author jack.junior
@since	27/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function RangesJoin(aData)
Local aResult   := {}
Local nI        := 0
Local nJ        := 0
Local nX        := 0
Local nQtdDias  := 0

//Data Inicial/Final:
ASort(aData,,, {|x, y| (x[1] < y[1]) .Or. (x[1] == y[1] .And. x[2] < y[2]) })

nI := 1
While nI <= Len(aData)
    // Tenta agrupar com próximos registros válidos
    nJ := nI + 1

    If !Empty(aData[nI])
        While nJ <= Len(aData)
            
            If !Empty(aData[nJ])
                // Verifica se tem a mesma configuração:
                If aData[nI][3] == aData[nJ][3] .And.;  // Função
                    aData[nI][4] == aData[nJ][4] .And.; // CCT
                    (aData[nI][2] == aData[nJ][1] .Or. (aData[nJ][1]-aData[nI][2] == 1) ) // Data final atual = inicial do próximo ou Data final um dia antes da inicial do próximo

                    // Junta os períodos e remove o que juntou:
                    aData[nI][2] := aData[nJ][2]
                    aData[nJ] := {}
                EndIf
            EndIf

            nJ++ // Avança para verificar o próximo
        EndDo
    EndIf

    nI++ // Avança para verificar o próximo
EndDo

For nX := 1 To Len(aData)
    If !Empty(aData[nX])
        nQtdDias := (aData[nX,2]-aData[nX,1]) +1
        nQtdDias := IIF(nQtdDias>31,31,nQtdDias)
        aData[nX,5] := nQtdDias //Referencia de dias para proprocionalizar o pagamento

        AAdd(aResult, aData[nX])
    EndIf
Next nX

If Len(aResult) == 1
    If aResult[1][1] == dDataIni .AND. aResult[1][2] == dDataFim
        aResult[1][5] := 30
    EndIf
EndIf

Return aResult

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckAdmDem
Valida as datas de Admissão e Demissão do Funcionário e Ajusta as datas do período caso necessário

@param	dDemissa, string, Data de demissão do funcionário
        dAdmissa, string, Data de admissão do funcionário
        dData1, date, Data Inicial do Período
        dData2, date, Data Finak do Período

@return aResult, array, Array formatado da configuração

@author jack.junior
@since	27/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CheckAdmDem(cCodTec, dDemissa, dAdmissa, dData1, dData2)
Local cMsg := ""
Local lRet := .T.

//Verifica demissão e ajusta a data fim do período:
If !Empty(dDemissa)
    If dDemissa < dData1
        cMsg := STR0004+" "+cCodTec+" "+STR0005+" "+DtoC(dDemissa)+" "+STR0006+" "+DtoC(dData1)+" "+STR0007+" "+DtoC(dData2)+"." //"Atendente X demitido em Y antes do periodo de cálculo Y a Z.
        dData1 := sTod("")
        dData2 := sTod("")
        lRet := .F.
    ElseIf dDemissa < dData2 .And. dDemissa >= dData1
        dData2 := dDemissa
    EndIf
EndIf

//Verifica admissão e ajusta a data fim do período:
If !Empty(dAdmissa) .And. lRet
    If dAdmissa > dData2
        cMsg := STR0004+" "+cCodTec+" "+STR0008+" "+DtoC(dDemissa)+" "+STR0009+" "+DtoC(dData1)+" "+STR0007+" "+DtoC(dData2)+"." //"Atendente X admitido em Y após do periodo de cálculo Y a Z.
        dData1 := sTod("")
        dData2 := sTod("") 
    ElseIf dAdmissa < dData2 .And. dAdmissa >= dData1
        dData1 := dAdmissa
    EndIf
EndIf

Return cMsg

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fAlocFunGS
Chamada da função com nome definido pelo RH
Retorna um array com os dias de alocação em certa Função/CCT

@author jack.junior
@since	29/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Function fAlocFunGS(cPeriodo)

Return TecAlocFun(cPeriodo)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fAlocPerInsGS
Chamada da função com nome definido pelo RH
Retorna um array com os dias para pagamento de Insalubridade ou Periculosidade de acordo com um período.

@author jack.junior
@since	29/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Function fAlocPerInsGS(cRot, cPeriodo)

Return TecInsPer(cRot, cPeriodo)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GsLogGPE
Gera na pasta /system/gestaoservicos do ambiente um Log de processamento

@return

@author jack.junior
@since	30/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GsLogGPE(aRet, cCodTec, cMsg, cType)
Local cCampo     := ""
Local cDescCombo := ""
Local cId        := "Id001"
Local cNome      := IIF(cType=="3",STR0011,STR0010) //"GratificacaoFuncao" "Insalubridade-Periculosidade" 
Local cNomeArq   := FwCodFil()+"-"+cNome+"-"+cCodTec+"-"+DtoS(Date())
Local lInsalu    := .F.
Local cBaseCalc  := ""
Local cGrauIns   := ""
Local nX         := 0
Local oGsLog     := Nil

//Instancia um novo Objeto GsLog
oGsLog := GsLog():new()

oGsLog:addLog(cId, Replicate("*",45))
oGsLog:addLog(cId, cInicioProc) //"Inicio Processamento - DATA-HORA"
oGsLog:addLog(cId, Replicate(" ",4)+"->")

If Len(aRet) > 0 .And. Empty(cMsg) .And. cType <> "3"
    For nX := 1 To Len(aRet)
        lInsalu := aRet[nX][1] == "2"
        cCampo := IIF(lInsalu, "WY_BCALIN", "WY_BCALPE")
        cBaseCalc := aRet[nX][4]
        cDescCombo := AllTrim(X3Combo(cCampo,cBaseCalc))
        oGsLog:addLog(cId, Replicate(" ",6)+STR0012+": " + IIF(lInsalu, STR0020, STR0021)) //"Tipo de adicional: " "Insalubridade" "Periculosidade"
        oGsLog:addLog(cId, Replicate(" ",6)+STR0013+": " + DtoC(aRet[nX][2])) //"Data inicial: " 
        oGsLog:addLog(cId, Replicate(" ",6)+STR0014+": " + DtoC(aRet[nX][3])) //"Data final: " 
        oGsLog:addLog(cId, Replicate(" ",6)+STR0015+": "  + cDescCombo) //"Base de cálculo do adicional: "
        oGsLog:addLog(cId, Replicate(" ",6)+STR0016+": "  + AllTrim(Transform(aRet[nX][5], "@E 999,999.99"))+" %") //"Percentual do adicional: " 
        If lInsalu
            cGrauIns := aRet[nX][6]
            oGsLog:addLog(cId, Replicate(" ",6)+STR0017+": " + AllTrim(X3Combo("TFF_GRAUIN",cGrauIns))) //"Grau de insalubridade: " 
        EndIf
        oGsLog:addLog(cId, Replicate(" ",6)+"Quantidade de dias: "+": "  + alltrim(str(aRet[nX][7]))) //"Quantidade de dias: " 
        
        If nX != Len(aRet)
            oGsLog:addLog(cId, Replicate(" ",4)+Replicate("-",39))
        EndIf
    Next nX
ElseIf Len(aRet) > 0 .And. Empty(cMsg)
    For nX := 1 To Len(aRet)
        oGsLog:addLog(cId, Replicate(" ",6)+STR0013+": " + DtoC(aRet[nX][1])) //"Data inicial: "
        oGsLog:addLog(cId, Replicate(" ",6)+STR0014+": " + DtoC(aRet[nX][2])) //"Data final: "
        oGsLog:addLog(cId, Replicate(" ",6)+STR0018+": "  + aRet[nX][3]) //"Função: "
        oGsLog:addLog(cId, Replicate(" ",6)+STR0019+": "  + aRet[nX][4]) //"Código da CCT: " 
        oGsLog:addLog(cId, Replicate(" ",6)+"Quantidade de dias: "+": "  + alltrim(str(aRet[nX][5]))) //"Quantidade de dias: " 

        If nX != Len(aRet)
            oGsLog:addLog(cId, Replicate(" ",4)+Replicate("-",39))
        EndIf
    Next nX
ElseIf !Empty(cMsg)
    oGsLog:addLog(cId, Replicate(" ",4)+cMsg)
EndIf

oGsLog:addLog(cId, Replicate(" ",4)+"<- ")
oGsLog:addLog(cId, Replicate(" ",4)+"Tempo de duração: "+ElapTime(ctime,time()))
oGsLog:addLog(cId, "Fim Processamento - " + FWTimeStamp(2)) //"Fim Processamento - DATA-HORA"
oGsLog:addLog(cId, Replicate("*",45))

//O log é gerado na pasta /system/gestaoservicos do ambiente - Nome Exemplo: D MG 01 +InsalubridadePericulosidade+d mg 01 000053+20250530
oGsLog:printLog(cId, cNomeArq)

Return



//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecCheckAd
Seta os campos de adicionais de Insalubridade e Periculosidade
da SRA caso estejam como "não" para o cálculo funcionar

@author jack.junior
@since	07/07/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecCheckAd()

ResetStatic()

cAdcPeri := SRA->RA_ADCPERI
cAdcIns  := SRA->RA_ADCINS
nHrsPeri := SRA->RA_PERICUL
nHrsIns  := SRA->RA_INSMAX

VarStaticIni()

If !Empty(cCodigoTec)

    If cAdcPeri == "1" .Or. cAdcIns == "1"

        aInsPer := TecInsPer()

        If Len(aInsper) > 0
            lAltPeri := ASCAN(aInsper, {|a| a[1] == '1'}) > 0
            lAltIns := ASCAN(aInsper, {|a| a[1] == '2'}) > 0
            If RecLock("SRA", .F.) //Alteração	

                lSRAChange := .T.
                
                If lAltPeri
                    SRA->RA_ADCPERI := "2" //2=Sim;
                    SRA->RA_PERICUL := 220 //horas de periculosidade
                EndIf
                If lAltIns
                    SRA->RA_ADCINS := "2" //2=Insalubridade Mínima;
                    SRA->RA_INSMAX := 220 //horas de insalubridade
                EndIf

                MsUnLock() //Confirma e finaliza a operação
            EndIf
        EndIf
    EndIf
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecResetAd
Seta os campos da SRA para os valores iniciais antes do cálculo.

@author jack.junior
@since	07/07/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecResetAd()
Local cCodTec := ""

cCodTec := cCodigoTec

If !Empty(cCodTec)
    If lSRAChange
        If RecLock("SRA", .F.) //Alteração	
        
            If lAltPeri
                SRA->RA_ADCPERI := cAdcPeri
                SRA->RA_PERICUL := nHrsPeri
            EndIf
            If lAltIns
                SRA->RA_ADCINS := cAdcIns 
                SRA->RA_INSMAX := nHrsIns
            EndIf

            MsUnLock() //Confirma e finaliza a operação
        EndIf
    EndIf
EndIf

ResetStatic()

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ResetStatic
Reseta as variáveis Staticas

@author jack.junior
@since	07/07/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ResetStatic()

//Limpeza de Staticas
cAdcPeri    := "" //RA_ADCPERI
cAdcIns     := "" //RA_ADCINS
cCodigoTec  := ""
cInicioProc := "Inicio Processamento - "
cTime       := ""
nHrsPeri    := 0 //RA_PERICUL
nHrsIns     := 0
lSRAChange  := .F.
lQryInsPer  := .F.
aInsPer     := {}
lAltPeri    := .F.
lAltIns     := .F.
lGsLog      := .F.
//xGsMultFil  := .F. Essa não reseta para manter configuração para o usuário.

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UpdateDate
Atualiza as datas dDataIni e dDataFim de acordo com getpaponta.
Leva em consideração os dias do periodo de Ponto com o mes e ano do periodo de Folha.

@author jack.junior
@since	07/07/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function UpdateDate()
Local cDiaFPonto := ""
Local cDiaIPonto := ""
Local cFimAno    := ""
Local cIniAno    := ""
Local cMesFPonto := ""
Local cMesIPonto := ""
Local cPerAponta := ""
Local dDataFimAux:= StoD("")
Local dDataIniAux:= StoD("")
Local dFimPonto  := StoD("")
Local dIniPonto  := StoD("")

cPerAponta := getpaponta(cFilAnt)
If !PerCompleto( @cPerAponta )
    cPerAponta := GetMv( "MV_PONMES" , NIL , "" )
EndIf
If !Empty(cPerAponta)

    dIniPonto := StoD(SubStr(cPerAponta, 1,8))
    dFimPonto := StoD(SubStr(cPerAponta, 10,8))

    //Ajusta as datas caso o Período de Ponto não esteja em conformidade com o de Folha:
    If dFimPonto < dDataIni .Or. dFimPonto > dDataFim
        //Dia inicial do Periodo de Ponto
        cDiaIPonto := Day2Str(dIniPonto)
        //Dia Final do Periodo de Ponto
        cDiaFPonto := Day2Str(dFimPonto)

        //Lógica de Mês e Ano
        If cDiaIPonto > cDiaFPonto
            //Reduz 1 Mês da data Inicial:
            cMesIPonto := Month2Str(MonthSub(dDataIni,1))
            //Caso seja janeiro voltando pra dezembro, reduz 1 do ano:
            If Month2Str(dDataIni) == "01"
                cIniAno := Year2Str(YearSub(dDataIni,1))
            Else
                cIniAno := Year2Str(dDataIni)
            EndIf
            cMesFPonto := Month2Str(dDataFim)
            cFimAno := Year2Str(dDataFim)
        Else
            cMesIPonto := Month2Str(dDataIni)
            cMesFPonto := Month2Str(dDataFim)
            cIniAno := Year2Str(dDataIni)
            cFimAno := Year2Str(dDataFim)
        EndIf

        //Forma a data de acordo com Dia do Ponto e Mes/Ano da Folha:
        dDataIniAux := GetDtoDate(cDiaIPonto+cMesIPonto+cIniAno)
        dDataFimAux := GetDtoDate(cDiaFPonto+cMesFPonto+cFimAno)

        //Tratamento Para Fevereiro:
        If Empty(dDataIniAux)
            cDiaIPonto := Day2Str(Last_Day(Stod(cIniAno+cMesIPonto+"01")))
        EndIf
        If Empty(dDataFimAux)
            cDiaFPonto := Day2Str(Last_Day(Stod(cFimAno+cMesFPonto+"01")))
        EndIf

        //Forma a data de acordo com Dia do Ponto e Mes/Ano da Folha:
        dDataIniAux := GetDtoDate(cDiaIPonto+cMesIPonto+cIniAno)
        dDataFimAux := GetDtoDate(cDiaFPonto+cMesFPonto+cFimAno)

        //Seta as Datas Staticas:
        dDataIni := dDataIniAux
        dDataFim := dDataFimAux
    Else
        //Seta as Datas Staticas igual ao período de Ponto.
        dDataIni := dIniPonto
        dDataFim := dFimPonto
    EndIf
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VarStaticIni
Inicializa as variáveis Staticas da rotina

@author jack.junior
@since	05/08/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function VarStaticIni()

cCodigoTec := GetCodTec(SRA->RA_FILIAL, SRA->RA_MAT)
cSRACC := Posicione("SRA",1,SRA->RA_FILIAL+SRA->RA_MAT,"RA_CC") // (1) RA_FILIAL+RA_MAT+RA_NOME

//Seta variável do Log
lGsLog := SuperGetMV('MV_GSLOG',,.F.)

If lGsLog
    cInicioProc += FWTimeStamp(2)
    cTime := time()
EndIf

//Verifica MultFilial apenas 1 vez ao abrir a rotina:
If ValType(xGsMultFil) == "C"
    xGsMultFil := SuperGetMV("MV_GSMSFIL",,.F.) .AND. ;
                (LEN(STRTRAN(FwModeAccess("AA1",1) + FwModeAccess("AA1",2) + FwModeAccess("AA1",3), "E")) > ;
                LEN(STRTRAN(FwModeAccess("SRA",1) + FwModeAccess("SRA",2) + FwModeAccess("SRA",3), "E")))
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} checkNewTFF
Verifica se o posto que o atendente foi tem função diferente.
Caso tenha, verifica se esse dia é uma substituição ou uma FT.
Caso seja Faz lógica para saber se tem direito a receber gratificação do posto novo ou do posto que ele ja estava.

@author jack.junior
@since	15/08/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function checkNewTFF(cFuncBefore, cFuncAfter, cDate, cAbbTipoMV, dAbbDtIni, cAbbHrini, dAbbDtFim, cAbbHrFim)
Local lisManut := .F.
Local lRet := .F.

If cFuncBefore <> cFuncAfter
    // verifica se esse dia é uma substituição ou uma Folga Trabalhada:
    lisManut := isAbbFT(cAbbTipoMV) .Or. (at190dSubs(cCodigoTec, dAbbDtIni, cAbbHrini, dAbbDtFim, cAbbHrFim) > 0)

    // A agenda que to vendo é manutenção ?
    If lisManut
        //O posto que ele tava antes tem gratificação ?
        If hasFuncGrat(cFuncBefore, StoD(cDate))
            lRet := .F.
        Else
            //O posto que ele foi recebe gratificação ?
            If hasFuncGrat(cFuncAfter, StoD(cDate))
                lRet := .T.
            EndIf    
        EndIf
    Else
        lRet := .T.
    EndIf
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} isAbbFT
Verifica se o Tipo de Movimentação é uma Folga Trabalhada.

@author jack.junior
@since	15/08/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function isAbbFT(cAbbTipoMV)
Local lRet := .F.
Local cTcuAlocEF := ""

// TCU_FILIAL+TCU_COD
cTcuAlocEF := Posicione("TCU",1,xFilial("TCU") + cAbbTipoMV,"TCU_ALOCEF")

If ValType(cTcuAlocEF) == 'C'
    If cTcuAlocEF == '2' // Aloc Efetivo = Não (FT)
        lRet := .T.
    EndIf
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} hasFuncGrat
Verifica se a função em determinado dia recebe Gratificação por função.

@author jack.junior
@since	15/08/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function hasFuncGrat(cFilFuncao, dDataRef)
Local lRet := .F.

DbSelectArea("RUJ")
If RUJ->(DbSeek(cFilFuncao))
    While RUJ->(!Eof() .and. RUJ_FILIAL + RUJ_FUNCAO == cFilFuncao )
        If AnoMes(RUJ->RUJ_DTINI) > AnoMes(dDataRef) .or. (!Empty(RUJ->RUJ_DTFIM) .and. AnoMes(RUJ->RUJ_DTFIM) < AnoMes(dDataRef) )
            RUJ->(DbSkip())
            Loop 
        Else
            lRet := .T.
            Exit
        EndIf
    EndDo		
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} mergeConfs
Une os arrays de configuração efetiva (que tem TGY) com os dias com manutenção.

Se houver dias de manutenção que colidem com de agenda efetiva esses são ignorados.

@return aFinal

@author jack.junior
@since	24/09/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function mergeConfs(aConfigTGY, aConfigABR)
    Local aAbr     := {}
    Local aFinal   := {}
    Local aTgy     := {}
    Local dDataAbr := Stod("")
    Local dFimTgy  := Stod("")
    Local dIniTgy  := Stod("")
    Local lDentro  := .F.
    Local nI       := 0
    Local nJ       := 0

    // Garante arrays válidos:
    Default aConfigTGY := {}
    Default aConfigABR := {}

    // Passo 1: adiciona tudo do TGY no resultado:
    For nI := 1 To Len(aConfigTGY)
        AAdd(aFinal, aConfigTGY[nI])
    Next

    // Passo 2: verifica os do ABR:
    For nI := 1 To Len(aConfigABR)
        aAbr     := aConfigABR[nI]
        dDataAbr := aAbr[2]
        lDentro  := .F.

        // procura range no TGY que contemple a data do ABR:
        For nJ := 1 To Len(aConfigTGY)
            aTgy    := aConfigTGY[nJ]
            dIniTgy := aTgy[2]
            dFimTgy := aTgy[3]

            If dDataAbr >= dIniTgy .And. dDataAbr <= dFimTgy
                lDentro := .T.
                Exit
            EndIf
        Next

        // Se não encontrou range correspondente na TGY, adiciona no final:
        If !lDentro
            AAdd(aFinal, aAbr)
        EndIf
    Next

Return aFinal

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} mergeInsPer
Une os arrays de configuração de Periculosidade e Insalubridade para retorno ao RH

@return aFinal

@author jack.junior
@since	24/09/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function mergeInsPer(aArray1, aArray2)
    Local aFinal := {}
    Local nI	 := 0

    Default aArray1 := {}
    Default aArray2 := {}

    // Copia Array1
    For nI := 1 To Len(aArray1)
        AAdd(aFinal, aArray1[nI])
    Next

    // Copia Array2
    For nI := 1 To Len(aArray2)
        AAdd(aFinal, aArray2[nI])
    Next

Return aFinal

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} isAgenEfe
Verifica se o dia de ABB é EFETIVA (tem TGY). Caso tenha Retorna TRUE e retorna cIniConf e cFimConf por referencia.

Retorna por referencia lStop TRUE caso toda o periodo sendo validado pertencer a uma agenda efetiva.

@return lRet

@author jack.junior
@since	24/09/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function isAgenEfe(cCodTec, cCodTFF, dDateRef, dDataIni, dDataFim, cIniConf, cFimConf, lStop)
    Local cAliasTGY := ""
    Local cQuery    := ""
    Local lRet      := .F.
    Local nQuery    := 1
    Local oQuery    := Nil

    If !Empty(cCodTFF) .And. !Empty(cCodTec) .And. !Empty(dDateRef) 
        cQuery := " SELECT TGY.TGY_DTINI, TGY.TGY_ULTALO "
        cQuery += " FROM ? TGY "
        cQuery += " WHERE TGY.TGY_ULTALO <> ' '
        If !xGsMultFil
            cQuery += " AND TGY.TGY_FILIAL = ? "
        EndIf
        cQuery += " AND TGY.TGY_ATEND = ? "
        cQuery += " AND TGY.TGY_CODTFF = ? "
        cQuery += " AND TGY.TGY_DTINI <= ? "
        cQuery += " AND TGY.TGY_ULTALO >= ? "
        cQuery += " AND TGY.D_E_L_E_T_ = ' ' "

        cQuery := ChangeQuery(cQuery)

        oQuery := FwExecStatement():New(cQuery)

        oQuery:SetUnsafe( nQuery++, RetSQLName("TGY") )
        If !xGsMultFil
            oQuery:SetString( nQuery++, xFilial("TGY") )
        EndIf
        oQuery:SetString( nQuery++, cCodTec )
        oQuery:SetString( nQuery++, cCodTFF )
        oQuery:SetDate( nQuery++, dDateRef )
        oQuery:SetDate( nQuery++, dDateRef )

        cAliasTGY := oQuery:OpenAlias()

        If (cAliasTGY)->(!EOF())
            cIniConf := (cAliasTGY)->TGY_DTINI
            cFimConf := (cAliasTGY)->TGY_ULTALO
            lRet := .T.

            If (cAliasTGY)->TGY_DTINI <= dtos(dDataIni) .And. (cAliasTGY)->TGY_ULTALO >= dtos(dDataFim)
                lStop := .T.
            EndIf

            If (cAliasTGY)->TGY_DTINI <= dtos(dDataIni)
                cIniConf := DtoS(dDataIni)
            EndIf

            If (cAliasTGY)->TGY_ULTALO >= dtos(dDataFim)
                cFimConf := DtoS(dDataFim)
            EndIf
        EndIf

        (cAliasTGY)->(DbCloseArea())

        oQuery:Destroy()
        FwFreeObj(oQuery)
    EndIf

Return lRet
