#INCLUDE 'PROTHEUS.CH'/*
*/

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA234A
  
Definição da Estrutura de Classes para geração do arquivo da ADRCST - Demonstrativo para Apuração Mensal 
do Ressarcimento, da Restituição e da Complementação do ICMS Substituição Tributária, do Estado de Santa 
Catarina.
O método de apuração é determinado pelo Decreto Nº 1818 DE 28/11/2018 e pela Portaria SEF N° 378/2018.

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------


//==================================================================================================
/*/{Protheus.doc} Classe ADRCSTTMP

Classe da tabela temporária

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//==================================================================================================
CLASS ADRCSTTMP
    Data cAliasTmp  As String
    Data cArqTmp    As String
    Data cDelimit   As String
    Data aRegistro  As Array 
    Data cLinhaTxt  As String
    Data cGrupo	    As String
    Data cBloco	    As String
    Data cRegistro  As String
    Data cDiretorio As String
    Data cNomeArq   As String
    
    Method New()
    Method CriaTabela()
    Method GrvReg()
    Method GeraLinha()
    Method GravaLinha()
    Method GravaTXT()
    Method DelTabela()
    Method SetAlsTmp(cAliasTmp)
    Method SetArqTmp(cArqTmp)
    Method SetDelimit(cDelimit)
    Method SetLinTxt(cLinhaTxt)
    Method SetGrupo(cGrupo)
    Method SetBloco(cBloco)
    Method SetRegist(cRegistro)
    Method SetDiretor(cDiretorio)
    Method SetNomeArq(cNomeArq)
    Method GetAlias()
ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe ADRCSTTMP

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() CLASS ADRCSTTMP
    Self:aRegistro :={}
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTabela
 
Método que irá criar a tabela temporária para gravação dos registros

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method CriaTabela() CLASS ADRCSTTMP
    Local aCmp      := {}
    Local cArquivo  := "ADRCST"+GetDBExtension() //---Recupera o nome fisico gerado---//
    Local cAliasTRB := "ADRCST"
    Local oArqtmp

    aAdd (aCmp, {'NROBLOCO',	'C', 	002,	0})	//---Número do bloco---//
    aAdd (aCmp, {'REGISTRO',	'C', 	004,	0})	//---Registro que deverá ser gravado---//
    aAdd (aCmp, {'GRUPO',	    'C', 	078,	0})	//---Código do grupo utilizado para ordenação da tabela, no momento da gravação do arquivo texto---//
    aAdd (aCmp, {'CONTEUDO',	'C', 	500,	0})	//---Conteúdo da linha a ser gravada no arquivo texto---//

    Self:cAliasTmp := cAliasTRB
    Self:cArqTmp   := cArquivo

    oArqtmp := FWTemporaryTable():New(cAliasTRB)
    oArqtmp:SetFields(aCmp)
    oArqtmp:AddIndex("01", {"NROBLOCO","GRUPO","REGISTRO"} )
    oArqtmp:Create()
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvReg
 
Método de Gravação

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method GrvReg(aRegistro) CLASS ADRCSTTMP
    Self:aRegistro := aRegistro
    Self:GeraLinha()
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraLinha
 
Método que monta a linha a ser denonstrada no arquivo

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method GeraLinha() CLASS ADRCSTTMP
    Local nContR    := 0
    Local nContC    := 0
    Local nDecimal  := 2
    Local cLinha    := ''
    Local cConteudo := ''
    Local cType		:= ''
    Local dDate		:= cTod('  /  /    ')
    
    Self:cDelimit	:= '|'

    //---Laço para percorrer os registros---//
    For nContR := 1 To Len(Self:aRegistro)

        //---Relacionamento dos registros---//
        Self:cGrupo	   := AllTrim(Self:aRegistro[nContR][1])
        Self:cRegistro := AllTrim(Self:aRegistro[nContR][2])
        Self:SetRegist(Self:cRegistro)

        //---Laço para percorrer os campos dos registros---//
        For nContC := 2 To Len(Self:aRegistro[nContR])
            cType := ValType(Self:aRegistro[nContR][nContC])

            If cType == 'A'
                If ValType(Self:aRegistro[nContR][nContC][1]) == 'N'

                    nDecimal := Self:aRegistro[nContR][nContC][2]

                    If Len(Self:aRegistro[nContR][nContC]) == 2
	                   	cConteudo := AllTrim(StrTran(Str(Self:aRegistro[nContR][nContC][1],,nDecimal), ".", ","))
                    ElseIf Len(Self:aRegistro[nContR][nContC]) == 3 .AND. Self:aRegistro[nContR][nContC][3] == 'P'
                 		cConteudo := NumSignif(Self:aRegistro[nContR][nContC][1], nDecimal)
                    EndIf
                    	                    
                Else
                    cConteudo := AllTrim (Self:aRegistro[nContR][nContC][1])
                EndIf
            ElseIf cType == 'N'
                nDecimal  := 2
                cConteudo := AllTrim(StrTran(Str(Self:aRegistro[nContR][nContC],,nDecimal), ".", ","))
            ElseIf cType == 'C'
                cConteudo := AllTrim (Self:aRegistro[nContR][nContC])
            ElseIf cType == 'D'
                dDate     := Self:aRegistro[nContR][nContC]
                cConteudo := StrZero(Day(dDate),2)+StrZero(Month(dDate),2)+StrZero(Year(dDate),4)
            Else
                cConteudo	:= ''
            EndIf
            
            cLinha +=  cConteudo + Self:cDelimit
            
        Next nContC
        
        cLinha         := AllTrim(Left(cLinha,Len(cLinha)-1))
        Self:cLinhaTxt := cLinha
        
        Self:GravaLinha()
        cLinha	:= ''
    Next nContR

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaLinha
 
Método que efetua a gravação da linha na tabela temporaria

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method GravaLinha() CLASS ADRCSTTMP
    RecLock(Self:cAliasTmp,.T.)
    Replace NROBLOCO  With Self:cBloco
    Replace REGISTRO  With Self:cRegistro
    Replace GRUPO     With Self:cGrupo
    Replace CONTEUDO  With Self:cLinhaTxt
    (Self:cAliasTmp)->(MsUnLock())
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaTXT
 
Método que efetua a gravação do arquivo texto
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method GravaTxt() CLASS ADRCSTTMP
    Local cNomeTmp  := Self:cDiretorio+'ADRCST - '+cFilAnt+'.Txt'
    Local cNomeReal := Self:cDiretorio+Self:cNomeArq
    Local bError
    Local lErro     := .F.
    
    DbSelectArea(Self:cAliasTmp)
    (Self:cAliasTmp)->(DBSetOrder(1))
    (Self:cAliasTmp)->(DbGoTop())
    Set Filter To

    bError := ErrorBlock( {|| lErro := .T. } )
    BEGIN SEQUENCE
        Copy to &cNomeReal FIELDS 'CONTEUDO' DELIMITED WITH ''
    END SEQUENCE
    ErrorBlock( bError )

    If lErro
        Alert('Erro ao gravar arquivo texto')
    EndIF
Return Iif(lErro,cNomeTmp,'')


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DelTabela
 
Método que apaga a tabela temporária criada para geração do arquivo texto
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method DelTabela() CLASS ADRCSTTMP
    FWCLOSETEMP(Self:cAliasTmp)
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetAlsTmp(cAliasTmp) CLASS ADRCSTTMP
    Self:cAliasTmp := cAliasTmp
Return

Method SetArqTmp(cArqTmp) CLASS ADRCSTTMP
    Self:cArqTmp := cArqTmp
Return

Method SetDelimit(cDelimit)   CLASS ADRCSTTMP
    Self:cDelimit := cDelimit
Return

Method SetLinTxt(cLinhaTxt) CLASS ADRCSTTMP
    Self:cLinhaTxt := cLinhaTxt
Return

Method SetGrupo(cGrupo) CLASS ADRCSTTMP
    Self:cGrupo := cGrupo
Return

Method SetBloco(cReg) CLASS ADRCSTTMP
Local cBloco := SubStr(cReg,1,1)

Do Case
	Case cBloco == '0'
		Self:cBloco	:= '00'
	Case cBloco == '1'
		Self:cBloco	:= '00'
	Case cBloco == '9'
		Self:cBloco	:= '00'		
EndCase

Return

Method SetRegist(cRegistro) CLASS ADRCSTTMP
    Self:cRegistro := cRegistro
    // Com base no registro passado determino o bloco. 
    // Este não é o bloco que vai para o arquivo, mas sim a ordem que será utilizada na ordenação dos registros.
    Self:SetBloco(cRegistro)
Return

Method SetDiretor(cDiretorio) CLASS ADRCSTTMP
    Self:cDiretorio := cDiretorio
Return

Method SetNomeArq(cNomeArq) CLASS ADRCSTTMP
    Self:cNomeArq := cNomeArq
Return

Method GetAlias() CLASS ADRCSTTMP
Return Self:cAliasTmp


//==================================================================================================
/*/{Protheus.doc} Classe ADRCST

Classe que controla o conteúdo dos blocos e registros do arquivo

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//==================================================================================================
CLASS ADRCST
    
//---Propriedades p/ controlar o relacionamento entre os registros---//
Data cGrupoReg  As String 
Data cRelac     As String 
Data aNumeracao As Array
Data cReg       As String
Data lConcFil   As Boolean
Data lBuild     As Boolean

Method New()
Method Clear()

Method AbreBloco(cReg,aReg,cIndMov)
Method FechaBloco(cReg,aReg,nQtde)

Method SetReg(cReg)
Method SetNumer(aNumeracao)
Method SetRelac(cRelac)
Method SetConcFil(lConcFil)
Method GetConcFil()
Method GetGrupo()

//---Metodos para manipulação das hashmaps.
Method AddHash(oHash,cChave,nPos)
Method FindHash(oHash, cChave)

ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe ADRCST

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() CLASS ADRCST
    Self:Clear()
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear
  
Método que inicializa os atributos da Classe DRCST

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear() CLASS ADRCST

    Self:cGrupoReg  := ''
    Self:cRelac     := ''
    Self:aNumeracao := {}
    Self:lConcFil   := SuperGetMv('MV_COFLSPD', .F., .T.)
    Self:lBuild     := GetBuild() >= "7.00.131227A"

    
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AbreBloco
  
Método que faz a abertura de Blocos

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method AbreBloco(cReg,aReg,cIndMov) CLASS ADRCST
    Local nPos := 0

    Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,'', cReg)
    aAdd(aReg, {})
    nPos := Len(aReg)
    aAdd (aReg[nPos], Self:cGrupoReg) //---Relacionamento com registro pai---//
    aAdd (aReg[nPos], cReg)           //---Registro---//
    aAdd (aReg[nPos], cIndMov)        //---Indica se tem ou não movimento---//
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FechaBloco
  
