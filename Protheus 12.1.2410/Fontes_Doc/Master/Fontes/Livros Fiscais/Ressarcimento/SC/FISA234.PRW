#Include "FISA234.CH"
#include "PROTHEUS.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA234
  
Rotina de geração do arquivo da DRCST - Demonstrativo para Apuração Mensal do Ressarcimento, 
da Restituição e da Complementação do ICMS Substituição Tributária, do Estado de Santa Catarina.
O método de apuração é determinado pelo Decreto Nº 1818 DE 28/11/2018 e pela Portaria SEF N° 378/2018.

@author Ulisses P. Oliveira
@since 29/04/2019
@version 1.0.
/*/
//--------------------------------------------------------------------------------------------------
Function FISA234()
    Local aArea     := GetArea()
    Local cIdApur   := ''
    Local cPerApur  := ''
    Local lProcess  := .T.

    If Pergunte("FSA234",.T.)
        cPerApur := Right(MV_PAR01,4)+Left(MV_PAR01,2)

        //---Verifica a existência de apuração no período selecionado---//
        cIdApur := ConfeApur(cPerApur)
        If Empty(cIdApur)
            MsgStop(STR0001) //---Apuração não realizada para o período selecionado!---//
            lProcess := .F.
        EndIf

        If lProcess
            FwMsgRun(,{|oSay| FISA234A(oSay,cPerApur,)},STR0002,"")   //---Arquivo: Ressarcimento, Restituição e Complementação ICMS ST---//
        EndIf

    EndIf

    RestArea(aArea)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA234A
  
Rotina de Processamento da Apuração.

@author Ulisses P. Oliveira
@since 29/04/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA234A(oSay,cPerApur,aFsa234C)
    Local dDataDe    := StoD(cPerApur+'01')
    Local dDataAte   := LastDay(dDataDe)

    Local oTabela    := TabTemp()
    
    Local aNumeracao := {}
    Local cChaveBlc0 := '0001000000001'
    Local cChaveBlcH := 'H001000000001'
    Local cChaveBlc2 := '2001000000001'

    Local aSM0       := FWLoadSM0()    
  
    Local oBlocReg   := DRCST():New()
    Local oBloco0    := DRCSTBLOC0():New()
    Local oBlocoH    := DRCSTBLOCH():New()
    Local oBloco2    := DRCSTBLOC2():New()

    Private lAutomato  := IsBlind()

    Default aFsa234C := Iif(lAutomato,{},ProcContab())

    //--Geração do Bloco 0---//
    AtualizaMsg(oSay, STR0003) //---Processando Bloco 0...---//
    Reg0000(oSay,oBloco0,oTabela,@aNumeracao,dDataDe,dDataAte,/*@lCancel*/)
    Reg0005(oSay,oBloco0,oTabela,@aNumeracao,cChaveBlc0,aSM0,lAutomato,/*@lCancel*/)
    Reg0100(oSay,oBloco0,oTabela,@aNumeracao,cChaveBlc0,dDataDe,dDataAte,aFsa234C,/*@lCancel*/)

    //---Geração do Bloco H---//
    AtualizaMsg(oSay, STR0004) //---Processando Bloco H...---//
    FSA234BLCH(oSay,oBlocoH,oTabela,@aNumeracao,cChaveBlcH,cPerApur,dDataAte)

    //---Geração do Bloco 2---//
    AtualizaMsg(oSay, STR0005) //---Processando Bloco 2...---//
    FSA234BLC2(oSay,oBloco0,oBloco2,oTabela,@aNumeracao,cChaveBlc0,cChaveBlc2,cPerApur,dDataDe,dDataAte)

    AtualizaMsg(oSay, STR0006) //---Finalizando processamento...---//

    //---Seta numeracao antes de totalizar os registros---//
    oBlocReg:SetNumer(aNumeracao)
    oBloco0:SetNumer(aNumeracao)
    oBlocoH:SetNumer(aNumeracao)
    oBloco2:SetNumer(aNumeracao)

    //---Gera registros de abertura e fechamento dos blocos e totaliza arquivo---//
    ContRegGer(oTabela,oBlocReg,oBloco0,oBlocoH,oBloco2)

    //---Gera conteúdo da tabela temporária no arquivo TXT---//
	If Empty(oTabela:GravaTxt())
        If !lAutomato
            MsgInfo(STR0007) //---Arquivo gerado com sucesso.---//
        EndIf
    EndIf

    //---Deleta tabela temporária---//
	oTabela:DelTabela()

    //---Elimina objetos utilizados no processamento---//
    FreeObj(oTabela)
    FreeObj(oBlocReg)
    FreeObj(oBloco0)
    FreeObj(oBlocoH)
    FreeObj(oBloco2)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TabTemp

