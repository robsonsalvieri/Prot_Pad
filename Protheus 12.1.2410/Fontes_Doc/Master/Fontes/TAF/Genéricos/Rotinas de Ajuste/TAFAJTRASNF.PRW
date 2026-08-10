
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFA250.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE SRE_EMPRESA_ORIGEM      01
#DEFINE SRE_FILIAL_ORIGEM       02
#DEFINE SRE_EMPRESA_DESTINO     03
#DEFINE SRE_FILIAL_DESTINO      04
#DEFINE SRE_DATA_TRANSFERENCIA  05
#DEFINE SRE_MATRICULA           06
#DEFINE SRE_VERIFICADO          07

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAJTRASNF
Rotina de paridade entre de transferências GPE x TAF.

* A rotina leva em consideração os registros existentes na tabelas SRE 
fazendo um de/para com os registros de transferêcia existentes na C9V.
* Se o registro existir na filial na SRE e não existir na C9V o mesmo
será incluido.
* Se o registro existir na filial na C9V e não existir na SRE o mesmo 
será inativado.
* A data de transferencia será atualizada conforme a ordem de inclusão (RECNO)
dos registros na SRE e C9V.

@return Nil - Array com as transferências duplicadas

@author Evandro dos Santos Oliveira
@since 11/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFAJTRASNF()  

    FWMsgRun(,{|oMsgRun|execAjuTransf(oMsgRun)},STR0001,STR0002)  //"Rotina de Ajuste Transferências SRE X C9V"#"Realizando Processamento ..." 

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} execAjuTransf
Função para execução da rotina

@param oMsgRun - Objeto FWMsgRun
@return Nil 