Método que faz o fechamento de Blocos

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method FechaBloco(cReg,aReg,nQtde) CLASS ADRCST
    Local nPos := 0
    
    Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,'', cReg)
    aAdd(aReg, {})
    nPos := Len(aReg)
    aAdd (aReg[nPos], Self:cGrupoReg) //---Relacionamento com registro pai---//
    aAdd (aReg[nPos], cReg)           //---Registro---//
    aAdd (aReg[nPos], nQtde)          //---Indica se tem ou não movimento---//
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add9001
 
Método para geração do registro de Abertura do Bloco 9
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
//Method Add9001(cIndMovto) CLASS ADRCST
//    Self:AbreBloco('9001',@Self:aReg9001,cIndMovto)
//Return Self:aReg9001


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add9900
 
Método para definir o grupo para saber de qual registro o 9900 pertence
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
//Method Add9900(cReg,nQtde) CLASS ADRCST
//    Local nPos	:= 0

  //  nPos := aScan (Self:aReg9900, {|aX| aX[3]==cReg})
    //If nPos == 0
      //  Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,'','9900')
        //aAdd(Self:aReg9900,{})
        //nPos :=	Len (Self:aReg9900)
        //aAdd (Self:aReg9900[nPos], Self:cGrupoReg)
        //aAdd (Self:aReg9900[nPos], '9900')  //---Regsistro 9900---//
        //aAdd (Self:aReg9900[nPos], cReg)    //---Registro que esta sendo calculado---//
        //aAdd (Self:aReg9900[nPos], nQtde)   //---Quantidade de Registros---//
    //Else
    //    Self:aReg9900[nPos][4] +=	nQtde   //---Quantidade de Registros---//
    //EndIf
//Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add9990
 
Método para geração do registro de Encerramento do Bloco 9
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
//Method Add9990(nQtde) CLASS ADRCST
//    Self:FechaBloco('9990',@Self:aReg9990,nQtde)
//Return Self:aReg9990



/*/{Protheus.doc} Add9900
 
Método para definir o grupo para saber de qual registro o 9900 pertence
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------



//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add9990
 
Método para geração do registro de Encerramento do Bloco 9
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
//Method Add9990(nQtde) CLASS ADRCST
//    Self:FechaBloco('9990',@Self:aReg9990,nQtde)
//Return Self:aReg9990

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add9999
 
Método de Encerramento do Arquivo Digital
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------



//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetReg(cReg) CLASS ADRCST
    Self:cReg := cReg
Return

Method SetNumer(aNumeracao) CLASS ADRCST
    Self:aNumeracao := aNumeracao
Return

Method SetRelac(cRelac) CLASS ADRCST
    Self:cRelac := cRelac
Return

Method SetConcFil(lConcFil) CLASS ADRCST
    Self:lConcFil := lConcFil
Return

Method GetConcFil() CLASS ADRCST
Return Self:lConcFil

Method GetGrupo() CLASS ADRCST
Return Self:cGrupoReg



//--------------------------------------------------------------------------------------------------
/*/
{Protheus.doc} AddHash

@author Ulisses P. Oliveira
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method AddHash(oHash,cChave,nPos) CLASS ADRCST
    Local cSet := "HMSet"
    &cSet.(oHash, cChave, nPos)
Return

//--------------------------------------------------------------------------------------------------
/*/
{Protheus.doc} FindHash

@author Ulisses P. Oliveira
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method FindHash(oHash, cChave) CLASS ADRCST
    Local nPosRet := 0
    Local cGet    := "HMGet"

    &cGet.(oHash,cChave,@nPosRet)
Return nPosRet

//==================================================================================================
/*/{Protheus.doc} Classe ADRCSTBLOC0

Classe para controle do bloco 0 da ADRCST

