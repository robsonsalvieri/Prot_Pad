#Include "FISA241.CH"
#include "PROTHEUS.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA241

Rotina de geração do arquivo da ADRCST - Demonstrativo para Apuração Mensal do Ressarcimento,
da Restituição e da Complementação do ICMS Substituição Tributária, do Estado de Santa Catarina.
O método de apuração é determinado pelo Decreto Nº 1818 DE 28/11/2018 e pela Portaria SEF N° 378/2018.

@author Ulisses P. Oliveira
@since 15/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA241()
    Local aArea       := GetArea()
    Local cIdApur     := ''
    Local cPerApur    := ''
    Local lProcess    := .T.

    Private nContReg  := 0

    If Pergunte("FSA241",.T.)
        cPerApur := Right(MV_PAR01,4)+Left(MV_PAR01,2)

        //---Verifica a existência de apuração no período selecionado---//
        cIdApur := ConfApur(cPerApur)

        If Empty(cIdApur)
            MsgStop(STR0001) //---Apuração não realizada para o período selecionado!---//
            lProcess := .F.
        EndIf

        If lProcess
            FwMsgRun(,{|oSay| FISA241A(oSay,cPerApur)},STR0002,"")   //---Arquivo: Ressarcimento, Restituição e Complementação ICMS ST---//
        EndIf

    EndIf

    RestArea(aArea)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA241A

Rotina de Processamento do Arquivo.

@author Ulisses P. Oliveira
@since 15/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA241A(oSay,cPerApur)
    Local dDataDe    := StoD(cPerApur+'01')
    Local dDataAte   := LastDay(dDataDe)

    Local oTabela    := TabTemp()
    Local aNumeracao := {}
    Local cChaveBlc0 := '0000000000001'

    Local oBlocReg   := ADRCST():New()
    Local oBloco0    := ADRCSTBLOC0():New()
    Local lSPDBlocH  := FindFunction("SPDBlocH")

    Private cAliBLH  := ""
    Private lAutomato  := IsBlind()
    Private ccNpjF  := ""
    Private cIeF    := ""

    If MV_PAR05 = 2   // Gera arquivo 1010 = Sim
        If lSPDBlocH
            SPDBlocH(@cAliBLH,'',dDataAte)
        EndIf
        If !Empty((cAliBLH))
            (cAliBLH)->(DbGotop())
        Else
            MsgStop(STR0006) //---Fechamento de estoque e execução do Relatório de Registro de Inventário Modelo P7 não encontrados para o período apurado.---//
            Return
        endif
    Endif

    AtualizaMsg(oSay, STR0003) //---Processando ...---//

    Reg0000(oSay,oBloco0,oTabela,@aNumeracao,dDataDe,dDataAte)
    FSA241BLC1(oSay,oBloco0,oTabela,@aNumeracao,cChaveBlc0,cPerApur,dDataDe,dDataAte)

    AtualizaMsg(oSay, STR0004) //---Finalizando processamento...---//

    //---Seta numeracao antes de totalizar os registros---//
    oBlocReg:SetNumer(aNumeracao)
    oBloco0:SetNumer(aNumeracao)

    //---Gera registros de abertura e fechamento dos blocos e totaliza arquivo---//
    //ContRegGer(oTabela,oBlocReg,oBloco0)

    //---Gera conteúdo da tabela temporária no arquivo TXT---//
	If Empty(oTabela:GravaTxt())
        If !lAutomato
            MsgInfo(STR0005) //---Arquivo gerado com sucesso.---//
        EndIf
    EndIf

    //---Deleta tabela temporária---//
	oTabela:DelTabela()

    //---Elimina objetos utilizados no processamento---//
    FreeObj(oTabela)
    FreeObj(oBlocReg)
    FreeObj(oBloco0)

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
    Local oTabTemp := ADRCSTTMP():New()
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
    Local cCont1    := 0
    Local cCont9    := 0
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
            Case cBloco == '1'
                cCont1++
            Case cBloco == '9'
                cCont9 ++

        EndCase

        (cAliasTRB)->(DbSkip())
    EndDo

    aAdd(aQtdBloco,AllTrim(Str(cCont0)))
    aAdd(aQtdBloco,AllTrim(Str(cCont1)))
    aAdd(aQtdBloco,AllTrim(Str(cCont9)))

Return {aQtdReg,aQtdBloco}

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
    oAbertura:Add0000(cIndMovto)
    oTabela:GrvReg(oAbertura:Get0000())
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
    oEncerra:Add9999(nQtd)
    oTabela:GrvReg(oEncerra:Get9999())
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Reg0000

Função para geração do Registro 0000 [Bloco 0].

@author Ulisses P. Oliveira
@since 29/04/201
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function Reg0000(oSay,oBloco0,oTabela,aNumeracao,dDataDe,dDataAte)
    Local cVersao  := iif(empty(MV_PAR07),'100', MV_PAR07)
    Local cFinalid := Iif(MV_PAR04 == 1,'0','1')                         //---Código da Finalidade do Arquivo---//
    Local cCnpjCD  := MV_PAR08
    Local CIeCD    := MV_PAR09

    cCNpjF   := SPEDConType(SPEDVldIE(Iif (RetPessoa(SM0->M0_CGC) == "J", SM0->M0_CGC, "")))
    cIeF     := SPEDConType(SPEDVldIE(SM0->M0_INSC,.F.,.F.))

    oBloco0:SetNumer(aNumeracao)
    oBloco0:SetRelac()
    oBloco0:SetReg("0000")                                                                              //A01 - REG
    oBloco0:SetCodVer(cVersao)                                                                          //A02 - COD_VERSAO
    oBloco0:SetMesano(MV_PAR01)
    oBloco0:SetCnpj(cCNpjF)	                                                                            //A04 - CNPJ
    oBloco0:SetIE(cIeF)										                                            //A05 - IE
    oBloco0:SetNome(SM0->M0_NOMECOM)                                                                    //A06 - NOME
    oBloco0:SetCodFin(cFinalid)                                                                         //A07 - CD_FIN
    oBloco0:SetReg_esp(MV_PAR06)
    oBloco0:SetCnpj_CD(cCnpjCD)
    oBloco0:SetIE_CD(CIeCD)
    oBloco0:Add0000()
    nContReg += 1

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RegProd

Rotina geração dos Registros: 1000 - [Bloco 0].