@author Evandro dos Santos Oliveira
@since 11/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function execAjuTransf(oMsgRun)

    Local aTransfDup    := {} 
    Local nX            := 0
    Local nY            := 0
    Local nPosFil       := 0
    Local cAliasC9V     := ""
    Local cAliasSRE     := ""
    Local cFilOri       := ""
    Local cFilDest      := ""
    Local cCpf          := ""
    Local cMatric       := ""
    Local cEvento       := ""
    Local cNomModel     := ""
    Local oModel        := Nil 
    Local aC9VbyCPF     := {} 
    Local aSREbyCPF     := {}
    Local aQtdsFil      := {} 
    Local aAux          := {}
    Local nPosQtdFil    := 0
    Local nRecNoC9V     := 0
    Local nDiffSRExC9V  := 0
    Local nTamFil       := 0
    Local nPosSreOri    := 0

    IncMessagens(oMsgRun,STR0003) //"Consultando Transferências ..."
    aTransfDup := getTransfDuplicada()

    dbSelectArea("C9V")
    C9V->(dbSetOrder(10))

    nTamFil := FWSizeFilial()

    For nX := 1 To Len(aTransfDup)

        cCpf    := aTransfDup[nX][1]
        cMatric := aTransfDup[nX][2]
        
        cAliasC9V := getC9VbyCPF(cCpf,cMatric)
        cAliasSRE := getSREbyCPF(cCpf)
        aQtdsFil := getC9VQtdbyFil(cCpf)

        While (cAliasC9V)->(!Eof())

            aAdd(aC9VbyCPF,{(cAliasC9V)->C9V_FILIAL;
                            ,(cAliasC9V)->C9V_CPF;
                            ,(cAliasC9V)->RECNO;
                            ,(cAliasC9V)->C9V_NOMEVE;
                            ,(cAliasC9V)->C9V_MATRIC;
                            ,.F.;
                            }) 

            (cAliasC9V)->(dbSkip())  
        EndDo 

        (cAliasC9V)->(dbCloseArea())

         IncMessagens(oMsgRun,STR0004 + cCpf + ".") //Analisando transferências do CPF 
        //Inclui transferencias que existem na SRE e não há correpondente na C9V
        While (cAliasSRE)->(!Eof())

            //Verifico se a quantidade da SRE bate com a quantidade da C9V.
            nPosQtdFil := aScan(aQtdsFil,{|cFil|cFil[1] == AllTrim((cAliasSRE)->FILDEST)})
            If nPosQtdFil == 0   
                //Quando nao encontro a empresa na C9V adiciono no array informando quantidade 0 na C9V e 1 na SRE
                aAdd(aQtdsFil,{AllTrim((cAliasSRE)->FILDEST),0,1})
            ElseIf AllTrim((cAliasSRE)->EMPORI) == AllTrim((cAliasSRE)->EMPDEST) .And. AllTrim((cAliasSRE)->FILORI) != AllTrim((cAliasSRE)->FILDEST)
                //a cada interação conto 1 item na SRE
                aQtdsFil[nPosQtdFil][3]++
            EndIf 

            aAux := Array(7)

            aAux[SRE_EMPRESA_ORIGEM]        := (cAliasSRE)->EMPORI
            aAux[SRE_FILIAL_ORIGEM]         := (cAliasSRE)->FILORI
            aAux[SRE_EMPRESA_DESTINO]       := (cAliasSRE)->EMPDEST
            aAux[SRE_FILIAL_DESTINO]        := (cAliasSRE)->FILDEST
            aAux[SRE_DATA_TRANSFERENCIA]    := (cAliasSRE)->DATAT
            aAux[SRE_MATRICULA]             := (cAliasSRE)->MATRICULA
            aAux[SRE_VERIFICADO]            := .F.

            aAdd(aSREbyCPF,aClone(aAux))
            aSize(aAux,0)
            (cAliasSRE)->(dbSkip())
        EndDo
        
        For nY := 1 To Len(aSREbyCPF)

            cFilOri     := PADR(AllTrim(aSREbyCPF[nY][SRE_FILIAL_ORIGEM])   ,nTamFil) 
            cFilDest    := PADR(AllTrim(aSREbyCPF[nY][SRE_FILIAL_DESTINO])  ,nTamFil) 
            nRecNoC9V   := 0

            If AllTrim(cFilOri) == AllTrim(cFilDest)

                 TafConout(STR0005 + AllTrim(cFilDest) + STR0006 + cCpf) //"Skip Filial : "#" Origem e Destino na SRE Iguais. CPF: "
            Else

                //Tratamento para criar itens que existem na SRE porem nao tem correspondente na C9V
                nRecNoC9V := 0
                nPosQtdC9V := aScan(aQtdsFil,{|cFil|cFil[1] == AllTrim(cFilDest)})

                If nPosQtdC9V > 0

                    nDiffSRExC9V :=  aQtdsFil[nPosQtdC9V][3] - aQtdsFil[nPosQtdC9V][2]

                    If nDiffSRExC9V > 0
            
                        nRecNoC9V := transfereFuncionario(cCpf,cMatric,cFilOri,cFilDest)

                        //gravo C9V recem criada
                        If nRecNoC9V > 0

                            C9V->(dbGoTo(nRecNoC9V))

                            aAdd(aC9VbyCPF,{C9V->C9V_FILIAL;
                                            ,C9V->C9V_CPF;
                                            ,nRecNoC9V;
                                            ,C9V->C9V_NOMEVE;
                                            ,C9V->C9V_MATRIC;
                                            ,.T.;
                                            }) 
                        EndIf 

                        aQtdsFil[nPosQtdC9V][3] --
                        aSREbyCPF[nY][SRE_VERIFICADO] := .T. 
                    EndIf 
                EndIf 
            EndIf 
        Next nY
        
        If TafColumnPos( "C9V_DTTRAN" )
            limpaDataTransf(cCpf)
        EndIf 

        //Atualiza Registros na C9V que tem um correspondente na SRE
        If Len(aC9VbyCPF) > 0

            For nY := 1 To Len(aSREbyCPF)

                cFilDest    := PADR(AllTrim(aSREbyCPF[nY][SRE_FILIAL_DESTINO]),nTamFil) 
                IncMessagens(oMsgRun,"Atualizando tranferência para CPF " + cCpf+ " " +  STR0008 + ": " + AllTrim(cFilDest) + ".") //"Atualizando tranferência para CPF " # " Filial: "

                If AllTrim(aSREbyCPF[nY][SRE_EMPRESA_ORIGEM]) == AllTrim(aSREbyCPF[nY][SRE_EMPRESA_DESTINO])

                    nPosFil := aScan(aC9VbyCPF,{|x| AllTrim(x[1]) == AllTrim(cFilDest) .And. !x[6] })
                    cFilOri := PADR(AllTrim(aSREbyCPF[nY][SRE_FILIAL_ORIGEM]),nTamFil) 
                    
                    If nPosFil > 0
                        
                        If AllTrim(cFilDest) == AllTrim(cFilOri)

                            TafConout("Skip " + STR0008 + " : " + AllTrim(cFilDest) + STR0009 + cCpf) //" Origem e Destino na SRE Iguais. CPF: "
                        Else 
                        
                            atuFilialC9V(oModel,cCpf,cMatric,aC9VbyCPF[nPosFil][1],cFilOri,cFilDest,aC9VbyCPF[nPosFil][3],4,aC9VbyCPF[nPosFil][4],.T.)
                            aC9VbyCPF[nPosFil][6] := .T.
                            aSREbyCPF[nY][SRE_VERIFICADO] := .T. 
                            TafConout(STR0008 + AllTrim(cFilDest) + STR0010 + aC9VbyCPF[nPosFil][2]) //Filial # " correta. CPF: " 
                        EndIf 
                    EndIf 
                EndIf
            Next nY 
        EndIf 

        //Inativa registros na C9V não encontrados na SRE
        For nY := 1 To Len(aC9VbyCPF)

            //Só Inativo Filiais que não existem na SRE.
            nPosSreOri := aScan(aSREbyCPF,{|x|AllTrim(x[2]) ==  AllTrim(aC9VbyCPF[nY][1])})
            C9V->(dbGoTo(aC9VbyCPF[nY][3]))
            If C9V->(!eof())

                RecLock("C9V",.F.)
                If aC9VbyCPF[nY][6] .Or. nPosSreOri > 0
                    C9V->C9V_ATIVO  := '1'
                Else
                    C9V->C9V_ATIVO  := '2'
                    C9V->C9V_IDTRAN :=  "AJ|D|TAF_" + AllTrim(aC9VbyCPF[nY][1]) 
                EndIf 	

                C9V->(MsUnlock())
            EndIf 
        Next nY

        //Atualiza data de Transferencia
        (cAliasSRE)->(dbGoTop())

        cAliasC9V := getC9VbyCPF(cCpf,cMatric,"ASC",.T.)

        While (cAliasSRE)->(!eof())

            If AllTrim((cAliasSRE)->EMPORI) == AllTrim((cAliasSRE)->EMPDEST) .And. AllTrim((cAliasSRE)->FILORI) != AllTrim((cAliasSRE)->FILDEST) 

                C9V->(dbGoTo((cAliasC9V)->RECNO) )
                If C9V->(!eof())
                    RecLock("C9V",.F.)		
                    If TafColumnPos( "C9V_DTTRAN" )
                        C9V->C9V_DTTRAN := STOD((cAliasSRE)->DATAT)
                    EndIf
                    C9V->(MsUnlock())
                EndIf 
                (cAliasC9V)->(dbSkip())
            EndIf 
            
            (cAliasSRE)->(dbSkip())
        EndDo

        (cAliasC9V)->(dbCloseArea())
        (cAliasSRE)->(dbCloseArea())
        aSize(aC9VbyCPF,0)
        aSize(aQtdsFil,0)
        aSize(aSREbyCPF,0)

    Next nX

    aSize(aTransfDup,0)

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTransfDuplicada
retorna array com a filial + cpf dos funcionarios que tivram a 
transferencia duplicada.