@author Ulisses P. Oliveira
@since 10/05/2019
@version 1.0
/*/
//==================================================================================================
CLASS ADRCSTBLOC0 FROM ADRCST

    Data oHashCvItm

    //---Registro 0000---//
    Data aReg0000   As Array  
    Data cCodver    As String //A02 - COD_VERSAO
    Data cMesano    As String //A03 - MES_ANO
    Data cCnpj      As String //A04 - CNPJ
    Data cIE        As String //A05 - IE
    Data cNome      As String //A06 - NOME
    Data cCodFin    As String //A07 - CD_FIN
    Data cReg_esp   As String //A08 - N_REG_ESPECIAL
    Data cCnpj_CD   As String //A09 - CNPJ_CD
    Data cIE_CD     As String //A10 - IE_CD
    Data cRev_01    As String //A11 -  reaver ou recolher o imposto nas saídas para consumidor final 
    Data cRev_02    As String//A12 - Código para reaver o imposto nas saídas interestaduais 
    Data cRev_03    as String // A13 Código para reaver o imposto nassaídas de que trata o art.119 do AnexoIX do RICMS/17 
    Data cRev_04    as String // A14 Código para reaver o imposto nas saídas destinadas ao Simples Nacional 

    //---Registro 1000---//
    Data aReg1000   As Array
    Data oHash1000
    Data cInc_FECOP As String //B02 - IND_FECOP
    Data cCodBarra  As String //B04 - COD_BARRAS
    Data cCodANP    As String //B05 - COD_ANP
    Data cCodNCM    As String //B06 - NCM
    Data cCest      As String //B07 - CEST
    Data cDescItem  As String //B08 - DESCR_ITEM   
    Data nAliqICM   As Numeric//B10 - ALIQ_ICMS_ITEM
    Data nAliqFECOP As Numeric//B11 - ALIQ_FECOP
    
    //---Registro 1010---//
    Data aReg1010   As Array  
    Data nQtde      As Mumeric//C04 - QTD
    Data nVtotItem  As Numeric//C05 - VL_TOT_ITEM
    Data cCompl     As String //C06 - TXT_COMPL

    //---Registro 1100---//
    Data aReg1100   As Array  
    Data nMVlUnit   As Numeric//D03 - MENOR_VL_UNIT_ITEM
    Data nICMSUNME  As Numeric//D04 - VL_BC_ICMSST_UNIT_MED
    Data nTICMSENT  As Numeric//D05 - VL_TOT_ICMS_SUPORT_ENTR
    Data nMICMSENT  As Numeric//D06 - VL_UNIT_MED_ICMS_SUPORT_ENTR

    //---Registro 1110---//
    Data aReg1110   As Array
    Data cRespRet   As String //E03 - COD_RESP_RET	
    Data nQtdEnt    As Numeric//E14 - QTD_ENTRADA
    
    //---Registro 1115---//
    Data aReg1115   As Array
    Data cTipDoc    As String //E02a - TP_GUIA
    Data cNmGuia    As String //E03a - NUM_IDENT
    Data cDtGuia    As String //E04a - DT_DOC	
    Data cDtPgto    As String //E05a - DT_PAG
    Data cCdArec    As String //E06a - COD_ARRECAD
    Data nVlRec     As Numeric//E07a - VL_RECOL

    //---Registro 1120---//
    Data aReg1120   As Array

    //---Registro 1200---//
    Data aReg1200   As Array  
    Data nResCompl  As Numeric//F06 - RESULT_COMPLEMENTAR
    Data nApICMSCp  As Numeric//F08 - APUR_ICMSST_COMPLEMENTAR
    Data nApFECPCp  As Numeric//F10 - APUR_FECOP_COMPLEMENTAR

    //---Registro 1210---//
    Data aReg1210   As Array

    //---Registro 1220---//
    Data aReg1220   As Array

    //---Registro 1300---//
    Data aReg1300   As Array  

    //---Registro 1310---//
    Data aReg1310   As Array

    //---Registro 1320---//
    Data aReg1320   As Array

    //---Registro 1400---//
    Data aReg1400   As Array

    //---Registro 1410---//
    Data aReg1410   As Array

    //---Registro 1420---//
    Data aReg1420   As Array        

    //---Registro 1500---//
    Data aReg1500   As Array  
    Data nVICMUEn   As Numeric//L03 - VL_ICMSST_UNIT_ENTR

    //---Registro 1510---//
    Data aReg1510   As Array

    //---Registro 1520---//
    Data aReg1520   As Array
    
    //---Registro 1999---//
    Data aReg1999   As Array
    Data nQtdeLin   As Numeric //R02 - QTD_LIN  //Z02 - QTD_LIN

    //---Registro 9000---//
    Data aReg9000   As Array
    Data n1200Re    As Numeric //X02 - REG1200_ICMSST_RECUPERAR_RESSARCIR
    Data n1200Com   As Numeric //X03 - REG1200_ICMSST_COMPLEMENTAR
    Data n1300Re    As Numeric //X04 - REG1300_ICMSST_RECUPERAR_RESSARCIR
    Data n1400Re    As Numeric //X05 - REG1400_ICMSST_RECUPERAR_RESSARCIR
    Data n1500Re    As Numeric //X06 - REG1500_ICMSST_RECUPERAR_RESSARCIR
    Data n9000Re    As Numeric //X07 - REG9000_FECOP_RESSARCIR
    Data n9000Com   As Numeric //X08 - REG9000_FECOP_COMPLEMENTAR

    //---Registros Compartilhados---//
    Data cCodItem   As String //B03 - COD_ITEM            Registro 1000     //C02 - COD_ITEM             Registro 1010 
    Data cUnidInv   As String //B09 - UNID_ITEM           Registro 1000     //C03 - UNID_ITEM            Registro 1010     //E13 - UNID_ITEM     Registro 1110     //E12D - UNID_ITEM     Registro 1120    //G12 - UNID_ITEM     Registro 1210   //G12D - UNID_ITEM    Registro 1220    //I12 - UNID_ITEM    Registro 1310   //I12D - UNID_ITEM   Registro 1320   //K12 - UNID_ITEM     Registro 1410   //K12D - UNID_ITEM    Registro 1420    //M12 - UNID_ITEM     Registro 1510      //M12D - UNID_ITEM Registro 1520
    Data cDatDoc    As String //E02 - DT_DOC              Registro 1110     //E02D - DT_DOC              Registro 1120     //G02 - DT_DOC        Registro 1210     //G02D - DT_DOC        Registro 1220    //I02 - DT_DOC        Registro 1310   //I02D - DT_DOC       Registro 1320    //K02 - DT_DOC       Registro 1410   //K02D - DT_DOC      Registro 1420   //M02 - DT_DOC        Registro 1510   //M02D - DT_DOC       Regitro  1520
    Data cCsosn     As String //E04 - CST_CSOSN           Registro 1110     //E03D - CST_CSOSN           Registro 1120     //G03 - CST_CSOSN     Registro 1210     //G03D - CST_CSOSN     Registro 1120    //I03 - CST_CSOSN     Registro 1310   //I03D - CST_CSOSN    Registro 1320    //K03 - CST_CSOSN    Registro 1410   //K03D - CST_CSOSN   Registro 1420   //M03 - CST_CSOSN     Registro 1510   //M03D - CST_CSOSN    Regitro  1520
    Data cChave     As String //E05 - CHAVE               Registro 1110     //E04D - CHAVE               Registro 1120     //G04 - CHAVE         Registro 1210     //G04D - CHAVE         Registro 1120    //I04 - CHAVE         Registro 1310   //I04D - CHAVE        Registro 1320    //K04 - CHAVE        Registro 1410   //K04D - CHAVE       Registro 1420   //M04 - CHAVE         Registro 1510   //M04D - CHAVE        Regitro  1520
    Data cNFiscal   As String //E06 - N_NF                Registro 1110     //E05D - N_NF                Registro 1120     //G05 - N_NF          Registro 1210     //G05D - N_NF          Registro 1120    //I05 - N_NF          Registro 1310   //I05D - N_NF         Registro 1320    //K05 - N_NF         Registro 1410   //K05D - N_NF        Registro 1420   //M05 - N_NF          Registro 1510   //M05D - N_NF         Regitro  1520
    Data cCnpjEmit  As String //E07 - CNPJ_EMIT           Registro 1110     //E06D - CNPJ_EMIT           Registro 1120     //G06 - CNPJ_EMIT     Registro 1210     //G06D - CNPJ_EMIT     Registro 1120    //I06 - CNPJ_EMIT     Registro 1310   //I06D - CNPJ_EMIT    Registro 1320    //K06 - CNPJ_EMIT    Registro 1410   //K06D - CNPJ_EMIT   Registro 1420   //M06 - CNPJ_EMIT     Registro 1510   //M06D -  CNPJ_EMIT   Regitro  1520
    Data cUFemit    As String //E08 - UF_EMIT             Registro 1110     //E07D - UF_EMIT             Registro 1120     //G07 - UF_EMIT       Registro 1210     //G07D - UF_EMIT       Registro 1120    //I07 - UF_EMIT       Registro 1310   //I07D - UF_EMIT      Registro 1320    //K07 - UF_EMIT      Registro 1410   //K07D - UF_EMIT     Registro 1420   //M07 - UF_EMIT      Registro 1510   //M07D - UF_EMIT      Regitro  1520
    Data cCnpjDest  As String //E09 - CNPJ_DEST           Registro 1110     //E08D - CNPJ_DEST           Registro 1120     //G08 - CNPJ_CPF_DEST Registro 1210     //G08D - CNPJ_CPF_DEST Registro 1120    //I08 - CNPJ_CPF_DEST Registro 1310   //I08D - CNPJ_DEST    Registro 1320    //K08 - CNPJ_DEST    Registro 1410   //K08D - CNPJ_DEST   Registro 1420   //M08 - CNPJ_DEST    Registro 1510   //M08D - CNPJ_DEST    Regitro  1520
    Data cUFdest    As String //E10 - UF_DEST             Registro 1110     //E09D - UF_DEST             Registro 1120     //G09 - UF_DEST       Registro 1210     //G09D - UF_DEST       Registro 1120    //I09 - UF_DEST       Registro 1310   //I09D - UF_DEST      Registro 1320    //K09 - UF_DEST      Registro 1410   //K09D - UF_DEST     Registro 1420   //M09 - UF_DEST      Registro 1510   //M09D - UF_DEST      Regitro  1520
    Data cCfop      As String //E11 - CFOP                Registro 1110     //E10D - CFOP                Registro 1120     //G10 - CFOP          Registro 1210     //G10D - CFOP          Registro 1120    //I10 - CFOP          Registro 1310   //I10D - CFOP         Registro 1320    //K10 - CFOP         Registro 1410   //K10D - CFOP        Registro 1420   //M10 - CFOP         Registro 1510   //M10D - CFOP         Regitro  1520
    Data cItem      As String //E12 - N_ITEM              Registro 1110     //E11D - N_ITEM              Registro 1120     //G11 - N_ITEM        Registro 1210     //G11D - N_ITEM        Registro 1120    //I11 - N_ITEM        Registro 1310   //I11D - N_ITEM       Registro 1320    //K11 - N_ITEM       Registro 1410   //K11D - N_ITEM      Registro 1420   //M11 - N_ITEM       Registro 1510   //M11D - N_ITEM       Regitro  1520
    Data nVunIem    As Numeric//E15 - VL_UNIT_ITEM        Registro 1110     //E14D - VL_UNIT_ITEM        Registro 1120     //G14 - VL_UNIT_ITEM  Registro 1210     //G14D - VL_UNIT_ITEM  Registro 1220    //I14 - VL_UNIT_ITEM  Registro 1310   //I14D - VL_UNIT_ITEM Registro 1320    //K14 - VL_UNIT_ITEM Registro 1410   //K14D - VL_UNIT_ITEM Registro 1420  //M14 - VL_UNIT_ITEM Registro 1510   //M14D - VL_UNIT_ITEM Registro 1520
    Data nVBIcmSt   As Numeric//E16 - VL_BC_ICMS_ST       Registro 1110     //E15D - VL_BC_ICMS_ST       Registro 1120
    Data nVIcmSEnt  As Numeric//E17 - VL_ICMS_SUPORT_ENTR Registro 1110     //E16D - VL_ICMS_SUPORT_ENTR Registro 1120
    Data nQtdDevol  As Numeric//E13D - QTD_DEVOLVIDA      Registro 1120     //G13D - QTD_DEVOLVIDA       Registro 1220     //I13D - QTD_DEVOLVIDA Registro 1320    //K13D - QTD_DEVOLVIDA Registro 1420    //M13D - QTD_DEVOLVIDA Registro 1520
    Data cChavRef   As String //E17D - CHAVE_REF          Registro 1120     //G16D - CHAVE_REF           Registro 1220     //I16D - CHAVE_REF     Registro 1320    //K16D - CHAVE_REF     Registro 1420    //M15D - CHAVE_REF     Registro 1520 
    Data cNIteRef   As String //E18D - N_ITEM_REF         Registro 1120     //G17D - N_ITEM_REF          Registro 1220     //I17D - N_ITEM_REF    Registro 1320    //K17D - N_ITEM_REF    Registro 1420    //M16D - N_ITEM_REF    Registro 1520
    Data nQtdTEnt   As Numeric//B12 - QTD_TOT_ENTRADA     Registro 1000     //D02 - QTD_TOT_ENTRADA      Registro 1100
    Data nQtdSai    As Numeric//G13 - QTD_SAIDA           Registro 1210     //I13 - QTD_SAIDA            Registro 1310     //K13 - QTD_SAIDA      Registro 1410    //M13 - QTD_SAIDA      Registro 1510
    Data nVlICMef   As Numeric//G15 - VL_ICMS_EFET        Registro 1210     //G15D - VL_ICMS_EFETIVO     Registro 1220     //I15 - VL_ICMS_EFET   Registro 1310    //I15D - VL_ICMS_EFET  Registro 1320    //K15 - VL_ICMS_EFET   Registro 1410   //K15D - VL_ICMS_EFET   Registro 1420
    Data nQtdTSai   As Numeric//B13 - QTD_TOT_SAIDA       Registro 1000     //F02 - QTD_TOT_SAIDA        Registro 1200     //H02 - QTD_TOT_SAIDA  Registro 1300    //J02 - QTD_TOT_SAIDA  Registro 1400    //L02 - QTD_TOT_SAIDA  Registro 1500
    Data nVTICMEf   As Numeric//F03 - VL_TOT_ICMS_EFETIVO Registro 1200     //H03 - VL_TOT_ICMS_EFETIVO  Registro 1300     //J03 - VL_TOT_ICMS_EFETIVO  Registro 1400
    Data nVCICMEn   As Numeric//F04 - VL_CONFRONTO_ICMS_ENTRADA        Registro 1200     //H04 - VL_CONFRONTO_ICMS_ENTRADA        Registro 1300    //J04 - VL_CONFRONTO_ICMS_ENTRADA  Registro 1400
    Data nReRec     As Numeric//F05 - RESULT_RECUPERAR_RESSARCIR       Registro 1200     //H05 - RESULT_RECUPERAR_RESSARCIR       Registro 1300
    Data nApICMRe   As Numeric//F07 - APUR_ICMSST_RECUPERAR_RESSARCIR  Registro 1200     //H06 - APUR_ICMSST_RECUPERAR_RESSARCIR  Registro 1300    //J05 - APUR_ICMSST_RECUPERAR_RESSARCIR  Registro 1400  //L04 - APUR_ICMSST_RECUPERAR_RESSARCIR  Registro 1500
    Data nApFECPRs  As Numeric//F09 - APUR_FECOP_RESSARCIR             Registro 1200     //H07 - APUR_FECOP_RESSARCIR             Registro 1300
    Data nPercMVa   As  Numeric//H05 Aliq MVA
    //---Registro 9999---//
    Data aReg9999   As Array
    
    Method New()
    Method Clear()
    Method FillCvItem()
    Method DoCvItem(cItem)

     //---Registro 0000---//
    Method Add0000(cIndMovto)
    Method Get0000()
    Method Alt0000(cCampo,cNewVal)
    Method SetCodVer(cCodVer)
    Method SetMesano(cMesano)
    Method SetCnpj(cCnpj)
    Method SetIE(cIE)
    Method SetNome(cNome)
    Method SetCodFin(cCodFin)
    Method SetReg_esp(cReg_esp)
    Method SetCnpj_CD(cCnpj_CD)
    Method SetIE_CD(cIE_CD)
    Method SetcRev_01(cRev_01)
    Method SetcRev_02(cRev_02)
    Method SetcRev_03(cRev_03)
    Method SetcRev_04(cRev_04)

    //---Registro 1000---//
    Method Add1000()
    Method Get1000(cProduto)
    Method SetInc_FEC(cInc_FECOP)  
    Method SetCodBarr(cCodBarra)
    Method SetCodANP(cCodANP)
    Method SetCodNCM(cCodNCM)
    Method SetCest(cCest)
    Method SetDesItem(cDescItem)
    Method SetAliqICM(cAliqICM)
    Method SetAliqFEC(nAliqFECOP)
    
    //---Registro 1010---//
    Method Add1010()
    Method Get1010()
    Method SetQtde(nQtde)
    Method SetVtotIt(nVtotItem)
    Method SetCompl(cCompl)

    //---Registro 1100---//
    Method Add1100()
    Method Get1100()
    Method SetMVlUnit(nMVlUnit)
    Method SetICMSUNM(nICMSUNME)
    Method SetTICMSEN(nTICMSENT)
    Method SetMICMSEN(nMICMSENT)

    //---Registro 1110---//
    Method Add1110()
    Method Get1110()
    Method SetRespRet(cRespRet)
    Method SetQtdEnt(nQtdEnt)

    //---Registro 1115---//
    Method Add1115()
    Method Get1115()
    Method SetTipDoc(cTipDoc)
    Method SetNmGuia(cNmGuia)
    Method SetDtGuia(cDtGuia)
    Method SetDtPgto(cDtPgto)
    Method SetCdArec(cCdArec)
    Method SetVlRec(nVlRec)

    //---Registro 1120---//
    Method Add1120()
    Method Get1120()

    //---Registro 1200---//
    Method Add1200()
    Method Get1200()
    Method SetResComp(nResCompl)
    Method SetApICMSC(nApICMSCp)
    Method SetApFECPC(nApFECPCp)

    //---Registro 1210---//
    Method Add1210()
    Method Get1210()

    //---Registro 1220---//
    Method Add1220()
    Method Get1220()

    //---Registro 1300---//
    Method Add1300()
    Method Get1300()

    //---Registro 1310---//
    Method Add1310()
    Method Get1310()

    //---Registro 1320---//
    Method Add1320()
    Method Get1320()

    //---Registro 1400---//
    Method Add1400()
    Method Get1400()

    //---Registro 1410---//
    Method Add1410()
    Method Get1410()

    //---Registro 1420---//
    Method Add1420()
    Method Get1420()

    //---Registro 1500---//
    Method Add1500()
    Method Get1500()
    Method SetVICMUEn(nVICMUEn)

    //---Registro 1510---//
    Method Add1510()
    Method Get1510()

    //---Registro 1520---//
    Method Add1520()
    Method Get1520()
    
    //---Registro 1999---//
    Method Add1999()
    Method Get1999()
    Method SetQtdeLin(nQtdeLin)

    //---Registro 9000---//
    Method Add9000()
    Method Get9000()
    Method Set1200Re(n1200Re)
    Method Set1200Com(n1200Com)
    Method Set1300Re(n1300Re)
    Method Set1400Re(n1400Re)
    Method Set1500Re(n1500Re)
    Method Set9000Re(n9000Re)
    Method Set9000Com(n9000Com)

    //---Registro 9999---//
    Method Add9999()
    Method Get9999()    

    ////---Registros Compartilhados---//
    Method SetCodItem(cCodItem)
    Method SetUnidInv(cUnidInv)
    Method SetDatDoc(cDatDoc)
    Method SetCsosn(cCsosn)
    Method SetChave(cChave)
    Method SetNFiscal(cNFiscal)
    Method SetCnpjEm(cCnpjEmit)
    Method SetUFemit(cUFemit)
    Method SetCnpjDes(cCnpjDest)
    Method SetUFdest(cUFdest)
    Method SetCfop(cCfop)
    Method SetItem(cItem)
    Method SetVunIem(nVunIem)
    Method SetVBIcmSt(nVBIcmSt)
    Method SetVIcmSEn(nVIcmSEnt)
    Method SetQtdDev(nQtdDevol)
    Method SetChavRef(cChavRef)
    Method SetNIteRef(cNIteRef)
    Method SetQtdTEnt(nQtdTEnt)
    Method SetQtdSai(nQtdSai)
    Method SetVlICMef(nVlICMef)
    Method SetQtdTSai(nQtdTSai)
    Method SetVTICMEf(nVTICMEf)
    Method SetVCICMEn(nVCICMEn)
    Method SetReRec(nReRec)
    Method SetApICMRe(nApICMRe)
    Method SetApMVA(nPercMVa)
    Method SetApFECPR(nApFECPRs)
    
ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
 
Construtor da classe
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New()  CLASS ADRCSTBLOC0
    Self:Clear()
    Self:FillCvItem()
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear
 
Método responsável por inicializar/limpar os atributos da classe.
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear()  CLASS ADRCSTBLOC0

Local cNew      := "HMNew()"

Self:lConcFil   := SuperGetMv('MV_COFLSPD', .F., .T.)
Self:lBuild     := GetBuild() >= "7.00.131227A"

If Self:lBuild
    Self:oHashCvItm := &cNew
EndIf

//---Registro 0000---//
Self:aReg0000   := {}
Self:cCodVer    := ''
Self:cMesano    := ''
Self:cCnpj      := ''
Self:cIE        := ''
Self:cNome      := ''
Self:cCodFin    := ''
Self:cReg_esp   := ''
Self:cCnpj_CD   := ''
Self:cIE_CD     := ''
Self:cRev_01     := ''
Self:cRev_02     := ''
Self:cRev_03     := ''
Self:cRev_04     := ''

//---Registro 1000---//
Self:aReg1000   := {}
If Self:lBuild
    Self:oHash1000 := &cNew
EndIf
Self:cInc_FECOP := ''
Self:cCodBarra  := ''
Self:cCodANP    := ''
Self:cCodNCM    := ''
Self:cCest      := ''
Self:cDescItem  := ''
Self:nAliqICM   := 0
Self:nAliqFECOP := 0

//---Registro 1010---//
Self:aReg1010   := {}
Self:nQtde      := 0
Self:nVtotItem  := 0
self:cCompl     := ''

//---Registro 1100---//
Self:aReg1100   := {}  
Self:nMVlUnit   := 0
Self:nICMSUNME  := 0
Self:nTICMSENT  := 0
Self:nMICMSENT  := 0

//---Registro 1110---//
Self:aReg1110   := {}  
Self:cRespRet   := ''
Self:nQtdEnt    := 0

//---Registro 1115---//
Self:aReg1115   := {}
Self:cTipDoc   := ''  
Self:cNmGuia   := ''
Self:cDtGuia   := ''
Self:cDtPgto   := ''
Self:cCdArec   := ''
Self:nVlRec    := 0

//---Registro 1120---//
Self:aReg1120   := {}

//---Registro 1200---//
Self:aReg1200   := {}   
Self:nResCompl  := 0
Self:nApICMSCp  := 0
Self:nApFECPCp  := 0

//---Registro 1210---//
Self:aReg1210   := {}

//---Registro 1220---//
Self:aReg1220   := {}

//---Registro 1300---//
Self:aReg1300   := {}

//---Registro 1310---//
Self:aReg1310   := {}

//---Registro 1320---//
Self:aReg1320   := {}

//---Registro 1400---//
Self:aReg1400   := {}

//---Registro 1410---//
Self:aReg1410   := {}

//---Registro 1420---//
Self:aReg1420   := {}

//---Registro 1500---//
Self:aReg1500   := {}
Self:nVICMUEn   := 0

//---Registro 1510---//
Self:aReg1510   := {}

//---Registro 1520---//
Self:aReg1520   := {}
    
//---Registro 1999---//
Self:aReg1999   := {}
Self:nQtdeLin   := 0

//---Registro 9000---//
Self:aReg9000   := {}
Self:n1200Re    := 0
Self:n1200Com   := 0
Self:n1300Re    := 0
Self:n1400Re    := 0
Self:n1500Re    := 0
Self:n9000Re    := 0
Self:n9000Com   := 0

//---Registro 9999---//
Self:aReg9999   := {}

//---Registros Compartilhados---//
Self:cCodItem    := ''
Self:cUnidInv   := ''
Self:cDatDoc    := ''
Self:cCsosn     := ''
Self:cChave     := ''
Self:cNFiscal   := ''
Self:cCnpjEmit  := ''
Self:cUFemit    := ''
Self:cCnpjDest  := ''
Self:cUFdest    := ''
Self:cCfop      := ''
Self:cItem      := ''
Self:nVunIem    := 0
Self:nVBIcmSt   := 0
Self:nVIcmSEnt  := 0
Self:nQtdDevol  := 0
Self:cChavRef   := ''
Self:cNIteRef   := ''
Self:nQtdTEnt   := 0
Self:nQtdSai    := 0
Self:nVlICMef   := 0
Self:nQtdTSai   := 0
Self:nVTICMEf   := 0
Self:nVCICMEn   := 0
Self:nReRec     := 0
Self:nApICMRe   := 0
Self:nApFECPRs  := 0
Self:nPercMVa  := 0

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add0001
  
Método para geração do registro de Abertura do Bloco 0

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add00001
 
Método para geração do registro 0000 do Bloco 0
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add0000() CLASS ADRCSTBLOC0

    Local nPos := 0

    Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,'','0000')

    aAdd(Self:aReg0000, {})
    nPos:= Len(Self:aReg0000)
    aAdd (Self:aReg0000[nPos], Self:cGrupoReg)  //---Grupo do Registro
    aAdd (Self:aReg0000[nPos], "0000"       )   //---A01 - REG
    aAdd (Self:aReg0000[nPos], Self:cCodVer )   //---A02 - COD_VERSAO
    aAdd (Self:aReg0000[nPos], Self:cMesano )   //---A03 - MES_ANO    
    aAdd (Self:aReg0000[nPos], Self:cCnpj   )   //---A04 - CNPJ 
    aAdd (Self:aReg0000[nPos], Self:cIE     )   //---A05 - IE
    aAdd (Self:aReg0000[nPos], Self:cNome   )   //---A06 - NOME
    aAdd (Self:aReg0000[nPos], Self:cCodFin )   //---A07 - CD_FIN 
    aAdd (Self:aReg0000[nPos], Self:cReg_esp)   //---A08 - N_REG_ESPECIAL
    aAdd (Self:aReg0000[nPos], Self:cCnpj_CD)   //---A09 - CNPJ_CD
    aAdd (Self:aReg0000[nPos], Self:cIE_CD  )   //---A10 - IE_CD
    IF F1I->(FieldPos("F1I_REVOP1")) > 0 
        aAdd (Self:aReg0000[nPos], Self:cRev_01  )   //---A11 - IE_CD
        aAdd (Self:aReg0000[nPos], Self:cRev_02  )   //---A12 - IE_CD
        aAdd (Self:aReg0000[nPos], Self:cRev_03  )   //---A13 - IE_CD
        aAdd (Self:aReg0000[nPos], Self:cRev_04  )   //---A14 - IE_CD
    EndIF

    
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get0000
 
Método para retornar os registros 0000 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get0000() CLASS ADRCSTBLOC0
Return Self:aReg0000

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Alt0000
 
Método para alterar os registros 0000 do array aReg0000.
            
@author matheus.massarotto
@since 14/01/2021
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Alt0000(cCampo,cNewVal) CLASS ADRCSTBLOC0
    Local nPos := Len(Self:aReg0000)
    Local nCol := 0

    nCol:= val(Right(cCampo,2))+1
    if !empty(cNewVal) .and. nCol > 0 .and. len(Self:aReg0000[nPos])>=nCol
        Self:aReg0000[nPos][nCol]:=cNewVal
    endif

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 0000

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetCodVer(cCodVer) Class ADRCSTBLOC0
    Self:cCodVer := cCodVer
Return

Method SetMesano(cMesano) Class ADRCSTBLOC0
    Self:cMesano := cMesano
Return

Method SetCnpj(cCnpj) Class ADRCSTBLOC0
    Self:cCnpj := cCnpj
Return

Method SetIE(cIE) Class ADRCSTBLOC0
    Self:cIE := cIE
Return

Method SetNome(cNome) Class ADRCSTBLOC0
    Self:cNome := cNome
Return

Method SetCodFin(cCodFin) Class ADRCSTBLOC0
    Self:cCodFin := cCodFin
Return

Method SetReg_esp(cReg_esp) Class ADRCSTBLOC0
    Self:cReg_esp := cReg_esp
Return

Method SetCnpj_CD(cCnpj_CD) Class ADRCSTBLOC0
    Self:cCnpj_CD := cCnpj_CD
Return

Method SetIE_CD(cIE_CD) Class ADRCSTBLOC0
    Self:cIE_CD := cIE_CD
Return
Method SetcRev_01(cRev_01) Class ADRCSTBLOC0
    Self:cRev_01 := cRev_01
Return
Method SetcRev_02(cRev_02) Class ADRCSTBLOC0
    Self:cRev_02 := cRev_02
Return
Method SetcRev_03(cRev_03) Class ADRCSTBLOC0
    Self:cRev_03 := cRev_03
Return
Method SetcRev_04(cRev_04) Class ADRCSTBLOC0
    Self:cRev_04 := cRev_04
Return
//--------------------------------------------------------------------------------------------------
Method Add1000() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1000')

aAdd (Self:aReg1000, {})
nPos := Len(Self:aReg1000)
aAdd (Self:aReg1000[nPos], Self:cGrupoReg)
aAdd (Self:aReg1000[nPos], '1000')            //B01 - REG
aAdd (Self:aReg1000[nPos], Self:cInc_FECOP)   //B02 - IND_FECOP
aAdd (Self:aReg1000[nPos], Self:cCodItem)     //B03 - COD_ITEM
aAdd (Self:aReg1000[nPos], Self:cCodBarra)    //B04 - COD_BARRAS
aAdd (Self:aReg1000[nPos], Self:cCodANP)      //B05 - COD_ANP
aAdd (Self:aReg1000[nPos], Self:cCodNCM)      //B06 - NCM
aAdd (Self:aReg1000[nPos], Self:cCest)        //B07 - CEST
aAdd (Self:aReg1000[nPos], Self:cDescItem)    //B08 - DESCR_ITEM   
aAdd (Self:aReg1000[nPos], Self:cUnidInv)     //B09 - UNID_ITEM
aAdd (Self:aReg1000[nPos], Self:nAliqICM)     //B10 - ALIQ_ICMS_ITEM
aAdd (Self:aReg1000[nPos], Self:nAliqFECOP)   //B11 - ALIQ_FECOP
aAdd (Self:aReg1000[nPos], {Self:nQtdTEnt,3}) //B12 - QTD_TOT_ENTRADA
aAdd (Self:aReg1000[nPos], {Self:nQtdTSai,3}) //B13 - QTD_TOT_SAIDA

If Self:lBuild
    Self:AddHash(Self:oHash1000, Self:cCodItem, nPos) 
EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1100
 
Método para retornar os registros 1100 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1000(cProduto) CLASS ADRCSTBLOC0
Local xRet := ""

DEFAULT cProduto := ""

If cProduto <> ""

    IF Self:lBuild
        nPos  := Self:FindHash(Self:oHash1000, cProduto + IIf(Self:lConcFil, xFilial("SB1"), ""))
    Else
        nPos := aScan(Self:aReg1000,{|aX| aX[2] == cProduto + IIf(Self:lConcFil, xFilial("SB1"), "")})
    EndIf

    xRet := nPos

Else
    xRet := Self:aReg1000
EndIf

Return xRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 1100

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetInc_FEC(cInc_FECOP) Class ADRCSTBLOC0
    Self:cInc_FECOP := cInc_FECOP
Return

Method SetCodBarr(cCodBarra) Class ADRCSTBLOC0
    Self:cCodBarra := cCodBarra
Return

Method SetCodANP(cCodANP) Class ADRCSTBLOC0
    Self:cCodANP := cCodANP
Return

Method SetCodNCM(cCodNCM) Class ADRCSTBLOC0
    Self:cCodNCM := cCodNCM
Return

Method SetCest(cCest) Class ADRCSTBLOC0
    Self:cCest := cCest
Return

Method SetDesItem(cDescItem) Class ADRCSTBLOC0
    Self:cDescItem := cDescItem
Return

Method SetAliqFEC(nAliqFECOP) Class ADRCSTBLOC0
    Self:nAliqFECOP := nAliqFECOP
Return

Method SetAliqICM(nAliqICM) Class ADRCSTBLOC0
    Self:nAliqICM := nAliqICM
Return

//--------------------------------------------------------------------------------------------------
Method Add1010() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1010')

aAdd (Self:aReg1010, {})
nPos := Len(Self:aReg1010)
aAdd (Self:aReg1010[nPos], Self:cGrupoReg)
aAdd (Self:aReg1010[nPos], '1010')          //C01 - REG
aAdd (Self:aReg1010[nPos], Self:cCodItem)   //C02 - COD_ITEM
aAdd (Self:aReg1010[nPos], Self:cUnidInv)   //C03 - UNID_ITEM
aAdd (Self:aReg1010[nPos], {Self:nQtde,3})  //C04 - QTD
aAdd (Self:aReg1010[nPos], Self:nVtotItem)  //C05 - VL_TOT_ITEM
aAdd (Self:aReg1010[nPos], Self:cCompl)     //C06 - TXT_COMPL

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 1010

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1010() CLASS ADRCSTBLOC0
Return Self:aReg1010
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1010
 
Método para retornar os registros 1010 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetQtde(nQtde) Class ADRCSTBLOC0
    Self:nQtde := nQtde
Return

Method SetVtotIt(nVtotItem) Class ADRCSTBLOC0
    Self:nVtotItem := nVtotItem
Return

Method SetCompl(cCompl) Class ADRCSTBLOC0
    Self:cCompl := cCompl
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1100
 
Método para geração do registro 1100 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1100() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1100')

aAdd (Self:aReg1100, {})
nPos := Len(Self:aReg1100)
aAdd (Self:aReg1100[nPos], Self:cGrupoReg)
aAdd (Self:aReg1100[nPos], '1100')              //D01 - REG
aAdd (Self:aReg1100[nPos], {Self:nQtdTEnt,3})   //D02 - QTD_TOT_ENTRADA
aAdd (Self:aReg1100[nPos], Self:nMVlUnit)       //D03 - MENOR_VL_UNIT_ITEM
aAdd (Self:aReg1100[nPos], Self:nICMSUNME)      //D04 - VL_BC_ICMSST_UNIT_MED
aAdd (Self:aReg1100[nPos], Self:nTICMSENT)      //D05 - VL_TOT_ICMS_SUPORT_ENTR
aAdd (Self:aReg1100[nPos], Self:nMICMSENT)      //D06 - VL_UNIT_MED_ICMS_SUPORT_ENTR

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1100
 
Método para retornar os registros 1100 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1100() CLASS ADRCSTBLOC0
Return Self:aReg1100


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 1100

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetMVlUnit(nMVlUnit) Class ADRCSTBLOC0
    Self:nMVlUnit := nMVlUnit
Return

Method SetICMSUNME(nICMSUNME) Class ADRCSTBLOC0
    Self:nICMSUNME := nICMSUNME
Return

Method SetTICMSENT(nTICMSENT) Class ADRCSTBLOC0
    Self:nTICMSENT := nTICMSENT
Return

Method SetMICMSENT(nMICMSENT) Class ADRCSTBLOC0
    Self:nMICMSENT := nMICMSENT
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1110
 
Método para geração do registro 1100 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1110() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1110')

aAdd (Self:aReg1110, {})
nPos := Len(Self:aReg1110)
aAdd (Self:aReg1110[nPos], Self:cGrupoReg)
aAdd (Self:aReg1110[nPos], '1110')          //E01 - REG
aAdd (Self:aReg1110[nPos], Self:cDatDoc)    //E02 - DT_DOC
aAdd (Self:aReg1110[nPos], Self:cRespRet)   //E03 - COD_RESP_RET
aAdd (Self:aReg1110[nPos], Self:cCsosn)     //E04 - CST_CSOSN
aAdd (Self:aReg1110[nPos], Self:cChave)     //E05 - CHAVE
aAdd (Self:aReg1110[nPos], Self:cNFiscal)   //E06 - N_NF
aAdd (Self:aReg1110[nPos], Self:cCnpjEmit)  //E07 - CNPJ_EMIT
aAdd (Self:aReg1110[nPos], Self:cUFemit)    //E08 - UF_EMIT
aAdd (Self:aReg1110[nPos], Self:cCnpjDest)  //E09 - CNPJ_DEST
aAdd (Self:aReg1110[nPos], Self:cUFdest)    //E10 - UF_DEST
aAdd (Self:aReg1110[nPos], Self:cCfop)      //E11 - CFOP
aAdd (Self:aReg1110[nPos], Self:cItem)      //E12 - N_ITEM
aAdd (Self:aReg1110[nPos], Self:cUnidInv)   //E13 - UNID_ITEM
aAdd (Self:aReg1110[nPos], {Self:nQtdEnt,3})//E14 - QTD_ENTRADA
aAdd (Self:aReg1110[nPos], Self:nVunIem)    //E15 - VL_UNIT_ITEM
aAdd (Self:aReg1110[nPos], Self:nVBIcmSt)   //E16 - VL_BC_ICMS_ST
aAdd (Self:aReg1110[nPos], Self:nVIcmSEnt)  //E17 - VL_ICMS_SUPORT_ENTR
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1110
 
Método para retornar os registros 1110 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1110() CLASS ADRCSTBLOC0
Return Self:aReg1110

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 1110

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------

Method SetRespRet(cRespRet) Class ADRCSTBLOC0
    Self:cRespRet := cRespRet
Return

Method SetQtdEnt(nQtdEnt) Class ADRCSTBLOC0
    Self:nQtdEnt := nQtdEnt
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1115
 
Método para geração do registro 1100 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1115() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1115')

aAdd (Self:aReg1115, {})
nPos := Len(Self:aReg1115)
aAdd (Self:aReg1115[nPos], Self:cGrupoReg)
aAdd (Self:aReg1115[nPos], '1115')          //E01a - REG
aAdd (Self:aReg1115[nPos], Self:cTipDoc)    //E02a - TP_GUIA
aAdd (Self:aReg1115[nPos], Self:cNmGuia)    //E03a - NUM_IDENT
aAdd (Self:aReg1115[nPos], Self:cDtGuia)    //E04a - DT_DOC
aAdd (Self:aReg1115[nPos], Self:cDtPgto)    //E05a - DT_PAG
aAdd (Self:aReg1115[nPos], Self:cCdArec)    //E06a - COD_ARRECAD
aAdd (Self:aReg1115[nPos], Self:nVlRec)     //E07a - VL_RECOL

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1115
 
Método para retornar os registros 1115 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1115() CLASS ADRCSTBLOC0
Return Self:aReg1115

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 1115

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetTipDoc(cTipDoc) Class ADRCSTBLOC0
    Self:cTipDoc := cTipDoc
Return

Method SetNmGuia(cNmGuia) Class ADRCSTBLOC0
    Self:cNmGuia := cNmGuia
Return

Method SetDtGuia(cDtGuia) Class ADRCSTBLOC0
    Self:cDtGuia := cDtGuia
Return

Method SetDtPgto(cDtPgto) Class ADRCSTBLOC0
    Self:cDtPgto := cDtPgto
Return

Method SetCdArec(cCdArec) Class ADRCSTBLOC0
    Self:cCdArec := cCdArec
Return

Method SetVlRec(nVlRec) Class ADRCSTBLOC0
    Self:nVlRec := nVlRec
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1120
 
Método para geração do registro 1120 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1120() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1120')

aAdd (Self:aReg1120, {})
nPos := Len(Self:aReg1120)
aAdd (Self:aReg1120[nPos], Self:cGrupoReg)
aAdd (Self:aReg1120[nPos], '1120')              //E01D - REG
aAdd (Self:aReg1120[nPos], Self:cDatDoc)        //E02D - DT_DOC
aAdd (Self:aReg1120[nPos], Self:cCsosn)         //E03D - CST_CSOSN
aAdd (Self:aReg1120[nPos], Self:cChave)         //E04D - CHAVE
aAdd (Self:aReg1120[nPos], Self:cNFiscal)       //E05D - N_NF
aAdd (Self:aReg1120[nPos], Self:cCnpjEmit)      //E06D - CNPJ_EMIT
aAdd (Self:aReg1120[nPos], Self:cUFemit)        //E07D - UF_EMIT
aAdd (Self:aReg1120[nPos], Self:cCnpjDest)      //E08D - CNPJ_DEST
aAdd (Self:aReg1120[nPos], Self:cUFdest)        //E09D - UF_DEST
aAdd (Self:aReg1120[nPos], Self:cCfop)          //E10D - CFOP
aAdd (Self:aReg1120[nPos], Self:cItem)          //E11D - N_ITEM
aAdd (Self:aReg1120[nPos], Self:cUnidInv)       //E12D - UNID_ITEM
aAdd (Self:aReg1120[nPos], {Self:nQtdDevol,3})  //E13D - QTD_DEVOLVIDA
aAdd (Self:aReg1120[nPos], Self:nVunIem)        //E14D - VL_UNIT_ITEM
aAdd (Self:aReg1120[nPos], Self:nVBIcmSt)       //E15D - VL_BC_ICMS_ST
aAdd (Self:aReg1120[nPos], Self:nVIcmSEnt)      //E16D - VL_ICMS_SUPORT_ENTR
aAdd (Self:aReg1120[nPos], Self:cChavRef)       //E17D - CHAVE_REF
aAdd (Self:aReg1120[nPos], Self:cNIteRef)       //E18D - N_ITEM_REF
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1120
 
Método para retornar os registros 1120 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1120() CLASS ADRCSTBLOC0
Return Self:aReg1120

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1200
 
Método para geração do registro 1200 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1200() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1200')

aAdd (Self:aReg1200, {})
nPos := Len(Self:aReg1200)
aAdd (Self:aReg1200[nPos], Self:cGrupoReg)
aAdd (Self:aReg1200[nPos], '1200')              //F01 - REG
aAdd (Self:aReg1200[nPos], {Self:nQtdTSai,3})   //F02 - QTD_TOT_SAIDA
aAdd (Self:aReg1200[nPos], Self:nVTICMEf)       //F03 - VL_TOT_ICMS_EFETIVO
aAdd (Self:aReg1200[nPos], Self:nVCICMEn)       //F04 - VL_CONFRONTO_ICMS_ENTRADA
aAdd (Self:aReg1200[nPos], Self:nReRec)         //F05 - RESULT_RECUPERAR_RESSARCIR
aAdd (Self:aReg1200[nPos], Self:nResCompl)      //F06 - RESULT_COMPLEMENTAR
aAdd (Self:aReg1200[nPos], Self:nApICMRe)       //F07 - APUR_ICMSST_RECUPERAR_RESSARCIR
aAdd (Self:aReg1200[nPos], Self:nApICMSCp)      //F08 - APUR_ICMSST_COMPLEMENTAR
aAdd (Self:aReg1200[nPos], Self:nApFECPRs)      //F09 - APUR_FECOP_RESSARCIR
aAdd (Self:aReg1200[nPos], Self:nApFECPCp)      //F10 - APUR_FECOP_COMPLEMENTAR

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1200
 
Método para retornar os registros 1200 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1200() CLASS ADRCSTBLOC0
Return Self:aReg1200


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 1200

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------

Method SetResComp(nResCompl) Class ADRCSTBLOC0
    Self:nResCompl := nResCompl
Return

Method SetApICMSC(nApICMSCp) Class ADRCSTBLOC0
    Self:nApICMSCp := nApICMSCp
Return

Method SetApFECPC(nApFECPCp) Class ADRCSTBLOC0
    Self:nApFECPCp := nApFECPCp
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1210
 
Método para geração do registro 1210 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1210() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1210')

aAdd (Self:aReg1210, {})
nPos := Len(Self:aReg1210)
aAdd (Self:aReg1210[nPos], Self:cGrupoReg)
aAdd (Self:aReg1210[nPos], '1210')          //G01 - REG
aAdd (Self:aReg1210[nPos], Self:cDatDoc)    //G02 - DT_DOC
aAdd (Self:aReg1210[nPos], Self:cCsosn)     //G03 - CST_CSOSN
aAdd (Self:aReg1210[nPos], Self:cChave)     //G04 - CHAVE
aAdd (Self:aReg1210[nPos], Self:cNFiscal)   //G05 - N_NF
aAdd (Self:aReg1210[nPos], Self:cCnpjEmit)  //G06 - CNPJ_EMIT
aAdd (Self:aReg1210[nPos], Self:cUFemit)    //G07 - UF_EMIT
aAdd (Self:aReg1210[nPos], Self:cCnpjDest)  //G08 - CNPJ_CPF_DEST
aAdd (Self:aReg1210[nPos], Self:cUFdest)    //G09 - UF_DEST
aAdd (Self:aReg1210[nPos], Self:cCfop)      //G10 - CFOP
aAdd (Self:aReg1210[nPos], Self:cItem)      //G11 - N_ITEM
aAdd (Self:aReg1210[nPos], Self:cUnidInv)   //G12 - UNID_ITEM
aAdd (Self:aReg1210[nPos], {Self:nQtdSai,3})//G13 - QTD_SAIDA
aAdd (Self:aReg1210[nPos], Self:nVunIem)    //G14 - VL_UNIT_ITEM
aAdd (Self:aReg1210[nPos], Self:nVlICMef)   //G15 - VL_ICMS_EFET
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1210
 
Método para retornar os registros 1210 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1210() CLASS ADRCSTBLOC0
Return Self:aReg1210

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1220
 
Método para geração do registro 1220 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1220() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1220')

aAdd (Self:aReg1220, {})
nPos := Len(Self:aReg1220)
aAdd (Self:aReg1220[nPos], Self:cGrupoReg)
aAdd (Self:aReg1220[nPos], '1220')             //G01D - REG
aAdd (Self:aReg1220[nPos], Self:cDatDoc)       //G02D - DT_DOC
aAdd (Self:aReg1220[nPos], Self:cCsosn)        //G03D - CST_CSOSN
aAdd (Self:aReg1220[nPos], Self:cChave)        //G04D - CHAVE
aAdd (Self:aReg1220[nPos], Self:cNFiscal)      //G05D - N_NF
aAdd (Self:aReg1220[nPos], Self:cCnpjEmit)     //G06D - CNPJ_EMIT
aAdd (Self:aReg1220[nPos], Self:cUFemit)       //G07D - UF_EMIT
aAdd (Self:aReg1220[nPos], Self:cCnpjDest)     //G08D - CNPJ_CPF_DEST
aAdd (Self:aReg1220[nPos], Self:cUFdest)       //G09D - UF_DEST
aAdd (Self:aReg1220[nPos], Self:cCfop)         //G10D - CFOP
aAdd (Self:aReg1220[nPos], Self:cItem)         //G11D - N_ITEM
aAdd (Self:aReg1220[nPos], Self:cUnidInv)      //G12D - UNID_ITEM
aAdd (Self:aReg1220[nPos], {Self:nQtdDevol,3}) //G13D - QTD_DEVOLVIDA
aAdd (Self:aReg1220[nPos], Self:nVunIem)       //G14D - VL_UNIT_ITEM
aAdd (Self:aReg1220[nPos], Self:nVlICMef)      //G15D - VL_ICMS_EFETIVO
aAdd (Self:aReg1220[nPos], Self:cChavRef)      //G16D - CHAVE_REF
aAdd (Self:aReg1220[nPos], Self:cNIteRef)      //G17D - N_ITEM_REF
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1220
 
Método para retornar os registros 1120 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1220() CLASS ADRCSTBLOC0
Return Self:aReg1220


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1300
 
Método para geração do registro 1300 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1300() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1300')

aAdd (Self:aReg1300, {})
nPos := Len(Self:aReg1300)
aAdd (Self:aReg1300[nPos], Self:cGrupoReg)
aAdd (Self:aReg1300[nPos], '1300')            //H01 - REG
aAdd (Self:aReg1300[nPos], {Self:nQtdTSai,3}) //H02 - QTD_TOT_SAIDA
aAdd (Self:aReg1300[nPos], Self:nVTICMEf)     //H03 - VL_TOT_ICMS_EFETIVO
aAdd (Self:aReg1300[nPos], Self:nVCICMEn)     //H04 - VL_CONFRONTO_ICMS_ENTRADA
aAdd (Self:aReg1300[nPos], Self:nReRec)       //H05 - RESULT_RECUPERAR_RESSARCIR
aAdd (Self:aReg1300[nPos], Self:nApICMRe)     //H06 - APUR_ICMSST_RECUPERAR_RESSARCIR
aAdd (Self:aReg1300[nPos], Self:nApFECPRs)    //H07 - APUR_FECOP_RESSARCIR

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1300
 
Método para retornar os registros 1300 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1300() CLASS ADRCSTBLOC0
Return Self:aReg1300

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1310
 
Método para geração do registro 1310 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1310() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1310')

aAdd (Self:aReg1310, {})
nPos := Len(Self:aReg1310)
aAdd (Self:aReg1310[nPos], Self:cGrupoReg)
aAdd (Self:aReg1310[nPos], '1310')          //I01 - REG
aAdd (Self:aReg1310[nPos], Self:cDatDoc)    //I02 - DT_DOC
aAdd (Self:aReg1310[nPos], Self:cCsosn)     //I03 - CST_CSOSN
aAdd (Self:aReg1310[nPos], Self:cChave)     //I04 - CHAVE
aAdd (Self:aReg1310[nPos], Self:cNFiscal)   //I05 - N_NF
aAdd (Self:aReg1310[nPos], Self:cCnpjEmit)  //I06 - CNPJ_EMIT
aAdd (Self:aReg1310[nPos], Self:cUFemit)    //I07 - UF_EMIT
aAdd (Self:aReg1310[nPos], Self:cCnpjDest)  //I08 - CNPJ_CPF_DEST
aAdd (Self:aReg1310[nPos], Self:cUFdest)    //I09 - UF_DEST
aAdd (Self:aReg1310[nPos], Self:cCfop)      //I10 - CFOP
aAdd (Self:aReg1310[nPos], Self:cItem)      //I11 - N_ITEM
aAdd (Self:aReg1310[nPos], Self:cUnidInv)   //I12 - UNID_ITEM
aAdd (Self:aReg1310[nPos], {Self:nQtdSai,3})//I13 - QTD_SAIDA
aAdd (Self:aReg1310[nPos], Self:nVunIem)    //I14 - VL_UNIT_ITEM
aAdd (Self:aReg1310[nPos], Self:nVlICMef)   //I15 - VL_ICMS_EFET
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1310
 
Método para retornar os registros 1310 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1310() CLASS ADRCSTBLOC0
Return Self:aReg1310

//--------------------------------------------------------------------------------------------------

/*/{Protheus.doc} Add1320
 