@author Ulisses P. Oliveira
@since 08/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function RegProd(cAliasMov,oBloco0,cChaveBlc0,aNumeracao,dDataDe,dDataAte,oTabela)
    Local	aMod		:= {}
    Local	cCodBarra	:= ''
    Local   lMVHISTTAB  := SuperGetMv("MV_HISTTAB",.F.,.F.)
    Local   lSX2AIF     := AliasIndic('AIF')
    Local   lSX3B1CEST  := (cAliasMov)->(FieldPos("B1_CEST")) > 0
    Local	lHistTab	:= 	lMVHISTTAB .And. lSX2AIF
    Local 	lTemAIF		:= .F.
    Local   cProd		:= (cAliasMov)->B1_COD
    Local   lAchouCD6   := .F.
    Local   cUnid       := (cAliasMov)->B1_UM
    Local   nTotSai     := 0
    Local   nTotEnt     := (cAliasMov)->F1L_QTDENT
    Local   nAliqInt    := 0
    Local   nAliqFec    := 0
    Local   cChave1000  := ''

    dbSelectArea("CD6")
    CD6->(dbsetorder(1))

    oBloco0:SetNumer(aNumeracao)
    oBloco0:SetRelac(cChaveBlc0)

    //REGISTRO 1000 - TABELA DE IDENTIFICACAO DO ITEM
    // Verifica se ja existe 1000 p/ o produto.
    If oBloco0:Get1000(cProd) == 0

        If lHistTab
            DbSelectArea("AIF")
            AIF->(dbsetorder(2))
            lTemAIF := AIF->(MsSeek(xFilial("AIF")+xFilial("SB1")+"SB1"+PadR(cProd, TamSX3("AIF_CODPRO")[1])))
        EndIf
    	//Verifica o tamanho do código de barras. Deve estar dentro do padrão GTIN (8,12,13,14)
    	If	Len(AllTrim((cAliasMov)->B1_CODBAR)) ==  8 .Or. Len(AllTrim((cAliasMov)->B1_CODBAR)) == 12 .Or.;
    		Len(AllTrim((cAliasMov)->B1_CODBAR)) == 13 .Or. Len(AllTrim((cAliasMov)->B1_CODBAR)) == 14
    		cCodBarra := (cAliasMov)->B1_CODBAR
    	Endif
        // Verifica se existe complemento de combustíveis p/ o documento.
        lAchouCD6 := CD6->(MsSeek(xFilial("CD6")   +;
                          (cAliasMov)->F1M_TPMOV   +;
                          (cAliasMov)->F1M_SERIE   +;
                          (cAliasMov)->F1M_NFISCA  +;
                          (cAliasMov)->F1M_PARTIC  +;
                          (cAliasMov)->F1M_LOJA    +;
                          (cAliasMov)->F1M_ITEM    +;
                          (cAliasMov)->F1M_PRODUT))
        oBloco0:SetReg("1000")                             //B01 - REG
    	oBloco0:SetCodItem(cProd)                          //B03 - COD_ITEM

    	//³Tratamento para pegar a informacao valida do cadastro dentro do prazo de geracao do spedifscal³
    	If lHistTab .And. lTemAIF
    		aMod := MsConHist("SB1","","",dDataDe,,Substr(cProd,1,TamSx3("B1_COD")[1]))
    	EndIf

    	cContCampo := RetCmpHist(cAliasMov+"->B1_DESC",aMod,dDataAte,lHistTab)
        oBloco0:SetCodBarr(cCodBarra)                      //B04 - COD_BARRAS
     	If lAchouCD6 .And. !Empty(AllTrim(CD6->CD6_CODANP))
    		oBloco0:SetCodANP(AllTrim(CD6->CD6_CODANP))    //B05 - COD_ANP
    	EndIF
        // 3.3.2 Campo COD_NCM - “Código da Nomenclatura Comum do Mercosul”: para este campo a especificação da obrigatoriedade do preenchimento deve ser “Obrigatório” (O);
    	If (cAliasMov)->(FieldPos("FT_POSIPI")) > 0
    		oBloco0:SetCodNCM((cAliasMov)->FT_POSIPI)      //B06 - COD_NCM
    	Else
    		oBloco0:SetCodNCM((cAliasMov)->B1_POSIPI)      //B06 - COD_NCM
    	EndIf
        If lSX3B1CEST
            oBloco0:SetCest((cAliasMov)->B1_CEST)          //B07 - CEST
        Else
            oBloco0:SetCest('')                            //B07 - CEST
        Endif
        oBloco0:SetDesItem(cContCampo)                     //B08 - DESCR_ITEM
    	oBloco0:SetUnidInv(cUnid)                          //B09 - UNID_ITEM

        F1Z->(DbSetOrder(1)) //---F1Z_FILIAL+F1Z_ANOMES+F1Z_PRODUT+F1Z_INDSAI---//
        F1Z->(DbSeek((cAliasMov)->F1M_FILIAL+(cAliasMov)->F1M_ANOMES+(cAliasMov)->F1M_PRODUT))
        While !F1Z->(Eof()) .And. F1Z->F1Z_FILIAL == (cAliasMov)->F1M_FILIAL  .And. F1Z->F1Z_ANOMES == (cAliasMov)->F1M_ANOMES .And. F1Z->F1Z_PRODUT == (cAliasMov)->F1M_PRODUT
            nTotSai  += F1Z->F1Z_QTDSAI
            nAliqInt := F1Z->F1Z_ALIEFE
            nAliqFec := F1Z->F1Z_ALIFEC
            F1Z->(DbSkip())
        EndDo

        oBloco0:SetInc_FEC(Iif(nAliqFec > 0, '1', '0'))    //B02 - IND_FECOP
        oBloco0:SetAliqICM(nAliqInt)                       //B10 - ALIQ_ICMS_ITEM
        oBloco0:SetAliqFEC(Iif(nAliqFec > 0, nAliqFec, ''))//B11 - ALIQ_FECOP
        oBloco0:SetQtdTEnt(nTotEnt)                        //B12 - QTD_TOT_ENTRADA
        oBloco0:SetQtdTSai(nTotSai)                        //B13 - QTD_TOT_SAIDA

        If (cAliasMov)->F1M_QTDS > 0 .And. nTotEnt > 0
            oBloco0:Add1000()
            cChave1000 := oBloco0:GetGrupo()
            nContReg += 1
        EndIf

    EndIf

Return cChave1000

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA234SEQ

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/