@return aTransfDupli - Array com as transferências duplicadas

@author Evandro dos Santos Oliveira
@since 11/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getTransfDuplicada()

    Local cQry := ""
    Local aTransfDupli := {}

    cQry := " SELECT C9V_CPF "
    cQry += " ,C9V_MATRIC "
    cQry += " ,COUNT(*) QTD "
    cQry += " FROM " + RetSqlName("C9V")
    cQry += " WHERE D_E_L_E_T_ = ' ' "
    cQry += " AND C9V_IDTRAN != ' ' "
    cQry += " AND C9V_STATUS = '4' "
    cQry += " AND C9V_PROTUL != ' ' "
 // cQry += " AND C9V_CPF = '01199007501'"
    cQry += " GROUP BY  " 
    cQry += " C9V_CPF " 
    cQry += " ,C9V_MATRIC " 
//  cQry += " HAVING COUNT(*) > 1 "

    TCQuery cQry New Alias 'rsTransfDupli'

    While rsTransfDupli->(!eof())

        aAdd(aTransfDupli,;
        {;
            AllTrim(rsTransfDupli->C9V_CPF);
           ,AllTrim(rsTransfDupli->C9V_MATRIC);
        })

        rsTransfDupli->(dbSkip())
    EndDo
    rsTransfDupli->(dbCloseArea())

