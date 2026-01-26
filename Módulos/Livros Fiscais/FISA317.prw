#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA317.CH"

STATIC dDataAtu  := dDataBase as Date

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA317
    Função que fará o processamento da apuração e/ou arquivo da EFD
    Contribuições quando este for executado via Smartschedule
    @type  Function
    @author Alexandre Esteves
    @since 22/04/2024
    @version 12.1.2410
    @param aParam, array, array do scheddef
    @return nil
/*/
//-------------------------------------------------------------------
Function FISA317()

Local oEfdAge    := nil	as object
Local aReprocess := {}  as array
Local aAutoFil	 := {}	as array
Local aContab    := {}  as array
Local cAliasCJT  := ""	as character
Local cAliasCJU	 := ""  as character
Local cCodAgen   := ""  as character
Local cTpProc    := ""  as character
Local cIdFil     := ""  as character
Local cTipoPer   := ""  as character
Local dVigIni,dVigFim,dPerIni,dPerFim  := ctod("//") as Date

oEfdAge	:= totvs.protheus.backoffice.fiscal.fisa317.efdagenda.EfdAgendamento():new("CJT")

cCodAgen  :=  MV_PAR01
cAliasCJT := oEfdAge:queryCJT(cCodAgen)
cTpProc   := (cAliasCJT)->CJT_TPPROC
dVigIni   := StoD((cAliasCJT)->CJT_VIGINI)	
dVigFim   := StoD((cAliasCJT)->CJT_VIGFIM)

If ((Empty(dVigIni) .Or. dVigIni <= dDataAtu) .And. (Empty(dVigFim) .Or. dVigFim >= dDataAtu))

    //Setup Filiais
    cIdFil    := (cAliasCJT)->CJT_IDFIL
    cAliasCJU := oEfdAge:queryCJU(cIdFil)

    While !(cAliasCJU)->(Eof())

        Aadd(aAutoFil,{.T.,( cAliasCJU)->CJU_FILSEL})

        (cAliasCJU)->(dbSkip())
    Enddo

    (cAliasCJU)->(DBCloseArea())

    //Setup Data de Processamento
    cTipoPer := (cAliasCJT)->CJT_TPPER

    If cTipoPer $ "1/2/3"
        dPerIni  := oEfdAge:setPeriodoIni(cTipoPer)
        dPerFim  := LastDay(dPerIni)
    Else
        dPerIni  := GetFormul((cAliasCJT)->CJT_FDTINI) 
        dPerFim  := GetFormul((cAliasCJT)->CJT_FDTFIM) 
    Endif

    //Processamento da Apuração
    If cTpProc $ "1/3" // Só Apuração ou Ambos

        aAdd(aReprocess,1) //NF Entrada?
        aAdd(aReprocess,1) //NF Saida?
        aAdd(aReprocess,1) //Tit.Entrada?
        aAdd(aReprocess,1) //Tit.Saida?
        aAdd(aReprocess,1) //Ativo Fixo?
        aAdd(aReprocess,1) //Cupom Fisc.?
        aAdd(aReprocess,1) //CPRB?    

        Pergunte("ISA001",.F.)
        DeParaApu(cAliasCJT,dPerIni, dPerFim)
        FChcTpFunc("001",Nil,aReprocess,aAutoFil)

        If MV_PAR13<>2 
            TrataCdRec(cAliasCJT,dPerFim)
        Endif
    Endif 

    // Processamento do Arquivo 
    If cTpProc $ "2/3" // Só Arquivo ou Ambos

        Pergunte("FSA008",.F.)
        DeParaArq(cAliasCJT,dPerIni, dPerFim)
        aContab := DeParaCont(cAliasCJT)
        FISA008(.T.,aContab,aAutoFil)

    Endif
Endif

oEfdAge:Destroy()
FwFreeArray(aReprocess)
FwFreeArray(aAutoFil)
FwFreeArray(aContab)
(cAliasCJT)->(DBCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Scheddef()
    Função scheddef
    @author Alexandre Esteves
    @since 22/04/2024
    @version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function Scheddef()

Local aParam  := {} as array

aParam := { "P",;           //Tipo R para relatorio P para processo
            "FSAPRE",;      //Pergunte do relatorio, caso nao use passar ParamDef
            ,;              //Alias
            ,;              //Array de ordens
            }               //Titulo

Return aParam

//-------------------------------------------------------------------
/*/{Protheus.doc} DeParaApu
    Função Estática para substituir os valores do pergunte ISA0001
    pelos valores que estão na tabela CJT de acordo com o Codigo de
    Agendamento setado na rotina do scheduler
    @type  Static Function
    @author Alexandre Esteves
    @since 25/04/2024
    @version 12.1.2410
    @param cAlias, character, Alias da tabela CJT
    @param dDataIni, date, Data inicial de processamento
    @param dDataFim, date, Data Final de processamento
    @return nil