//--------------------------------------------------------------------------------------------------
Function FISA241SEQ(aGrupoReg,cGrupoPai,cReg)
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
/*/{Protheus.doc} Reg1010

Função responsável pela geração do bloco H.

@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function Reg1010(cAliasMov,oBloco0,cChave1000,aNumeracao)

    // Para cada produto apurado, procuro no temporário as informações sobre o estoque.
    // Conforme layout, é obrigatório que o indicador de propriedade seja “0 -  Item de propriedade do informante e em seu poder”.
    //---FILIAL+COD_ITEM+IND_PROP+COD_PART---//
    If (cAliBLH)->(DbSeek((cAliasMov)->F1M_FILIAL + (cAliasMov)-> F1M_PRODUT + "0"))
        oBloco0:SetNumer(aNumeracao)
        oBloco0:SetRelac(cChave1000)
        oBloco0:SetReg("1010")
        oBloco0:SetCodItem((cAliBLH)->COD_ITEM)
        oBloco0:SetUnidInv((cAliBLH)->UNID)
        oBloco0:SetQtde((cAliBLH)->QTD)
        oBloco0:SetVtotIt((cAliBLH)->VL_ITEM)
        oBloco0:SetCompl("")
        oBloco0:Add1010()

        nContReg += 1
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSA241BLC1

Função responsável pela geração do bloco 1.

@author Ulisses P. Oliveira
@since 15/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function FSA241BLC1(oSay,oBloco0,oTabela,aNumeracao,cChaveBlc0,cPerApur,dDataDe,dDataAte)
    Local aArea      := GetArea()
    Local cAlsF1I    := GetNextAlias()
    Local cAlsF1Z    := GetNextAlias()
    Local cAlsF1L    := GetNextAlias()
    Local cAlsF1M    := GetNextAlias()
    Local cIdApur    := ''
    Local cProduto   := ''
    Local cChave1000 := ''
    Local cChave1100 := ''
    Local cChave1110 := ''
    Local cChave1200 := ''
    Local cChave1300 := ''
    Local cChave1400 := ''
    Local cChave1500 := ''
    Local aDocOriApu := {}
    Local cEstF      := SuperGetMV("MV_ESTADO")
    Local cUFEmit    := ''
    Local cCnpjEmit  := ''
    Local cItemDoc   := ''
    Local cItemOri   := ''
    Local cQry       := ''
    Local lcpoPec    := F1L->(FieldPos('F1L_PRCMVA')) > 0
    Local lCpoDes    := F1M->(FieldPos('F1M_VLDESP')) > 0 .and. F1M->(FieldPos('F1M_VLDESC')) > 0
    Local lCpoRev    := F1I->(FieldPos("F1I_REVOP1")) > 0 .and. F1I->(FieldPos("F1I_REVOP2")) > 0 .and. F1I->(FieldPos("F1I_REVOP3")) > 0 .and. F1I->(FieldPos("F1I_REVOP4")) > 0  
    Local cCposAdi   := "%%"
    Local cR1200     := "" 
    Local cR1300     := ""
    Local cR1400     := "" 
    Local cR1500     := "" 
    Local nVlrItem   := 0
    Local oQryMov    := Nil as Object
    Local cQryMov    := ""  as character

    dbSelectArea("SB1")
    SB1->(DbSetOrder(1))
     //--------------------------------//
    //---Registro 9000 - Tabela F1I---//
    //--------------------------------//

    if lCpoRev
        cCposAdi:="%,F1I_REVOP1,F1I_REVOP2,F1I_REVOP3,F1I_REVOP4%"
    endif

    BeginSql Alias cAlsF1I
        SELECT F1I_IDAPUR, F1I_SDREST, F1I_SDCOMP, F1I_SDRES1, F1I_SDRES2, F1I_SDRES3, F1I_FECRES, F1I_FECCMP
        %EXP:cCposAdi%
        FROM %TABLE:F1I% F1I
        WHERE F1I_FILIAL = %XFILIAL:F1I%  AND
              F1I_ORIGEM = 'FISA240'      AND
              F1I_ANOMES = %EXP:cPerApur% AND
              F1I.%NOTDEL%
    EndSql

    DbSelectArea(cAlsF1I)
    (cAlsF1I)->(DbGoTop())
    If !(cAlsF1I)->(Eof()) .And. !Empty((cAlsF1I)->F1I_IDAPUR)

        cIdApur := (cAlsF1I)->F1I_IDAPUR

        //---Seta valores para o array aReg9000 do objeto---//
        oBloco0:SetNumer(aNumeracao)
        oBloco0:SetRelac(cChaveBlc0)
        oBloco0:SetReg("9000")                    //X01 - REG
        oBloco0:Set1200Re((cAlsF1I)->F1I_SDREST)  //X02 - REG1200_ICMSST_RECUPERAR_RESSARCIR
        oBloco0:Set1200Com((cAlsF1I)->F1I_SDCOMP) //X03 - REG1200_ICMSST_COMPLEMENTAR
        oBloco0:Set1300Re((cAlsF1I)->F1I_SDRES1)  //X04 - REG1300_ICMSST_RECUPERAR_RESSARCIR
        oBloco0:Set1400Re((cAlsF1I)->F1I_SDRES2)  //X05 - REG1400_ICMSST_RECUPERAR_RESSARCIR
        oBloco0:Set1500Re((cAlsF1I)->F1I_SDRES3)  //X06 - REG1500_ICMSST_RECUPERAR_RESSARCIR
        oBloco0:Set9000Re((cAlsF1I)->F1I_FECRES)  //X07 - REG9000_FECOP_RESSARCIR
        oBloco0:Set9000Com((cAlsF1I)->F1I_FECCMP) //X08 - REG9000_FECOP_COMPLEMENTAR
        oBloco0:Add9000()

        if lCpoRev
            cR1200:= (cAlsF1I)->F1I_REVOP4 //1200
            cR1300:= (cAlsF1I)->F1I_REVOP1 //1300
            cR1400:= (cAlsF1I)->F1I_REVOP2 //1400
            cR1500:= (cAlsF1I)->F1I_REVOP3 //1500
        endif

    EndIf
    (cAlsF1I)->(DbCloseArea())
    //------------------------------------//
    //---FIM Registro 9000 - Tabela F1I---//
    //------------------------------------//

    If !Empty(cIdApur)

        If  !lcpoPec
            cQry := "%F1L_PRODUT, F1L_QTDENT, F1L_VMENUN, F1L_VMUBST, F1L_TOTSUP, F1L_VMUSUP, F1M_.F1M_QTDS, F1M_.F1M_QTDS12, F1M_.F1M_QTDS13, F1M_.F1M_QTDS14, F1M_.F1M_QTDS15,"
            cQry += "F1M2.F1M_FILIAL, F1M2.F1M_ANOMES, F1M2.F1M_TPMOV,  F1M2.F1M_SERIE, F1M2.F1M_NFISCA, F1M2.F1M_PARTIC, F1M2.F1M_LOJA, F1M2.F1M_ITEM, F1M2.F1M_PRODUT,"
            cQry +=  "SFT.FT_POSIPI,SB1.B1_COD, SB1.B1_TIPO, SB1.B1_CEST, SB1.B1_UM, SB1.B1_SEGUM, SB1.B1_TIPCONV, SB1.B1_CONV, SB1.B1_DATREF, SB1.B1_CODBAR, SB1.B1_DESC, SB1.B1_POSIPI, SB1.B1_EX_NCM, SB1.B1_CODISS, SB1.B1_PICM, SB1.B1_CODANT%"
        Else
            cQry := "%F1L_PRODUT,F1L_PRCMVA, F1L_QTDENT, F1L_VMENUN, F1L_VMUBST, F1L_TOTSUP, F1L_VMUSUP, F1M_.F1M_QTDS, F1M_.F1M_QTDS12, F1M_.F1M_QTDS13, F1M_.F1M_QTDS14, F1M_.F1M_QTDS15,"
            cQry += "F1M2.F1M_FILIAL, F1M2.F1M_ANOMES, F1M2.F1M_TPMOV,  F1M2.F1M_SERIE, F1M2.F1M_NFISCA, F1M2.F1M_PARTIC, F1M2.F1M_LOJA, F1M2.F1M_ITEM, F1M2.F1M_PRODUT,"
            cQry += "SFT.FT_POSIPI,SB1.B1_COD, SB1.B1_TIPO, SB1.B1_CEST, SB1.B1_UM, SB1.B1_SEGUM, SB1.B1_TIPCONV, SB1.B1_CONV, SB1.B1_DATREF, SB1.B1_CODBAR, SB1.B1_DESC, SB1.B1_POSIPI, SB1.B1_EX_NCM, SB1.B1_CODISS, SB1.B1_PICM, SB1.B1_CODANT%"
     
        EndIf    
        BeginSql Alias cAlsF1L
            SELECT  %Exp:cQry%  FROM %TABLE:F1L% F1L LEFT OUTER JOIN (SELECT F1M.F1M_FILIAL, F1M.F1M_ANOMES, F1M.F1M_PRODUT, MIN(F1M.F1M_ORDEM) F1M_ORDEM,
                                                         SUM(CASE WHEN ((F1M.F1M_TPMOV = 'S' AND F1M.F1M_INDOP = '0') OR (F1M.F1M_TPMOV = 'E' AND F1M.F1M_INDOP = '1'))                           THEN F1M.F1M_QTDCON ELSE 0 END) F1M_QTDS,
                                                         SUM(CASE WHEN ((F1M.F1M_TPMOV = 'S' AND F1M.F1M_INDOP = '0') OR (F1M.F1M_TPMOV = 'E' AND F1M.F1M_INDOP = '1')) AND F1M.F1M_INDSAI = '12' THEN F1M.F1M_QTDCON ELSE 0 END) F1M_QTDS12,
                                                         SUM(CASE WHEN ((F1M.F1M_TPMOV = 'S' AND F1M.F1M_INDOP = '0') OR (F1M.F1M_TPMOV = 'E' AND F1M.F1M_INDOP = '1')) AND F1M.F1M_INDSAI = '13' THEN F1M.F1M_QTDCON ELSE 0 END) F1M_QTDS13,
                                                         SUM(CASE WHEN ((F1M.F1M_TPMOV = 'S' AND F1M.F1M_INDOP = '0') OR (F1M.F1M_TPMOV = 'E' AND F1M.F1M_INDOP = '1')) AND F1M.F1M_INDSAI = '14' THEN F1M.F1M_QTDCON ELSE 0 END) F1M_QTDS14,
                                                         SUM(CASE WHEN ((F1M.F1M_TPMOV = 'S' AND F1M.F1M_INDOP = '0') OR (F1M.F1M_TPMOV = 'E' AND F1M.F1M_INDOP = '1')) AND F1M.F1M_INDSAI = '15' THEN F1M.F1M_QTDCON ELSE 0 END) F1M_QTDS15
                                                  FROM %TABLE:F1M% F1M
            								      WHERE F1M.F1M_FILIAL = %XFILIAL:F1M% AND
                                                        F1M.%NOTDEL%
            								      GROUP BY F1M.F1M_FILIAL, F1M.F1M_ANOMES, F1M.F1M_PRODUT) F1M_ ON (F1M_.F1M_FILIAL = F1L.F1L_FILIAL AND F1M_.F1M_ANOMES = F1L.F1L_ANOMES AND F1M_.F1M_PRODUT = F1L.F1L_PRODUT)
                            LEFT OUTER JOIN %TABLE:F1M% F1M2 ON (F1M2.F1M_FILIAL = F1L.F1L_FILIAL AND F1M2.F1M_ANOMES = F1L.F1L_ANOMES AND F1M2.F1M_PRODUT = F1L.F1L_PRODUT AND F1M2.F1M_ORDEM = F1M_.F1M_ORDEM AND F1M2.%NOTDEL%)
                                 INNER JOIN %TABLE:SB1% SB1 ON (SB1.B1_FILIAL = %XFILIAL:SB1% AND SB1.B1_COD     = F1M2.F1M_PRODUT AND SB1.%NOTDEL%)
                                 INNER JOIN %TABLE:SFT% SFT ON (SFT.FT_FILIAL = %XFILIAL:SFT% AND SFT.FT_TIPOMOV = F1M2.F1M_TPMOV  AND SFT.FT_SERIE = F1M2.F1M_SERIE AND SFT.FT_NFISCAL = F1M2.F1M_NFISCA AND SFT.FT_CLIEFOR = F1M2.F1M_PARTIC AND SFT.FT_LOJA = F1M2.F1M_LOJA AND SFT.FT_ITEM = F1M2.F1M_ITEM AND SFT.FT_PRODUTO = F1M2.F1M_PRODUT AND SFT.%NOTDEL%)
            WHERE F1L.F1L_FILIAL = %XFILIAL:F1L%  AND
                  F1L.F1L_IDAPUR = %EXP:cIdApur%  AND
            	  F1L.%NOTDEL%
            ORDER BY F1L_PRODUT
        EndSql

        DbSelectArea(cAlsF1L)
        
        (cAlsF1L)->(DbGoTop())
        While !(cAlsF1L)->(Eof())
            cProduto   := (cAlsF1L)->F1L_PRODUT
            cChave1000 := ''
            cChave1100 := ''
            cChave1200 := ''
            cChave1300 := ''
            cChave1400 := ''
            cChave1500 := ''

            //---Registro 1000---//
            If SB1->(DbSeek(xFilial("SB1")+cProduto))
                cChave1000 := RegProd(cAlsF1L,oBloco0,cChaveBlc0,aNumeracao,dDataDe,dDataAte,oTabela)
            EndIf

            If !Empty(cChave1000)

                If MV_PAR05 = 2   // Gera arquivo 1010 = Sim
                    Reg1010(cAlsF1L,oBloco0,cChave1000,aNumeracao)
                Endif

                //---Registro 1100---//
                //---Seta valores para o array aReg1100---//
                oBloco0:SetNumer(aNumeracao)
                oBloco0:SetRelac(cChave1000)
                oBloco0:SetReg("1100")                     //D01 - REG
                oBloco0:SetQtdTEnt((cAlsF1L)->F1L_QTDENT)  //D02 - QTD_TOT_ENTRADA
                oBloco0:SetMVlUnit((cAlsF1L)->F1L_VMENUN)  //D03 - MENOR_VL_UNIT_ITEM
                oBloco0:SetICMSUNM((cAlsF1L)->F1L_VMUBST)  //D04 - VL_BC_ICMSST_UNIT_MED
                oBloco0:SetTICMSEN((cAlsF1L)->F1L_TOTSUP)  //D05 - VL_TOT_ICMS_SUPORT_ENTR
                oBloco0:SetMICMSEN((cAlsF1L)->F1L_VMUSUP)  //D06 - VL_UNIT_MED_ICMS_SUPORT_ENTR
                oBloco0:Add1100()
                nContReg += 1
                cChave1100 := oBloco0:GetGrupo()
             
                //---Registros: 1200 / 1300 / 1400 / 1500---//
                BeginSql Alias cAlsF1Z
                    SELECT  F1Z_INDSAI, F1Z_QTDSAI, F1Z_VTOSAI, F1Z_VCONFE, F1Z_VMABST, F1Z_VMEBST, F1Z_VLRESS, F1Z_VLCOMP, F1Z_VLFRES,F1Z_VLFCOM
                    FROM %TABLE:F1Z% F1Z
                    WHERE  F1Z.F1Z_FILIAL = %XFILIAL:F1Z%  AND
                           F1Z.F1Z_IDAPUR = %EXP:cIdApur%  AND
                           F1Z.F1Z_PRODUT = %EXP:cProduto% AND
                           F1Z.%NOTDEL%
                EndSql

                DbSelectArea(cAlsF1Z)
                
                (cAlsF1Z)->(DbGoTop())
                While (cAlsF1Z)->(!Eof())

                    If (cAlsF1Z)->F1Z_INDSAI == "12" .And. (cAlsF1L)->F1M_QTDS12 > 0

                        //---Seta valores para o array aReg1200---//
                        oBloco0:SetNumer(aNumeracao)
                        oBloco0:SetRelac(cChave1000)
                        oBloco0:SetReg("1200")                     //F01 - REG
                        oBloco0:SetQtdTSai((cAlsF1Z)->F1Z_QTDSAI)  //F02 - QTD_TOT_SAIDA
                        oBloco0:SetVTICMEf((cAlsF1Z)->F1Z_VTOSAI)  //F03 - VL_TOT_ICMS_EFETIVO
                        oBloco0:SetVCICMEn((cAlsF1Z)->F1Z_VCONFE)  //F04 - VL_CONFRONTO_ICMS_ENTRADA
                        oBloco0:SetReRec((cAlsF1Z)->F1Z_VMABST)    //F05 - RESULT_RECUPERAR_RESSARCIR
                        oBloco0:SetResComp((cAlsF1Z)->F1Z_VMEBST)  //F06 - RESULT_COMPLEMENTAR
                        oBloco0:SetApICMRe((cAlsF1Z)->F1Z_VLRESS)  //F07 - APUR_ICMSST_RECUPERAR_RESSARCIR
                        oBloco0:SetApICMSC((cAlsF1Z)->F1Z_VLCOMP)  //F08 - APUR_ICMSST_COMPLEMENTAR
                        oBloco0:SetApFECPR((cAlsF1Z)->F1Z_VLFRES)  //F09 - APUR_FECOP_RESSARCIR
                        oBloco0:SetApFECPC((cAlsF1Z)->F1Z_VLFCOM)  //F10 - APUR_FECOP_COMPLEMENTAR
                        oBloco0:Add1200()
                        cChave1200 := oBloco0:GetGrupo()
                        nContReg += 1

                        //Caso tenha o registro 1200 informa no registro 000 o campo A11 com o que foi informado no pergunte da apuração.
                        if lCpoRev
                            oBloco0:Alt0000("A11",cR1200)
                        endif

                    ElseIf (cAlsF1Z)->F1Z_INDSAI == "13" .And. (cAlsF1L)->F1M_QTDS13 > 0

                        //---Seta valores para o array aReg1300---//
                        oBloco0:SetNumer(aNumeracao)
                        oBloco0:SetRelac(cChave1000)
                        oBloco0:SetReg("1300")                      //H01 - REG
                        oBloco0:SetQtdTSai((cAlsF1Z)->F1Z_QTDSAI)   //H02 - QTD_TOT_SAIDA
                        oBloco0:SetVTICMEf((cAlsF1Z)->F1Z_VTOSAI)   //H03 - VL_TOT_ICMS_EFETIVO
                        oBloco0:SetVCICMEn((cAlsF1Z)->F1Z_VCONFE)   //H04 - VL_CONFRONTO_ICMS_ENTRADA
                        oBloco0:SetReRec((cAlsF1Z)->F1Z_VMABST)     //H05 - RESULT_RECUPERAR_RESSARCIR
                        oBloco0:SetApICMRe((cAlsF1Z)->F1Z_VLRESS)   //H07 - APUR_ICMSST_RECUPERAR_RESSARCIR
                        oBloco0:SetApFECPR((cAlsF1Z)->F1Z_VLFRES)   //H09 - APUR_FECOP_RESSARCIR
                        oBloco0:Add1300()
                        cChave1300 := oBloco0:GetGrupo()
                        nContReg += 1

                        //Caso tenha o registro 1300 informa no registro 000 o campo A12 com o que foi informado no pergunte da apuração.
                        if lCpoRev
                            oBloco0:Alt0000("A12",cR1300)
                        endif

                    ElseIf (cAlsF1Z)->F1Z_INDSAI == "14" .And. (cAlsF1L)->F1M_QTDS14 > 0

                        //---Seta valores para o array aReg1400---//
                        oBloco0:SetNumer(aNumeracao)
                        oBloco0:SetRelac(cChave1000)
                        oBloco0:SetReg("1400")                      //J01 - REG
                        oBloco0:SetQtdTSai((cAlsF1Z)->F1Z_QTDSAI)   //J02 - QTD_TOT_SAIDA
                        oBloco0:SetVTICMEf((cAlsF1Z)->F1Z_VTOSAI)   //J03 - VL_TOT_ICMS_EFETIVO
                        oBloco0:SetVCICMEn((cAlsF1Z)->F1Z_VCONFE)   //J04 - VL_CONFRONTO_ICMS_ENTRADA
                        oBloco0:SetApICMRe((cAlsF1Z)->F1Z_VLRESS)   //J05 - APUR_ICMSST_RECUPERAR_RESSARCIR
                        oBloco0:Add1400()
                        cChave1400 := oBloco0:GetGrupo()
                        nContReg += 1

                        //Caso tenha o registro 1400 informa no registro 000 o campo A13 com o que foi informado no pergunte da apuração.
                        if lCpoRev
                            oBloco0:Alt0000("A13",cR1400)
                        endif

                    ElseIf (cAlsF1Z)->F1Z_INDSAI == "15" .And. (cAlsF1L)->F1M_QTDS15 > 0

                        //---Seta valores para o array aReg1500---//
                        oBloco0:SetNumer(aNumeracao)
                        oBloco0:SetRelac(cChave1000)
                        oBloco0:SetReg("1500")                      //L01 - REG
                        oBloco0:SetQtdTSai((cAlsF1Z)->F1Z_QTDSAI)   //L02 - QTD_TOT_SAIDA
                        oBloco0:SetVCICMEn((cAlsF1Z)->F1Z_VCONFE)   //L03 - VL_CONFRONTO_ICMS_ENTRADA
                        oBloco0:SetApICMRe((cAlsF1Z)->F1Z_VLRESS)   //L04 - APUR_ICMSST_RECUPERAR_RESSARCIR
                        If lcpoPec
                            oBloco0:SetApMVA((cAlsF1L)->F1L_PRCMVA) 
                        EndIF
                        oBloco0:Add1500()
                        cChave1500 := oBloco0:GetGrupo()
                        nContReg += 1

                        //Caso tenha o registro 1500 informa no registro 000 o campo A14 com o que foi informado no pergunte da apuração.
                        if lCpoRev
                            oBloco0:Alt0000("A14",cR1500)
                        endif

                    EndIf

                    (cAlsF1Z)->(DbSkip())
                EndDo
                (cAlsF1Z)->(DbCloseArea())

                //---Registros: 1110 / 1120 / 1210 / 1220 / 1310 / 1320 / 1410 / 1420 / 1510 / 1520---//
                


                If  lCpoDes
                    cQryMov:="SELECT F1M.F1M_VLUNIT, F1M.F1M_VLDESP, F1M.F1M_VLDESC,"
                Else
                    cQryMov:= "SELECT F1M.F1M_VLUNIT,"
                Endif

                cQryMov+= " F1M.F1M_PRODUT, F1M.F1M_DTMOV, F1M.F1M_TPMOV, F1M.F1M_INDOP, F1M.F1M_NFISCA, F1M.F1M_SERIE, F1M.F1M_ITEM, F1M.F1M_CFOP, F1M.F1M_PARTIC,"
                cQryMov+= " F1M.F1M_LOJA, F1M.F1M_CNPJ, F1M.F1M_CHVDOC, F1M.F1M_QTDCON, F1M.F1M_UNIDAD, F1M.F1M_VLRCON, F1M.F1M_VLRICM,F1M.F1M_BASIST, F1M.F1M_VLRIST,"
	            cQryMov+= " F1M.F1M_CODRES, F1M.F1M_INDSAI, F1M.F1M_VLRSUP, F1M.F1M_VLREFE,SFT.FT_EMISSAO, SFT.FT_POSIPI, SFT.FT_CFOP, SFT.FT_CLASFIS, SFT.FT_ESTADO,"
                cQryMov+= " SFT.FT_NFORI, SFT.FT_SERORI, SFT.FT_ITEMORI , SFT.FT_FORMUL, SF6.F6_NUMERO, SF6.F6_VALOR, SF6.F6_DTPAGTO, SF6.F6_DTARREC, SF6.F6_CODREC, "
                cQryMov+= " CASE WHEN SF6.F6_TIPOIMP = '0' THEN '2' "
                cQryMov+= " ELSE '1' "
                cQryMov+= " END TIPOIMP "
                cQryMov+= "     FROM " + RetSqlName('F1M') + " F1M " 
                cQryMov+= "         INNER JOIN " + RetSqlName('SFT') + " SFT ON "
                cQryMov+= "          (SFT.FT_FILIAL  = ? AND "
                cQryMov+= "           SFT.FT_TIPOMOV = F1M.F1M_TPMOV  AND SFT.FT_SERIE = F1M.F1M_SERIE AND SFT.FT_NFISCAL = F1M.F1M_NFISCA AND SFT.FT_CLIEFOR = F1M.F1M_PARTIC"
                cQryMov+= "           AND SFT.FT_LOJA = F1M.F1M_LOJA AND SFT.FT_ITEM = F1M.F1M_ITEM AND SFT.FT_PRODUTO = F1M.F1M_PRODUT "
                cQryMov+= "           AND SFT.D_E_L_E_T_ = ?)"
                cQryMov+= "         LEFT JOIN " + RetSqlName('SF6') + " SF6 ON "
                cQryMov+= "          (SF6.F6_FILIAL  = ? AND "
                cQryMov+= "           SF6.F6_OPERNF = ? "
                cQryMov+= "           AND SF6.F6_DOC = SFT.FT_NFISCAL AND SF6.F6_SERIE = SFT.FT_SERIE AND "
                cQryMov+= "           SF6.F6_CLIFOR = SFT.FT_CLIEFOR AND SF6.F6_LOJA = SFT.FT_LOJA "
                cQryMov+= "           AND SF6.D_E_L_E_T_ = ?)"
                cQryMov+= "     WHERE  F1M.F1M_FILIAL = ?  "
                cQryMov+= "         AND F1M.F1M_IDAPUR = ? "
                cQryMov+= "         AND F1M.F1M_PRODUT = ? "
                cQryMov+= "         AND F1M.D_E_L_E_T_ = ? "
                cQryMov+= "     ORDER BY SFT.FT_EMISSAO, F1M.F1M_TPMOV, F1M.F1M_INDOP, F1M.F1M_PARTIC, F1M.F1M_LOJA, F1M.F1M_NFISCA, F1M.F1M_ITEM, F1M.F1M_SERIE"

                cQryMov := ChangeQuery(cQryMov)
                oQryMov := FwExecStatement():New(cQryMov)
                If oQryMov != Nil
	                oQryMov:SetString(1, xFilial('SFT') )
                    oQryMov:SetString(2, ' ' )
                    oQryMov:SetString(3, xFilial('SF6') )
                    oQryMov:SetString(4, '1' )
                    oQryMov:SetString(5, ' ' )
	                oQryMov:SetString(6, xFilial('F1M'))
	                oQryMov:SetString(7, cIdApur) 
                    oQryMov:SetString(8, cProduto)
                    oQryMov:SetString(9, ' ')

                	cAlsF1M := oQryMov:OpenAlias()

                    TcSetField(cAlsF1M, "FT_EMISSAO"  , "D", 8, 0)
	                TcSetField(cAlsF1M, "F6_DTARREC"  , "D", 8, 0)
                    TcSetField(cAlsF1M, "F6_DTPAGTO"  , "D", 8, 0)
                    TcSetField(cAlsF1M, "F1M_DTMOV"  , "D", 8, 0)
                    
                EndIf 

                While !(cAlsF1M)->(Eof())

                    //---Ajuste do item quando este está no formato alfanumérico---//
                    cItemDoc := ConvItem(oBloco0, (cAlsF1M)->F1M_ITEM)

                    nVlrItem := (cAlsF1M)->F1M_VLUNIT

                    If  lCpoDes
                        If (cAlsF1M)->F1M_QTDCON > 0
                            nVlrItem += (cAlsF1M)->F1M_VLDESP / (cAlsF1M)->F1M_QTDCON
                        Endif
                    Endif

                    If ((cAlsF1M)->F1M_TPMOV == 'E' .And. (cAlsF1M)->F1M_INDOP == '0' .And. !Empty(cChave1100))

                        //---Seta valores para o array aReg1110---//
                        oBloco0:SetNumer(aNumeracao)
                        oBloco0:SetRelac(cChave1100)
                        oBloco0:SetReg("1110")                                //E01 - REG
                        oBloco0:SetDatDoc((cAlsF1M)->FT_EMISSAO)              //E02 - DT_DOC
                        oBloco0:SetRespRet((cAlsF1M)->F1M_CODRES)             //E03 - COD_RESP_RET
                        oBloco0:SetCsosn(Right((cAlsF1M)->FT_CLASFIS,2))      //E04 - CST_CSOSN
                        oBloco0:SetChave((cAlsF1M)->F1M_CHVDOC)               //E05 - CHAVE
                        oBloco0:SetNFiscal((cAlsF1M)->F1M_NFISCA)             //E06 - N_NF
                        oBloco0:SetCnpjEm((cAlsF1M)->F1M_CNPJ)                //E07 - CNPJ_EMIT
                        oBloco0:SetUFemit((cAlsF1M)->FT_ESTADO)               //E08 - UF_EMIT
                        oBloco0:SetCnpjDes(cCNpjF)                            //E09 - CNPJ_DEST
                        oBloco0:SetUFdest(cEstF)                              //E10 - UF_DEST
                        oBloco0:SetCfop((cAlsF1M)->F1M_CFOP)                  //E11 - CFOP
                        oBloco0:SetItem(cItemDoc)                             //E12 - N_ITEM
                        oBloco0:SetUnidInv((cAlsF1M)->F1M_UNIDAD)             //E13 - UNID_ITEM
                        oBloco0:SetQtdEnt((cAlsF1M)->F1M_QTDCON)              //E14 - QTD_ENTRADA
                        oBloco0:SetVunIem(nVlrItem)                           //E15 - VL_UNIT_ITEM
                        oBloco0:SetVBIcmSt((cAlsF1M)->F1M_BASIST)             //E16 - VL_BC_ICMS_ST
                        oBloco0:SetVIcmSEn((cAlsF1M)->F1M_VLRSUP)             //E17 - VL_ICMS_SUPORT_ENTR
                        oBloco0:Add1110()
                        cChave1110 := oBloco0:GetGrupo()
                        nContReg += 1

                        If !Empty((cAlsF1M)->F6_NUMERO)
                            oBloco0:SetNumer(aNumeracao)
                            oBloco0:SetRelac(cChave1110) 
                            oBloco0:SetReg("1115") 
                            oBloco0:SetTipDoc((cAlsF1M)->TIPOIMP)   
                            oBloco0:SetNmGuia((cAlsF1M)->F6_NUMERO)   
                            oBloco0:SetDtGuia((cAlsF1M)->F6_DTARREC) 
                            oBloco0:SetDtPgto((cAlsF1M)->F6_DTPAGTO)
                            oBloco0:SetCdArec((cAlsF1M)->F6_CODREC)
                            oBloco0:SetVlRec((cAlsF1M)->F6_VALOR)
                            oBloco0:Add1115()
                            nContReg += 1
                        Endif

                    ElseIf ((cAlsF1M)->F1M_TPMOV == 'S' .And. (cAlsF1M)->F1M_INDOP == '1' .And. !Empty(cChave1100))

                        aDocOriApu := aSize(aDocOriApu,0)
                        aDocOriApu := FsaB240Ap((cAlsF1M)->F1M_TPMOV, (cAlsF1M)->FT_NFORI, (cAlsF1M)->FT_SERORI, (cAlsF1M)->FT_ITEMORI, (cAlsF1M)->F1M_PARTIC, (cAlsF1M)->F1M_LOJA, (cAlsF1M)->F1M_PRODUT, cPerApur)
                        //---Ajuste do item quando este está no formato alfanumérico---//
                        cItemOri := ConvItem(oBloco0, aDocOriApu[08])

                        //---Seta valores para o array aReg1120---//
                        oBloco0:SetNumer(aNumeracao)
                        oBloco0:SetRelac(cChave1100)
                        oBloco0:SetReg("1120")                                //E01D - REG
                        oBloco0:SetDatDoc((cAlsF1M)->FT_EMISSAO)              //E02D - DT_DOC
                        oBloco0:SetCsosn(Right((cAlsF1M)->FT_CLASFIS,2))      //E03D - CST_CSOSN
                        oBloco0:SetChave((cAlsF1M)->F1M_CHVDOC)               //E04D - CHAVE
                        oBloco0:SetNFiscal((cAlsF1M)->F1M_NFISCA)             //E05D - N_NF
                        oBloco0:SetCnpjEm(cCnpjF)                             //E06D - CNPJ_EMIT
                        oBloco0:SetUFemit(cEstF)                              //E07D - UF_EMIT
                        oBloco0:SetCnpjDes((cAlsF1M)->F1M_CNPJ)               //E08D - CNPJ_DEST
                        oBloco0:SetUFdest((cAlsF1M)->FT_ESTADO)               //E09D - UF_DEST
                        oBloco0:SetCfop((cAlsF1M)->F1M_CFOP)                  //E10D - CFOP
                        oBloco0:SetItem(cItemDoc)                             //E11D - N_ITEM
                        oBloco0:SetUnidInv((cAlsF1M)->F1M_UNIDAD)             //E12D - UNID_ITEM
                        oBloco0:SetQtdDev((cAlsF1M)->F1M_QTDCON)              //E13D - QTD_DEVOLVIDA
                        oBloco0:SetVunIem(nVlrItem)                           //E14D - VL_UNIT_ITEM
                        oBloco0:SetVBIcmSt((cAlsF1M)->F1M_BASIST)             //E15D - VL_BC_ICMS_ST
                        oBloco0:SetVIcmSEn((cAlsF1M)->F1M_VLRSUP)             //E16D - VL_ICMS_SUPORT_ENTR
                        oBloco0:SetChavRef(aDocOriApu[06])                    //E17D - CHAVE_REF
                        oBloco0:SetNIteRef(cItemOri)                          //E18D - N_ITEM_REF
                        oBloco0:Add1120()
                        nContReg += 1

                    ElseIf (cAlsF1M)->F1M_TPMOV == 'S' .And. (cAlsF1M)->F1M_INDOP == '0'

                        If (cAlsF1M)->F1M_INDSAI == '12' .And. !Empty(cChave1200)

                            //---Seta valores para o array aReg1210---//
                            oBloco0:SetNumer(aNumeracao)
                            oBloco0:SetRelac(cChave1200)
                            oBloco0:SetReg("1210")                            //G01 - REG
                            oBloco0:SetDatDoc((cAlsF1M)->FT_EMISSAO)          //G02 - DT_DOC
                            oBloco0:SetCsosn(Right((cAlsF1M)->FT_CLASFIS,2))  //G03 - CST_CSOSN
                            oBloco0:SetChave((cAlsF1M)->F1M_CHVDOC)           //G04 - CHAVE
                            oBloco0:SetNFiscal((cAlsF1M)->F1M_NFISCA)         //G05 - N_NF
                            oBloco0:SetCnpjEm(cCnpjF)                         //G06 - CNPJ_EMIT
                            oBloco0:SetUFemit(cEstF)                          //G07 - UF_EMIT
                            oBloco0:SetCnpjDes((cAlsF1M)->F1M_CNPJ)           //G08 - CNPJ_CPF_DEST
                            oBloco0:SetUFdest((cAlsF1M)->FT_ESTADO)           //G19 - UF_DEST
                            oBloco0:SetCfop((cAlsF1M)->F1M_CFOP)              //G10 - CFOP
                            oBloco0:SetItem(cItemDoc)                         //G11 - N_ITEM
                            oBloco0:SetUnidInv((cAlsF1M)->F1M_UNIDAD)         //G12 - UNID_ITEM
                            oBloco0:SetQtdSai((cAlsF1M)->F1M_QTDCON)          //G13 - QTD_SAIDA
                            oBloco0:SetVunIem(nVlrItem)                       //G14 - VL_UNIT_ITEM
                            oBloco0:SetVlICMef((cAlsF1M)->F1M_VLREFE)         //G15 - VL_ICMS_EFET
                            oBloco0:Add1210()
                            nContReg += 1

                        ElseIf (cAlsF1M)->F1M_INDSAI == '13' .And. !Empty(cChave1300)

                            //---Seta valores para o array aReg1310---//
                            oBloco0:SetNumer(aNumeracao)
                            oBloco0:SetRelac(cChave1300)
                            oBloco0:SetReg("1310")                              //I01 - REG
                            oBloco0:SetDatDoc((cAlsF1M)->FT_EMISSAO)            //I02 - DT_DOC
                            oBloco0:SetCsosn(Right((cAlsF1M)->FT_CLASFIS,2))    //I03 - CST_CSOSN
                            oBloco0:SetChave((cAlsF1M)->F1M_CHVDOC)             //I04 - CHAVE
                            oBloco0:SetNFiscal((cAlsF1M)->F1M_NFISCA)           //I05 - N_NF
                            oBloco0:SetCnpjEm(cCnpjF)                           //I06 - CNPJ_EMIT
                            oBloco0:SetUFemit(cEstF)                            //I07 - UF_EMIT
                            oBloco0:SetCnpjDes((cAlsF1M)->F1M_CNPJ)             //I08 - CNPJ_CPF_DEST
                            oBloco0:SetUFdest((cAlsF1M)->FT_ESTADO)             //I09 - UF_DEST
                            oBloco0:SetCfop((cAlsF1M)->F1M_CFOP)                //I10 - CFOP
                            oBloco0:SetItem(cItemDoc)                           //I11 - N_ITEM
                            oBloco0:SetUnidInv((cAlsF1M)->F1M_UNIDAD)           //I12 - UNID_ITEM
                            oBloco0:SetQtdSai((cAlsF1M)->F1M_QTDCON)            //I13 - QTD_SAIDA
                            oBloco0:SetVunIem(nVlrItem)                         //I14 - VL_UNIT_ITEM
                            oBloco0:SetVlICMef((cAlsF1M)->F1M_VLREFE)           //I15 - VL_ICMS_EFET
                            oBloco0:Add1310()
                            nContReg += 1

                        ElseIf (cAlsF1M)->F1M_INDSAI == '14' .And. !Empty(cChave1400)

                            //---Seta valores para o array aReg1410---//
                            oBloco0:SetNumer(aNumeracao)
                            oBloco0:SetRelac(cChave1400)
                            oBloco0:SetReg("1410")                              //K01 - REG
                            oBloco0:SetDatDoc((cAlsF1M)->FT_EMISSAO)            //K02 - DT_DOC
                            oBloco0:SetCsosn(Right((cAlsF1M)->FT_CLASFIS,2))    //K03 - CST_CSOSN
                            oBloco0:SetChave((cAlsF1M)->F1M_CHVDOC)             //K04 - CHAVE
                            oBloco0:SetNFiscal((cAlsF1M)->F1M_NFISCA)           //K05 - N_NF
                            oBloco0:SetCnpjEm(cCnpjF)                           //K06 - CNPJ_EMIT
                            oBloco0:SetUFemit(cEstF)                            //K07 - UF_EMIT
                            oBloco0:SetCnpjDes((cAlsF1M)->F1M_CNPJ)             //K08 - CNPJ_DEST
                            oBloco0:SetUFdest((cAlsF1M)->FT_ESTADO)             //K09 - UF_DEST
                            oBloco0:SetCfop((cAlsF1M)->F1M_CFOP)                //K10 - CFOP
                            oBloco0:SetItem(cItemDoc)                           //K11 - NUM_ITEM
                            oBloco0:SetUnidInv((cAlsF1M)->F1M_UNIDAD)           //K12 - UNID_ITEM
                            oBloco0:SetQtdSai((cAlsF1M)->F1M_QTDCON)            //K13 - QTD_SAIDA
                            oBloco0:SetVunIem(nVlrItem)                         //K14 - VL_UNIT_ITEM
                            oBloco0:SetVlICMef((cAlsF1M)->F1M_VLREFE)           //K15 - VL_ICMS_EFET
                            oBloco0:Add1410()
                            nContReg += 1

                        ElseIf (cAlsF1M)->F1M_INDSAI == '15' .And. !Empty(cChave1500)

                            //---Seta valores para o array aReg1510---//
                            oBloco0:SetNumer(aNumeracao)
                            oBloco0:SetRelac(cChave1500)
                            oBloco0:SetReg("1510")                              //M01 - REG
                            oBloco0:SetDatDoc((cAlsF1M)->FT_EMISSAO)            //M02 - DT_DOC
                            oBloco0:SetCsosn(Right((cAlsF1M)->FT_CLASFIS,2))    //M03 - CST_CSOSN
                            oBloco0:SetChave((cAlsF1M)->F1M_CHVDOC)             //M04 - CHAVE
                            oBloco0:SetNFiscal((cAlsF1M)->F1M_NFISCA)           //M05 - N_NF
                            oBloco0:SetCnpjEm(cCnpjF)                           //M06 - CNPJ_EMIT
                            oBloco0:SetUFemit(cEstF)                            //M07 - UF_EMIT
                            oBloco0:SetCnpjDes((cAlsF1M)->F1M_CNPJ)             //M08 - CNPJ_DEST
                            oBloco0:SetUFdest((cAlsF1M)->FT_ESTADO)             //M09 - UF_DEST
                            oBloco0:SetCfop((cAlsF1M)->F1M_CFOP)                //M10 - CFOP
                            oBloco0:SetItem(cItemDoc)                           //M11 - N_ITEM
                            oBloco0:SetUnidInv((cAlsF1M)->F1M_UNIDAD)           //M12 - UNID_ITEM
                            oBloco0:SetQtdSai((cAlsF1M)->F1M_QTDCON)            //M13 - QTD_SAIDA
                            oBloco0:SetVunIem(nVlrItem)                         //M14 - VL_UNIT_ITEM
                            oBloco0:Add1510()
                            nContReg += 1

                        Endif

                    ElseIf ((cAlsF1M)->F1M_TPMOV == 'E' .And. (cAlsF1M)->F1M_INDOP == '1')

                        aDocOriApu := aSize(aDocOriApu,0)
                        aDocOriApu := FsaB240Ap((cAlsF1M)->F1M_TPMOV, (cAlsF1M)->FT_NFORI, (cAlsF1M)->FT_SERORI, (cAlsF1M)->FT_ITEMORI, (cAlsF1M)->F1M_PARTIC, (cAlsF1M)->F1M_LOJA, (cAlsF1M)->F1M_PRODUT, cPerApur)
                        //---Ajuste do item quando este está no formato alfanumérico---//
                        cItemOri := ConvItem(oBloco0, aDocOriApu[08])

                        //---Definição do CNPJ e UF do emitente do Documento Fiscal---//
                        cUFEmit    := Iif((cAlsF1M)->FT_FORMUL = 'S', cEstF , (cAlsF1M)->FT_ESTADO)
                        cCnpjEmit  := Iif((cAlsF1M)->FT_FORMUL = 'S', cCnpjF, (cAlsF1M)->F1M_CNPJ)

                        If (cAlsF1M)->F1M_INDSAI == '12' .And. !Empty(cChave1200)

                            //---Seta valores para o array aReg1220---//
                            oBloco0:SetNumer(aNumeracao)
                            oBloco0:SetRelac(cChave1200)
                            oBloco0:SetReg("1220")                              //G01D - REG
                            oBloco0:SetDatDoc((cAlsF1M)->FT_EMISSAO)            //G02D - DT_DOC
                            oBloco0:SetCsosn(Right((cAlsF1M)->FT_CLASFIS,2))    //G03D - CST_CSOSN
                            oBloco0:SetChave((cAlsF1M)->F1M_CHVDOC)             //G04D - CHAVE
                            oBloco0:SetNFiscal((cAlsF1M)->F1M_NFISCA)           //G05D - N_NF
                            oBloco0:SetCnpjEm(cCnpjEmit)                        //G06D - CNPJ_EMIT
                            oBloco0:SetUFemit(cUFEmit)                          //G07D - UF_EMIT
                            oBloco0:SetCnpjDes(cCnpjF)                          //G08D - CNPJ_CPF_DEST
                            oBloco0:SetUFdest(cEstF)                            //G09D - UF_DEST
                            oBloco0:SetCfop((cAlsF1M)->F1M_CFOP)                //G10D - CFOP
                            oBloco0:SetItem(cItemDoc)                           //G11D - N_ITEM
                            oBloco0:SetUnidInv((cAlsF1M)->F1M_UNIDAD)           //G12D - UNID_ITEM
                            oBloco0:SetQtdDev((cAlsF1M)->F1M_QTDCON)            //G13D - QTD_DEVOLVIDA
                            oBloco0:SetVunIem(nVlrItem)                         //G14D - VL_UNIT_ITEM
                            oBloco0:SetVlICMef((cAlsF1M)->F1M_VLREFE)           //G15D - VL_ICMS_EFETIVO
                            oBloco0:SetChavRef(aDocOriApu[06])                  //G16D - CHAVE_REF
                            oBloco0:SetNIteRef(cItemOri)                        //G17D - N_ITEM_REF
                            oBloco0:Add1220()
                            nContReg += 1

                        ElseIf (cAlsF1M)->F1M_INDSAI == '13' .And. !Empty(cChave1300)

                            //---Seta valores para o array aReg1320---//
                            oBloco0:SetNumer(aNumeracao)
                            oBloco0:SetRelac(cChave1300)
                            oBloco0:SetReg("1320")                              //I01D - REG
                            oBloco0:SetDatDoc((cAlsF1M)->FT_EMISSAO)            //I02D - DT_DOC
                            oBloco0:SetCsosn(Right((cAlsF1M)->FT_CLASFIS,2))    //I03D - CST_CSOSN
                            oBloco0:SetChave((cAlsF1M)->F1M_CHVDOC)             //I04D - CHAVE
                            oBloco0:SetNFiscal((cAlsF1M)->F1M_NFISCA)           //I05D - N_NF
                            oBloco0:SetCnpjEm(cCnpjEmit)                        //I06D - CNPJ_EMIT
                            oBloco0:SetUFemit(cUFEmit)                          //I07D - UF_EMIT
                            oBloco0:SetCnpjDes(cCnpjF)                          //I08D - CNPJ_CPF_DEST
                            oBloco0:SetUFdest(cEstF)                            //I09D - UF_DEST
                            oBloco0:SetCfop((cAlsF1M)->F1M_CFOP)                //I10D - CFOP
                            oBloco0:SetItem(cItemDoc)                           //I11D - N_ITEM
                            oBloco0:SetUnidInv((cAlsF1M)->F1M_UNIDAD)           //I12D - UNID_ITEM
                            oBloco0:SetQtdDev((cAlsF1M)->F1M_QTDCON)            //I13D - QTD_DEVOLVIDA
                            oBloco0:SetVunIem(nVlrItem)                         //I14D - VL_UNIT_ITEM
                            oBloco0:SetVlICMef((cAlsF1M)->F1M_VLREFE)           //I15D - VL_ICMS_EFET
                            oBloco0:SetChavRef(aDocOriApu[06])                  //I16D - CHAVE_REF
                            oBloco0:SetNIteRef(cItemOri)                        //I17D - N_ITEM_REF
                            oBloco0:Add1320()
                            nContReg += 1

                        ElseIf (cAlsF1M)->F1M_INDSAI == '14' .And. !Empty(cChave1400)

                            //---Seta valores para o array aReg1420---//
                            oBloco0:SetNumer(aNumeracao)
                            oBloco0:SetRelac(cChave1400)
                            oBloco0:SetReg("1420")                              //K01D - REG
                            oBloco0:SetDatDoc((cAlsF1M)->FT_EMISSAO)            //K02D - DT_DOC
                            oBloco0:SetCsosn(Right((cAlsF1M)->FT_CLASFIS,2))    //K03D - CST_CSOSN
                            oBloco0:SetChave((cAlsF1M)->F1M_CHVDOC)             //K04D - CHAVE
                            oBloco0:SetNFiscal((cAlsF1M)->F1M_NFISCA)           //K05D - N_NF
                            oBloco0:SetCnpjEm(cCnpjEmit)                        //K06D - CNPJ_EMIT
                            oBloco0:SetUFemit(cUFEmit)                          //K07D - UF_EMIT
                            oBloco0:SetCnpjDes(cCnpjF)                          //K08D - CNPJ_DEST
                            oBloco0:SetUFdest(cEstF)                            //K09D - UF_DEST
                            oBloco0:SetCfop((cAlsF1M)->F1M_CFOP)                //K10D - CFOP
                            oBloco0:SetItem(cItemDoc)                           //K11D - N_ITEM
                            oBloco0:SetUnidInv((cAlsF1M)->F1M_UNIDAD)           //K12D - UNID_ITEM
                            oBloco0:SetQtdDev((cAlsF1M)->F1M_QTDCON)            //K13D - QTD_DEVOLVIDA
                            oBloco0:SetVunIem(nVlrItem)                         //K14D - VL_UNIT_ITEM
                            oBloco0:SetVlICMef((cAlsF1M)->F1M_VLREFE)           //K15D - VL_ICMS_EFET
                            oBloco0:SetChavRef(aDocOriApu[06])                  //K16D - CHAVE_REF
                            oBloco0:SetNIteRef(cItemOri)                        //K17D - N_ITEM_REF
                            oBloco0:Add1420()
                            nContReg += 1

                        ElseIf (cAlsF1M)->F1M_INDSAI == '15' .And. !Empty(cChave1500)

                            //---Seta valores para o array aReg1520---//
                            oBloco0:SetNumer(aNumeracao)
                            oBloco0:SetRelac(cChave1500)
                            oBloco0:SetReg("1520")                              //M01D - REG
                            oBloco0:SetDatDoc((cAlsF1M)->FT_EMISSAO)            //M02D - DT_DOC
                            oBloco0:SetCsosn(Right((cAlsF1M)->FT_CLASFIS,2))    //M03D - CST_CSOSN
                            oBloco0:SetChave((cAlsF1M)->F1M_CHVDOC)             //M04D - CHAVE
                            oBloco0:SetNFiscal((cAlsF1M)->F1M_NFISCA)           //M05D - N_NF
                            oBloco0:SetCnpjEm(cCnpjEmit)                        //M06D - CNPJ_EMIT
                            oBloco0:SetUFemit(cUFEmit)                          //M07D - UF_EMIT
                            oBloco0:SetCnpjDes(cCnpjF)                          //M08D - CNPJ_DEST
                            oBloco0:SetUFdest(cEstF)                            //M09D - UF_DEST
                            oBloco0:SetCfop((cAlsF1M)->F1M_CFOP)                //M10D - CFOP
                            oBloco0:SetItem(cItemDoc)                           //M11D - N_ITEM
                            oBloco0:SetUnidInv((cAlsF1M)->F1M_UNIDAD)           //M12D - UNID_ITEM
                            oBloco0:SetQtdDev((cAlsF1M)->F1M_QTDCON)            //M13D - QTD_DEVOLVIDA
                            oBloco0:SetVunIem(nVlrItem)                        //M14D - VL_UNIT_ITEM
                            oBloco0:SetChavRef(aDocOriApu[06])                  //M15D - CHAVE_REF
                            oBloco0:SetNIteRef(cItemOri)                        //M16D - N_ITEM_REF
                            oBloco0:Add1520()
                            nContReg += 1

                        Endif
                    EndIf
                    (cAlsF1M)->(DbSkip())
                EndDo
                (cAlsF1M)->(DbCloseArea())

            EndIf
            (cAlsF1L)->(DbSkip())
        EndDo
        (cAlsF1L)->(DbCloseArea())
        oQryMov:Destroy()
        oQryMov:= NIL
    EndIf


    //---------------------------------------------------------------------//
    //---Grava registros gerados nos arrays aRegxxx na tabela temporária---//
    //---------------------------------------------------------------------//
    oTabela:GrvReg(oBloco0:Get0000()) 
    oTabela:GrvReg(oBloco0:Get1000())
    oTabela:GrvReg(oBloco0:Get1010())
    oTabela:GrvReg(oBloco0:Get1100())
    oTabela:GrvReg(oBloco0:Get1115())
    oTabela:GrvReg(oBloco0:Get1200())
    oTabela:GrvReg(oBloco0:Get1300())
    oTabela:GrvReg(oBloco0:Get1400())
    oTabela:GrvReg(oBloco0:Get1500())
    oTabela:GrvReg(oBloco0:Get1110())
    oTabela:GrvReg(oBloco0:Get1120())
    oTabela:GrvReg(oBloco0:Get1210())
    oTabela:GrvReg(oBloco0:Get1310())
    oTabela:GrvReg(oBloco0:Get1410())
    oTabela:GrvReg(oBloco0:Get1510())
    oTabela:GrvReg(oBloco0:Get1220())
    oTabela:GrvReg(oBloco0:Get1320())
    oTabela:GrvReg(oBloco0:Get1420())
    oTabela:GrvReg(oBloco0:Get1520())
    oTabela:GrvReg(oBloco0:Get9000())

    //--------------------//
    //---Registro 1999 ---//
    //--------------------//
    oBloco0:SetNumer(aNumeracao)
    oBloco0:SetRelac(cChaveBlc0)
    nContReg += 1
    oBloco0:SetReg("1999")            //R01 - REG
    oBloco0:SetQtdeLin(STR(nContReg)) //R02 - QTD_LIN
    oBloco0:Add1999()
    oTabela:GrvReg(oBloco0:Get1999())

    //--------------------//
    //---Registro 9999 ---//
    //--------------------//
    oBloco0:SetNumer(aNumeracao)
    oBloco0:SetRelac(cChaveBlc0)
    nContReg += 2
    oBloco0:SetReg("9999")            //Z01 - REG
    oBloco0:SetQtdeLin(STR(nContReg)) //Z02 - QTD_LIN
    oBloco0:Add9999()
    oTabela:GrvReg(oBloco0:Get9999())

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


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc}

Função

@author Ulisses P. Oliveira
@since 19/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function ConvItem(oBloco,cItemDoc)
Local cItemConv := PadL(Right(AllTrim(cItemDoc),3),3,'0')
Local nItemDoc  := 0

If cItemConv > '099'
    nItemDoc  := oBloco:DoCvItem(Right(cItemConv,2))
    cItemConv := Iif(nItemDoc > 0, StrZero(nItemDoc,3), cItemConv)
EndIf

Return cItemConv