Return aTransfDupli 

//-------------------------------------------------------------------
/*/{Protheus.doc} getC9VbyCPF
retorna o RecordSet da tabela C9V realizando um filtro por C9V 
e utilizando parâmetros que indicam que o funcioanrio foi transferido

@param cCpfFunc -> CPF do Funcionario
@param cMatric -> Matricula do funcionário
@param cOrdem -> Ordem de ordenação da 
@param lAtivo -> Informa se deve considerar o campo ativo.

@Return cAliasC9V - RecordSet da Consulta

@author Evandro dos Santos Oliveira
@since 11/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getC9VbyCPF(cCpfFunc,cMatric,cOrdem,lAtivo)

    Local cAliasC9V := getNextAlias()
    Local cQry := ""

    Default cOrdem := "DESC"
    Default lAtivo := .F.

    cQry := " SELECT C9V_FILIAL " 
    cQry += " ,C9V_CPF " 
    cQry += " ,C9V_MATRIC " 
    cQry += " ,C9V_NOMEVE " 
    cQry += " ,R_E_C_N_O_ RECNO "
    cQry += " FROM " + RetSqlName("C9V")  
    cQry += " WHERE C9V_CPF = '" + AllTrim(cCpfFunc) + "'"
    cQry += " AND C9V_MATRIC = '" + AllTrim(cMatric) + "'"

    If lAtivo
        cQry += " AND C9V_ATIVO = '1' "
    EndIf 

    cQry += " AND C9V_STATUS = '4' "
    cQry += " AND D_E_L_E_T_ = ' ' "
  //cQry += " AND C9V_IDTRAN != ' ' "
    cQry += " ORDER BY R_E_C_N_O_  " + cOrdem

    TCQuery cQry New Alias (cAliasC9V)

Return cAliasC9V

//-------------------------------------------------------------------
/*/{Protheus.doc} getC9VQtdbyFil
Retorna a quantidade de registro por filial para um determinado CPF

@param cCpfFunc -> CPF do Funcionario

@Return aQtdsFil - Array com a quantidade de registro por filial
        aQtdsFil[n][1] - Filial
        aQtdsFil[n][2] - Quantidade C9V
        aQtdsFil[n][3] - Quantidade SRE

@author Evandro dos Santos Oliveira
@since 11/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getC9VQtdbyFil(cCpfFunc)

    Local cQry := ""
    Local aQtdsFil := {}
    Local nQtd := 0
    Local cFil := ""
    Local lFirstReg := .T. 

    cQry := " SELECT C9V_FILIAL FILIAL" 
    cQry += ", COUNT(*) QTD " 
    cQry += ", MIN(R_E_C_N_O_) MINIMO "
    cQry += " FROM " + RetSqlName("C9V")   
    cQry += " WHERE C9V_CPF = '" + cCpfFunc +"'"
    cQry += " AND C9V_ATIVO = '1' "
    cQry += " AND C9V_STATUS = '4' "
    cQry += " AND D_E_L_E_T_ = ' ' "
    cQry += " AND C9V_IDTRAN != ' ' "
    cQry += " GROUP BY C9V_FILIAL "
    cQry += " ORDER BY MINIMO "

    TCQuery cQry New Alias 'qtdByFil'


    While qtdByFil->(!Eof())

        If lFirstReg

            //O primeiro registro não se caracteriza uma transferencia
            //neste caso tenho que subtratir para bater com a SRE.
            nQtd := qtdByFil->QTD - 1
            lFirstReg := .F. 
        Else
            nQtd := qtdByFil->QTD 
        EndIf 

        cFil := AllTrim(qtdByFil->FILIAL)
        aAdd(aQtdsFil,{cFil,nQtd,0})
        qtdByFil->(!dbSkip())
    EndDo

    qtdByFil->(dbCloseArea())