/*/
//-------------------------------------------------------------------
Static Function DeParaApu(cAlias, dDataIni, dDataFim)

Default dDataIni := firstDay(dDataAtu)
Default dDataFim := lastDay(dDataAtu) 

MV_PAR01 := dDataIni                    //Data Inicial ?
MV_PAR02 := dDataFim                    //Data Final?
MV_PAR03 := (cAlias)->CJT_LIVRO         //Livro ?
MV_PAR04 := 1                           //Seleciona Filial? - sempre será 1
MV_PAR05 := val((cAlias)->CJT_TRIBUT)   //Tributos?
MV_PAR06 := val((cAlias)->CJT_REGIME)   //Regime Pis/Cofins
MV_PAR07 := val((cAlias)->CJT_PISFOL)   //Pis Folha de Salario ?
MV_PAR08 := val((cAlias)->CJT_SOCCOP)   //Sociedade Cooperativa?
MV_PAR09 := val((cAlias)->CJT_INSFIN)   //Instuição Financeira?
MV_PAR10 := val((cAlias)->CJT_DIFMNT)   //Diferimento?
MV_PAR11 := val((cAlias)->CJT_CPFIS)    //Cupom Fiscal?
MV_PAR12 := val((cAlias)->CJT_DETRCX)   //Detalhamento Regime Caixa?
MV_PAR13 := val((cAlias)->CJT_GERTIT)   //Gera Titulo?
MV_PAR14 := val((cAlias)->CJT_CONTAB)   //Contabiliza?
MV_PAR15 := val((cAlias)->CJT_OPGRV)    //Opção de Gravação?
MV_PAR16 := (cAlias)->CJT_CDRCSV        //Cod Rec Serviço
MV_PAR17 := (cAlias)->CJT_CDDMOP        //Cod Receita Demais Operações
MV_PAR18 := (cAlias)->CJT_INATPJ        //Indicador Natureza PJ?
MV_PAR19 := val((cAlias)->CJT_PRRETS)   //Processa Retenções-Saidas?
MV_PAR20 := val((cAlias)->CJT_IREGCM)   //Indicado Regime Cumulativo?
MV_PAR21 := val((cAlias)->CJT_ALTTIT)   //Alterar Titulo Gerado?
MV_PAR22 := val((cAlias)->CJT_DECJUD)   //Decisão Judicial Exclusão ICMS?
MV_PAR23 := val((cAlias)->CJT_EXCICM)   //Exclusão ICMS a Recolher?
MV_PAR24 := val((cAlias)->CJT_DEVCAN)   //Dev/Canc. Periodo Anterior?
    
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataCdRec
    Função Estática com proposito de preencher os dados da guia de 
    pagamento e adicionar os valores na rotina FISA002, tratando 
    data de vencimento e codigos de receita.
    @type  Static Function
    @author Alexandre Esteves
    @since 29/04/2024
    @version 12.1.2410
    @param cAlias, character, Alias da tabela CJT 
    @param dDtFim, date, Data final do processamento usado como base 
    para composição da data de vencimento.
    @return nil
/*/
//-------------------------------------------------------------------
Static Function TrataCdRec(cAlias, dDtFim)


Local cPisNc        := "" as character
Local cCofNc        := "" as character
Local cCPRB         := "" as character
Local cPisCm        := "" as character  
Local cCofCm        := "" as character
Local cTpVencto     := "" as character
Local dDtVencto     := Ctod("//") as Date
Local lIsBlind		:= IsBlind() as logical
Local aRecolh		:= {} as array
Local aRecolhAux	:= {} as array
Local nDiasVenc	    := 0  as numeric
Local nMesSub		:= 1  as numeric
Local lAntPos       :=.F. as logical
Local oModel			  as object
Local oCodRec			  as object


//-- Variáveis que são privates dentro da rotina FISA002
Private lCarrega	:= .F. as logical
Private cConsol	    := '2' as character

cPisNc  := (cAlias)->CJT_CRPSNC
cCofNc  := (cAlias)->CJT_CRCFNC
cPisCm  := (cAlias)->CJT_CRPISC
cCofCm  := (cAlias)->CJT_CRCOFC
cCPRB   := (cAlias)->CJT_CRCPRB
cTpVencto := (cAlias)->CJT_TPVCTO
nMesSub := (cAlias)->CJT_MESSUB
nDiasVenc := (cAlias)->CJT_DIAVCT
lAntPos := !((cAlias)->CJT_ANTPOS == '1')


dDtVencto :=CtoD(""+StrZero(nDiasVenc,2)+"/"+StrZero(Month(dDtFim),2)+"/"+Str(Year(dDtFim)))
dDtVencto := MonthSum(dDtVencto, nMesSub)