Função para criação da tabela temporária

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function TabTemp()
    Local oTabTemp := DRCSTTMP():New()
    Local cNomeArq := Alltrim(MV_PAR03)
    Local nRemType := GetRemoteType()
    Local cDir     := Alltrim(MV_PAR02)
    
    MakeDir(cDir)
    
    If nRemType == 2
        If (SubStr(cDir, Len(cDir), 1)<>"/")
            cDir += "/"
        EndIf
    Else
        If (SubStr(cDir, Len(cDir), 1)<>"\")
            cDir += "\"
        EndIf
    EndIf
    
    oTabTemp:SetNomeArq(cNomeArq)
    oTabTemp:SetDiretor(cDir)
    oTabTemp:CriaTabela()
Return oTabTemp


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ContRegGer

Função para realizar a contagem geral dos registros gerados e levar informações para o Bloco 9

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function ContRegGer(oTabela,oBlocReg,oBloco0,oBlocoH,oBloco2)

    Local aRetCont   := {}
    Local aContReg   := {}
    Local aContBloco := {}
    Local nCont      := 0
    Local nTotArqTxt := 0
    Local nTotBloco9 := 0
    
    //---ContRegBlc busca na tabela temporária a quantidade de registros por bloco já gravados---//
    aRetCont   := ContRegBlc(oTabela)
    aContReg   := aRetCont[1] //---Contagem por Registro---//
    aContBloco := aRetCont[2] //---Contagem por Bloco---//
    
    //---Gera registro 9900 para cada registro contido em aContReg---//
    For nCont := 1 To Len(aContReg)
        GerReg9900(oBlocReg, aContReg[nCont][1], Alltrim(Str(aContReg[nCont][2])))
        nTotArqTxt += aContReg[nCont][2]  //---Acumula a variável nTotArqTxt que contem o contador do Registro 9999---//
    Next nCont
    
    //---Atualiza contadores---//
    nTotArqTxt += Len(aContReg)
    nTotBloco9 := Len(aContReg)
    
    //---Gerar registro de abertura e fechamento para cada bloco---//
    For nCont := 1 To Len(aContBloco)
        Do Case
            //---BLOCO 0
            Case nCont == 1                
                InicBloco( '', oBloco0, '0001', Iif(aContBloco[nCont] == '0' ,'1' ,'0'), oTabela)
                EncerBloco('', oBloco0, '0990', AllTrim(Str(Val(aContBloco[nCont])+2)) , oTabela)
                GerReg9900(oBlocReg, '0001', '1')
                GerReg9900(oBlocReg, '0990', '1')
                nTotBloco9 += 2
                nTotArqTxt += 4
            //---BLOCO H
            Case nCont == 2
                InicBloco( '', oBlocoH, 'H001', Iif(aContBloco[nCont] == '0' ,'1' ,'0'), oTabela)
                EncerBloco('', oBlocoH, 'H990', AllTrim(Str(Val(aContBloco[nCont])+2)) , oTabela)
                GerReg9900(oBlocReg, 'H001', '1')
                GerReg9900(oBlocReg, 'H990', '1')
                nTotBloco9 += 2
                nTotArqTxt += 4
            //---BLOCO 2
            Case nCont == 3
                InicBloco( '', oBloco2, '2001', Iif(aContBloco[nCont] == '0' ,'1' ,'0'), oTabela)
                EncerBloco('', oBloco2, '2990', AllTrim(Str(Val(aContBloco[nCont])+2)) , oTabela)
                GerReg9900(oBlocReg, '2001', '1')
                GerReg9900(oBlocReg, '2990', '1')
                nTotBloco9 += 2
                nTotArqTxt += 4
        EndCase
    Next nCont
    
    //---Gera abertura e fechamento do bloco 9 e atualiza totalizadores---//
    nTotBloco9 += 7
    
    InicBloco( '', oBlocReg, '9001', '0'                     , oTabela)
    EncerBloco('', oBlocReg, '9990', AllTrim(Str(nTotBloco9)), oTabela)
    
    GerReg9900(oBlocReg, '9001', '1')
    GerReg9900(oBlocReg, '9900', AllTrim(Str(nTotBloco9-3)))
    GerReg9900(oBlocReg, '9990', '1')
    GerReg9900(oBlocReg, '9999', '1')
    
    oTabela:GrvReg(oBlocReg:Get9900())
    
    nTotArqTxt += 7
    EncerBloco('', oBlocReg, '9999', AllTrim(Str(nTotArqTxt)), oTabela)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ContRegBlc

Função para realizar a contagem dos registros por blocos

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function ContRegBlc(oTabela)
    Local cAliasTRB	:= oTabela:GetAlias()
    Local aQtdReg   := {}
    Local aQtdBloco	:= {}
    Local cCont0    := 0
    Local cCont2    := 0
    Local cContH    := 0
    Local cBloco    := ''
    Local nPos      := 0
    
    (cAliasTRB)->(DbSetOrder(1))
    (cAliasTRB)->(DbGoTop())
    Do While !(cAliasTRB)->(Eof())

        nPos := aScan(aQtdReg, {|aX| aX[1]==(cAliasTRB)->REGISTRO})
        If nPos == 0
            aAdd(aQtdReg, {(cAliasTRB)->REGISTRO,1})
        Else
            aQtdReg[nPos][2] += 1
        EndIf
        
        cBloco := Left((cAliasTRB)->REGISTRO,1)
        
        Do Case
            Case cBloco == '0'
                cCont0 ++
            Case cBloco == 'H'
                cContH++
            Case cBloco == '2'
                cCont2 ++

        EndCase
        
        (cAliasTRB)->(DbSkip())
    EndDo
    
    aAdd(aQtdBloco,AllTrim(Str(cCont0)))
    aAdd(aQtdBloco,AllTrim(Str(cContH)))
    aAdd(aQtdBloco,AllTrim(Str(cCont2)))

Return {aQtdReg,aQtdBloco}


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerReg9900

Função para geração de registro 9900 para cada registro gerado no arquivo

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GerReg9900(oObj9900, cReg, cQtd)
    oObj9900:Add9900(cReg, cQtd)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InicBloco

Função para geração de registro de abertura (x001) para cada registro gerado no arquivo

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function InicBloco(cChave, oAbertura, cReg, cIndMovto, oTabela)

    oAbertura:SetRelac(cChave)

    Do case
        Case cReg == '0001'
            oAbertura:Add0001(cIndMovto)
            oTabela:GrvReg(oAbertura:Get0001())
        Case cReg == 'H001'
            oAbertura:AddH001(cIndMovto)
            oTabela:GrvReg(oAbertura:GetH001())
        Case cReg == '2001'
            oAbertura:Add2001(cIndMovto)
            oTabela:GrvReg(oAbertura:Get2001())
        Case cReg == '9001'
            oAbertura:Add9001(cIndMovto)
            oTabela:GrvReg(oAbertura:Get9001())
    EndCase

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EncerBloco

Função para geração de registro de encerramento (x990) para cada registro gerado no arquivo

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function EncerBloco(cChave, oEncerra, cReg, nQtd, otabela)

    oEncerra:SetRelac(cChave)

    Do case
        Case cReg == '0990'
            oEncerra:Add0990(nQtd)
            oTabela:GrvReg(oEncerra:Get0990())
        Case cReg == 'H990'
            oEncerra:AddH990(nQtd)
            oTabela:GrvReg(oEncerra:GetH990())
        Case cReg == '2990'
            oEncerra:Add2990(nQtd)
            oTabela:GrvReg(oEncerra:Get2990())
        Case cReg == '9990'
            oEncerra:Add9990(nQtd)
            oTabela:GrvReg(oEncerra:Get9990())
        Case cReg == '9999'
            oEncerra:Add9999(nQtd)
            oTabela:GrvReg(oEncerra:Get9999())
    EndCase

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg0000
  
Função para geração do Registro 0000 [Bloco 0].

@author Ulisses P. Oliveira
@since 29/04/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function Reg0000(oSay,oBloco0,oTabela,aNumeracao,dDataDe,dDataAte,lCancel)
    Local cVersao  := ''
    Local cFinalid := Iif(MV_PAR04 == 1,'0','1')                         //---Código da Finalidade do Arquivo---//
    Local cPerfil  := Iif(MV_PAR05 == 1,'A',Iif(MV_PAR05 == 2,'B','C'))  //---Perfil de Apresentação---//
    Local cTpAtiv  := Iif(MV_PAR06 == 1,'0','1')                         //---Tipo de Atividade---//

    If cPerfil != 'C'
        Do Case
        	Case(Year(dDataDe)<=2008)
        		cVersao := "001"
        	Case(Year(dDataDe)==2009)
        		cVersao := "002"
        	Case(Year(dDataDe)==2010)
        		cVersao := "003"
        	Case(Year(dDataDe)==2011)
        		cVersao := "004"
        	Case(Year(dDataDe)==2012)
        		If DtoS(dDataDe) <= "20120630"
        			cVersao := "005"
        		Else
        			cVersao := "006"
        		Endif
        	Case(Year(dDataDe)==2013)
        		cVersao	:= "007" 
        	Case(Year(dDataDe)==2014)
        		cVersao := "008"	 
        	Case(Year(dDataDe)==2015)
        		cVersao := "009"
        	Case(Year(dDataDe)==2016)	
        		cVersao := "010"	   
        	Case(Year(dDataDe)==2017)  
                cVersao := "011"
        	Case(Year(dDataDe)==2018)  
                cVersao := "012" 
        	Case(Year(dDataDe)>=2019)  
                cVersao := "013" 
        EndCase
    EndIf

    oBloco0:SetNumer(aNumeracao)
    oBloco0:SetRelac()
    oBloco0:SetReg("0000")                                                                                                                     //01 - REG
    oBloco0:SetCodVer(cVersao)                                                                                                                 //02 - COD_VER
    oBloco0:SetCodFin(cFinalid)                                                                                                                //03 - COD_FIN
    oBloco0:SetDataIni(dDataDe)                                                                                                                //04 - DT_INI
    oBloco0:SetDataFim(dDataAte)                                                                                                               //05 - DT_FIM
    oBloco0:SetNome(SM0->M0_NOMECOM)                                                                                                           //06 - NOME
    oBloco0:SetCnpj(SPEDConType(SPEDVldIE(Iif (RetPessoa(SM0->M0_CGC) == "J", SM0->M0_CGC, ""))))	                                           //07 - CNPJ
    oBloco0:SetCpf(SPEDConType(SPEDVldIE(Iif (RetPessoa(SM0->M0_CGC) == "F", SM0->M0_CGC, ""))))                                               //08 - CPF
    oBloco0:SetUF(SM0->M0_ESTENT)																	                                           //09 - UF
    oBloco0:SetIE(SPEDConType(SPEDVldIE(SM0->M0_INSC,.F.,.F.)))										                                           //10 - IE
    oBloco0:SetCodMun(Iif(Upper(SM0->M0_ESTENT) == "EX","",Iif(Len(Alltrim(SM0->M0_CODMUN))<=5,UfCodIBGE(SM0->M0_ESTENT),"")+SM0->M0_CODMUN))  //11 - COD_MUN
    oBloco0:SetIM(SPEDConType(SM0->M0_INSCM))		                                                                                           //12 - IM
    oBloco0:SetSuframa(SPEDConType(SM0->M0_INS_SUF))                                                                                           //13 - SUFRAMA
    oBloco0:SetIndPerf(cPerfil)                                                                                                                //14 - IND_PERFIL
    oBloco0:SetIndAtv(cTpAtiv)                                                                                                                 //15 - IND_ATIV
    oBloco0:Add0000()
    oTabela:GrvReg(oBloco0:Get0000())

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg0005
  
Função para geração do Registro 0005 [Bloco 0].

@author Ulisses P. Oliveira
@since 03/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function Reg0005(oSay,oBloco0,oTabela,aNumeracao,cChaveBlc0,aSM0,lAutomato,lCancel)
    Local	cTel      := ""
    Local	cFax      := ""
    Local 	lUsaXX8   := SuperGetMv("MV_USAXX8",,.F.) //---Parametro define se as informacoes da empresa virao do XX8---//
    Local	cNomeFant := ""
    Local	cRetPE    := ""

    If Len(SM0->M0_CODFIL) > 2
    	If lUsaXX8	//--Tabela XX8---//
    		aEval(aSM0,{|x| cNomeFant := Iif(x[SM0_GRPEMP]==cEmpAnt .And. x[SM0_CODFIL]==cFilAnt .And. x[SM0_USEROK], x[SM0_NOMRED], cNomeFant)})	
    	Else
    		cNomeFant := SM0->M0_FILIAL
    	EndIf
    Else
    	cNomeFant := SM0->M0_NOME
    EndIf

    If ExistBlock("SPEDFANT") //---PE usado para alterar campo 02-FANTASIA---//
        cRetPE := ExecBlock("SPEDFANT",.F.,.F.)
    	If  ValType(cRetPE) == "C"
    		cNomeFant := cRetPE
    	EndIf
    EndIf

    cTel := SPEDConType(SPEDVldIE(SM0->M0_TEL)) //---Tira espaços e caracteres especiais---//
    cFax := SPEDConType(SPEDVldIE(SM0->M0_FAX)) //---Tira espaços e caracteres especiais---//

    oBloco0:SetNumer(aNumeracao)
    oBloco0:SetRelac(cChaveBlc0)
    oBloco0:SetReg("0005")						                                                                                  //01 - REG
    oBloco0:SetFantas(cNomeFant)				                                                                                  //02 - FANTASIA
    oBloco0:SetCep(SPEDConType(SM0->M0_CEPENT))	                                                                                  //03 - CEP
    oBloco0:SetEnderec(SPEDConType(FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[1]))                                                  //04 - END
    oBloco0:SetNumEnd(Iif(!Empty(FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[2]),FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[3],"SN"))  //05 - NUM
    oBloco0:SetComplem(SPEDConType(Iif(!Empty(SM0->M0_COMPENT),SM0->M0_COMPENT,FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[4]))	) //06 - COMPL
    oBloco0:SetBairro(SPEDConType(SM0->M0_BAIRENT))                                                                               //07 - BAIRRO
    oBloco0:SetFone(Right(cTel,11))                                                                                               //08 - FONE
    oBloco0:SetFax(Right(cFax,11))                                                                                                //09 - FAX
    oBloco0:SetEmail(MV_PAR07)                                                                                                    //10 - EMAIL
    oBloco0:Add0005()
    oTabela:GrvReg(oBloco0:Get0005())

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg0100
  
Rotina geração do Registro 0100 [Bloco 0].

@author Ulisses P. Oliveira
@since 03/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function Reg0100(oSay,oBloco0,oTabela,aNumeracao,cChaveBlc0,dDataDe,dDataAte,aFsa234C,lCancel)
    Local cCNPJ      := ""     
    Local lInclui    := .F.
    Local cAliasCVB  := "CVB"
    Local lCvbCPF    := (cAliasCVB)->(FieldPos("CVB_CPF"))    > 0
    Local lCvbCodMun := (cAliasCVB)->(FieldPos("CVB_CODMUN")) > 0

    If (!Empty(aFsa234C[1]) .And. !Empty(aFsa234C[7])) .Or. !(AliasIndic("CVB")) //---Se o nome e o endereco estiver informado na wizard, continuo a pegar as informacoes da wizard.
        oBloco0:SetNumer(aNumeracao)
        oBloco0:SetRelac(cChaveBlc0)
        oBloco0:SetReg("0100")                  //01 - REG
        oBloco0:SetNome(aFsa234C[01])           //02 - NOME
        oBloco0:SetCpf(aFsa234C[03])            //03 - CPF
        oBloco0:SetCrc(aFsa234C[04])            //04 - CRC
        oBloco0:SetCnpj(aFsa234C[02])           //05 - CNPJ
        oBloco0:SetCep(aFsa234C[05])            //06 - CEP
        oBloco0:SetEnderec(aFsa234C[07])        //07 - END
        oBloco0:SetNumEnd(aFsa234C[08])         //08 - NUM
        oBloco0:SetComplem(aFsa234C[09])        //09 - COMPL
        oBloco0:SetBairro(aFsa234C[10])         //10 - BAIRRO
        oBloco0:SetFone(aFsa234C[11])           //11 - FONE
        oBloco0:SetFax(aFsa234C[12])            //12 - FAX
        oBloco0:SetEmail(aFsa234C[13])          //13 - EMAIL
        oBloco0:SetCodMun(aFsa234C[06])         //14 - COD_MUN
        oBloco0:Add0100()
        oTabela:GrvReg(oBloco0:Get0100())
    Else
    	lInclui := .F.
    	If !Empty(aFsa234C[03]) .And.lCvbCPF //---Se o CPF estiver informado, mas sem o nome e endereco, pesquiso na tabela CVB - contabilista pelo num. documento.
    		lInclui := SPEDFFiltro(1,"CVB",@cAliasCVB,{DToS(dDataDe),DToS(dDataAte),aFsa234C[03],""})
    	ElseIf !Empty(aFsa234C[02]) .Or. (!Empty(aFsa234C[03]) .And. !lCvbCPF) //---Se o CNPJ estiver informado, mas sem o nome e endereco, pesquiso na tabela CVB - contabilista pelo num. documento.
    		cCNPJ := Iif(!Empty(aFsa234C[02]), aFsa234C[02], aFsa234C[03])	 
    		cCNPJ := Padr(SubStr(cCNPJ,1,TamSx3("A2_CGC")[1]),TamSx3("A2_CGC")[1])
    		lInclui := SPEDFFiltro(1,"CVB",@cAliasCVB,{DToS(dDataDe),DToS(dDataAte),"",cCNPJ})
    	Else //---Senao pego o primeiro contabilista informado para a filial corrente.
    		lInclui := SPEDFFiltro(1,"CVB",@cAliasCVB,{DToS(dDataDe),DToS(dDataAte),"",""})
    	Endif	

    	If lInclui
            oBloco0:SetNumer(aNumeracao)
            oBloco0:SetRelac(cChaveBlc0)
            oBloco0:SetReg("0100")				   																				                                          //01 - REG
            oBloco0:SetNome((cAliasCVB)->CVB_NOME )																						                                  //02 - NOME
            oBloco0:SetCpf(Iif(lCvbCPF,Alltrim((cAliasCVB)->CVB_CPF),Iif(Len(Alltrim((cAliasCVB)->CVB_CGC))<14,Alltrim((cAliasCVB)->CVB_CGC),"")))	                      //03 - CPF
            oBloco0:SetCrc(SPEDConType((cAliasCVB)->CVB_CRC))																				                              //04 - CRC
            oBloco0:SetCnpj(SPEDConType(Iif(Len(Alltrim((cAliasCVB)->CVB_CGC))>11,Alltrim((cAliasCVB)->CVB_CGC),"")))								                      //05 - CNPJ
            oBloco0:SetCep(SPEDConType((cAliasCVB)->CVB_CEP)) 											   									                              //06 - CEP
            oBloco0:SetEnderec(SPEDConType(FisGetEnd((cAliasCVB)->CVB_END,(cAliasCVB)->CVB_UF)[1]))						 							                      //07 - END
            oBloco0:SetNumEnd(Iif(!Empty(FisGetEnd((cAliasCVB)->CVB_END,(cAliasCVB)->CVB_UF)[2]),FisGetEnd((cAliasCVB)->CVB_END,(cAliasCVB)->CVB_UF)[3],"SN"))            //08 - NUM
            oBloco0:SetComplem(SPEDConType((cAliasCVB)->CVB_COMPL))											   								                              //09 - COMPL
            oBloco0:SetBairro(SPEDConType((cAliasCVB)->CVB_BAIRRO))																			                              //10 - BAIRRO
            oBloco0:SetFone(SPEDConType((cAliasCVB)->CVB_TEL))																				                              //11 - FONE
            oBloco0:SetFax(SPEDConType((cAliasCVB)->CVB_FAX))																				                              //12 - FAX
            oBloco0:SetEmail((cAliasCVB)->CVB_EMAIL)																						                              //13 - EMAIL
            oBloco0:SetCodMun ("")
    		If lCvbCodMun
    			oBloco0:SetCodMun(Iif(Len(Alltrim((cAliasCVB)->CVB_CODMUN)) <= 5 , UfCodIBGE((cAliasCVB)->CVB_UF) + Alltrim((cAliasCVB)->CVB_CODMUN), Alltrim((cAliasCVB)->CVB_CODMUN))) 
    		EndIf            																					   				                                          //14 - COD_MUN
            oBloco0:Add0100()
            oTabela:GrvReg(oBloco0:Get0100())

    		SPEDFFiltro(2,,cAliasCVB)
    	Endif     
    Endif

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RegProd
  
Rotina geração dos Registros: 0190 / 0200 / 0205 / 0206 / 0220 - [Bloco 0].

@author Ulisses P. Oliveira
@since 08/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function RegProd(cAliasMov,oBloco0,cChvBlc0,aNumeracao,dDataDe,dDataAte,nAliqEfet)

    Local	aHist		:= {}
    Local	aHistCod	:= {}
    Local	aMod		:= {}
    Local	cDescProd	:= ''
    Local	cCodBarra	:= ''    
    Local	cSegUnid	:= ''
    Local	cTpConv		:= ''
    Local	cAliasIt	:= ''
    Local	cTpPrd		:= ''
    Local	cTipo		:= '99'
    Local	cTipo00		:= iif(Empty(SuperGetMv("MV_BLKTP00",.F.,'ME')),"ME",SuperGetMv("MV_BLKTP00",.F.,'ME')) // 00 - Mercadoria para Revenda
    Local	cTipo01		:= iif(Empty(SuperGetMv("MV_BLKTP01",.F.,'MP')),"MP",SuperGetMv("MV_BLKTP01",.F.,'MP')) // 01 - Materia-prima
    Local	cTipo02		:= iif(Empty(SuperGetMv("MV_BLKTP02",.F.,'EM')),"EM",SuperGetMv("MV_BLKTP02",.F.,'EM')) // 02 - Embalagem
    Local	cTipo03		:= iif(Empty(SuperGetMv("MV_BLKTP03",.F.,'PP')),"PP",SuperGetMv("MV_BLKTP03",.F.,'PP')) // 03 - Produto em Processo
    Local	cTipo04		:= iif(Empty(SuperGetMv("MV_BLKTP04",.F.,'PA')),"PA",SuperGetMv("MV_BLKTP04",.F.,'PA')) // 04 - Produto Acabado
    Local	cTipo05		:= iif(Empty(SuperGetMv("MV_BLKTP05",.F.,'SP')),"SP",SuperGetMv("MV_BLKTP05",.F.,'SP')) // 05 - SubProduto
    Local	cTipo06		:= iif(Empty(SuperGetMv("MV_BLKTP06",.F.,'PI')),"PI",SuperGetMv("MV_BLKTP06",.F.,'PI')) // 06 - Produto Intermediario
    Local	cTipo10		:= iif(Empty(SuperGetMv("MV_BLKTP10",.F.,'OI')),"OI",SuperGetMv("MV_BLKTP10",.F.,'OI')) // 10 - Outros insumos
    Local   lMVHISTTAB  := SuperGetMv("MV_HISTTAB",.F.,.F.)
    Local   nMV205HIST  := SuperGetMv("MV_205HIST",.F.,0)
    Local   lSX2AIF     := AliasIndic('AIF')
    Local   lSX3B1CEST  := (cAliasMov)->(FieldPos("B1_CEST")) > 0
    Local   lSPDFIS001  := ExistBlock("SPDFIS001",,.T.)

    Local	aTipo		:=	{ {cTipo00,"00"},;
    						  {cTipo01,"01"},;
    						  {cTipo02,"02"},;
    						  {cTipo03,"03"},;
    						  {cTipo04,"04"},;
    						  {cTipo05,"05"},;
    						  {cTipo06,"06"},;
    						  {"MC"   ,"07"},;
    						  {"AI"   ,"08"},;
    						  {"MO"   ,"09"},;
    						  {cTipo10,"10"} }

    Local	dDataFinal	:= ctod("  /  /  ")
    Local	dDataInici	:= ctod("  /  /  ")
    Local	dDataCont	:= ctod("01/01/2000")
    Local	lRet		:= 	.T.
    Local	lHistTab	:= 	lMVHISTTAB .And. lSX2AIF
    Local	nX			:= 	0
    Local	nFldPrdPri	:= 	0
    Local	nConv		:= 	0
    Local	nTipo		:= 	1
    Local	lProdPrim	:= .f.
    Local	lSegUnid	:= (cAliasMov)->(FieldPos("B1_SEGUM"))>0 .AND. (cAliasMov)->(FieldPos("B1_TIPCONV"))>0 .AND. (cAliasMov)->(FieldPos("B1_CONV"))>0
    Local	lSegUnidPE	:= (cAliasMov)->F1M_UNIDAD != (cAliasMov)->B1_UM
    Local 	lTemAIF		:= .F.
    Local   cPRDPRIB5	:= Alltrim(SuperGetMv("MV_PRDPRI",.F., ""))
    Local   cProd		:= (cAliasMov)->B1_COD
    Local   cMVDTINCB1	:= Iif((cMVDTINCB1 := AllTrim(SuperGetMv("MV_DTINCB1",.F.,""))) != "", StrTran(cMVDTINCB1,'"',""), "B1_DATREF") // Evitar errorlog caso o parametro seja preenchido com aspas.
    Local	cCmpDTINCB1	:= "SB1->" + cMVDTINCB1
    Local   cChv0200    := ""
    Local   lAchouCD6   := .F.
    Local   cUnid       := (cAliasMov)->B1_UM
    Local   aGet0200    := {}

    dbSelectArea("SB5")
    SB5->(dbSetOrder(1))

    dbSelectArea("CD6")
    CD6->(dbsetorder(1))

    oBloco0:SetNumer(aNumeracao)
    oBloco0:SetRelac(cChvBlc0)

    //REGISTRO 0190 - UNIDADES DE MEDIDA 
    oBloco0:SetUnidInv(cUnid)

    // Adiciona um novo 0190
    oBloco0:Add0190()

    //REGISTRO 0200 - TABELA DE IDENTIFICACAO DO ITEM 
    // Verifica se ja existe 0200 p/ o produto.
    aGet0200 := oBloco0:Get0200(cProd)
    If aGet0200[1] == 0

        // Verifica se o produto tem histório de alteração p/ geração do 0205.
        If lHistTab
            DbSelectArea("AIF")
            AIF->(dbsetorder(2))
            lTemAIF := AIF->(MsSeek(xFilial("AIF")+xFilial("SB1")+"SB1"+PadR(cProd, TamSX3("AIF_CODPRO")[1])))
        EndIf

        // Verifica se existe complemento SB5.
        If !Empty(cPRDPRIB5) .And. SB5->(MsSeek(xFilial("SB5") + cProd))
            //Verifica existencia do campo indicado no parametro MV_PRDPRI.
            nFldPrdPri := Iif(Empty(cPRDPRIB5), 0, SB5->(FieldPos(cPRDPRIB5)))
            // Se existir, seta a flag de produto primario.
            If nFldPrdPri > 0
                lProdPrim := SB5->(FieldGet(nFldPrdPri)) <> "N"
            EndIf
        EndIf

    	//Ponto de entrada para o usuario relacionar tipos de produto criados com o codigo da tabela de tipos do ATO COTEPE 09/2008 (layout SPED Fiscal)
    	If lSPDFIS001
    		aTipo := ExecBlock("SPDFIS001", .F., .F., {aTipo,cAliasMov})
    	EndIf

    	//Obtendo o tipo de item para montar o campo do registro
    	cTpPrd := RetFldProd((cAliasMov)->B1_COD,"B1_TIPO",cAliasMov)

    	Iif(Empty(cTpPrd),cTpPrd:=(cAliasMov)->B1_TIPO,)
    	For nTipo := 1 To Len(aTipo)
    		If cTpPrd $ aTipo[nTipo][1]
    			cTipo := aTipo[nTipo][2]
    			Exit
    		EndIf
    	Next nTipo

    	//Verifica o tamanho do código de barras. Deve estar dentro do padrão GTIN (8,12,13,14)
    	If	Len(AllTrim((cAliasMov)->B1_CODBAR)) ==  8 .Or. Len(AllTrim((cAliasMov)->B1_CODBAR)) == 12 .Or.;
    		Len(AllTrim((cAliasMov)->B1_CODBAR)) == 13 .Or. Len(AllTrim((cAliasMov)->B1_CODBAR)) == 14
    		cCodBarra := (cAliasMov)->B1_CODBAR	
    	Endif

    	oBloco0:SetCodItem(cProd)	    																//02 - COD_ITEM

    	//³Tratamento para pegar a informacao valida do cadastro dentro do prazo de geracao do spedifscal³
    	If lHistTab .And. lTemAIF
    		aMod := MsConHist("SB1","","",dDataDe,,Substr(cProd,1,TamSx3("B1_COD")[1]))
    	EndIf

    	cContCampo := RetCmpHist(cAliasMov+"->B1_DESC",aMod,dDataAte,lHistTab)

    	oBloco0:SetDesItem(cContCampo)							//03 - DESCR_ITEM	
    	oBloco0:SetCodBarr(cCodBarra)							//04 - COD_BARRA
    	oBloco0:SetCodAnIt("")									//05 - COD_ANT_IETM
    	oBloco0:SetUnidInv(cUnid)								//06 - UNI_INV
    	oBloco0:SetTipoItm(cTipo)								//07 - TIPO_ITEM

        // 3.3.2 Campo COD_NCM - “Código da Nomenclatura Comum do Mercosul”: para este campo a especificação da obrigatoriedade do preenchimento deve ser “Obrigatório” (O);
    	If (cAliasMov)->(FieldPos("FT_POSIPI")) > 0
    		oBloco0:SetCodNCM((cAliasMov)->FT_POSIPI)			//08 - COD_NCM
    	Else
    		oBloco0:SetCodNCM((cAliasMov)->B1_POSIPI)			//08 - COD_NCM
    	EndIf	

    	oBloco0:SetExIPI((cAliasMov)->B1_EX_NCM)				//09 - EX_IPI

        If Empty((cAliasMov)->B1_CODISS)

    		/*Verifico se utiliza o parametro MV_PRDPRI
    		Este paramentro indica se eh referente a um produto primario, conforme guia pratico, o preenchimento deste campo é obrigatorio apenas para produtos primarios */
    		If nFldPrdPri <> 0    			
    			If (cAliasMov)->(FieldPos("FT_POSIPI")) > 0
    				oBloco0:SetCodGen(Iif(lProdPrim,Left((cAliasMov)->FT_POSIPI,2),""))			//10 - COD_GEN				
    			Else
    				oBloco0:SetCodGen(Iif(lProdPrim,Left((cAliasMov)->B1_POSIPI,2),""))			//10 - COD_GEN
    			EndIf
    		Elseif (cAliasMov)->(FieldPos("FT_POSIPI")) > 0
    			oBloco0:SetCodGen(Left((cAliasMov)->FT_POSIPI,2))								//10 - COD_GEN
    		Else
    			oBloco0:SetCodGen(Left((cAliasMov)->B1_POSIPI,2))								//10 - COD_GEN
    		EndIf			

    	//Para servico, utilizo sempre "00"
    	Else
    		oBloco0:SetCodGen("00")															  	//10 - COD_GEN
    	Endif
    
    	oBloco0:SetCodLst("")																	//11 - COD_LST
    
    	//---Alíquota interna não mais será definida via B1_PICM ou MV_ICMPAD. Será obtida da própria apuração, através da tabela F1J---//
    	oBloco0:SetAliqICM(nAliqEfet)															//12 - ALIQ_ICM
    
        If lSX3B1CEST
            oBloco0:SetCest((cAliasMov)->B1_CEST)
        Else
            oBloco0:SetCest('')                                                      			//13 - CEST
        Endif

        // Adiciona um novo 0200
        oBloco0:Add0200()

        // Obtem chave do 0200 gerado para gerar os registros filhos.
        cChv0200 := oBloco0:GetGrupo()

        //REGISTRO 0205 - ALTERACOES DO ITEM
        If lTemAIF
    
    		// Conforme manual o, caso não tenha ocorrido movimentação no período da alteração do item, deverá ser informada no primeiro período em que houver movimentação do item 
   			aHist := MsConHist("SB1","","",MonthSub(ddatade,nMV205HIST),dDataAte,Substr(cProd,1,TamSx3("B1_COD")[1]))

            If (cAliasMov)->(FieldPos("FT_CFOP")) > 0
    	        cAliasIt := IIf (Substr((cAliasMov)->FT_CFOP,1,1)>="5", "SD2", "SD1")
            EndIf

    		//Exclui alteracoes que nao sejam de "B1_DESC"
    		nX := 1
    		While nX <= Len(aHist)
    			If Alltrim(aHist[nX][1])<>"B1_DESC"
    				If Alltrim(aHist[nX][1])=="B1_CODANT"
    					aadd(aHistCod,aHist[nx])
    				Endif	
    				aDel(aHist, nX)
    				aSize(aHist, Len(aHist) - 1)
    				nX := 0
    			ElseIf cAliasIt $ "SD1/SD2"
    				DbSelectArea(cAliasIt)
    				If cAliasIt $ "SD1"
    					(cAliasIt)->(DbSetOrder(2)) //filial + Produto
    				Else
    					(cAliasIt)->(DbSetOrder(1)) //filial + produto
    				EndIF
    				If ((cAliasIt)->(DbSeek(xFilial(cAliasIt)+Substr(cProd,1,TamSx3("B1_COD")[1]))))
    					cCampData	:= SubStr (cAliasIt,2,2)+"_EMISSAO"
    					cCampCod	:= SubStr (cAliasIt,2,2)+"_COD"
    					While !(cAliasIt)->(Eof()) .AND. ((cAliasIt)->&cCampData>= aHist[nX][3]) .AND. ((cAliasIt)->&cCampData<= dDataAte) .And. (cAliasIt)->&cCampCod == Substr(cProd,1,TamSx3("B1_COD")[1])
    						If (cAliasIt)->&cCampCod == Substr(cProd,1,TamSx3("B1_COD")[1]) .And. !((cAliasIt)->&cCampData >= dDataDe)
    							aHist := {}
    							Exit
    						EndIf
    						(cAliasIt)->(dbSkip())
    					EndDo
    				EndIf
    			EndIf
    			nX++
    		EndDo

    		//Verificando se a função MsConHist retornou pelo menos um array
    		If Len(aHist) > 0 .Or. Len(aHistCod) > 0

    			//Exclui alteracoes de "B1_DESC" que sejam do mesmo dia com horarios menores, deixa a ultima
    			nY := 1
    			While nY <= Len(aHist)
    				For nX := 1 To Len(aHist)
    					If Len(aHist)>1 .And. nX<=Len(aHist)
    						If nX > 1 .And. nX<Len(aHist)
    							If (aHist[nX][3]=aHist[nX-1][3]) .And. (aHist[nX][4]>=aHist[nX-1][4])
    								aDel(aHist, nX-1)
    								aSize(aHist, Len(aHist) - 1)
    								nX := 0
    							ElseIf (aHist[nX][3]=aHist[nX+1][3]) .And. (aHist[nX][4]<=aHist[nX+1][4])
    								aDel(aHist, nX+1)
    								aSize(aHist, Len(aHist) - 1)
    								nX := 0
    							EndIf
    						ElseIf nX > 1 .And. nX=Len(aHist)
    							If (aHist[nX][3]=aHist[nX-1][3]) .And. (aHist[nX][4]>=aHist[nX-1][4])
    								aDel(aHist, nX-1)
    								aSize(aHist, Len(aHist) - 1)
    								nX := 0
    							EndIf
    						EndIf
    					Else
    						Exit
    					EndIf
    				Next nX
    				nY++
    			Enddo

    			//Passando para um array auxiliar os arrays que são do campo B1_DESC, para ordenar corretamente por DATA e HORA de alteração
    			For nX := 1 To Len(aHist)
    				//Atribuindo a variavel cDescProd o valor da 'DESCRIçãO ANTERIOR DO PRODUTO' da ultima alteração
    				cDescProd := aHist[nX][2]

    				//Atribuindo a ultima data de alteração a variavel dDataFinal
    				dDataFinal := aHist[nX][3]-1
    				If nX==1
    					dDataInici := &(cCmpDTINCB1)
    					If Empty(dDataInici)
    						dDataInici := aHist[nX][3]
    					Endif
    				Else
    					//Atribuindo a penultima data de alteração a variavel dDataInici independente se houve alteracao ou não no mesmo dia
    					dDataInici := aHist[nX-1][3]

    					/*Este tratamento abaixo foi efetuado para tratar alteracoes de produto validas por um dia. Neste caso, leva a data fim como sendo a data contida no historico
    					Devido a restricoes no layout */
    					If nX = Len(aHist) .And. dDataFinal = dDataInici
    						dDataFinal := aHist[nX][3]
    					EndIf
    				Endif
    
    				If Valtype(dDataInici) != Valtype(dDataFinal) .And. !Empty(dDataInici)
    					dDataInici := IIF(Valtype(dDataInici) == "C" .And. Valtype(dDataFinal) == "D", StoD(dDataInici)  ,dDataInici )
    				EndIf

    				/* Tratamento na geracao do registro 0205 - Alteracao do Item quando um item for alterado na data final do arquivo do Sped Fiscal
    				Este tratamento abaixo de <= foi efetuado para tratar alteracoes de produto validas por um dia. Neste caso, o registro e gerado com data devido a restricoes no layout */
    				If dDataFinal <= dDataAte .And. Alltrim(aHist[nX][1])$"B1_DESC"
    					If dDataInici < dDataFinal                        
    					    oBloco0:SetRelac(cChv0200)
    						oBloco0:SetDescAnt(cDescProd)												//02 - DESCR_ANT_ITEM
    						IF dDataInici < dDataCont
                                oBloco0:SetDtIniUt(dDataCont)                                           //03 - DT_INI
    						Else
                                oBloco0:SetDtIniUt(dDataInici)                                          //03 - DT_INI
    						EndIF
    						oBloco0:SetDtFimUt(dDataFinal)												//04 - DT_FIM    						
    						//A partir da versão 008 o PVA aceita dois registros 0205, então não deverá informar neste registro CODANT
    						//pois o PVA não aceita mais o CODANT e DescProd no mesmo 0205. CODANT será informado em outro registro 0205 abaixo.
    						 oBloco0:SetCodAnt('') //05 - COD_ANT_ITEM - LAYOUT 2010

                            // Adiciona um novo 0205
                            oBloco0:Add0205()
    					Endif
    				Endif
                    									
    				If !Empty(Alltrim((cAliasMov)->B1_CODANT))					
    					//Segundo registro 0205 com o CODANT e sem Descricção anterior.
                        oBloco0:SetRelac(cChv0200)
                        oBloco0:SetDescAnt("")												//02 - DESCR_ANT_ITEM
                        IF dDataInici < dDataCont
                            oBloco0:SetDtIniUt(dDataCont)                                           //03 - DT_INI
                        Else
                            oBloco0:SetDtIniUt(dDataInici)                                          //03 - DT_INI
                        EndIF
                        oBloco0:SetDtFimUt(dDataFinal)												//04 - DT_FIM                        
                        //A partir da versão 008 o PVA aceita dois registros 0205, então não deverá informar neste registro CODANT
                        //pois o PVA não aceita mais o CODANT e DescProd no mesmo 0205. CODANT será informado em outro registro 0205 abaixo.
                        oBloco0:SetCodAnt((cAliasMov)->B1_CODANT) //05 - COD_ANT_ITEM - LAYOUT 2010    					

                        // Adiciona um novo 0205
                        oBloco0:Add0205()
    				EndIf

    			Next nX

    			If !Empty(aHist)
    				aHistCod := {}
    			Endif

    			If !Empty(aHistCod)
    				If Empty(aHist)
    					dDataInici := &(cCmpDTINCB1)
    				Endif
    				dDataFinal := aHistCod[1][3]

    				If Valtype(dDataInici) != Valtype(dDataFinal) .And. !Empty(dDataInici)
    					dDataInici := IIF(Valtype(dDataInici) == "C" .And. Valtype(dDataFinal) == "D", StoD(dDataInici)  ,dDataInici )
    				EndIf

    				If !Empty(Alltrim((cAliasMov)->B1_CODANT))
                        //Segundo registro 0205 com o CODANT e sem Descricção anterior.
                        oBloco0:SetRelac(cChv0200)
                        oBloco0:SetDescAnt("")												//02 - DESCR_ANT_ITEM
                        IF dDataInici < dDataCont
                            oBloco0:SetDtIniUt(dDataCont)                                           //03 - DT_INI
                        Else
                            oBloco0:SetDtIniUt(dDataInici)                                          //03 - DT_INI
                        EndIF
                        oBloco0:SetDtFimUt(dDataFinal)												//04 - DT_FIM                        
                        //A partir da versão 008 o PVA aceita dois registros 0205, então não deverá informar neste registro CODANT
                        //pois o PVA não aceita mais o CODANT e DescProd no mesmo 0205. CODANT será informado em outro registro 0205 abaixo.
                        oBloco0:SetCodAnt((cAliasMov)->B1_CODANT) //05 - COD_ANT_ITEM - LAYOUT 2010    					

                        // Adiciona um novo 0205
                        oBloco0:Add0205()
    				EndIF					
    			EndIf

    		EndIf

            // Verifica se existe complemento de combustíveis p/ o documento.
            lAchouCD6 := CD6->(MsSeek(xFilial("CD6")          +;
                                     (cAliasMov)->F1M_TPMOV   +;
                                     (cAliasMov)->F1M_SERIE   +;
                                     (cAliasMov)->F1M_NFISCA  +;
                                     (cAliasMov)->F1M_PARTIC  +;
                                     (cAliasMov)->F1M_LOJA    +;
                                     (cAliasMov)->F1M_ITEM    +;
                                     (cAliasMov)->F1M_PRODUT))

    		//³REGISTRO 0206 - CODIGO DE PRODUTO CONFORME TABELA PUBLICADA PELA ANP (COMBUSTIVEIS)  ³
    		If lAchouCD6 .And. !Empty(AllTrim(CD6->CD6_CODANP))
                oBloco0:SetRelac(cChv0200)
    			oBloco0:SetCodANP(AllTrim(CD6->CD6_CODANP))					//02 - COD_COMB

                // Adiciona um novo 0206
                oBloco0:Add0206()
    		EndIF

        EndIf

    Else
        cChv0200 := aGet0200[2]
    EndIf

    // REGISTRO 0220 - FATORES DE CONVERSÃO DE UNIDADES
    IF lSegUnid .Or. lSegUnidPE

        cSegUnid := Iif(lSegUnidPE, (cAliasMov)->F1M_UNIDAD, (cAliasMov)->B1_SEGUM)   
    	nConv	 := Iif(lSegUnidPE, (cAliasMov)->F1M_FATCON, (cAliasMov)->B1_CONV)   
    	cTpConv	 := Iif(lSegUnidPE, 'M'                    , (cAliasMov)->B1_TIPCONV)

        If !Empty(cSegUnid) .AND. cSegUnid <> cUnid
            oBloco0:SetRelac(cChv0200)
            oBloco0:SetUndConv(cSegUnid)				//02 - UNID_CONV				
            If cTpConv == "D"
                oBloco0:SetFatConv((1/nConv))			//03 - FAT_CONV
            Else
                oBloco0:SetFatConv(nConv)				//03 - FAT_CONV
            EndIf

            // Adiciona um novo 0220
            oBloco0:Add0220(lSegUnidPE)

            // Adiciona um 0190 com a segunda unidade de medida.
            oBloco0:SetRelac(cChvBlc0)
            oBloco0:SetUnidInv(cSegUnid)    
            oBloco0:Add0190()
        EndIf

    EndIf

Return (lRet)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcContab
  
Rotina para tratamento das informações do contabilista, utilizadas no registro 0100.

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function ProcContab()
	Local aFsa234  := {}
	Local aFsa234C := {}

	//---Guarda pergunte inicial da rotina---//
	aAdd(aFsa234,MV_PAR01)
	aAdd(aFsa234,MV_PAR02)
	aAdd(aFsa234,MV_PAR03)
	aAdd(aFsa234,MV_PAR04)
	aAdd(aFsa234,MV_PAR05)
	aAdd(aFsa234,MV_PAR06)
	aAdd(aFsa234,MV_PAR07)

	//--Chama perguntas do contabilista e armazena em aFsa234C
	If Pergunte('FSA234C',.T.,'Parâmetros do Contabilista')
		aAdd(aFsa234C,MV_PAR01)
		aAdd(aFsa234C,MV_PAR02)
		aAdd(aFsa234C,MV_PAR03)
		aAdd(aFsa234C,MV_PAR04)
		aAdd(aFsa234C,MV_PAR05)
		aAdd(aFsa234C,MV_PAR06)
		aAdd(aFsa234C,MV_PAR07)
		aAdd(aFsa234C,MV_PAR08)
		aAdd(aFsa234C,MV_PAR09)
		aAdd(aFsa234C,MV_PAR10)
		aAdd(aFsa234C,MV_PAR11)
		aAdd(aFsa234C,MV_PAR12)
		aAdd(aFsa234C,MV_PAR13)
	Else
		aAdd(aFsa234C,'')
		aAdd(aFsa234C,'')
		aAdd(aFsa234C,'')
		aAdd(aFsa234C,'')
		aAdd(aFsa234C,'')
		aAdd(aFsa234C,'')
		aAdd(aFsa234C,'')
		aAdd(aFsa234C,'')
		aAdd(aFsa234C,'')
		aAdd(aFsa234C,'')
		aAdd(aFsa234C,'')
		aAdd(aFsa234C,'')
		aAdd(aFsa234C,'')
	EndIf

	//---Restaura as informações da pergunta inicial---//
	MV_PAR01 := aFsa234[1]
	MV_PAR02 := aFsa234[2]
	MV_PAR03 := aFsa234[3]
	MV_PAR04 := aFsa234[4]
	MV_PAR05 := aFsa234[5]
	MV_PAR06 := aFsa234[6]
	MV_PAR07 := aFsa234[7]
    MV_PAR08 := ''
    MV_PAR09 := ''
    MV_PAR10 := ''
    MV_PAR11 := ''
    MV_PAR12 := ''
    MV_PAR13 := ''
	
Return aFsa234C


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA234SEQ
  
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA234SEQ(aGrupoReg,cGrupoPai,cReg)
    Local nPos      := 0
    Local cGrupoReg := ''

    nPos := aScan(aGrupoReg, {|aX| aX[1] == cReg })
    If nPos > 0
        aGrupoReg[nPos][2] ++
    Else
        aAdd(aGrupoReg, {})
        nPos := Len(aGrupoReg)
        aAdd(aGrupoReg[nPos], cReg)
        aAdd(aGrupoReg[nPos], 1)
    EndIf

    cGrupoReg := cGrupoPai + cReg + Strzero(aGrupoReg[nPos][2],9)
Return cGrupoReg


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSA234BLCH
  
Função responsável pela geração do bloco H.

@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function FSA234BLCH(oSay,oBlocoH,oTabela,aNumeracao,cChaveBlcH,cPerApur,dDataAte)

Local lSPDBlocH := FindFunction("SPDBlocH")
Local cAliBLH   := ""
Local cAlsF1J   := ""
Local cProduto  := ""
Local nTotInv   := 0

If lSPDBlocH
    cAliBLH := GetNextAlias()
    SPDBlocH(@cAliBLH,'',dDataAte)
EndIf

If !Empty(cAliBLH)
    // Abertura do alias p/ query na F1J.
    cAlsF1J   := GetNextAlias()

    // Seta indice do temporário
    (cAliBLH)->(DbSetOrder(1)) //---FILIAL+COD_ITEM+IND_PROP+COD_PART---//

    // Query na F1J p/ obter os produtos que foram apurados no período.
    BeginSql Alias cAlsF1J
        SELECT
            F1J.F1J_PRODUT
        FROM %Table:F1J% F1J
        WHERE
            F1J.F1J_FILIAL = %xFilial:F1J%        AND
            F1J.F1J_ANOMES = %Exp:cPerApur%       AND
           (F1J_QTDVCF+F1J_QTDSOE+F1J_QTDSSN) > 0 AND
            F1J.%NotDel%
        ORDER BY F1J.F1J_PRODUT
    EndSql

    dbSelectArea(cAlsF1J)
    (cAlsF1J)->(dbGoTop())

    While (cAlsF1J)->(!Eof())

        cProduto := (cAlsF1J)->F1J_PRODUT

        // Para cada produto apurado, procuro no temporário as informações sobre o estoque.
        // Conforme layout, é obrigatório que o indicador de propriedade seja “0 -  Item de propriedade do informante e em seu poder”.
        If (cAliBLH)->(DbSeek(xFilial("SB2") + cProduto + "0"))

            oBlocoH:SetNumer(aNumeracao)
            oBlocoH:SetRelac(cChaveBlcH)
            oBlocoH:SetCodItem((cAliBLH)->COD_ITEM)
            oBlocoH:SetUnid((cAliBLH)->UNID)
            oBlocoH:SetQtde((cAliBLH)->QTD)
            oBlocoH:SetVlUnit((cAliBLH)->VL_UNIT)
            oBlocoH:SetVlItem((cAliBLH)->VL_ITEM)
            oBlocoH:SetIndProp((cAliBLH)->IND_PROP)
            oBlocoH:SetCodPart("") // Não precisa gerar quando o indicador de propriedade é 0 (Neste caso sempre será)
            oBlocoH:SetTxtCompl("")
            oBlocoH:SetConta((cAliBLH)->COD_CTA)
            oBlocoH:SetVlrItemIR((cAliBLH)->VL_ITEM_IR)
            oBlocoH:AddH010()

            // Soma VL_ITEM para gerar o registro H005 posteriormente
            nTotInv += (cAliBLH)->VL_ITEM

        EndIf

        (cAlsF1J)->(dbSkip())

    EndDo

    // No final do laço gera o registro H005 (Totalizador) com a soma de VL_ITEM.
    oBlocoH:SetNumer(aNumeracao)
    oBlocoH:SetRelac(cChaveBlcH)
    oBlocoH:SetDtInv(dDataAte)
    oBlocoH:SetVlInv(nTotInv)
    oBlocoH:SetMotInv("05") // Por determinação do layout deve ser, obrigatoriamente, 05.
    oBlocoH:AddH005()

    // Gravação dos registros no TRB.
    oTabela:GrvReg(oBlocoH:GetH010())
    oTabela:GrvReg(oBlocoH:GetH005())

    // Fecha os alias utilizados
    (cAlsF1J)->(dbCloseArea())
    (cAliBLH)->(dbCloseArea())

EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSA234BLC2
  
Função responsável pela geração do bloco 2.

@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function FSA234BLC2(oSay,oBloco0,oBloco2,oTabela,aNumeracao,cChaveBlc0,cChaveBlc2,cPerApur,dDataDe,dDataAte)
    Local aArea      := GetArea()
    Local cAlsF1I    := GetNextAlias()
    Local cAlsF1J    := GetNextAlias()
    Local cAlsF1K    := GetNextAlias()
    Local cAlsF1L    := GetNextAlias()
    Local cAlsF1M    := GetNextAlias()
    Local cIdApur    := ''
    Local cProduto   := ''
    Local nAliqEfet  := 0
    Local cChave2110 := ''
    Local cChave2113 := ''
    Local cChave2120 := ''
    Local cChave2121 := ''
    Local cChave212X := ''
    Local cChave2130 := ''
    Local aDocOriApu := {}
    Local aVlrCmp    := {}
    Local lF1L2121   := F1L->(FieldPos("F1L_QTDVLM")) > 0 .And. F1L->(FieldPos("F1L_CODREG")) > 0
    Local lF1MTagRet := F1M->(FieldPos("F1M_TAGRET")) > 0
    Local lF1MNfComp := F1M->(FieldPos("F1M_NFCOMP")) > 0
    Local cF1L2121   := ''
    Local cF1MTagRet := ''
    Local cF1MNfComp := ''
    Local nCont      := 0
    Local cItemDoc   := ''
    Local cItemCmp   := ''
    Local nItemDoc   := 0
    Local lF1MVlrTot := F1M->(FieldPos("F1M_VLRTOT")) > 0
    Local cF1MVlrTot := ""
    //---Inclusão de campos atrelada à existencia desses campos no dicionário de dados---//
    If lF1L2121
        cF1L2121 := ', F1L_QTDVLM, F1L_CODREG'
    EndIf
    If lF1MTagRet
        cF1MTagRet := ', F1M_TAGRET '
    EndIf
    If lF1MNfComp
        cF1MNfComp := 'F1M_NFCOMP, '
    EndIf
    If lF1MVlrTot
        cF1MVlrTot := ' ,F1M_VLRTOT '
    EndIf
    cF1L2121   := "%" + cF1L2121   + "%"
    cF1MTagRet := "%" + cF1MTagRet + "%"
    cF1MNfComp := "%" + cF1MNfComp + "%"
    cF1MVlrTot := "%" + cF1MVlrTot + "%"

    dbSelectArea("SB1")
    SB1->(DbSetOrder(1))

    //--------------------------------//
    //---Registro 2100 - Tabela F1I---//
    //--------------------------------//
    BeginSql Alias cAlsF1I
        SELECT F1I_IDAPUR, F1I_VLREST, F1I_VLCOMP, F1I_SDREST, F1I_SDRESS, F1I_SDCOMP, F1I_SDICOP, F1I_VLACRE, F1I_VLACOM
        FROM %TABLE:F1I% F1I
        WHERE F1I_FILIAL = %XFILIAL:F1I%  AND 
              F1I_ANOMES = %EXP:cPerApur% AND 
              F1I.%NOTDEL%
    EndSql

    DbSelectArea(cAlsF1I)
    (cAlsF1I)->(DbGoTop())
    If !(cAlsF1I)->(Eof()) .And. !Empty((cAlsF1I)->F1I_IDAPUR)

        cIdApur := (cAlsF1I)->F1I_IDAPUR

        //---Seta valores para o array aReg2100 do objeto e grava registro gerado no array aReg2100 na tabela temporária---//
        oBloco2:SetNumer(aNumeracao)
        oBloco2:SetRelac(cChaveBlc2)
        oBloco2:SetReg("2100")                     //01 - REG
        oBloco2:Set2100C02((cAlsF1I)->F1I_VLREST)  //02 - S_VL_ICMS_ST_REST 
        oBloco2:Set2100C03((cAlsF1I)->F1I_VLCOMP)  //03 - S_VL_ICMS_ST_COMPL
        oBloco2:Set2100C04((cAlsF1I)->F1I_SDREST)  //04 - SD_ICMS_ST_REST   
        oBloco2:Set2100C05((cAlsF1I)->F1I_SDRESS)  //05 - SD_ICMS_ST_RESS   
        oBloco2:Set2100C06((cAlsF1I)->F1I_SDCOMP)  //06 - SD_ICMS_ST_COMPL  
        oBloco2:Set2100C07((cAlsF1I)->F1I_SDICOP)  //07 - SD_ICMS_OP        
        oBloco2:Set2100C08((cAlsF1I)->F1I_VLACRE)  //08 - V_APUR_CRED_ICMS  
        oBloco2:Set2100C09((cAlsF1I)->F1I_VLACOM)  //09 - V_APUR_ICMS_COMP  
        oBloco2:Add2100()

    EndIf
    (cAlsF1I)->(DbCloseArea())
    //------------------------------------//
    //---FIM Registro 2100 - Tabela F1I---//
    //------------------------------------//

    If !Empty(cIdApur)

        //--------------------------------//
        //---Registro 2110 - Tabela F1J---//
        //--------------------------------//
        BeginSql Alias cAlsF1J
            SELECT F1J_PRODUT, F1J_QTDVCF, F1J_VLRVCF, F1J_VMUVCF, F1J_VBSTCF, F1J_VMABST, F1J_VMEBST, F1J_ALIQEF, F1J_VLREST, F1J_VLCOMP, F1J_QTDSOE, F1J_VICMOE, F1J_VISTOE, F1J_QTDSSN, F1J_VCRDSN
            FROM %TABLE:F1J% F1J
            WHERE  F1J.F1J_FILIAL = %XFILIAL:F1J%        AND
                   F1J.F1J_IDAPUR = %EXP:cIdApur%        AND
                  (F1J_QTDVCF+F1J_QTDSOE+F1J_QTDSSN) > 0 AND
                   F1J.%NOTDEL%	
            ORDER BY F1J.F1J_PRODUT
        EndSql

        DbSelectArea(cAlsF1J)
        (cAlsF1J)->(DbGoTop())
        While !(cAlsF1J)->(Eof())
            cProduto  := (cAlsF1J)->F1J_PRODUT
            nAliqEfet := (cAlsF1J)->F1J_ALIQEF

            //---Seta valores para o array aReg2110 do objeto---//
            oBloco2:SetNumer(aNumeracao)
            oBloco2:SetRelac(cChaveBlc2)
            oBloco2:SetReg("2110")                     //01 - REG
            oBloco2:Set2110C02((cAlsF1J)->F1J_PRODUT)  //02 - COD_ITEM           
            oBloco2:Set2110C03((cAlsF1J)->F1J_QTDVCF)  //03 - QTDE_T_V_CF        
            oBloco2:Set2110C04((cAlsF1J)->F1J_VLRVCF)  //04 - VL_T_V_CF          
            oBloco2:Set2110C05((cAlsF1J)->F1J_VMUVCF)  //05 - VLM_UNIT_V_CF      
            oBloco2:Set2110C06((cAlsF1J)->F1J_VBSTCF)  //06 - VL_T_BCST_V_CF     
            oBloco2:Set2110C07((cAlsF1J)->F1J_VMABST)  //07 - VL_DIF_MAIOR_BCST  
            oBloco2:Set2110C08((cAlsF1J)->F1J_VMEBST)  //08 - VL_DIF_MENOR_BCST  
            oBloco2:Set2110C09((cAlsF1J)->F1J_ALIQEF)  //09 - ALIQ_EF            
            oBloco2:Set2110C10((cAlsF1J)->F1J_VLREST)  //10 - VL_ICMS_ST_REST    
            oBloco2:Set2110C11((cAlsF1J)->F1J_VLCOMP)  //11 - VL_ICMS_ST_COMPL   
            oBloco2:Set2110C12((cAlsF1J)->F1J_QTDSOE)  //12 - QTDE_T_IND_S_OE    
            oBloco2:Set2110C13((cAlsF1J)->F1J_VICMOE)  //13 - VL_ICMS_IND_S_OE   
            oBloco2:Set2110C14((cAlsF1J)->F1J_VISTOE)  //14 - VL_ICMS_ST_IND_S_OE
            oBloco2:Set2110C15((cAlsF1J)->F1J_QTDSSN)  //15 - QTDE_T_IND_S_SN    
            oBloco2:Set2110C16((cAlsF1J)->F1J_VCRDSN)  //16 - VL_T_CREDITO_MVA_SN
            oBloco2:Add2110()

            cChave2110 := oBloco2:GetGrupo()

            //--------------------------------//
            //---Registro 2112 - Tabela F1K---//
            //--------------------------------//
            BeginSql Alias cAlsF1K
                SELECT F1K_QTDVCF, F1K_UNID, F1K_FATCON, F1K_QTVCFC, F1K_VLRVCF
                FROM %TABLE:F1K% F1K
                WHERE  F1K.F1K_FILIAL = %XFILIAL:F1K% AND
                       F1K.F1K_IDAPUR = %EXP:cIdApur% AND
                       F1K.F1K_PRODUT = %EXP:cProduto% AND
                       F1K.%NOTDEL%	
                ORDER BY F1K.F1K_UNID
            EndSql
    
            DbSelectArea(cAlsF1K)
            (cAlsF1K)->(DbGoTop())
            While !(cAlsF1K)->(Eof())

                //---Seta valores para o array aReg2120 do objeto---//
                oBloco2:SetNumer(aNumeracao)
                oBloco2:SetRelac(cChave2110)
                oBloco2:SetReg("2112")                     //01 - REG
                oBloco2:SetQtdMov((cAlsF1K)->F1K_QTDVCF)   //02 - QTDE_V_CF     
                oBloco2:SetUnid((cAlsF1K)->F1K_UNID)       //03 - UNID          
                oBloco2:SetFatConv((cAlsF1K)->F1K_FATCON)  //04 - FAT_CONV      
                oBloco2:SetQtdConv((cAlsF1K)->F1K_QTVCFC)  //05 - QTDE_V_CF_C   
                oBloco2:SetVlrCont((cAlsF1K)->F1K_VLRVCF)  //06 - VL_V_CF       
                oBloco2:Add2112()

                (cAlsF1K)->(DbSkip())
            EndDo
            (cAlsF1K)->(DbCloseArea())
            //------------------------------------//
            //---FIM Registro 2112 - Tabela F1K---//
            //------------------------------------//

            //----------------------------------------//
            //---Registros 2120 e 2121 - Tabela F1L---//
            //----------------------------------------//
            cChave2120 := ''
            cChave2121 := ''
            BeginSql Alias cAlsF1L
                SELECT F1L_QTDENT, F1L_TOTBST, F1L_VMUBST, F1L_TOTICM, F1L_VMUICM, F1L_TOTIST, F1L_VMUIST %Exp:cF1L2121%
                FROM %TABLE:F1L% F1L
                WHERE  F1L.F1L_FILIAL = %XFILIAL:F1L%  AND
                       F1L.F1L_IDAPUR = %EXP:cIdApur%  AND
                       F1L.F1L_PRODUT = %EXP:cProduto% AND
                       F1L.%NOTDEL%	
            EndSql

            DbSelectArea(cAlsF1L)
            (cAlsF1L)->(DbGoTop())
            While !(cAlsF1L)->(Eof())

                If !lF1L2121 .Or. ((cAlsF1L)->F1L_CODREG == '' .Or. (cAlsF1L)->F1L_CODREG == '2120')

                    //---Seta valores para o array aReg2120 do objeto---//
                    oBloco2:SetNumer(aNumeracao)
                    oBloco2:SetRelac(cChave2110)
                    oBloco2:SetReg("2120")                     //01 - REG
                    oBloco2:Set2120C02((cAlsF1L)->F1L_QTDENT)  //02 - S_QTDE_C          
                    oBloco2:Set2120C03((cAlsF1L)->F1L_TOTBST)  //03 - S_VL_BCST_INT     
                    oBloco2:Set2120C04((cAlsF1L)->F1L_VMUBST)  //04 - VLM_UNIT_BCST     
                    oBloco2:Set2120C05((cAlsF1L)->F1L_TOTICM)  //05 - S_VL_ICMS         
                    oBloco2:Set2120C06((cAlsF1L)->F1L_VMUICM)  //06 - VLM_UNIT_ICMS     
                    oBloco2:Set2120C07((cAlsF1L)->F1L_TOTIST)  //07 - S_VL_ICMS_ST      
                    oBloco2:Set2120C08((cAlsF1L)->F1L_VMUIST)  //08 - VLM_UNIT_ICMS_ST  
                    oBloco2:Add2120()

                    cChave2120 := oBloco2:GetGrupo()

                ElseIf (cAlsF1L)->F1L_CODREG == '2121'

                    //---Seta valores para o array aReg2121 do objeto---//
                    oBloco2:SetNumer(aNumeracao)
                    oBloco2:SetRelac(cChave2110)
                    oBloco2:SetReg("2121")                     //01 - REG
                    oBloco2:Set2121C02((cAlsF1L)->F1L_QTDENT)  //02 - S_QTDE_C_T          
                    oBloco2:Set2121C03((cAlsF1L)->F1L_QTDVLM)  //03 - S_QTDE_C_VLM     
                    oBloco2:Set2121C04((cAlsF1L)->F1L_TOTBST)  //04 - S_VL_BCST_INT_VLM     
                    oBloco2:Set2121C05((cAlsF1L)->F1L_VMUBST)  //05 - VLM_UNIT_BCST_G         
                    oBloco2:Add2121()

                    cChave2121 := oBloco2:GetGrupo()

                EndIf

                (cAlsF1L)->(DbSkip())
            EndDo
            (cAlsF1L)->(DbCloseArea())
            cChave212X := Iif(!Empty(cChave2120) .And. !Empty(cChave2121), cChave2121, Iif(!Empty(cChave2120), cChave2120, cChave2121))
            //-------------------------------------------//
            //---FIM Registros 2120 e 2121 - Tabela F1L--//
            //-------------------------------------------//

            //----------------------------------------//
            //---Registros 2113 e 2130 - Tabela F1M---//
            //----------------------------------------//
            BeginSql Alias cAlsF1M
                COLUMN F1M_DTMOV AS DATE

                SELECT F1M_TPMOV, F1M_PARTIC, F1M_LOJA, F1M_DTMOV, F1M_INDOP, F1M_ITEM, F1M_CFOP, F1M_CHVDOC, F1M_CNPJ, F1M_QTDMOV, F1M_UNIDAD, F1M_FATCON, F1M_QTDCON, F1M_VLRCON,  
                       F1M_BASICM, F1M_ALQICM, F1M_VLRICM, F1M_BASIST, F1M_ALQIST, F1M_VLRIST, F1M_BCEFST, F1M_ALQEST, F1M_CALCST, F1M_CODAJU, F1M_CODDA, F1M_NMDARE, F1M_CODRES, 
                       F1M_INDSAI, F1M_VCRDSN, F1M_NFISCA, F1M_SERIE, F1M_PARTIC, F1M_LOJA, F1M_PRODUT %Exp:cF1MTagRet%,  %Exp:cF1MNfComp% 
                       B1_COD, B1_TIPO, B1_CEST, B1_UM, B1_SEGUM, B1_TIPCONV, B1_CONV, B1_DATREF, B1_CODBAR, B1_DESC, B1_POSIPI, B1_EX_NCM, B1_CODISS, B1_PICM, B1_CODANT, 
	                   SFT.FT_POSIPI, SFT.FT_CFOP, SFT.FT_NFORI, SFT.FT_SERORI, SFT.FT_ITEMORI %Exp:cF1MVlrTot% 
                FROM %TABLE:F1M% F1M INNER JOIN %TABLE:SB1% SB1 ON (SB1.B1_FILIAL = %XFILIAL:SB1% AND SB1.B1_COD     = F1M.F1M_PRODUT AND SB1.%NOTDEL%)
                                     INNER JOIN %TABLE:SFT% SFT ON (SFT.FT_FILIAL = %XFILIAL:SFT% AND SFT.FT_TIPOMOV = F1M.F1M_TPMOV  AND SFT.FT_SERIE = F1M.F1M_SERIE AND SFT.FT_NFISCAL = F1M.F1M_NFISCA AND SFT.FT_CLIEFOR = F1M.F1M_PARTIC AND SFT.FT_LOJA = F1M.F1M_LOJA AND SFT.FT_ITEM = F1M.F1M_ITEM AND SFT.FT_PRODUTO = F1M.F1M_PRODUT AND SFT.%NOTDEL%)
                WHERE  F1M.F1M_FILIAL = %XFILIAL:F1M%  AND
                       F1M.F1M_IDAPUR = %EXP:cIdApur%  AND
                       F1M.F1M_PRODUT = %EXP:cProduto% AND
                       F1M.%NOTDEL%	
                ORDER BY F1M.F1M_ORDEM, F1M.F1M_PARTIC, F1M.F1M_LOJA, F1M.F1M_NFISCA, F1M.F1M_ITEM, F1M.F1M_SERIE 
            EndSql

            DbSelectArea(cAlsF1M)
            (cAlsF1M)->(DbGoTop())
            While !(cAlsF1M)->(Eof())

                //---Ajuste do item quando este está no formato alfanumérico---//
                cItemDoc := PadL(Right(AllTrim((cAlsF1M)->F1M_ITEM),3),3,'0')
                If cItemDoc > '099'
                    nItemDoc := oBloco2:DoCvItem(Right(cItemDoc,2))
                    cItemDoc := Iif(nItemDoc > 0, StrZero(nItemDoc,3), cItemDoc) 
                EndIf

                If ((cAlsF1M)->F1M_TPMOV == 'E' .And. (cAlsF1M)-> F1M_INDOP == '0') .Or. ((cAlsF1M)->F1M_TPMOV == 'S' .And. (cAlsF1M)->F1M_INDOP == '1')

                    //---Seta valores para o array aReg2130 do objeto---//
                    oBloco2:SetNumer(aNumeracao)
                    oBloco2:SetRelac(cChave212X)  
                    oBloco2:SetReg("2130")                                 //01 - REG
                    oBloco2:SetIndOp((cAlsF1M)->F1M_INDOP)                 //02 - IND_OPER   
                    oBloco2:SetChvDoc((cAlsF1M)->F1M_CHVDOC)               //03 - CHV_NFE    
                    oBloco2:SetDataMov((cAlsF1M)->F1M_DTMOV)               //04 - DT_E       |05 - DT_NFE     
                    oBloco2:SetCNPJ((cAlsF1M)->F1M_CNPJ)                   //06 - CNPJ       
                    oBloco2:SetItem(cItemDoc)                              //07 - NUM_ITEM   
                    oBloco2:Set2130C08((cAlsF1M)->F1M_CODRES)              //08 - COD_RESP_RE
                    oBloco2:SetQtdMov((cAlsF1M)->F1M_QTDMOV)               //09 - QTDE       
                    oBloco2:SetUnid((cAlsF1M)->F1M_UNIDAD)                 //10 - UNID       
                    oBloco2:SetFatConv((cAlsF1M)->F1M_FATCON)              //11 - FAT_CONV   
                    oBloco2:SetQtdConv((cAlsF1M)->F1M_QTDCON)              //12 - QTDE_C     
                    oBloco2:SetVlrCont((cAlsF1M)->F1M_VLRCON)              //13 - VL_E       
                    oBloco2:SetCFOP((cAlsF1M)->F1M_CFOP)                   //14 - CFOP       
                    oBloco2:Set2130C15((cAlsF1M)->F1M_BASICM)              //15 - VL_BC_ICMS 
                    oBloco2:Set2130C16((cAlsF1M)->F1M_ALQICM)              //16 - ALIQ_ICMS  
                    oBloco2:Set2130C17((cAlsF1M)->F1M_VLRICM)              //17 - VL_ICMS    
                    oBloco2:Set2130C18((cAlsF1M)->F1M_BASIST)              //18 - VL_BCST    
                    oBloco2:Set2130C19((cAlsF1M)->F1M_BCEFST)              //19 - VL_BCST_INT
                    oBloco2:Set2130C20((cAlsF1M)->F1M_ALQIST)              //20 - ALIQ_ST_E  
                    oBloco2:Set2130C21((cAlsF1M)->F1M_ALQEST)              //21 - ALIQ_ST_EF 
                    oBloco2:Set2130C22((cAlsF1M)->F1M_CALCST)              //22 - CAL_ICMS_ST
                    oBloco2:Set2130C23((cAlsF1M)->F1M_VLRIST)              //23 - VL_ICMS_ST 
                    oBloco2:Set2130C24((cAlsF1M)->F1M_CODDA)               //24 - COD_DA     
                    oBloco2:Set2130C25((cAlsF1M)->F1M_NMDARE)              //25 - NUM_DARE   
                    oBloco2:Set2130C26((cAlsF1M)->F1M_CODAJU)              //26 - COD_AJ C   
                    oBloco2:Add2130()

                    cChave2130 := oBloco2:GetGrupo()

                    //-------------------//
                    //---Registro 2132---//
                    //-------------------//
                    If (cAlsF1M)->F1M_INDOP == '1'

                        aDocOriApu := aSize(aDocOriApu,0)
                        aDocOriApu := Fisa231Ap((cAlsF1M)->F1M_TPMOV, (cAlsF1M)->FT_NFORI, (cAlsF1M)->FT_SERORI, (cAlsF1M)->FT_ITEMORI, (cAlsF1M)->F1M_PARTIC, (cAlsF1M)->F1M_LOJA, (cAlsF1M)->B1_COD, cPerApur)
                        //---Seta valores para o array aReg2132 do objeto---//
                        oBloco2:SetNumer(aNumeracao)
                        oBloco2:SetRelac(cChave2130)
                        oBloco2:SetReg("2132")                 //01 - REG
                        oBloco2:SetCNPJ(aDocOriApu[13])        //02 - CNPJ       
                        oBloco2:SetChvDoc(aDocOriApu[14])      //03 - CHV_NFE_REF
                        oBloco2:SetDataMov(aDocOriApu[01])     //04 - DT_E_REF   
                        oBloco2:Add2132()

                    EndIf

                    //-------------------//
                    //---Registro 2133---//
                    //-------------------//
                    If lF1MNfComp .And. (cAlsF1M)->F1M_NFCOMP == 'S'

                        aVlrCmp := aSize(aVlrCmp,0)
                        aVlrCmp := FISA231CMP((cAlsF1M)->F1M_TPMOV, (cAlsF1M)->F1M_NFISCA, (cAlsF1M)->F1M_SERIE, (cAlsF1M)->F1M_ITEM, (cAlsF1M)->F1M_PARTIC, (cAlsF1M)->F1M_LOJA, (cAlsF1M)->B1_COD, (cAlsF1M)->F1M_DTMOV)

                        If Len(aVlrCmp) > 0 .And. aVlrCmp[10] .And. Len(aVlrCmp[11]) > 0
                            For nCont := 1 To Len(aVlrCmp[11])

                                //---Ajuste do item quando este está no formato alfanumérico---//
                                cItemCmp := PadL(Right(AllTrim(aVlrCmp[11][nCont][2]),3),3,'0')
                                If cItemCmp > '099'
                                    nItemDoc := oBloco2:DoCvItem(Right(cItemCmp,2))
                                    cItemCmp := Iif(nItemDoc > 0, StrZero(nItemDoc,3), cItemCmp) 
                                EndIf

                                //---Seta valores para o array aReg2133 do objeto---//
                                oBloco2:SetNumer(aNumeracao)
                                oBloco2:SetRelac(cChave2130)
                                oBloco2:SetReg("2133")                   //01 - REG
                                oBloco2:SetChvDoc(aVlrCmp[11][nCont][1]) //02 - CHV_NFE_COMP
                                oBloco2:SetItem(cItemCmp)                //03 - NUM_ITEM_NFE_COMP
                                oBloco2:Add2133()

                            Next nCont
                        EndIf

                    EndIf

                    //-------------------//
                    //---Registro 2134---//
                    //-------------------//
                    If lF1MTagRet .And. (cAlsF1M)->F1M_TAGRET == 'N'

                        //---Seta valores para o array aReg2134 do objeto---//
                        oBloco2:SetNumer(aNumeracao)
                        oBloco2:SetRelac(cChave2130)
                        oBloco2:SetReg("2134")        //01 - REG
                        oBloco2:Set2134C02('1')       //02 - COD_IND_XML       
                        oBloco2:Add2134()

                    EndIf

                ElseIf ((cAlsF1M)->F1M_TPMOV == 'S' .And. (cAlsF1M)->F1M_INDOP == '0' .And. (cAlsF1M)->F1M_INDSAI != '99') .Or. ((cAlsF1M)->F1M_TPMOV == 'E' .And. (cAlsF1M)->F1M_INDOP == '1')

                    //---Seta valores para o array aReg2113 do objeto---//
                    oBloco2:SetNumer(aNumeracao)
                    oBloco2:SetRelac(cChave2110)
                    oBloco2:SetReg("2113")                                 //01 - REG
                    oBloco2:SetIndOp((cAlsF1M)->F1M_INDOP)                 //02 IND_OPER
                    oBloco2:Set2113C03((cAlsF1M)->F1M_INDSAI)              //03 IND_S
                    oBloco2:SetChvDoc((cAlsF1M)->F1M_CHVDOC)               //04 CHV_NFE
                    oBloco2:SetDataMov((cAlsF1M)->F1M_DTMOV)               //05 DT_NFE           |06 DT_E
                    oBloco2:SetCNPJ((cAlsF1M)->F1M_CNPJ)                   //07 CNPJ             |08 CPF 
                    oBloco2:SetItem(cItemDoc)                              //09 NUM_ITEM
                    oBloco2:SetQtdMov((cAlsF1M)->F1M_QTDMOV)               //10 QTDE_IND_S
                    oBloco2:SetUnid((cAlsF1M)->F1M_UNIDAD)                 //11 UNID
                    oBloco2:SetFatConv((cAlsF1M)->F1M_FATCON)              //12 FAT_CONV
                    oBloco2:SetQtdConv((cAlsF1M)->F1M_QTDCON)              //13 QTDE_IND_S_C
                    oBloco2:SetVlrCont((cAlsF1M)->F1M_VLRCON)              //Para manter a integridade
                    If lF1MVlrTot
                        oBloco2:SetVlrTotal((cAlsF1M)->F1M_VLRTOT)         //14 VL_V_IND_S
                    EndIf    
                    oBloco2:SetCFOP((cAlsF1M)->F1M_CFOP)                   //15 CFOP
                    oBloco2:Set2113C16((cAlsF1M)->F1M_VCRDSN)              //16 VL_CREDITO_MVA_SN
                    oBloco2:Add2113()

                    cChave2113 := oBloco2:GetGrupo()

                    //-------------------//
                    //---Registro 2114---//
                    //-------------------//
                    If (cAlsF1M)->F1M_INDOP == '1'

                        aDocOriApu := aSize(aDocOriApu,0)                        
                        aDocOriApu := Fisa231Ap((cAlsF1M)->F1M_TPMOV, (cAlsF1M)->FT_NFORI, (cAlsF1M)->FT_SERORI, (cAlsF1M)->FT_ITEMORI, (cAlsF1M)->F1M_PARTIC, (cAlsF1M)->F1M_LOJA, (cAlsF1M)->B1_COD, cPerApur)
                        //---Seta valores para o array aReg2132 do objeto---//
                        oBloco2:SetNumer(aNumeracao)
                        oBloco2:SetRelac(cChave2113)
                        oBloco2:SetReg("2114")                 //01 - REG
                        oBloco2:SetCNPJ(aDocOriApu[13])        //02 - CNPJ        //03 - CPF
                        oBloco2:SetChvDoc(aDocOriApu[14])      //04 - CHV_NFE_REF
                        oBloco2:Set2114C05(aDocOriApu[15])     //05 - ECF_CX_REF 
                        oBloco2:Set2114C06(aDocOriApu[16])     //06 - NUM_DOC_REF
                        oBloco2:SetDataMov(aDocOriApu[01])     //07 - DT_DOC_REF 
                        oBloco2:Add2114()

                    EndIf

                    //-------------------//
                    //---Registro 2115---//
                    //-------------------//
                    If lF1MNfComp .And. (cAlsF1M)->F1M_NFCOMP == 'S'

                        aVlrCmp := aSize(aVlrCmp,0)
                        aVlrCmp := FISA231CMP((cAlsF1M)->F1M_TPMOV, (cAlsF1M)->F1M_NFISCA, (cAlsF1M)->F1M_SERIE, (cAlsF1M)->F1M_ITEM, (cAlsF1M)->F1M_PARTIC, (cAlsF1M)->F1M_LOJA, (cAlsF1M)->B1_COD, (cAlsF1M)->F1M_DTMOV)

                        If Len(aVlrCmp) > 0 .And. aVlrCmp[10] .And. Len(aVlrCmp[11]) > 0
                            For nCont := 1 To Len(aVlrCmp[11])

                                //---Ajuste do item quando este está no formato alfanumérico---//
                                cItemCmp := PadL(Right(AllTrim(aVlrCmp[11][nCont][2]),3),3,'0')
                                If cItemCmp > '099'
                                    nItemDoc := oBloco2:DoCvItem(Right(cItemCmp,2))
                                    cItemCmp := Iif(nItemDoc > 0, StrZero(nItemDoc,3), cItemCmp) 
                                EndIf

                                //---Seta valores para o array aReg2115 do objeto---//
                                oBloco2:SetNumer(aNumeracao)
                                oBloco2:SetRelac(cChave2113)
                                oBloco2:SetReg("2115")                    //01 - REG
                                oBloco2:SetChvDoc(aVlrCmp[11][nCont][1])  //02 - CHV_NFE_COMP
                                oBloco2:SetItem(cItemCmp)                 //03 - NUM_ITEM_NFE_COMP
                                oBloco2:Add2115()

                            Next nCont
                        EndIf

                    EndIf

                EndIf

                //-----------------------------------------------------------//
                //---Registros: 0190 / 0200 / 0205 / 0206 / 0220 - Bloco 0---//
                //-----------------------------------------------------------//
                If SB1->(DbSeek(xFilial("SB1")+cProduto))
                    RegProd(cAlsF1M,oBloco0,cChaveBlc0,aNumeracao,dDataDe,dDataAte,nAliqEfet)
                EndIf
                //---------------------------------------------------------------//
                //---FIM Registros: 0190 / 0200 / 0205 / 0206 / 0220 - Bloco 0---//
                //---------------------------------------------------------------//

                (cAlsF1M)->(DbSkip())
            EndDo
            (cAlsF1M)->(DbCloseArea())
            //--------------------------------------------//
            //---FIM Registros 2113 e 2130 - Tabela F1M---//
            //--------------------------------------------//

            (cAlsF1J)->(DbSkip())
        EndDo
        (cAlsF1J)->(DbCloseArea())
        //------------------------------------//
        //---FIM Registro 2110 - Tabela F1J---//
        //------------------------------------//

        //---------------------------------------------------------------------//
        //---Grava registros gerados nos arrays aRegxxx na tabela temporária---//
        //---------------------------------------------------------------------//
        //---Bloco 0---//
        oTabela:GrvReg(oBloco0:Get0190())
        oTabela:GrvReg(oBloco0:Get0200())
        oTabela:GrvReg(oBloco0:Get0205())
        oTabela:GrvReg(oBloco0:Get0206())
        oTabela:GrvReg(oBloco0:Get0220())
        
        //---Bloco 2---//
        oTabela:GrvReg(oBloco2:Get2100())
        oTabela:GrvReg(oBloco2:Get2110())
        oTabela:GrvReg(oBloco2:Get2112())
        oTabela:GrvReg(oBloco2:Get2113())
        oTabela:GrvReg(oBloco2:Get2114())
        oTabela:GrvReg(oBloco2:Get2115())
        oTabela:GrvReg(oBloco2:Get2120())
        oTabela:GrvReg(oBloco2:Get2121())
        oTabela:GrvReg(oBloco2:Get2130())
        oTabela:GrvReg(oBloco2:Get2132())
        oTabela:GrvReg(oBloco2:Get2133())
        oTabela:GrvReg(oBloco2:Get2134())

    EndIf

    RestArea(aArea)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Função que será chamada para atualizar descrição da barra de status

@author Ulisses P. Oliveira
@since 27/03/2019
@version 12.1.17
/*/
//--------------------------------------------------------------------------------------------------
Static Function AtualizaMsg(oSay,cMsg)
    If !lAutomato
        oSay:cCaption := (cMsg)
        ProcessMessages()
    EndIf
Return