Return aQtdsFil 

//-------------------------------------------------------------------
/*/{Protheus.doc} getSREbyCPF
retorna o RecordSet da tabela SRE realizando de acordo com o CPF
passado por parâmetro

@param cCpfFunc -> CPF do Funcionario

@Return cAliasSRE - RecordSet da Consulta

@author Evandro dos Santos Oliveira
@since 11/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getSREbyCPF(cCpfFunc)

    Local cAliasSRE := getNextAlias()
    Local cQry := ""

    cQry := " SELECT RE_DATA DATAT " 
    cQry += " ,RE_EMPD EMPORI " 
    cQry += " ,RE_FILIALD FILORI" 
    cQry += " ,RE_EMPP EMPDEST " 
    cQry += " ,RE_FILIALP FILDEST "
    cQry += " ,RE_MATD MATRICULA "
    
    cQry += " ,(SELECT COUNT(*) "
    cQry += " FROM " + RetSqlName("SRE") 
    cQry += " WHERE RE_MATD IN ( "
	cQry += " SELECT RA_MAT FROM " + RetSqlName("SRA")
	cQry += " WHERE RA_CIC = '" + cCpfFunc + "'" 
	cQry += " AND D_E_L_E_T_ = ' ' "
    cQry += " ) "
    cQry += " AND D_E_L_E_T_ = ' ' "
    cQry += " AND RE_DATA > '20180301' "
    cQry += " AND (RE_EMPD = RE_EMPP "
    cQry += " AND RE_FILIALD != RE_FILIALP) "
    cQry += " AND RE_FILIALP = SRE.RE_FILIALP "
    cQry += " ) QTD "
    
    cQry += " FROM " + RetSqlName("SRE") + " SRE " 
    cQry += " WHERE RE_MATD IN " 
    cQry += " ( "
	cQry += " SELECT RA_MAT FROM " + RetSqlName("SRA")  
	cQry += " WHERE RA_CIC = '" + cCpfFunc + "'" 
	cQry += " AND D_E_L_E_T_ = ' ' "
    cQry += " ) "
    cQry += " AND D_E_L_E_T_ = ' ' " 
    cQry += " AND RE_DATA > '20180301' "
    cQry += " ORDER BY RE_DATA ASC "

    TCQuery cQry New Alias (cAliasSRE)

Return cAliasSRE

//-------------------------------------------------------------------
/*/{Protheus.doc} atuFilialC9V
Ajusta a Filial da tabela C9V de acordo com a SRE

@param oModel -> Modelo de dados 
@param cCpf -> Cpf do Funcionario 
@param cMatric -> Matricula
@param cFilC9V -> Filial do registro posicionado na C9V
@param cFilSREOrig -> Filial de Origem SRE
@param cFilSREDest -> Filial de Destino SRE
@param nRecNoC9V -> Recno para posicionamento na C9V
@parma nOpc -> Operação do Modelo
@param cEvento -> Nome do Evento
@param lRegTrans -> Informa se o registro foi transmitido.

@return lOk -> Retorna True se a gravação foi realizada

@author Evandro dos Santos Oliveira
@since 11/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function atuFilialC9V(oModel,cCpf,cMatric,cFilC9V,cFilSREOrig,cFilSREDest,nRecNoC9V,nOpc,cEvento,lRegTrans)

    Local lOk := .T.
    Local cIdTransf := ""
    Local cNomModel := ""
    Local cChaveOri := ""
    Local nLastRecno := 0

    Default nOpc := 3
    Default lRegTrans := .T. //registro transmitido
    Default cEvento := "S2200"


    If AllTrim(cFilC9V) == AllTrim(cFilSREDest)

        C9V->(dbGoTo(nRecNoC9V))

        If cEvento == "S2200"
            cNomModel := "TAFA278"
        Else
            cNomModel := "TAFA279"
        EndIf 

        If C9V->(!Eof())

            FCModelInt("C9V", cNomModel, @oModel, nOpc,"",lRegTrans)

            cIdTransf := "AJ|A|SRE_" + AllTrim(cFilSREOrig) + "-" + AllTrim(cFilSREDest) + "|TAF_" + AllTrim(cFilC9V)

            oModel:LoadValue("MODEL_C9V", "C9V_FILIAL",AllTrim(cFilSREDest) )
            oModel:LoadValue("MODEL_C9V", "C9V_IDTRAN",cIdTransf )
            oModel:LoadValue("MODEL_C9V", "C9V_ATIVO","1" )

            FwFormCommit( oModel )
            

            nLastRecno := C9V->(RecNo())

            /*
            If oModel:VldData()
                FwFormCommit( oModel )
            Else
                
                cToken := AllTrim(cFilC9V)+"|"+cValToChar(nRecNoC9V)
                varInfo(cToken,oModel:GetErrorMessage())
            EndIf 
            */
        Else
            lOk := .F.
        EndIf 
    EndIf 