If cTpVencto == '1' 
     dDtVencto := DataValida(dDtVencto, lAntPos) 
Endif

oCodRec:= totvs.protheus.backoffice.fiscal.fisa001.utils.CodigoReceita():new()
aRecolhAux:= oCodRec:toArray()

If Len(aRecolhAux) == 0
    aRecolhAux:= {'','','',''}
Endif

// Hierarquia CJT e depois Parametro inicialmente - PIS/COFINS Não Cumulativo
if (cAlias)->CJT_REGIME $ '1/4'
    If !Empty(cPisNc) .and. !Empty(cCofNc)
        aadd(aRecolh,{cPisNc,dDtVencto})
        aadd(aRecolh,{cCofNc,dDtVencto})
    Else
        aadd(aRecolh,{aRecolhAux[1],dDtVencto})//Primeira posição corresponde ao código de receita de PIS Não Cumulativo;
        aadd(aRecolh,{aRecolhAux[2],dDtVencto})//Segunda posição corresponde ao código de receita de COFINS Não Cumulativo;
    Endif
Endif

// Hierarquia CJT e depois Parametro inicialmente - PIS/COFINS Cumulativo
If (cAlias)->CJT_REGIME $ '2/3/4'
    If !Empty(cPisCm) .and. !Empty(cCofCm)
        aadd(aRecolh,{cPisCm,dDtVencto})
        aadd(aRecolh,{cCofCm,dDtVencto})
    Else
        aadd(aRecolh,{aRecolhAux[3],dDtVencto})//Terceira posição corresponde ao código de receita de PIS Cumulativo;
        aadd(aRecolh,{aRecolhAux[4],dDtVencto})//Quarta posição corresponde ao código de Receita de COFINS Cumulativo.
    Endif
Endif

//--- FISA002 ---
//Carrego o Model
oModel	:= FWLoadModel('FISA002')
//Seto a operação do Model
oModel:SetOperation(MODEL_OPERATION_UPDATE)
//Ativo o Model
oModel:Activate()

ASA001GDUP(aRecolh,lIsBlind)

FreeObj(oCodRec)
FwFreeArray(aRecolh)
FwFreeArray(aRecolhAux)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} DeParaArq
    Função Estática para substituir os valores do pergunte FSA008
    pelos valores que estão na tabela CJT de acordo com o Codigo de
    Agendamento setado na rotina do scheduler
    @type  Static Function
    @author Alexandre Esteves
    @since 02/05/2024
    @version 12.1.2410
    @param cAlias, character, Alias da tabela CJT
    @param dDataIni, date, Data inicial de processamento
    @param dDataFim, date, Data Final de processamento
    @return nil
/*/
//-------------------------------------------------------------------
Static Function DeParaArq(cAlias, dDataIni, dDataFim)

Local cPrefixo   := "" as character
Local cCodReg    := Alltrim((cAlias)->CJT_CODREG) as character
Local cArq       := Alltrim((cAlias)->CJT_ARQ)    as character
Local cFilAtu    := xFilial("CJT")                as character
Local cPeriodo   := "" as character
Local nTamCmp    := TamSx1("FSA008","06")[1] 

Default dDataIni := firstDay(dDataAtu)
Default dDataFim := lastDay(dDataAtu) 

cPeriodo := StrZero(Year (dDataFim),4)+StrZero(Month (dDataFim),2)
cPrefixo := "EFDAGEN_"+Alltrim(cFilAtu)+"_"+cCodReg+"_"+cPeriodo+"_"+cArq 
cPrefixo := Substr(cPrefixo,1,nTamCmp)

MV_PAR01 := dDataIni                    //Data Inicial ?
MV_PAR02 := dDataFim                    //Data Final?
MV_PAR03 := (cAlias)->CJT_LIVRO         //Livro ?
MV_PAR04 := 1                           //Seleciona Filial? - sempre será 1
MV_PAR05 := (cAlias)->CJT_DIR           //Diretório?
MV_PAR06 := cPrefixo                    //Arquivo?
MV_PAR07 := val((cAlias)->CJT_AGRUPA)   //Agrupa por CNPJ?
MV_PAR08 := val((cAlias)->CJT_TPESCR)   //Regime Pis/Cofins?
MV_PAR09 := 1                           //Tipo Escrituração? //Sempre iremos processar 1 - Original
MV_PAR10 := (cAlias)->CJT_SITESP        //Indicador Situação Especial?
MV_PAR11 := (cAlias)->CJT_INDNAT        //Indicador Natureza PJ?
MV_PAR12 := (cAlias)->CJT_ATIVIP        //Atividade Preponderante?
MV_PAR13 := (cAlias)->CJT_NRECIB        //Numero do Recibo?
MV_PAR14 := (cAlias)->CJT_ISCCOP        //Sociedade Cooperativa?
MV_PAR15 := val((cAlias)->CJT_TPCTRB)   //Tipo Contribuição?
MV_PAR16 := val((cAlias)->CJT_ITPCUM)   //Indicador Regime Cumulativo?
MV_PAR17 := (cAlias)->CJT_BLOCOI        //Indicador Bloco I
MV_PAR18 := val((cAlias)->CJT_NFECUP)   //Indicador NFe/Cupom?
MV_PAR19 := val((cAlias)->CJT_GERCP)    //Gera Cupom Fiscal
MV_PAR20 := val((cAlias)->CJT_BLOCOP)   //Gera Bloco P?
MV_PAR21 := (cAlias)->CJT_ICTRIB        //Incidencia Tributaria(0145)?
MV_PAR22 := val((cAlias)->CJT_RG0400)   //Decisão Judicial Exclusão ICMS?
MV_PAR23 := val((cAlias)->CJT_DISPEN)   //Exclusão ICMS a Recolher?
MV_PAR24 := val((cAlias)->CJT_ENVPOS)   //Dev/Canc. Periodo Anterior?

   
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} DeParaCont
 Função Estática para atribuir os dados de contabilista a um array que
 sera usado na geração do arquivo da EFD Contribuições
    @type  Static Function
    @author Alexandre Esteves
    @since 02/05/2024
    @version 12.1.2410
    @param cAlias, character, Alias com os dados da tabela CJT
    @return aContab, array, Array com os dados do contabilista
/*/
//-------------------------------------------------------------------
Static Function DeParaCont(cAlias)