Método para geração do registro 1320 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1320() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1320')

aAdd (Self:aReg1320, {})
nPos := Len(Self:aReg1320)
aAdd (Self:aReg1320[nPos], Self:cGrupoReg)
aAdd (Self:aReg1320[nPos], '1320')            //I01D - REG
aAdd (Self:aReg1320[nPos], Self:cDatDoc)      //I02D - DT_DOC
aAdd (Self:aReg1320[nPos], Self:cCsosn)       //I03D - CST_CSOSN
aAdd (Self:aReg1320[nPos], Self:cChave)       //I04D - CHAVE
aAdd (Self:aReg1320[nPos], Self:cNFiscal)     //I05D - N_NF
aAdd (Self:aReg1320[nPos], Self:cCnpjEmit)    //I06D - CNPJ_EMIT
aAdd (Self:aReg1320[nPos], Self:cUFemit)      //I07D - UF_EMIT
aAdd (Self:aReg1320[nPos], Self:cCnpjDest)    //I08D - CNPJ_CPF_DEST
aAdd (Self:aReg1320[nPos], Self:cUFdest)      //I09D - UF_DEST
aAdd (Self:aReg1320[nPos], Self:cCfop)        //I10D - CFOP
aAdd (Self:aReg1320[nPos], Self:cItem)        //I11D - N_ITEM
aAdd (Self:aReg1320[nPos], Self:cUnidInv)     //I12D - UNID_ITEM
aAdd (Self:aReg1320[nPos], {Self:nQtdDevol,3})//I13D - QTD_DEVOLVIDA
aAdd (Self:aReg1320[nPos], Self:nVunIem)      //I14D - VL_UNIT_ITEM
aAdd (Self:aReg1320[nPos], Self:nVlICMef)     //I15D - VL_ICMS_EFET
aAdd (Self:aReg1320[nPos], Self:cChavRef)     //I16D - CHAVE_REF
aAdd (Self:aReg1320[nPos], Self:cNIteRef)     //I17D - N_ITEM_REF
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1320
 