Return lOk 

//-------------------------------------------------------------------
/*/{Protheus.doc} transfereFuncionario
Realiza a Transferencia de Filial de um determinado funcionario

@param cCpf -> Cpf do funcionário 
@param cMatric -> Maricula do funcionário
@param cFilOri -> Filial de Origem
@param cFilDest -> Filial de Destino
@param cFilSREOrig -> Filial de Origem SRE
@param cFilSREDest -> Filial de Destino SRE
@param nRecNoC9V -> Recno para posicionamento na C9V
@parma nOpc -> Operação do Modelo
@param cEvento -> Nome do Evento
@param lRegTrans -> Informa se o registro foi transmitido.

@return lOk -> Retorna True se a gravação foi realizada

@author Evandro dos Santos Oliveira
@since 11/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function transfereFuncionario(cCpf,cMatric,cFilOri,cFilDest)

    Local aChaveC9V := {} 
    Local aChaveOri := {}
    Local cLayout   := "S2200"
    Local cId := ""
    Local cChaveOri := ""
    Local cRastro := "" 
    Local nIndPos := 10
    Local nRecNoC9V := 0


    Default cCpf := ""
    Default cMatric := ""
    Default cFilOri := ""
    Default cFilDest := ""

    aAdd(aChaveOri,{cLayout,cFilOri,Padr(cCpf, TamSX3("C9V_CPF")[1]) ,Padr(cMatric, TamSX3("C9V_MATRIC")[1]) ,"","S2200" + '1'} )
    aAdd(aChaveC9V,{cLayout,cFilDest, Padr(cCpf, TamSX3("C9V_CPF")[1]) , Padr(cMatric, TamSX3("C9V_MATRIC")[1]) , "" , "S2200" + '1'} ) 

    cId := GetSx8Num("C9V","C9V_ID")
    While !TAFCheckID(cId,"C9V")
        C9V->(ConfirmSX8())
        cId := GetSx8Num("C9V","C9V_ID")
    EndDo

    cRastro := "AJ|I|SRE_" + AllTrim(cFilOri) + "-" + AllTrim(cFilDest) + "|TAF_" + AllTrim(cFilDest)
    cChaveOri := aChaveOri[ 1, 2 ] + aChaveOri[ 1, 3 ] + aChaveOri[ 1, 4 ] + aChaveOri[ 1, 6 ]

    nRecNoC9V := tafTrasfFunc(cChaveOri, nIndPos, cId , cFilOri, cFilDest, aChaveC9V,cRastro,.T.)

Return nRecNoC9V 

//---------------------------------------------------------------------
/*/{Protheus.doc} limpaDataTransf
Limpa os campos de transferencia de um determinado trabalhador

@param cCpf - Cpf do Trabalhador.

@Author		Evandro dos Santos Oliveira
@Since		02/10/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function limpaDataTransf(cCpf)

    Local cSql := ""

    cSql := " UPDATE " + RetSqlName("C9V")
    cSql += " SET C9V_DTTRAN = ' ' "
    cSql += " WHERE C9V_CPF = '" + cCpf + "'

    If TCSQLExec (cSql) < 0
        MsgStop(TCSQLError(),STR0011) //"Erro na limpeza da Data de Transferência."
    EndIf

Return Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} IncMessagens

Atualiza o label do objeto FWMSGRUN

@Author		Evandro dos Santos Oliveira
@Since		02/10/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function IncMessagens(oMsgRun,cMsg)

    oMsgRun:cCaption := cMsg
    ProcessMessages()

Return Nil 