Local aContab := {} as array

//Array do Contabilista EFD Contribuições             	
aAdd(aContab,(cAlias)->CJT_NOME)	               
aAdd(aContab,(cAlias)->CJT_CGC)                	
aAdd(aContab,(cAlias)->CJT_CPF)	            
aAdd(aContab,(cAlias)->CJT_CRC)	         
aAdd(aContab,(cAlias)->CJT_CEP)	                  
aAdd(aContab,(cAlias)->CJT_CODMUN)	                  
aAdd(aContab,(cAlias)->CJT_END)          	
aAdd(aContab,(cAlias)->CJT_NUM)	        
aAdd(aContab,(cAlias)->CJT_COMPL)	                  
aAdd(aContab,(cAlias)->CJT_BAIRRO)	                
aAdd(aContab,(cAlias)->CJT_TEL)
aAdd(aContab,(cAlias)->CJT_FAX)
aAdd(aContab,(cAlias)->CJT_EMAIL)
 
Return aContab

//-------------------------------------------------------------------
/*/{Protheus.doc} F317VIG
 Função para validar vigencia inicial e final no pergunte
    @type  Static Function
    @author Alexandre Esteves
    @since 09/05/2024
    @version 12.1.2410
    @param cCodReg, character, Codigo do Agendamento vindo do Pergunte
    @return lRet, logical,Retorno logico sobre o ponto de validação das vigencias
/*/
//-------------------------------------------------------------------
Function F317VIG(cCodReg as character) 

Local lRet    := .F. as logical
Local cAlias  := ""  as character
Local oEfdAge := Nil as Object
Local dVigIni, dVigFim := CtoD("//") as Date

Default cCodReg := ""

oEfdAge	:= totvs.protheus.backoffice.fiscal.fisa317.efdagenda.EfdAgendamento():new("CJT")

cAlias := oEfdAge:queryCJT(cCodReg)
dVigIni   := StoD((cAlias)->CJT_VIGINI)
dVigFim   := StoD((cAlias)->CJT_VIGFIM)

If ((Empty(dVigIni) .Or. dVigIni <= dDataAtu) .And. (Empty(dVigFim) .Or. dVigFim >= dDataAtu))  
    lRet := .T.
Else
    lRet := .F.
    FwAlertInfo( STR0001, STR0002)
Endif

oEfdAge:Destroy()
(cAlias)->(DBCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFormul
 Função Estática para pegar a data do campo formula da tabela CJT
    @type  Static Function
    @author Alexandre Esteves
    @since 11/05/2024
    @version 12.1.2410
    @param cFormula, character, Codigo da Formula da CJT para ser achada na SM4
    @return dDataFml, date, Resultado do encontrado do campo SM4->FORMULA
/*/
//-------------------------------------------------------------------
Static Function GetFormul(cFormula as character) 

Local dDataFml := CtoD("//")   as Date

Default cFormula := ""

SM4->( DbSetOrder( 1 ))
If SM4->( MsSeek( xFilial("SM4") + cFormula ) )
	 dDataFml := &(SM4->M4_FORMULA)
EndIf

Return dDataFml