Método para retornar os registros 1320 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1320() CLASS ADRCSTBLOC0
Return Self:aReg1320

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1400
 
Método para geração do registro 1400 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1400() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1400')

aAdd (Self:aReg1400, {})
nPos := Len(Self:aReg1400)
aAdd (Self:aReg1400[nPos], Self:cGrupoReg)
aAdd (Self:aReg1400[nPos], '1400')           //J01 - REG
aAdd (Self:aReg1400[nPos], {Self:nQtdTSai,3})//J02 - QTD_TOT_SAIDA
aAdd (Self:aReg1400[nPos], Self:nVTICMEf)    //J03 - VL_TOT_ICMS_EFETIVO
aAdd (Self:aReg1400[nPos], Self:nVCICMEn)    //J04 - VL_CONFRONTO_ICMS_ENTRADA
aAdd (Self:aReg1400[nPos], Self:nApICMRe)    //J05 - APUR_ICMSST_RECUPERAR_RESSARCIR

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1300
 
Método para retornar os registros 1400 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1400() CLASS ADRCSTBLOC0
Return Self:aReg1400

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1410
 
Método para geração do registro 1410 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1410() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1410')

aAdd (Self:aReg1410, {})
nPos := Len(Self:aReg1410)
aAdd (Self:aReg1410[nPos], Self:cGrupoReg)
aAdd (Self:aReg1410[nPos], '1410')          //K01 - REG
aAdd (Self:aReg1410[nPos], Self:cDatDoc)    //K02 - DT_DOC
aAdd (Self:aReg1410[nPos], Self:cCsosn)     //K03 - CST_CSOSN
aAdd (Self:aReg1410[nPos], Self:cChave)     //K04 - CHAVE
aAdd (Self:aReg1410[nPos], Self:cNFiscal)   //K05 - N_NF
aAdd (Self:aReg1410[nPos], Self:cCnpjEmit)  //K06 - CNPJ_EMIT
aAdd (Self:aReg1410[nPos], Self:cUFemit)    //K07 - UF_EMIT
aAdd (Self:aReg1410[nPos], Self:cCnpjDest)  //K08 - CNPJ_DEST
aAdd (Self:aReg1410[nPos], Self:cUFdest)    //K09 - UF_DEST
aAdd (Self:aReg1410[nPos], Self:cCfop)      //K10 - CFOP
aAdd (Self:aReg1410[nPos], Self:cItem)      //K11 - N_ITEM
aAdd (Self:aReg1410[nPos], Self:cUnidInv)   //K12 - UNID_ITEM
aAdd (Self:aReg1410[nPos], {Self:nQtdSai,3})//K13 - QTD_SAIDA
aAdd (Self:aReg1410[nPos], Self:nVunIem)    //K14 - VL_UNIT_ITEM
aAdd (Self:aReg1410[nPos], Self:nVlICMef)   //K15 - VL_ICMS_EFET
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1410
 
Método para retornar os registros 1410 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1410() CLASS ADRCSTBLOC0
Return Self:aReg1410

//--------------------------------------------------------------------------------------------------

/*/{Protheus.doc} Add1420
 
Método para geração do registro 1420 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1420() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1420')

aAdd (Self:aReg1420, {})
nPos := Len(Self:aReg1420)
aAdd (Self:aReg1420[nPos], Self:cGrupoReg)
aAdd (Self:aReg1420[nPos], '1420')            //K01D - REG
aAdd (Self:aReg1420[nPos], Self:cDatDoc)      //K02D - DT_DOC
aAdd (Self:aReg1420[nPos], Self:cCsosn)       //K03D - CST_CSOSN
aAdd (Self:aReg1420[nPos], Self:cChave)       //K04D - CHAVE
aAdd (Self:aReg1420[nPos], Self:cNFiscal)     //K05D - N_NF
aAdd (Self:aReg1420[nPos], Self:cCnpjEmit)    //K06D - CNPJ_EMIT
aAdd (Self:aReg1420[nPos], Self:cUFemit)      //K07D - UF_EMIT
aAdd (Self:aReg1420[nPos], Self:cCnpjDest)    //K08D - CNPJ_DEST
aAdd (Self:aReg1420[nPos], Self:cUFdest)      //K09D - UF_DEST
aAdd (Self:aReg1420[nPos], Self:cCfop)        //K10D - CFOP
aAdd (Self:aReg1420[nPos], Self:cItem)        //K11D - N_ITEM
aAdd (Self:aReg1420[nPos], Self:cUnidInv)     //K12D - UNID_ITEM
aAdd (Self:aReg1420[nPos], {Self:nQtdDevol,3})//K13D - QTD_DEVOLVIDA
aAdd (Self:aReg1420[nPos], Self:nVunIem)      //K14D - VL_UNIT_ITEM
aAdd (Self:aReg1420[nPos], Self:nVlICMef)     //K15D - VL_ICMS_EFET
aAdd (Self:aReg1420[nPos], Self:cChavRef)     //K16D - CHAVE_REF
aAdd (Self:aReg1420[nPos], Self:cNIteRef)     //K17D - N_ITEM_REF
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1420
 
Método para retornar os registros 1420 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1420() CLASS ADRCSTBLOC0
Return Self:aReg1420



//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1500
 
Método para geração do registro 1500 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1500() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1500')

aAdd (Self:aReg1500, {})
nPos := Len(Self:aReg1500)
aAdd (Self:aReg1500[nPos], Self:cGrupoReg)
aAdd (Self:aReg1500[nPos], '1500')          //L01 - REG
aAdd (Self:aReg1500[nPos], Self:nQtdTSai)   //L02 - QTD_TOT_SAIDA
aAdd (Self:aReg1500[nPos], Self:nVCICMEn)   //L03 - VL_TOT_ICMS_EFETIVO
aAdd (Self:aReg1500[nPos], Self:nApICMRe)   //L04 - APUR_ICMSST_RECUPERAR_RESSARCIR
If F1L->(FieldPos("F1L_PRCMVA")) > 0 
    aAdd (Self:aReg1500[nPos], Self:nPercMVa)  //L05 -AliqMVA
EndIF
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1500
 
Método para retornar os registros 1500 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1500() CLASS ADRCSTBLOC0
Return Self:aReg1500


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 1500

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetVICMUEn(nVICMUEn) Class ADRCSTBLOC0
    Self:nVICMUEn := nVICMUEn
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1510
 
Método para geração do registro 1510 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1510() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1510')

aAdd (Self:aReg1510, {})
nPos := Len(Self:aReg1510)
aAdd (Self:aReg1510[nPos], Self:cGrupoReg)
aAdd (Self:aReg1510[nPos], '1510')          //M01 - REG
aAdd (Self:aReg1510[nPos], Self:cDatDoc)    //M02 - DT_DOC
aAdd (Self:aReg1510[nPos], Self:cCsosn)     //M03 - CST_CSOSN
aAdd (Self:aReg1510[nPos], Self:cChave)     //M04 - CHAVE
aAdd (Self:aReg1510[nPos], Self:cNFiscal)   //M05 - N_NF
aAdd (Self:aReg1510[nPos], Self:cCnpjEmit)  //M06 - CNPJ_EMIT
aAdd (Self:aReg1510[nPos], Self:cUFemit)    //M07 - UF_EMIT
aAdd (Self:aReg1510[nPos], Self:cCnpjDest)  //M08 - CNPJ_DEST
aAdd (Self:aReg1510[nPos], Self:cUFdest)    //M09 - UF_DEST
aAdd (Self:aReg1510[nPos], Self:cCfop)      //M10 - CFOP
aAdd (Self:aReg1510[nPos], Self:cItem)      //M11 - N_ITEM
aAdd (Self:aReg1510[nPos], Self:cUnidInv)   //M12 - UNID_ITEM
aAdd (Self:aReg1510[nPos], {Self:nQtdSai,3})//M13 - QTD_SAIDA
aAdd (Self:aReg1510[nPos], Self:nVunIem)    //M14 - VL_UNIT_ITEM
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1410
 
Método para retornar os registros 1410 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1510() CLASS ADRCSTBLOC0
Return Self:aReg1510

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add1520
 
Método para geração do registro 1520 do Bloco 1
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add1520() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1520')

aAdd (Self:aReg1520, {})
nPos := Len(Self:aReg1520)
aAdd (Self:aReg1520[nPos], Self:cGrupoReg)
aAdd (Self:aReg1520[nPos], '1520')            //M01D - REG
aAdd (Self:aReg1520[nPos], Self:cDatDoc)      //M02D - DT_DOC
aAdd (Self:aReg1520[nPos], Self:cCsosn)       //M03D - CST_CSOSN
aAdd (Self:aReg1520[nPos], Self:cChave)       //M04D - CHAVE
aAdd (Self:aReg1520[nPos], Self:cNFiscal)     //M05D - N_NF
aAdd (Self:aReg1520[nPos], Self:cCnpjEmit)    //M06D - CNPJ_EMIT
aAdd (Self:aReg1520[nPos], Self:cUFemit)      //M07D - UF_EMIT
aAdd (Self:aReg1520[nPos], Self:cCnpjDest)    //M08D - CNPJ_DEST
aAdd (Self:aReg1520[nPos], Self:cUFdest)      //M09D - UF_DEST
aAdd (Self:aReg1520[nPos], Self:cCfop)        //M10D - CFOP
aAdd (Self:aReg1520[nPos], Self:cItem)        //M11D - N_ITEM
aAdd (Self:aReg1520[nPos], Self:cUnidInv)     //M12D - UNID_ITEM
aAdd (Self:aReg1520[nPos], {Self:nQtdDevol,3})//M13D - QTD_DEVOLVIDA
aAdd (Self:aReg1520[nPos], Self:nVunIem)      //M14D - VL_UNIT_ITEM
aAdd (Self:aReg1520[nPos], Self:cChavRef)     //M15D - CHAVE_REF
aAdd (Self:aReg1520[nPos], Self:cNIteRef)     //M16D - N_ITEM_REF
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get1520
 
Método para retornar os registros 1520 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get1520() CLASS ADRCSTBLOC0
Return Self:aReg1520


//--------------------------------------------------------------------------------------------------
//registros compartilhados
//--------------------------------------------------------------------------------------------------
Method SetCodItem(cCodItem) Class ADRCSTBLOC0       // registros compartilhados
    Self:cCodItem := cCodItem + IIf(Self:lConcFil, xFilial("SB1"), "")
Return

Method SetUnidInv(cUnidInv) Class ADRCSTBLOC0      //registros compartilhados
    Self:cUnidInv := cUnidInv
Return

Method SetQtdTEnt(nQtdTEnt) Class ADRCSTBLOC0     // registros compartilhados
    Self:nQtdTEnt := nQtdTEnt
Return

Method SetQtdTSai(nQtdTSai) Class ADRCSTBLOC0     //registros compartilhados
    Self:nQtdTSai := nQtdTSai
Return

Method SetDatDoc(cDatDoc) Class ADRCSTBLOC0     //registros compartilhados
    Self:cDatDoc := cDatDoc
Return

Method SetCsosn(cCsosn) Class ADRCSTBLOC0     //registros compartilhados
    Self:cCsosn := cCsosn
Return

Method SetChave(cChave) Class ADRCSTBLOC0     //registros compartilhados
    Self:cChave := cChave
Return

Method SetNFiscal(cNFiscal) Class ADRCSTBLOC0     //registros compartilhados
    Self:cNFiscal := cNFiscal
Return

Method SetCnpjEm(cCnpjEmit) Class ADRCSTBLOC0     //registros compartilhados
    Self:cCnpjEmit := cCnpjEmit
Return

Method SetUFemit(cUFemit) Class ADRCSTBLOC0     //registros compartilhados
    Self:cUFemit := cUFemit
Return

Method SetCnpjDes(cCnpjDest) Class ADRCSTBLOC0     //registros compartilhados
    Self:cCnpjDest := cCnpjDest
Return

Method SetUFdest(cUFdest) Class ADRCSTBLOC0     //registros compartilhados
    Self:cUFdest := cUFdest
Return

Method SetCfop(cCfop) Class ADRCSTBLOC0     //registros compartilhados
    Self:cCfop := cCfop
Return

Method SetItem(cItem) Class ADRCSTBLOC0     //registros compartilhados
    Self:cItem := cItem
Return

Method SetVunIem(nVunIem) Class ADRCSTBLOC0     //registros compartilhados
    Self:nVunIem := nVunIem
Return

Method SetVBIcmSt(nVBIcmSt) Class ADRCSTBLOC0     //registros compartilhados
    Self:nVBIcmSt := nVBIcmSt
Return

Method SetVIcmSEn(nVIcmSEnt) Class ADRCSTBLOC0     //registros compartilhados
    Self:nVIcmSEnt := nVIcmSEnt
Return

Method SetQtdDev(nQtdDevol) Class ADRCSTBLOC0     //registros compartilhados
    Self:nQtdDevol := nQtdDevol
Return

Method SetChavRef(cChavRef) Class ADRCSTBLOC0       //registros compartilhados
    Self:cChavRef := cChavRef
Return

Method SetVTICMEf(nVTICMEf) Class ADRCSTBLOC0       //registros compartilhados
    Self:nVTICMEf := nVTICMEf
Return

Method SetVCICMEn(nVCICMEn) Class ADRCSTBLOC0       //registros compartilhados
    Self:nVCICMEn := nVCICMEn
Return

Method SetReRec(nReRec) Class ADRCSTBLOC0           //registros compartilhados
    Self:nReRec := nReRec
Return

Method SetApICMRe(nApICMRe) Class ADRCSTBLOC0       //registros compartilhados
    Self:nApICMRe := nApICMRe
Return
Method SetApMVA(nPercMVa) Class ADRCSTBLOC0       //registros compartilhados
    Self:nPercMVa := nPercMVa
Return

Method SetApFECPR(nApFECPRs) Class ADRCSTBLOC0     //registros compartilhados
    Self:nApFECPRs := nApFECPRs
Return

Method SetQtdSai(nQtdSai) Class ADRCSTBLOC0         //registros compartilhados
    Self:nQtdSai := nQtdSai
Return

Method SetVlICMef(nVlICMef) Class ADRCSTBLOC0       //registros compartilhados
    Self:nVlICMef := nVlICMef
Return

Method SetNIteRef(cNIteRef) Class ADRCSTBLOC0       //registros compartilhados
    Self:cNIteRef := cNIteRef
Return





Method Add1999(cReg,nQtde) CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'1999')

aAdd (Self:aReg1999,{})
nPos :=	Len (Self:aReg1999)
aAdd (Self:aReg1999[nPos], Self:cGrupoReg)
aAdd (Self:aReg1999[nPos], '1999')  //---Regsistro 1999---//
aAdd (Self:aReg1999[nPos], Self:nQtdeLin)   //---Quantidade de Registros---//
Return

Method Get1999() CLASS ADRCSTBLOC0
Return Self:aReg1999

Method SetQtdeLin(nQtdeLin) Class ADRCSTBLOC0
    Self:nQtdeLin := nQtdeLin
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add9000
 
Método para geração do registro 9000
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add9000() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,Self:cRelac,'9000')

aAdd (Self:aReg9000, {})
nPos := Len(Self:aReg9000)
aAdd (Self:aReg9000[nPos], Self:cGrupoReg)
aAdd (Self:aReg9000[nPos], '9000')            //X01 - REG
aAdd (Self:aReg9000[nPos], Self:n1200Re)      //X02 - REG1200_ICMSST_RECUPERAR_RESSARCIR
aAdd (Self:aReg9000[nPos], Self:n1200Com)     //X03 - REG1200_ICMSST_COMPLEMENTAR
aAdd (Self:aReg9000[nPos], Self:n1300Re)      //X04 - REG1300_ICMSST_RECUPERAR_RESSARCIR
aAdd (Self:aReg9000[nPos], Self:n1400Re)      //X05 - REG1400_ICMSST_RECUPERAR_RESSARCIR
aAdd (Self:aReg9000[nPos], Self:n1500Re)      //X06 - REG1500_ICMSST_RECUPERAR_RESSARCIR
aAdd (Self:aReg9000[nPos], Self:n9000Re)      //X07 - REG9000_FECOP_RESSARCIR
aAdd (Self:aReg9000[nPos], Self:n9000Com)     //X08 - REG9000_FECOP_COMPLEMENTAR
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get9000
 
Método para retornar os registros 9000 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get9000() CLASS ADRCSTBLOC0
Return Self:aReg9000

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 9000

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set1200Re(n1200Re) Class ADRCSTBLOC0
    Self:n1200Re := n1200Re
Return

Method Set1200Com(n1200Com) Class ADRCSTBLOC0
    Self:n1200Com := n1200Com
Return

Method Set1300Re(n1300Re) Class ADRCSTBLOC0
    Self:n1300Re := n1300Re
Return

Method Set1400Re(n1400Re) Class ADRCSTBLOC0
    Self:n1400Re := n1400Re
Return

Method Set1500Re(n1500Re) Class ADRCSTBLOC0
    Self:n1500Re := n1500Re
Return

Method Set9000Re(n9000Re) Class ADRCSTBLOC0
    Self:n9000Re := n9000Re
Return

Method Set9000Com(n9000Com) Class ADRCSTBLOC0
    Self:n9000Com := n9000Com
Return



Method Add9999() CLASS ADRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA241SEQ(@Self:aNumeracao,'','9999')

aAdd (Self:aReg9999,{})
nPos :=	Len (Self:aReg9999)
aAdd (Self:aReg9999[nPos], Self:cGrupoReg)
aAdd (Self:aReg9999[nPos], '9999')  //---Regsistro 9999---//
aAdd (Self:aReg9999[nPos], Self:nQtdeLin)   //---Quantidade de Registros---//
Return

Method Get9999() CLASS ADRCSTBLOC0
Return Self:aReg9999


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FillCvItem
 
Método responsável por carregar um vetor ou hash de relações para conversão do item caso esteja gravado
no formato 9A, 9B, 9C, etc.

@author Ulisses P. Oliveira
@since 31/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method FillCvItem() CLASS ADRCSTBLOC0
Local cItemDoc := '99'
Local nItemDoc := 0

For nItemDoc := 100 To 999
    cItemDoc := Soma1(cItemDoc)

    If Self:lBuild
        Self:AddHash(Self:oHashCvItm, cItemDoc, nItemDoc) 
    EndIf

Next nItemDoc

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DoCvItem
 
Método responsável por retornar número do item convertido para numérico.

@author Ulisses P. Oliveira
@since 31/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method DoCvItem(cItem) CLASS ADRCSTBLOC0
    Local nPos := 0

    If Self:lBuild
        nPos  := Self:FindHash(Self:oHashCvItm, cItem)
    EndIf

Return nPos
