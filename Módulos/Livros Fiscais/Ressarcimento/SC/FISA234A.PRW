#INCLUDE 'PROTHEUS.CH'/*
#INCLUDE 'FISA234A.CH'*/

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA234A
  
Definição da Estrutura de Classes para geração do arquivo da DRCST - Demonstrativo para Apuração Mensal 
do Ressarcimento, da Restituição e da Complementação do ICMS Substituição Tributária, do Estado de Santa 
Catarina.
O método de apuração é determinado pelo Decreto Nº 1818 DE 28/11/2018 e pela Portaria SEF N° 378/2018.

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------


//==================================================================================================
/*/{Protheus.doc} Classe DRCSTTMP

Classe da tabela temporária

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//==================================================================================================
CLASS DRCSTTMP
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
  
Método construtor da Classe DRCSTTMP

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() CLASS DRCSTTMP
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
Method CriaTabela() CLASS DRCSTTMP
    Local aCmp      := {}
    Local cArquivo  := "DRCST"+GetDBExtension() //---Recupera o nome fisico gerado---//
    Local cAliasTRB := "DRCST"
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
Method GrvReg(aRegistro) CLASS DRCSTTMP
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
Method GeraLinha() CLASS DRCSTTMP
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
        
        cLinha         := Self:cDelimit + AllTrim(cLinha) //---AllTrim(Left(cLinha,Len(cLinha)-1))
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
Method GravaLinha() CLASS DRCSTTMP
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
Method GravaTxt() CLASS DRCSTTMP
    Local cNomeTmp  := Self:cDiretorio+'DRCST - '+cFilAnt+'.Txt'
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
Method DelTabela() CLASS DRCSTTMP
    FWCLOSETEMP(Self:cAliasTmp)
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetAlsTmp(cAliasTmp) CLASS DRCSTTMP
    Self:cAliasTmp := cAliasTmp
Return

Method SetArqTmp(cArqTmp) CLASS DRCSTTMP
    Self:cArqTmp := cArqTmp
Return

Method SetDelimit(cDelimit)   CLASS DRCSTTMP
    Self:cDelimit := cDelimit
Return

Method SetLinTxt(cLinhaTxt) CLASS DRCSTTMP
    Self:cLinhaTxt := cLinhaTxt
Return

Method SetGrupo(cGrupo) CLASS DRCSTTMP
    Self:cGrupo := cGrupo
Return

Method SetBloco(cReg) CLASS DRCSTTMP

Local cBloco	:= SubStr(cReg,1,1)

Do Case
	Case cBloco == '0'
		Self:cBloco	:= '01'
	Case cBloco == 'H'
		Self:cBloco	:= '02'
	Case cBloco == '2'
		Self:cBloco	:= '03'		
	Case cBloco == '9'
		Self:cBloco	:= '04'	
EndCase

Return

Method SetRegist(cRegistro) CLASS DRCSTTMP
    Self:cRegistro := cRegistro
    // Com base no registro passado determino o bloco. 
    // Este não é o bloco que vai para o arquivo, mas sim a ordem que será utilizada na ordenação dos registros.
    Self:SetBloco(cRegistro)
Return

Method SetDiretor(cDiretorio) CLASS DRCSTTMP
    Self:cDiretorio := cDiretorio
Return

Method SetNomeArq(cNomeArq) CLASS DRCSTTMP
    Self:cNomeArq := cNomeArq
Return

Method GetAlias() CLASS DRCSTTMP
Return Self:cAliasTmp


//==================================================================================================
/*/{Protheus.doc} Classe DRCST

Classe que controla o conteúdo dos blocos e registros do arquivo

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//==================================================================================================
CLASS DRCST
    
//---Propriedades p/ controlar o relacionamento entre os registros---//
Data cGrupoReg  As String 
Data cRelac     As String 
Data aNumeracao As Array
Data cReg       As String
Data lConcFil   As Boolean
Data lBuild     As Boolean

//---Registros de Abertura e Encerramento dos Blocos---//
Data aReg9001   As Array  
Data aReg9900   As Array  
Data aReg9990   As Array  
Data aReg9999   As Array 

Method New()
Method Clear()

Method AbreBloco(cReg,aReg,cIndMov)
Method FechaBloco(cReg,aReg,nQtde)

//---Registros de Abertura e Encerramento dos Blocos---//    
Method Add9001(cIndMovto)
Method Add9900(cReg,nQtde)
Method Add9990(nQtde)
Method Add9999(nQtde)

Method SetReg(cReg)
Method SetNumer(aNumeracao)
Method SetRelac(cRelac)
Method SetConcFil(lConcFil)
Method GetConcFil()
Method GetGrupo()

Method Get9001()
Method Get9900()
Method Get9990()
Method Get9999()

//---Metodos para manipulação das hashmaps.
Method AddHash(oHash,cChave,nPos)
Method FindHash(oHash, cChave)

ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe DRCST

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() CLASS DRCST
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
Method Clear() CLASS DRCST

    Self:cGrupoReg  := ''
    Self:cRelac     := ''
    Self:aNumeracao := {}
    Self:lConcFil   := SuperGetMv('MV_COFLSPD', .F., .T.)
    Self:lBuild     := GetBuild() >= "7.00.131227A"

    //---Registros de Abertura e Encerramento dos Blocos---//
    Self:aReg9001   := {}
    Self:aReg9900   := {}
    Self:aReg9990   := {}
    Self:aReg9999   := {}
    
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AbreBloco
  
Método que faz a abertura de Blocos

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method AbreBloco(cReg,aReg,cIndMov) CLASS DRCST
    Local nPos := 0

    Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,'', cReg)
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
Method FechaBloco(cReg,aReg,nQtde) CLASS DRCST
    Local nPos := 0
    
    Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,'', cReg)
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
Method Add9001(cIndMovto) CLASS DRCST
    Self:AbreBloco('9001',@Self:aReg9001,cIndMovto)
Return Self:aReg9001


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add9900
 
Método para definir o grupo para saber de qual registro o 9900 pertence
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add9900(cReg,nQtde) CLASS DRCST
    Local nPos	:= 0

    nPos := aScan (Self:aReg9900, {|aX| aX[3]==cReg})
    If nPos == 0
        Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,'','9900')
        aAdd(Self:aReg9900,{})
        nPos :=	Len (Self:aReg9900)
        aAdd (Self:aReg9900[nPos], Self:cGrupoReg)
        aAdd (Self:aReg9900[nPos], '9900')  //---Regsistro 9900---//
        aAdd (Self:aReg9900[nPos], cReg)    //---Registro que esta sendo calculado---//
        aAdd (Self:aReg9900[nPos], nQtde)   //---Quantidade de Registros---//
    Else
        Self:aReg9900[nPos][4] +=	nQtde   //---Quantidade de Registros---//
    EndIf
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add9990
 
Método para geração do registro de Encerramento do Bloco 9
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add9990(nQtde) CLASS DRCST
    Self:FechaBloco('9990',@Self:aReg9990,nQtde)
Return Self:aReg9990


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add9999
 
Método de Encerramento do Arquivo Digital
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add9999(nQtde) CLASS DRCST
    Self:FechaBloco('9999',@Self:aReg9999,nQtde)
Return Self:aReg9999


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetReg(cReg) CLASS DRCST
    Self:cReg := cReg
Return

Method SetNumer(aNumeracao) CLASS DRCST
    Self:aNumeracao := aNumeracao
Return

Method SetRelac(cRelac) CLASS DRCST
    Self:cRelac := cRelac
Return

Method SetConcFil(lConcFil) CLASS DRCST
    Self:lConcFil := lConcFil
Return

Method GetConcFil() CLASS DRCST
Return Self:lConcFil

Method GetGrupo() CLASS DRCST
Return Self:cGrupoReg

Method Get9001() CLASS DRCST
Return Self:aReg9001

Method Get9990() CLASS DRCST
Return Self:aReg9990

Method Get9900() CLASS DRCST
Return Self:aReg9900

Method Get9999() CLASS DRCST
Return Self:aReg9999

//--------------------------------------------------------------------------------------------------
/*/
{Protheus.doc} AddHash

@author Ulisses P. Oliveira
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method AddHash(oHash,cChave,nPos) CLASS DRCST
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
Method FindHash(oHash, cChave) CLASS DRCST
    Local nPosRet := 0
    Local cGet    := "HMGet"

    &cGet.(oHash,cChave,@nPosRet)
Return nPosRet

//==================================================================================================
/*/{Protheus.doc} Classe DRCSTBLOC0

Classe para controle do bloco 0 da DRCST

@author Ulisses P. Oliveira
@since 10/05/2019
@version 1.0
/*/
//==================================================================================================
CLASS DRCSTBLOC0 FROM DRCST

    Data aReg0001   As Array  
    Data aReg0990   As Array

    //---Registro 0000---//
    Data aReg0000   As Array  
    Data cCodVer    As String //---02 - COD_VER
    Data cCodFin    As String //---03 - COD_FIN
    Data cDataIni   As String //---04 - DT_INI
    Data cDataFim   As String //---05 - DT_FIM
    Data cNome      As String //---06 - NOME
    Data cCnpj      As String //---07 - CNPJ
    Data cCpf       As String //---08 - CPF
    Data cUF        As String //---09 - UF
    Data cIE        As String //---10 - IE
    Data cCodMun    As String //---11 - COD_MUN
    Data cIM        As String //---12 - IM
    Data cSuframa   As String //---13 - SUFRAMA
    Data cIndPerf   As String //---14 - IND_PERFIL
    Data cIndAtv    As String //---15 - IND_ATIV

    //---Registro 0005---//
    Data aReg0005   As Array
    Data cFantasia  As String //02 - FANTASIA
    Data cCep       As String //03 - CEP
    Data cEndereco  As String //04 - END
    Data cNumEnd    As String //05 - NUM
    Data cComplemen As String //06 - COMPL
    Data cBairro    As String //07 - BAIRRO
    Data cFone      As String //08 - FONE
    Data cFax       As String //09 - FAX
    Data cEmail     As String //10 - EMAIL

    //---Registro 0100---//
    Data aReg0100   As Array  
    Data cCrc       As String //---04 - CRC

    //---Registro 0190---//
    Data aReg0190   As Array
    Data cDescrUM   As String //---03 - DESCR

    //---Registro 0200---//
    Data aReg0200   As Array
    Data oHash0200  
    Data cCodItem   As String //---02 - COD_ITEM
    Data cDescItem  As String //---03 - DESCR_ITEM	
    Data cCodBarra  As String //---04 - COD_BARRA
    Data cCodAntIt  As String //---05 - COD_ANT_IETM
    Data cUnidInv   As String //---06 - UNI_INV
    Data cTipoItem  As String //---07 - TIPO_ITEM
    Data cCodNCM    As String //---08 - COD_NCM
    Data cExIPI     As String //---09 - EX_IPI
    Data cCodGen    As String //---10 - COD_GEN
    Data cCodLst    As String //---11 - COD_LST
    Data cAliqICM   As String //---12 - ALIQ_ICM
    Data cCest      As String //---13 - CEST

    //---Registro 0205---//
    Data aReg0205   As Array
    Data cDescAnt   As String //---02 - DESCR_ANT_ITEM
    Data dDtIniUt   As Date   //---03 - DT_INI
    Data dDtFimUt   As Date   //---04 - DT_FIM
    Data cCodAnt    As String //---05 - COD_ANT_ITEM

    //---Registro 0206---//
    Data aReg0206   As Array
    Data cCodANP    As String //---02 - COD_COMB

    //---Registro 0220---//
    Data aReg0220   As Array
    Data cUndConv   As String  //---02 - UNID_CONV
    Data nFatConv   As Numeric //---03 - FAT_CONV

    Method New()
    Method Clear()

    Method Add0001(cIndMovto)
    Method Add0990(nQtde)
    Method Get0001()
    Method Get0990()

     //---Registro 0000---//
    Method Add0000()
    Method Get0000()
    Method SetCodVer(cCodVer)
    Method SetCodFin(cCodFin)
    Method SetDataIni(cDataIni)
    Method SetDataFim(cDataFim)
    Method SetNome(cNome)
    Method SetCnpj(cCnpj)
    Method SetCpf(cCpf)
    Method SetUF(cUF)
    Method SetIE(cIE)
    Method SetCodMun(cCodMun)
    Method SetIM(cIM)
    Method SetSuframa(cSuframa)
    Method SetIndPerf(cIndPerf)
    Method SetIndAtv(cIndAtv)

    //---Registro 0005---//
    Method Add0005()
    Method Get0005()
    Method SetFantas(cFantasia)
    Method SetCep(cCep)
    Method SetEnderec(cEndereco)
    Method SetNumEnd(cNumEnd)
    Method SetComplem(cComplemen)
    Method SetBairro(cBairro)
    Method SetFone(cFone)
    Method SetFax(cFax)
    Method SetEmail(cEmail)

    //---Registro 0100---//
    Method Add0100()
    Method Get0100()
    Method SetCrc(cCrc)

    //---Registro 0190---//
    Method Add0190()
    Method Get0190()
    Method SetDescrUM(cDescrUM)

    //---Registro 0200---//
    Method Add0200()
    Method SetCodItem(cCodItem)
    Method SetDesItem(cDescItem)
    Method SetCodBarr(cCodBarra)
    Method SetCodAnIt(cCodAntIt)
    Method SetUnidInv(cUnidInv)
    Method SetTipoItm(cTipoItem)
    Method SetCodNCM(cCodNCM)
    Method SetExIPI(cExIPI)
    Method SetCodGen(cCodGen)
    Method SetCodLst(cCodLst)
    Method SetAliqICM(cAliqICM)
    Method SetCest(cCest)
    Method Get0200(cProduto)

    //---Registro 0205---//
    Method Add0205()
    Method Get0205()
    Method SetDescAnt(cDescAnt)
    Method SetDtIniUt(dDtIniUt)
    Method SetDtFimUt(dDtFimUt)
    Method SetCodAnt(cCodAnt)

    //---Registro 0206---//
    Method Add0206()
    Method Get0206()
    Method SetCodANP(cCodANP)

    //---Registro 0220---//
    Method Add0220()
    Method Get0220()
    Method SetUndConv(cUndConv)
    Method SetFatConv(nFatConv)
    
ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
 
Construtor da classe
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New()  CLASS DRCSTBLOC0
    Self:Clear()
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear
 
Método responsável por inicializar/limpar os atributos da classe.
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear()  CLASS DRCSTBLOC0

Local cNew      := "HMNew()"

Self:lConcFil   := SuperGetMv('MV_COFLSPD', .F., .T.)
Self:lBuild     := GetBuild() >= "7.00.131227A"

Self:aReg0001   := {}
Self:aReg0990   := {}

//---Registro 0000---//
Self:aReg0000   := {}
Self:cCodVer    := ''
Self:cCodFin    := ''
Self:cDataIni   := ''
Self:cDataFim   := ''
Self:cNome      := ''
Self:cCnpj      := ''
Self:cCpf       := ''
Self:cUF        := ''
Self:cIE        := ''
Self:cCodMun    := ''
Self:cIM        := ''
Self:cSuframa   := ''
Self:cIndPerf   := ''
Self:cIndAtv    := ''

//---Registro 0005---//
Self:aReg0005   := {}
Self:cFantasia  := ''
Self:cCep       := ''
Self:cEndereco  := ''
Self:cNumEnd    := ''
Self:cComplemen := ''
Self:cBairro    := ''
Self:cFone      := ''
Self:cFax       := ''
Self:cEmail     := ''

//---Registro 0100---//
Self:aReg0100   := {}
Self:cCrc       := ''

//---Registro 0190---//
Self:aReg0190   := {}
Self:cDescrUM   := ""

//---Registro 0200---//
Self:aReg0200   := {}

If Self:lBuild
    Self:oHash0200 := &cNew
EndIf

Self:cCodItem   := ''
Self:cDescItem  := ''
Self:cCodBarra  := ''
Self:cCodAntIt  := ''
Self:cUnidInv   := ''
Self:cTipoItem  := ''
Self:cCodNCM    := ''
Self:cExIPI     := ''
Self:cCodGen    := ''
Self:cCodLst    := ''
Self:cAliqICM   := ''
Self:cCest      := ''

//---Registro 0205---//
Self:aReg0205   := {}
Self:cDescAnt   := ""
Self:dDtIniUt   := cToD("//")
Self:dDtFimUt   := cToD("//")
Self:cCodAnt    := ""

//---Registro 0206---//
Self:aReg0206   := {}
Self:cCodANP    := ""

//---Registro 0220---//
Self:aReg0220  := {}
Self:cUndConv  := ""
Self:nFatConv  := 0

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add0001
  
Método para geração do registro de Abertura do Bloco 0

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add0001(cIndMovto) CLASS DRCSTBLOC0
    Self:AbreBloco('0001',@Self:aReg0001,cIndMovto)
Return Self:aReg0001

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add0990
  
Método para geração do registro de Encerramento do Bloco 0

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add0990(nQtde) CLASS DRCSTBLOC0
    Self:FechaBloco('0990',@Self:aReg0990, nQtde)
Return Self:aReg0990

Method Get0001() CLASS DRCSTBLOC0
Return Self:aReg0001

Method Get0990() CLASS DRCSTBLOC0
Return Self:aReg0990


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add0000
 
Método para geração do registro 0000 do Bloco 0
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add0000() CLASS DRCSTBLOC0

    Local nPos := 0

    Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,'','0000')

    aAdd(Self:aReg0000, {})
    nPos:= Len(Self:aReg0000)
    aAdd (Self:aReg0000[nPos], Self:cGrupoReg)  //---Grupo do Registro
    aAdd (Self:aReg0000[nPos], "0000")          //---01 - REG
    aAdd (Self:aReg0000[nPos], Self:cCodVer )   //---02 - COD_VER
    aAdd (Self:aReg0000[nPos], Self:cCodFin )   //---03 - COD_FIN
    aAdd (Self:aReg0000[nPos], Self:cDataIni)   //---04 - DT_INI
    aAdd (Self:aReg0000[nPos], Self:cDataFim)   //---05 - DT_FIM
    aAdd (Self:aReg0000[nPos], Self:cNome   )   //---06 - NOME
    aAdd (Self:aReg0000[nPos], Self:cCnpj   )   //---07 - CNPJ
    aAdd (Self:aReg0000[nPos], Self:cCpf    )   //---08 - CPF
    aAdd (Self:aReg0000[nPos], Self:cUF     )   //---09 - UF
    aAdd (Self:aReg0000[nPos], Self:cIE     )   //---10 - IE
    aAdd (Self:aReg0000[nPos], Self:cCodMun )   //---11 - COD_MUN
    aAdd (Self:aReg0000[nPos], Self:cIM     )   //---12 - IM
    aAdd (Self:aReg0000[nPos], Self:cSuframa)   //---13 - SUFRAMA
    aAdd (Self:aReg0000[nPos], Self:cIndPerf)   //---14 - IND_PERFIL
    aAdd (Self:aReg0000[nPos], Self:cIndAtv )   //---15 - IND_ATIV

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get0000
 
Método para retornar os registros 0000 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get0000() CLASS DRCSTBLOC0
Return Self:aReg0000


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 0000

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetCodVer(cCodVer) Class DRCSTBLOC0
    Self:cCodVer := cCodVer
Return

Method SetCodFin(cCodFin) Class DRCSTBLOC0
    Self:cCodFin := cCodFin
Return

Method SetDataIni(cDataIni) Class DRCSTBLOC0
    Self:cDataIni := cDataIni
Return

Method SetDataFim(cDataFim) Class DRCSTBLOC0
    Self:cDataFim := cDataFim
Return

Method SetNome(cNome) Class DRCSTBLOC0
    Self:cNome := cNome
Return

Method SetCnpj(cCnpj) Class DRCSTBLOC0
    Self:cCnpj := cCnpj
Return

Method SetCpf(cCpf) Class DRCSTBLOC0
    Self:cCpf := cCpf
Return

Method SetUF(cUF) Class DRCSTBLOC0
    Self:cUF := cUF
Return

Method SetIE(cIE) Class DRCSTBLOC0
    Self:cIE := cIE
Return

Method SetCodMun(cCodMun) Class DRCSTBLOC0
    Self:cCodMun := cCodMun
Return

Method SetIM(cIM) Class DRCSTBLOC0
    Self:cIM := cIM
Return

Method SetSuframa(cSuframa) Class DRCSTBLOC0
    Self:cSuframa := cSuframa
Return

Method SetIndPerf(cIndPerf) Class DRCSTBLOC0
    Self:cIndPerf := cIndPerf
Return

Method SetIndAtv(cIndAtv) Class DRCSTBLOC0
    Self:cIndAtv := cIndAtv
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add0005
 
Método para geração do registro 0005 do Bloco 0
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add0005() CLASS DRCSTBLOC0

    Local nPos := 0

    Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'0005')

    aAdd (Self:aReg0005, {})
    nPos := Len(Self:aReg0005)
    aAdd (Self:aReg0005[nPos], Self:cGrupoReg)
    aAdd (Self:aReg0005[nPos], '0005')          //01 - REG
    aAdd (Self:aReg0005[nPos], Self:cFantasia)  //02 - FANTASIA
    aAdd (Self:aReg0005[nPos], Self:cCep)       //03 - CEP
    aAdd (Self:aReg0005[nPos], Self:cEndereco)  //04 - END
    aAdd (Self:aReg0005[nPos], Self:cNumEnd)    //05 - NUM
    aAdd (Self:aReg0005[nPos], Self:cComplemen) //06 - COMPL
    aAdd (Self:aReg0005[nPos], Self:cBairro)    //07 - BAIRRO
    aAdd (Self:aReg0005[nPos], Self:cFone)      //08 - FONE
    aAdd (Self:aReg0005[nPos], Self:cFax)       //09 - FAX
    aAdd (Self:aReg0005[nPos], Self:cEmail)     //10 - EMAIL

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get0005
 
Método para retornar os registros 0005 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get0005() CLASS DRCSTBLOC0
Return Self:aReg0005


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 0005

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetFantas(cFantasia) Class DRCSTBLOC0
    Self:cFantasia := cFantasia
Return

Method SetCep(cCep) Class DRCSTBLOC0
    Self:cCep := cCep
Return

Method SetEnderec(cEndereco) Class DRCSTBLOC0
    Self:cEndereco := cEndereco
Return

Method SetNumEnd(cNumEnd) Class DRCSTBLOC0
    Self:cNumEnd := cNumEnd
Return

Method SetComplem(cComplemen) Class DRCSTBLOC0
    Self:cComplemen := cComplemen
Return

Method SetBairro(cBairro) Class DRCSTBLOC0
    Self:cBairro := cBairro
Return

Method SetFone(cFone) Class DRCSTBLOC0
    Self:cFone := cFone
Return

Method SetFax(cFax) Class DRCSTBLOC0
    Self:cFax := cFax
Return

Method SetEmail(cEmail) Class DRCSTBLOC0
    Self:cEmail := cEmail
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add0100
 
Método para geração do registro 0100 do Bloco 0
            
@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add0100() CLASS DRCSTBLOC0

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'0100')

aAdd (Self:aReg0100, {})
nPos := Len(Self:aReg0100)
aAdd (Self:aReg0100[nPos], Self:cGrupoReg)
aAdd (Self:aReg0100[nPos], '0100')          //01 - REG
aAdd (Self:aReg0100[nPos], Self:cNome)      //02 - NOME
aAdd (Self:aReg0100[nPos], Self:cCpf)       //03 - CPF
aAdd (Self:aReg0100[nPos], Self:cCrc)       //04 - CRC
aAdd (Self:aReg0100[nPos], Self:cCnpj)      //05 - CNPJ
aAdd (Self:aReg0100[nPos], Self:cCep)       //06 - CEP
aAdd (Self:aReg0100[nPos], Self:cEndereco)  //07 - END
aAdd (Self:aReg0100[nPos], Self:cNumEnd)    //08 - NUM
aAdd (Self:aReg0100[nPos], Self:cComplemen) //09 - COMPL
aAdd (Self:aReg0100[nPos], Self:cBairro)    //10 - BAIRRO
aAdd (Self:aReg0100[nPos], Self:cFone)      //11 - FONE
aAdd (Self:aReg0100[nPos], Self:cFax)       //12 - FAX
aAdd (Self:aReg0100[nPos], Self:cEmail)     //13 - EMAIL
aAdd (Self:aReg0100[nPos], Self:cCodMun)    //14 - COD_MUN

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get0100
 
Método para retornar os registros 0100 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get0100() CLASS DRCSTBLOC0
Return Self:aReg0100


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 0100

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetCrc(cCrc) CLASS DRCSTBLOC0
    Self:cCrc := cCrc
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add0190
 
Método para geração do registro 0190 do Bloco 0
            
@author joap.pellegrini
@since 13/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add0190() CLASS DRCSTBLOC0

Local nPos := 0

DbSelectArea("SAH")
SAH->(DbSetOrder(1))

If (nPos := aScan(Self:aReg0190, {|x| AllTrim(x[3]) == AllTrim(Self:cUnidInv)})) == 0

    If SAH->(MsSeek(xFilial("SAH") + Self:cUnidInv))
        Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'0190')
        aAdd(Self:aReg0190, {})
        nPos := Len(Self:aReg0190)
        aAdd(Self:aReg0190[nPos], Self:cGrupoReg)
        aAdd(Self:aReg0190[nPos], '0190')          //01 - REG
        aAdd(Self:aReg0190[nPos], Self:cUnidInv)   //02 - UNID
        aAdd(Self:aReg0190[nPos], SAH->AH_DESCPO)   //03 - DESCR
    EndIF

EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get0190
 
Método para retornar os registros 0190 gerados.
            
@author joao.pellegrini
@since 13/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get0190() CLASS DRCSTBLOC0
Return Self:aReg0190

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 0190

@author Ulisses P. Oliveira
@since 06/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetDescrUM(cDescrUM) CLASS DRCSTBLOC0
    Self:cDescrUM := cDescrUM
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add0200
 
Método para geração do registro 0200 do Bloco 0
            
@author Ulisses P. Oliveira
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add0200() CLASS DRCSTBLOC0

    Local nPos := 0

    Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'0200')

    aAdd (Self:aReg0200, {})
    nPos := Len(Self:aReg0200)
    aAdd (Self:aReg0200[nPos], Self:cGrupoReg)
    aAdd (Self:aReg0200[nPos], '0200')          //01 - REG
    aAdd (Self:aReg0200[nPos], Self:cCodItem)   //02 - COD_ITEM
    aAdd (Self:aReg0200[nPos], Self:cDescItem)  //03 - DESCR_ITEM	
    aAdd (Self:aReg0200[nPos], Self:cCodBarra)  //04 - COD_BARRA
    aAdd (Self:aReg0200[nPos], Self:cCodAntIt)  //05 - COD_ANT_IETM
    aAdd (Self:aReg0200[nPos], Self:cunidInv)   //06 - UNI_INV
    aAdd (Self:aReg0200[nPos], Self:cTipoItem)  //07 - TIPO_ITEM
    aAdd (Self:aReg0200[nPos], Self:cCodNCM)    //08 - COD_NCM
    aAdd (Self:aReg0200[nPos], Self:cExIPI)     //09 - EX_IPI
    aAdd (Self:aReg0200[nPos], Self:cCodGen)    //10 - COD_GEN
    aAdd (Self:aReg0200[nPos], Self:cCodLst)    //11 - COD_LST
    aAdd (Self:aReg0200[nPos], Self:cAliqICM)   //12 - ALIQ_ICM
    aAdd (Self:aReg0200[nPos], Self:cCest)      //13 - CEST

    If Self:lBuild
        Self:AddHash(Self:oHash0200, Self:cCodItem, nPos) 
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 0200

@author Ulisses P. Oliveira
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetCodItem(cCodItem) CLASS DRCSTBLOC0
    Self:cCodItem := cCodItem + IIf(Self:lConcFil, xFilial("SB1"), "")
Return

Method SetDesItem(cDescItem) CLASS DRCSTBLOC0
    Self:cDescItem := cDescItem
Return

Method SetCodBarr(cCodBarra) CLASS DRCSTBLOC0
    Self:cCodBarra := cCodBarra
Return

Method SetCodAnIt(cCodAntIt) CLASS DRCSTBLOC0
    Self:cCodAntIt := cCodAntIt
Return

Method SetUnidInv(cUnidInv) CLASS DRCSTBLOC0
    Self:cUnidInv := cUnidInv
Return

Method SetTipoItm(cTipoItem) CLASS DRCSTBLOC0
    Self:cTipoItem := cTipoItem
Return

Method SetCodNCM(cCodNCM) CLASS DRCSTBLOC0
    Self:cCodNCM := cCodNCM
Return

Method SetExIPI(cExIPI) CLASS DRCSTBLOC0
    Self:cExIPI := cExIPI
Return

Method SetCodGen(cCodGen) CLASS DRCSTBLOC0
    Self:cCodGen := cCodGen
Return

Method SetCodLst(cCodLst) CLASS DRCSTBLOC0
    Self:cCodLst := cCodLst
Return

Method SetAliqICM(cAliqICM) CLASS DRCSTBLOC0
    Self:cAliqICM := cAliqICM
Return

Method SetCest(cCest) CLASS DRCSTBLOC0
    Self:cCest := cCest
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get0200
 
Método para retornar os registros 0200 gerados.
            
@author joao.pellegrini
@since 13/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------------------------------------- 
Method Get0200(cProduto) CLASS DRCSTBLOC0

Local xRet := ""

DEFAULT cProduto := ""

If cProduto <> ""

    IF Self:lBuild
        nPos  := Self:FindHash(Self:oHash0200, cProduto + IIf(Self:lConcFil, xFilial("SB1"), ""))
    Else
        nPos := aScan(Self:aReg0200,{|aX| aX[3] == cProduto + IIf(Self:lConcFil, xFilial("SB1"), "")})
    EndIf

    xRet := {nPos, Iif(nPos > 0, Self:aReg0200[nPos][1], '')}

Else
    xRet := Self:aReg0200
EndIf

Return xRet


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add0205
 
Método para geração do registro 0205 do Bloco 0
            
@author joao.pellegrini
@since 13/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add0205() CLASS DRCSTBLOC0

    Local nPos := 0

    Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'0205')

    aAdd(Self:aReg0205, {})
    nPos := Len(Self:aReg0205)
    aAdd(Self:aReg0205[nPos], Self:cGrupoReg)
    aAdd(Self:aReg0205[nPos], '0205')           //---01 - REG
    aAdd(Self:aReg0205[nPos], Self:cDescAnt)    //---02 - DESCR_ANT_ITEM 
    aAdd(Self:aReg0205[nPos], Self:dDtIniUt)    //---03 - DT_INI
    aAdd(Self:aReg0205[nPos], Self:dDtFimUt)    //---04 - DT_FIM
    aAdd(Self:aReg0205[nPos], Self:cCodAnt)     //---05 - COD_ANT_ITEM

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get0205
 
Método para retornar os registros 0205 gerados.
            
@author joao.pellegrini
@since 13/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get0205() CLASS DRCSTBLOC0
Return Self:aReg0205

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 0205

@author joao.pellegrini
@since 13/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetDescAnt(cDescAnt) CLASS DRCSTBLOC0
    Self:cDescAnt := cDescAnt
Return

Method SetDtIniUt(dDtIniUt) CLASS DRCSTBLOC0
    Self:dDtIniUt := dDtIniUt
Return

Method SetDtFimUt(dDtFimUt) CLASS DRCSTBLOC0
    Self:dDtFimUt := dDtFimUt
Return

Method SetCodAnt(cCodAnt) CLASS DRCSTBLOC0
    Self:cCodAnt := cCodAnt
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add0206
 
Método para geração do registro 0206 do Bloco 0
            
@author joao.pellegrini
@since 13/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add0206() CLASS DRCSTBLOC0

    Local nPos := 0    

    If (nPos := aScan(Self:aReg0206, {|x| x[2] == Self:cCodANP})) == 0

        Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'0206')
        aAdd(Self:aReg0206, {})
        nPos := Len(Self:aReg0206)
        aAdd(Self:aReg0206[nPos], Self:cGrupoReg)
        aAdd(Self:aReg0206[nPos], '0206')           //---01 - REG
        aAdd(Self:aReg0206[nPos], Self:cCodANP)     //---02 - COD_COMB

    EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get0205
 
Método para retornar os registros 0206 gerados.
            
@author joao.pellegrini
@since 13/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------    
Method Get0206() CLASS DRCSTBLOC0
Return Self:aReg0206

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 0206

@author joao.pellegrini
@since 13/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetCodANP(cCodANP) CLASS DRCSTBLOC0
    Self:cCodANP := cCodANP
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add0206
 
Método para geração do registro 0206 do Bloco 0
            
@author joao.pellegrini
@since 13/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add0220(lSegUnidPE) CLASS DRCSTBLOC0

    Local nPos := aScan(Self:aReg0220, {|x| SubStr(x[1],1,Len(Self:cRelac)) == Self:cRelac .And. x[3] == Self:cUndConv})

    If nPos == 0

        Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'0220')
        aAdd(Self:aReg0220, {})
        nPos := Len(Self:aReg0220)
        aAdd(Self:aReg0220[nPos], Self:cGrupoReg)
        aAdd(Self:aReg0220[nPos], '0220')            //---01 - REG
        aAdd(Self:aReg0220[nPos], Self:cUndConv)     //---02 - UNID_CONV
        aAdd(Self:aReg0220[nPos], {Self:nFatConv,6}) //---02 - FAT_CONV

    ElseIf lSegUnidPE
        Self:aReg0220[nPos][4] := {Self:nFatConv,6}
    EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get0205
 
Método para retornar os registros 0206 gerados.
            
@author joao.pellegrini
@since 13/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------    
Method Get0220() CLASS DRCSTBLOC0
Return Self:aReg0220

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 0206

@author joao.pellegrini
@since 13/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetUndConv(cUndConv) CLASS DRCSTBLOC0
    Self:cUndConv := cUndConv
Return

Method SetFatConv(nFatConv) CLASS DRCSTBLOC0
    Self:nFatConv := nFatConv
Return

//==================================================================================================
/*/{Protheus.doc} Classe DRCSTBLOCH

Classe para controle do bloco H da DRCST

@since 10/05/2019
@version 1.0
/*/
//==================================================================================================
CLASS DRCSTBLOCH FROM DRCST

Data aRegH001   As Array
Data aRegH990   As Array   

//---Registro H005---//
Data aRegH005   As Array   
Data dDtInv     As Date    //02 - DT_INV
Data nVlInv     As Numeric //03 - VL_INV
Data cMotInv    As String  //04 - MOT_INV

//---Registro H010---//
Data aRegH010   As Array
Data cCodItem   As String  //02 - COD_ITEM
Data cUnid      As String  //03 - UNID
Data nQtde      As Numeric //04 - QTD
Data nVlUnit    As Numeric //05 - VL_UNITt
Data nVlItem    As Numeric //06 - VL_ITEM
Data cIndProp   As String  //07 - IND_PROP
Data cCodPart   As String  //08 - COD_PART
Data cTxtCompl  As String  //09 - TXT_COMPL
Data cCodCta    As String  //10 - COD_CTA
Data nVlrItemIR As Numeric //11 - VL_ITEM_IR

Method New()
Method Clear()

Method AddH001(cIndMovto)
Method AddH990(nQtde)
Method GetH001()
Method GetH990()

//---Registro H005---//
Method AddH005()
Method GetH005()
Method SetDtInv(dDtInv)
Method SetVlInv(nVlInv)
Method SetMotInv(cMotInv)

//--RegistroH010---//
Method AddH010()
Method GetH010()
Method SetCodItem(cCodItem)
Method SetUnid(cUnid)
Method SetQtde(nQtde)
Method SetVlUnit(nVlUnit)
Method SetVlItem(nVlItem)
Method SetIndProp(cIndProp)
Method SetCodPart(cCodPart)
Method SetTxtCompl(cTxtCompl)
Method SetConta(cCodCta)
Method SetVlrItemIR(nVlrItemIR)

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
 
Construtor da classe
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() CLASS DRCSTBLOCH
    Self:Clear()
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear
 
Método responsável por inicializar/limpar os atributos da classe.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear() CLASS DRCSTBLOCH

Self:lConcFil   := SuperGetMv('MV_COFLSPD', .F., .T.)
Self:lBuild     := GetBuild() >= "7.00.131227A"

Self:aRegH001   := {}
Self:aRegH990   := {}

//---Registro H005---//
Self:aRegH005 := {}
Self:dDtInv   := cToD("//")
Self:nVlInv   := 0
Self:cMotInv  := ""

//---Registro H010---//
Self:aRegH010   := {}
Self:cCodItem   := ""
Self:cUnid      := ""
Self:nQtde      := 0
Self:nVlUnit    := 0
Self:nVlItem    := 0
Self:cIndProp   := ""
Self:cCodPart   := ""
Self:cTxtCompl  := ""
Self:cCodCta    := ""
Self:nVlrItemIR := 0

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddH001
 
Método para geração do registro de Abertura do Bloco H
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method AddH001(cIndMovto) CLASS DRCSTBLOCH
    Self:AbreBloco('H001',@Self:aRegH001,cIndMovto)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddH990
  
Método para geração do registro de Encerramento do Bloco H

@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method AddH990(nQtde) CLASS DRCSTBLOCH
    Self:FechaBloco('H990',@Self:aRegH990,nQtde)
Return

Method GetH001() CLASS DRCSTBLOCH
Return Self:aRegH001

Method GetH990() CLASS DRCSTBLOCH
Return Self:aRegH990


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddH005
 
Método para geração do registro H005 do bloco H
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method AddH005() Class DRCSTBLOCH

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'H005')

aAdd (Self:aRegH005, {})
nPos := Len(Self:aRegH005)
aAdd (Self:aRegH005[nPos], Self:cGrupoReg)
aAdd (Self:aRegH005[nPos], "H005")          //01 - REG
aAdd (Self:aRegH005[nPos], Self:dDtInv)     //02 - DT_INV
aAdd (Self:aRegH005[nPos], Self:nVlInv)     //03 - VL_INV
aAdd (Self:aRegH005[nPos], Self:cMotInv)    //04 - MOT_INV

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetH005
 
Método para retornar os registros H005 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method GetH005() Class DRCSTBLOCH
Return Self:aRegH005


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro H005

@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetDtInv(dDtInv) Class DRCSTBLOCH
    Self:dDtInv := dDtInv
Return

Method SetVlInv(nVlInv) Class DRCSTBLOCH
    Self:nVlInv := nVlInv
Return

Method SetMotInv(cMotInv) Class DRCSTBLOCH
    Self:cMotInv := cMotInv
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddH010
 
Método para geração do registro H010 do bloco H
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method AddH010() Class DRCSTBLOCH

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'H010')

aAdd (Self:aRegH010, {})
nPos := Len(Self:aRegH010)
aAdd (Self:aRegH010[nPos], Self:cGrupoReg)
aAdd (Self:aRegH010[nPos], "H010")          //01 - REG
aAdd (Self:aRegH010[nPos], Self:cCodItem)   //02 - COD_ITEM
aAdd (Self:aRegH010[nPos], Self:cUnid)      //03 - UNID
aAdd (Self:aRegH010[nPos], Self:nQtde)      //04 - QTD
aAdd (Self:aRegH010[nPos], Self:nVlUnit)    //05 - VL_UNIT
aAdd (Self:aRegH010[nPos], Self:nVlItem)    //06 - VL_ITEM
aAdd (Self:aRegH010[nPos], Self:cIndProp)   //07 - IND_PROP
aAdd (Self:aRegH010[nPos], Self:cCodPart)   //08 - COD_PART
aAdd (Self:aRegH010[nPos], Self:cTxtCompl)  //09 - TXT_COMPL
aAdd (Self:aRegH010[nPos], Self:cCodCta)    //10 - COD_CTA
aAdd (Self:aRegH010[nPos], Self:nVlrItemIR) //11 - VL_ITEM_IR

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetH010
 
Método para retornar os registros H010 gerados.
            
@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method GetH010() Class DRCSTBLOCH
Return Self:aRegH010


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro H010

@author joao.pellegrini
@since 10/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetCodItem(cCodItem) Class DRCSTBLOCH
    Self:cCodItem := cCodItem + Iif(Self:lConcFil, xFilial("SB1"), "")
Return

Method SetUnid(cUnid) Class DRCSTBLOCH
    Self:cUnid := cUnid
Return

Method SetQtde(nQtde) Class DRCSTBLOCH
    Self:nQtde := nQtde
Return

Method SetVlUnit(nVlUnit) Class DRCSTBLOCH
    Self:nVlUnit := nVlUnit
Return

Method SetVlItem(nVlItem) Class DRCSTBLOCH
    Self:nVlItem := nVlItem
Return

Method SetIndProp(cIndProp) Class DRCSTBLOCH
    Self:cIndProp := cIndProp
Return

Method SetCodPart(cCodPart) Class DRCSTBLOCH
    Self:cCodPart := cCodPart
Return

Method SetTxtCompl(cTxtCompl) Class DRCSTBLOCH
    Self:cTxtCompl := cTxtCompl
Return

Method SetConta(cCodCta) Class DRCSTBLOCH
    Self:cCodCta := cCodCta
Return

Method SetVlrItemIR(nVlrItemIR) Class DRCSTBLOCH
    Self:nVlrItemIR := nVlrItemIR
Return


//==================================================================================================
/*/{Protheus.doc} Classe DRCSTBLOC2

Classe para controle do bloco 2 da DRCST

@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//==================================================================================================
CLASS DRCSTBLOC2 FROM DRCST

Data aReg2001   As Array
Data aReg2990   As Array   
Data aRegCvItem As Array
Data oHashCvItm

//---Registro 2100---//
Data aReg2100   As Array
Data nSVlICSTRt As Numeric  //02 - S_VL_ICMS_ST_REST 
Data nSVlICSTCp As Numeric  //03 - S_VL_ICMS_ST_COMPL
Data nSdICMSTRt As Numeric  //04 - SD_ICMS_ST_REST   
Data nSdICMSTRe As Numeric  //05 - SD_ICMS_ST_RESS   
Data nSdICMSTCp As Numeric  //06 - SD_ICMS_ST_COMPL  
Data nSdICMSOp  As Numeric  //07 - SD_ICMS_OP        
Data nVlApCrICM As Numeric  //08 - V_APUR_CRED_ICMS  
Data nVlApICMCp As Numeric  //09 - V_APUR_ICMS_COMP  

//---Registro 2110---//
Data aReg2110   As Array
Data cCodItem   As String   //02 - COD_ITEM           
Data nQtdeTVCF  As Numeric  //03 - QTDE_T_V_CF        
Data nVlTVCF    As Numeric  //04 - VL_T_V_CF          
Data nVlMUniVCF As Numeric  //05 - VLM_UNIT_V_CF      
Data nVlTBSTVCF As Numeric  //06 - VL_T_BCST_V_CF     
Data nVlDMaiBST As Numeric  //07 - VL_DIF_MAIOR_BCST  
Data nVlDMenBST As Numeric  //08 - VL_DIF_MENOR_BCST  
Data nAliqEf    As Numeric  //09 - ALIQ_EF            
Data nVlICMSTRt As Numeric  //10 - VL_ICMS_ST_REST    
Data nVlICMSTCp As Numeric  //11 - VL_ICMS_ST_COMPL   
Data nQtdeTSOE  As Numeric  //12 - QTDE_T_IND_S_OE    
Data nVlICMSOE  As Numeric  //13 - VL_ICMS_IND_S_OE   
Data nVlICMSTOE As Numeric  //14 - VL_ICMS_ST_IND_S_OE
Data nQtdeTSSN  As Numeric  //15 - QTDE_T_IND_S_SN    
Data nVlTCMVASN As Numeric  //16 - VL_T_CREDITO_MVA_SN

//---Comuns: Registro 2112 / 2113 e 2130 / 2114 e 2132 / 2115 e 2133---//
Data dDataMov   As Date     //2130  4 - DT_E     / E  5 DT_NFE |2113  6 - DT_E        / S  5 DT_NFE
Data cIndOp     As String   //2130  2 - IND_OPER               |2113  2 - IND_OPER    
Data cItem      As String   //2130  7 - NUM_ITEM               |2113  9 - NUM_ITEM     
Data cCFOP      As String   //2130 14 - CFOP                   |2113 15 - CFOP         
Data cChaveDoc  As String   //2130  3 - CHV_NFE                |2113  4 - CHV_NFE     
Data cCNPJ      As String   //2130  6 - CNPJ                   |2113  7 - CNPJ        / S 8 CPF
Data nQtdMov    As Numeric  //2130  9 - QTDE                   |2113 10 - QTDE_IND_S  
Data cUnid      As String   //2130 10 - UNID                   |2113 11 - UNID        
Data nFatConv   As Numeric  //2130 11 - FAT_CONV               |2113 12 - FAT_CONV    
Data nQtdConv   As Numeric  //2130 12 - QTDE_C                 |2113 13 - QTDE_IND_S_C
Data nVlrCont   As Numeric  //2130 13 - VL_E                   
Data nVlrTotal  As Numeric  //2113 14 - VL_V_IND_S  
//---Registro 2112---//
Data aReg2112   As Array

//---Registro 2113---//
Data aReg2113   As Array
Data cIndSaida  As String   //3  - IND_S            
Data nVlrCredSN As Numeric  //16 - VL_CREDITO_MVA_SN

//---Registro 2114---//
Data aReg2114   As Array
Data cNumcCxECF As String   //05 - ECF_CX_REF
Data cNumDoc    As String   //05 - NUM_DOC_REF

//---Registro 2115---//
Data aReg2115   As Array

//---Registro 2120---//
Data aReg2120   As Array
Data nSQtdeC    As Numeric  //02 - S_QTDE_C        
Data nSBICMSTIn As Numeric  //03 - S_VL_BCST_INT   
Data nVlrMUnBST As Numeric  //04 - VLM_UNIT_BCST   
Data nSVlrICMS  As Numeric  //05 - S_VL_ICMS       
Data nVlrMUnICM As Numeric  //06 - VLM_UNIT_ICMS   
Data nSVlrICMST As Numeric  //07 - S_VL_ICMS_ST    
Data nVlrMUnIST As Numeric  //08 - VLM_UNIT_ICMS_ST

//---Registro 2121---//
Data aReg2121   As Array
Data nSQtdeCT   As Numeric  //02 - S_QTDE_C_T 
Data nSQtdeCVlM As Numeric  //03 - S_QTDE_C_VLM 
Data nSBICMSTVM As Numeric  //04 - S_VL_BCST_INT_VLM
Data nVlrMUBSTG As Numeric  //05 - VLM_UNIT_BCST_G

//---Registro 2130---//
Data aReg2130   As Array
Data nVlrBICMS  As Numeric  //15 - VL_BC_ICMS
Data nVlrAICMS  As Numeric  //16 - ALIQ_ICMS 
Data nVlrICMS   As Numeric  //17 - VL_ICMS   
Data nVlrBICMST As Numeric  //18 - VL_BCST   
Data nVlrAICMST As Numeric  //20 - ALIQ_ST_E 
Data nVlrICMSST As Numeric  //23 - VL_ICMS_ST
Data nVlrBINTST As Numeric  //19 - VL_BCST_INT
Data nVlrAEFEST As Numeric  //21 - ALIQ_ST_EF 
Data nVlrCALCST As Numeric  //22 - CAL_ICMS_ST
Data cCodAjuste As String   //26 - COD_AJ C	 
Data cCodDA     As String   //24 - COD_DA      
Data cNumDARE   As String   //25 - NUM_DARE    
Data cRespRet   As String   // 8 - COD_RESP_RET

//---Registro 2132---//
Data aReg2132   As Array

//---Registro 2133---//
Data aReg2133   As Array

//---Registro 2134---//
Data aReg2134   As Array
Data cCodIndXml As String   //02 - COD_IND_XML

Method New()
Method Clear()
Method FillCvItem()
Method DoCvItem(cItem)

Method Add2001(cIndMovto)
Method Add2990(nQtde)
Method Get2001()
Method Get2990()

//---Registro 2100---//
Method Add2100()
Method Get2100()
Method Set2100C02(nSVlICSTRt)
Method Set2100C03(nSVlICSTCp)
Method Set2100C04(nSdICMSTRt)
Method Set2100C05(nSdICMSTRe)
Method Set2100C06(nSdICMSTCp)
Method Set2100C07(nSdICMSOp)
Method Set2100C08(nVlApCrICM)
Method Set2100C09(nVlApICMCp)

//--Registro 2110---//
Method Add2110()
Method Get2110()
Method Set2110C02(cCodItem)
Method Set2110C03(nQtdeTVCF)
Method Set2110C04(nVlTVCF)
Method Set2110C05(nVlMUniVCF)
Method Set2110C06(nVlTBSTVCF)
Method Set2110C07(nVlDMaiBST)
Method Set2110C08(nVlDMenBST)
Method Set2110C09(nAliqEf)
Method Set2110C10(nVlICMSTRt)
Method Set2110C11(nVlICMSTCp)
Method Set2110C12(nQtdeTSOE)
Method Set2110C13(nVlICMSOE)
Method Set2110C14(nVlICMSTOE)
Method Set2110C15(nQtdeTSSN)
Method Set2110C16(nVlTCMVASN)

//---Comuns: Registro 2112 / 2113 e 2130 / 2114 e 2132---//
Method SetDataMov(dDataMov) 
Method SetIndOp(cIndOp)
Method SetItem(cItem)
Method SetCFOP(cCFOP)
Method SetChvDoc(cChaveDoc)
Method SetCNPJ(cCNPJ)
Method SetQtdMov(nQtdMov)
Method SetUnid(cUnid)
Method SetFatConv(nFatConv)
Method SetQtdConv(nQtdConv)
Method SetVlrCont(nVlrCont)
Method SetVlrTotal(nVlrTotal)

//---Registro 2112---//
Method Add2112()
Method Get2112()

//---Registro 2113---//
Method Add2113()
Method Get2113()
Method Set2113C03(cIndSaida)
Method Set2113C16(nVlrCredSN)

//---Registro 2114---//
Method Add2114()
Method Get2114()
Method Set2114C05(cNumcCxECF)
Method Set2114C06(cNumDoc)

//---Registro 2115---//
Method Add2115()
Method Get2115()

//---Registro 2120---//
Method Add2120()
Method Get2120()
Method Set2120C02(nSQtdeC)
Method Set2120C03(nSBICMSTIn)
Method Set2120C04(nVlrMUnBST)
Method Set2120C05(nSVlrICMS)
Method Set2120C06(nVlrMUnICM)
Method Set2120C07(nSVlrICMST)
Method Set2120C08(nVlrMUnIST)

//---Registro 2121---//
Method Add2121()
Method Get2121()
Method Set2121C02(nSQtdeCT)
Method Set2121C03(nSQtdeCVlM)
Method Set2121C04(nSBICMSTVM)
Method Set2121C05(nVlrMUBSTG)

//---Registro 2130---//
Method Add2130()
Method Get2130()
Method Set2130C15(nVlrBICMS)
Method Set2130C16(nVlrAICMS)
Method Set2130C17(nVlrICMS)
Method Set2130C18(nVlrBICMST)
Method Set2130C20(nVlrAICMST)
Method Set2130C23(nVlrICMSST)
Method Set2130C19(nVlrBINTST)
Method Set2130C21(nVlrAEFEST)
Method Set2130C22(nVlrCALCST)
Method Set2130C26(cCodAjuste)
Method Set2130C24(cCodDA)
Method Set2130C25(cNumDARE)
Method Set2130C08(cRespRet)

//---Registro 2132---//
Method Add2132()
Method Get2132()

//---Registro 2133---//
Method Add2133()
Method Get2133()

//---Registro 2134---//
Method Add2134()
Method Get2134()
Method Set2134C02(cCodIndXml)

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
 
Construtor da classe
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() CLASS DRCSTBLOC2
    Self:Clear()
    Self:FillCvItem()
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Clear
 
Método responsável por inicializar/limpar os atributos da classe.
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Clear() CLASS DRCSTBLOC2
Local cNew      := "HMNew()"

Self:lConcFil   := SuperGetMv('MV_COFLSPD', .F., .T.)
Self:lBuild     := GetBuild() >= "7.00.131227A"

Self:aReg2001   := {}
Self:aReg2990   := {}

Self:aRegCvItem := {}
If Self:lBuild
    Self:oHashCvItm := &cNew
EndIf

//---Registro 2100---//
Self:aReg2100   := {}
Self:nSVlICSTRt := 0
Self:nSVlICSTCp := 0
Self:nSdICMSTRt := 0
Self:nSdICMSTRe := 0
Self:nSdICMSTCp := 0
Self:nSdICMSOp  := 0
Self:nVlApCrICM := 0
Self:nVlApICMCp := 0

//---Registro 2110---//
Self:aReg2110   := {}
Self:cCodItem   := ''
Self:nQtdeTVCF  := 0
Self:nVlTVCF    := 0
Self:nVlMUniVCF := 0
Self:nVlTBSTVCF := 0
Self:nVlDMaiBST := 0
Self:nVlDMenBST := 0
Self:nAliqEf    := 0
Self:nVlICMSTRt := 0
Self:nVlICMSTCp := 0
Self:nQtdeTSOE  := 0
Self:nVlICMSOE  := 0
Self:nVlICMSTOE := 0
Self:nQtdeTSSN  := 0
Self:nVlTCMVASN := 0

//---Comuns: Registro 2112 / 2113 e 2130 / 2114 e 2132---//
Self:dDataMov   := CtoD('  /  /    ')
Self:cIndOp     := ''
Self:cItem      := ''
Self:cCFOP      := ''
Self:cChaveDoc  := ''
Self:cCNPJ      := ''
Self:nQtdMov    := 0
Self:cUnid      := ''
Self:nFatConv   := 0
Self:nQtdConv   := 0
Self:nVlrCont   := 0
Self:nVlrTotal  := 0

//---Registro 2112---//
Self:aReg2112   := {}

//---Registro 2113---//
Self:aReg2113   := {}
Self:cIndSaida  := ''
Self:nVlrCredSN := 0

//---Registro 2114---//
Self:aReg2114   := {}
Self:cNumcCxECF := ''
Self:cNumDoc    := ''

//---Registro 2115---//
Self:aReg2115   := {}

//---Registro 2120---//
Self:aReg2120   := {}
Self:nSQtdeC    := 0
Self:nSBICMSTIn := 0
Self:nVlrMUnBST := 0
Self:nSVlrICMS  := 0
Self:nVlrMUnICM := 0
Self:nSVlrICMST := 0
Self:nVlrMUnIST := 0

//---Registro 2121---//
Self:aReg2121   := {}
Self:nSQtdeCT   := 0
Self:nSQtdeCVlM := 0
Self:nSBICMSTVM := 0
Self:nVlrMUBSTG := 0

//---Registro 2130---//
Self:aReg2130   := {}
Self:nVlrBICMS  := 0
Self:nVlrAICMS  := 0
Self:nVlrICMS   := 0
Self:nVlrBICMST := 0
Self:nVlrAICMST := 0
Self:nVlrICMSST := 0
Self:nVlrBINTST := 0
Self:nVlrAEFEST := 0
Self:nVlrCALCST := 0
Self:cCodAjuste := ''
Self:cCodDA     := ''
Self:cNumDARE   := ''
Self:cRespRet   := ''

//---Registro 2132---//
Self:aReg2132   := {}

//---Registro 2133---//
Self:aReg2133   := {}

//---Registro 2134---//
Self:aReg2134   := {}
Self:cCodIndXml := ''

Return



//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FillCvItem
 
Método responsável por carregar um vetor ou hash de relações para conversão do item caso esteja gravado
no formato 9A, 9B, 9C, etc.

@author Ulisses P. Oliveira
@since 31/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method FillCvItem() CLASS DRCSTBLOC2
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
Method DoCvItem(cItem) CLASS DRCSTBLOC2
    Local nPos := 0

    If Self:lBuild
        nPos  := Self:FindHash(Self:oHashCvItm, cItem)
    EndIf

Return nPos


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} aReg2001
 
Método para geração do registro de Abertura do Bloco 2
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2001(cIndMovto) CLASS DRCSTBLOC2
    Self:AbreBloco('2001',@Self:aReg2001,cIndMovto)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add2990
  
Método para geração do registro de Encerramento do Bloco 2
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2990(nQtde) CLASS DRCSTBLOC2
    Self:FechaBloco('2990',@Self:aReg2990,nQtde)
Return

Method Get2001() CLASS DRCSTBLOC2
Return Self:aReg2001

Method Get2990() CLASS DRCSTBLOC2
Return Self:aReg2990


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add2100
 
Método para geração do registro 2100 do bloco 2
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2100() Class DRCSTBLOC2

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'2100')

aAdd (Self:aReg2100, {})
nPos := Len(Self:aReg2100)
aAdd (Self:aReg2100[nPos], Self:cGrupoReg)
aAdd (Self:aReg2100[nPos], "2100")           //01 - REG
aAdd (Self:aReg2100[nPos], Self:nSVlICSTRt)  //02 - S_VL_ICMS_ST_REST
aAdd (Self:aReg2100[nPos], Self:nSVlICSTCp)  //03 - S_VL_ICMS_ST_COMPL
aAdd (Self:aReg2100[nPos], Self:nSdICMSTRt)  //04 - SD_ICMS_ST_REST  
aAdd (Self:aReg2100[nPos], Self:nSdICMSTRe)  //05 - SD_ICMS_ST_RESS  
aAdd (Self:aReg2100[nPos], Self:nSdICMSTCp)  //06 - SD_ICMS_ST_COMPL 
aAdd (Self:aReg2100[nPos], Self:nSdICMSOp)   //07 - SD_ICMS_OP       
aAdd (Self:aReg2100[nPos], Self:nVlApCrICM)  //08 - V_APUR_CRED_ICMS 
aAdd (Self:aReg2100[nPos], Self:nVlApICMCp)  //09 - V_APUR_ICMS_COMP 

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get2100
 
Método para retornar os registros 2100 gerados.
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get2100() Class DRCSTBLOC2
Return Self:aReg2100


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 2100

@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set2100C02(nSVlICSTRt) Class DRCSTBLOC2
    Self:nSVlICSTRt := nSVlICSTRt
Return

Method Set2100C03(nSVlICSTCp) Class DRCSTBLOC2
    Self:nSVlICSTCp := nSVlICSTCp
Return

Method Set2100C04(nSdICMSTRt) Class DRCSTBLOC2
    Self:nSdICMSTRt := nSdICMSTRt
Return

Method Set2100C05(nSdICMSTRe) Class DRCSTBLOC2
    Self:nSdICMSTRe := nSdICMSTRe
Return

Method Set2100C06(nSdICMSTCp) Class DRCSTBLOC2
    Self:nSdICMSTCp := nSdICMSTCp
Return

Method Set2100C07(nSdICMSOp) Class DRCSTBLOC2
    Self:nSdICMSOp := nSdICMSOp
Return

Method Set2100C08(nVlApCrICM) Class DRCSTBLOC2
    Self:nVlApCrICM := nVlApCrICM
Return

Method Set2100C09(nVlApICMCp) Class DRCSTBLOC2
    Self:nVlApICMCp := nVlApICMCp
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add2110
 
Método para geração do registro 2110 do bloco 2
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2110() Class DRCSTBLOC2

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'2110')

aAdd (Self:aReg2110, {})
nPos := Len(Self:aReg2110)
aAdd (Self:aReg2110[nPos], Self:cGrupoReg)
aAdd (Self:aReg2110[nPos], "2110")               //01 - REG
aAdd (Self:aReg2110[nPos], Self:cCodItem)        //02 - COD_ITEM           
aAdd (Self:aReg2110[nPos], {Self:nQtdeTVCF,5})   //03 - QTDE_T_V_CF        
aAdd (Self:aReg2110[nPos], Self:nVlTVCF)         //04 - VL_T_V_CF          
aAdd (Self:aReg2110[nPos], {Self:nVlMUniVCF,3})  //05 - VLM_UNIT_V_CF      
aAdd (Self:aReg2110[nPos], Self:nVlTBSTVCF)      //06 - VL_T_BCST_V_CF     
aAdd (Self:aReg2110[nPos], Self:nVlDMaiBST)      //07 - VL_DIF_MAIOR_BCST  
aAdd (Self:aReg2110[nPos], Self:nVlDMenBST)      //08 - VL_DIF_MENOR_BCST  
aAdd (Self:aReg2110[nPos], Self:nAliqEf)         //09 - ALIQ_EF            
aAdd (Self:aReg2110[nPos], Self:nVlICMSTRt)      //10 - VL_ICMS_ST_REST    
aAdd (Self:aReg2110[nPos], Self:nVlICMSTCp)      //11 - VL_ICMS_ST_COMPL   
aAdd (Self:aReg2110[nPos], {Self:nQtdeTSOE,5})   //12 - QTDE_T_IND_S_OE    
aAdd (Self:aReg2110[nPos], Self:nVlICMSOE)       //13 - VL_ICMS_IND_S_OE   
aAdd (Self:aReg2110[nPos], Self:nVlICMSTOE)      //14 - VL_ICMS_ST_IND_S_OE
aAdd (Self:aReg2110[nPos], {Self:nQtdeTSSN,5})   //15 - QTDE_T_IND_S_SN    
aAdd (Self:aReg2110[nPos], Self:nVlTCMVASN)      //16 - VL_T_CREDITO_MVA_SN

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get2110
 
Método para retornar os registros 2110 gerados.
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get2110() Class DRCSTBLOC2
Return Self:aReg2110


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 2110

@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set2110C02(cCodItem) Class DRCSTBLOC2
    Self:cCodItem := cCodItem + Iif(Self:lConcFil, xFilial("SB1"), "")
Return

Method Set2110C03(nQtdeTVCF) Class DRCSTBLOC2
    Self:nQtdeTVCF := nQtdeTVCF
Return

Method Set2110C04(nVlTVCF) Class DRCSTBLOC2
    Self:nVlTVCF := nVlTVCF
Return

Method Set2110C05(nVlMUniVCF) Class DRCSTBLOC2
    Self:nVlMUniVCF := nVlMUniVCF
Return

Method Set2110C06(nVlTBSTVCF) Class DRCSTBLOC2
    Self:nVlTBSTVCF := nVlTBSTVCF
Return

Method Set2110C07(nVlDMaiBST) Class DRCSTBLOC2
    Self:nVlDMaiBST := nVlDMaiBST
Return

Method Set2110C08(nVlDMenBST) Class DRCSTBLOC2
    Self:nVlDMenBST := nVlDMenBST
Return

Method Set2110C09(nAliqEf) Class DRCSTBLOC2
    Self:nAliqEf := nAliqEf
Return

Method Set2110C10(nVlICMSTRt) Class DRCSTBLOC2
    Self:nVlICMSTRt := nVlICMSTRt
Return

Method Set2110C11(nVlICMSTCp) Class DRCSTBLOC2
    Self:nVlICMSTCp := nVlICMSTCp
Return

Method Set2110C12(nQtdeTSOE) Class DRCSTBLOC2
    Self:nQtdeTSOE := nQtdeTSOE
Return

Method Set2110C13(nVlICMSOE) Class DRCSTBLOC2
    Self:nVlICMSOE := nVlICMSOE
Return

Method Set2110C14(nVlICMSTOE) Class DRCSTBLOC2
    Self:nVlICMSTOE := nVlICMSTOE
Return

Method Set2110C15(nQtdeTSSN) Class DRCSTBLOC2
    Self:nQtdeTSSN := nQtdeTSSN
Return

Method Set2110C16(nVlTCMVASN) Class DRCSTBLOC2
    Self:nVlTCMVASN := nVlTCMVASN
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Comuns: Registro 2112 / 2113 e 2130 / 2114 e 2132

@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetDataMov(dDataMov) Class DRCSTBLOC2
    Self:dDataMov := dDataMov
Return

Method SetIndOp(cIndOp) Class DRCSTBLOC2
    Self:cIndOp := cIndOp
Return

Method SetItem(cItem) Class DRCSTBLOC2
    Self:cItem := cItem
Return

Method SetCFOP(cCFOP) Class DRCSTBLOC2
    Self:cCFOP := cCFOP
Return

Method SetChvDoc(cChaveDoc) Class DRCSTBLOC2
    Self:cChaveDoc := cChaveDoc
Return

Method SetCNPJ(cCNPJ) Class DRCSTBLOC2
    Self:cCNPJ := cCNPJ
Return

Method SetQtdMov(nQtdMov) Class DRCSTBLOC2
    Self:nQtdMov := nQtdMov
Return

Method SetUnid(cUnid) Class DRCSTBLOC2
    Self:cUnid := cUnid
Return

Method SetFatConv(nFatConv) Class DRCSTBLOC2
    Self:nFatConv := nFatConv
Return

Method SetQtdConv(nQtdConv) Class DRCSTBLOC2
    Self:nQtdConv := nQtdConv
Return

Method SetVlrCont(nVlrCont) Class DRCSTBLOC2
    Self:nVlrCont := nVlrCont
Return

Method SetVlrTotal(nVlrTotal) Class DRCSTBLOC2
    Self:nVlrTotal := nVlrTotal
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add2112
 
Método para geração do registro 2112 do bloco 2
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2112() Class DRCSTBLOC2

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'2112')

aAdd (Self:aReg2112, {})
nPos := Len(Self:aReg2112)
aAdd (Self:aReg2112[nPos], Self:cGrupoReg)
aAdd (Self:aReg2112[nPos], "2112")               //01 - REG
aAdd (Self:aReg2112[nPos], {Self:nQtdMov,5})     //02 - QTDE_V_CF  
aAdd (Self:aReg2112[nPos], Self:cUnid)           //03 - UNID       
aAdd (Self:aReg2112[nPos], {Self:nFatConv,6})    //04 - FAT_CONV   
aAdd (Self:aReg2112[nPos], {Self:nQtdConv,5})    //05 - QTDE_V_CF_C
aAdd (Self:aReg2112[nPos], Self:nVlrCont)        //06 - VL_V_CF    

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get2112
 
Método para retornar os registros 2112 gerados.
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get2112() Class DRCSTBLOC2
Return Self:aReg2112


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add2113
 
Método para geração do registro 2113 do bloco 2
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2113() Class DRCSTBLOC2

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'2113')

aAdd (Self:aReg2113, {})
nPos := Len(Self:aReg2113)
aAdd (Self:aReg2113[nPos], Self:cGrupoReg)
aAdd (Self:aReg2113[nPos], "2113")                                          //01 - REG
aAdd (Self:aReg2113[nPos], Self:cIndOp)                                     //02 - IND_OPER
aAdd (Self:aReg2113[nPos], Self:cIndSaida)                                  //03 - IND_S
aAdd (Self:aReg2113[nPos], Self:cChaveDoc)                                  //04 - CHV_NFE
aAdd (Self:aReg2113[nPos], Iif(Self:cIndOp=='0',Self:dDataMov,''))          //05 - DT_NFE
aAdd (Self:aReg2113[nPos], Iif(Self:cIndOp=='1',Self:dDataMov,''))          //06 - DT_E
aAdd (Self:aReg2113[nPos], Iif(Len(AllTrim(Self:cCNPJ))==14,Self:cCNPJ,'')) //07 - CNPJ
aAdd (Self:aReg2113[nPos], Iif(Len(AllTrim(Self:cCNPJ))==11,Self:cCNPJ,'')) //08 - CPF
aAdd (Self:aReg2113[nPos], Self:cItem)                                      //09 - NUM_ITEM
aAdd (Self:aReg2113[nPos], {Self:nQtdMov,5})                                //10 - QTDE_IND_S
aAdd (Self:aReg2113[nPos], Self:cUnid)                                      //11 - UNID
aAdd (Self:aReg2113[nPos], {Self:nFatConv,6})                               //12 - FAT_CONV
aAdd (Self:aReg2113[nPos], {Self:nQtdConv,5})                               //13 - QTDE_IND_S_C
aAdd (Self:aReg2113[nPos], Self:nVlrTotal)                                  //14 - VL_V_IND_S
aAdd (Self:aReg2113[nPos], Self:cCFOP)                                      //15 - CFOP
aAdd (Self:aReg2113[nPos], Self:nVlrCredSN)                                 //16 - VL_CREDITO_MVA_SN

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get2113
 
Método para retornar os registros 2113 gerados.
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get2113() Class DRCSTBLOC2
Return Self:aReg2113


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 2113

@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set2113C03(cIndSaida) Class DRCSTBLOC2
    Self:cIndSaida := cIndSaida
Return

Method Set2113C16(nVlrCredSN) Class DRCSTBLOC2
    Self:nVlrCredSN := nVlrCredSN
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add2114
 
Método para geração do registro 2114 do bloco 2
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2114() Class DRCSTBLOC2

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'2114')

aAdd (Self:aReg2114, {})
nPos := Len(Self:aReg2114)
aAdd (Self:aReg2114[nPos], Self:cGrupoReg)
aAdd (Self:aReg2114[nPos], "2114")                                           //01 - REG
aAdd (Self:aReg2114[nPos], Iif(Len(AllTrim(Self:cCNPJ))==14,Self:cCNPJ,''))  //02 - CNPJ       
aAdd (Self:aReg2114[nPos], Iif(Len(AllTrim(Self:cCNPJ))==11,Self:cCNPJ,''))  //03 - CPF        
aAdd (Self:aReg2114[nPos], Self:cChaveDoc)                                   //04 - CHV_NFE_REF
aAdd (Self:aReg2114[nPos], Right(AllTrim(Self:cNumcCxECF),3))                //05 - ECF_CX_REF 
aAdd (Self:aReg2114[nPos], Self:cNumDoc)                                     //06 - NUM_DOC_REF
aAdd (Self:aReg2114[nPos], Self:dDataMov)                                    //07 - DT_DOC_REF 

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get2114
 
Método para retornar os registros 2114 gerados.
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get2114() Class DRCSTBLOC2
Return Self:aReg2114


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 2114

@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set2114C05(cNumcCxECF) Class DRCSTBLOC2
    Self:cNumcCxECF := cNumcCxECF
Return

Method Set2114C06(cNumDoc) Class DRCSTBLOC2
    Self:cNumDoc := cNumDoc
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add2115
 
Método para geração do registro 2115 do bloco 2
            
@author Ulisses P. Oliveira
@since 29/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2115() Class DRCSTBLOC2

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'2115')

aAdd (Self:aReg2115, {})
nPos := Len(Self:aReg2115)
aAdd (Self:aReg2115[nPos], Self:cGrupoReg)
aAdd (Self:aReg2115[nPos], "2115")          //01 - REG
aAdd (Self:aReg2115[nPos], Self:cChaveDoc)  //02 - CHV_NFE_COMP       
aAdd (Self:aReg2115[nPos], Self:cItem)      //03 - NUM_ITEM_NFE_COMP

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get2115
 
Método para retornar os registros 2115 gerados.
            
@author Ulisses P. Oliveira
@since 29/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get2115() Class DRCSTBLOC2
Return Self:aReg2115


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add2120
 
Método para geração do registro 2120 do bloco 2
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2120() Class DRCSTBLOC2

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'2120')

aAdd (Self:aReg2120, {})
nPos := Len(Self:aReg2120)
aAdd (Self:aReg2120[nPos], Self:cGrupoReg)
aAdd (Self:aReg2120[nPos], "2120")               //01 - REG
aAdd (Self:aReg2120[nPos], {Self:nSQtdeC,5})     //02 - S_QTDE_C        
aAdd (Self:aReg2120[nPos], Self:nSBICMSTIn)      //03 - S_VL_BCST_INT   
aAdd (Self:aReg2120[nPos], {Self:nVlrMUnBST,3})  //04 - VLM_UNIT_BCST   
aAdd (Self:aReg2120[nPos], Self:nSVlrICMS)       //05 - S_VL_ICMS       
aAdd (Self:aReg2120[nPos], {Self:nVlrMUnICM,3})  //06 - VLM_UNIT_ICMS   
aAdd (Self:aReg2120[nPos], Self:nSVlrICMST)      //07 - S_VL_ICMS_ST    
aAdd (Self:aReg2120[nPos], {Self:nVlrMUnIST,3})  //08 - VLM_UNIT_ICMS_ST

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get2120
 
Método para retornar os registros 2120 gerados.
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get2120() Class DRCSTBLOC2
Return Self:aReg2120


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 2120

@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set2120C02(nSQtdeC) Class DRCSTBLOC2
    Self:nSQtdeC := nSQtdeC
Return

Method Set2120C03(nSBICMSTIn) Class DRCSTBLOC2
    Self:nSBICMSTIn := nSBICMSTIn
Return

Method Set2120C04(nVlrMUnBST) Class DRCSTBLOC2
    Self:nVlrMUnBST := nVlrMUnBST
Return

Method Set2120C05(nSVlrICMS) Class DRCSTBLOC2
    Self:nSVlrICMS := nSVlrICMS
Return

Method Set2120C06(nVlrMUnICM) Class DRCSTBLOC2
    Self:nVlrMUnICM := nVlrMUnICM
Return

Method Set2120C07(nSVlrICMST) Class DRCSTBLOC2
    Self:nSVlrICMST := nSVlrICMST
Return

Method Set2120C08(nVlrMUnIST) Class DRCSTBLOC2
    Self:nVlrMUnIST := nVlrMUnIST
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add2121
 
Método para geração do registro 2121 do bloco 2
            
@author Ulisses P. Oliveira
@since 29/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2121() Class DRCSTBLOC2

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'2121')

aAdd (Self:aReg2121, {})
nPos := Len(Self:aReg2121)
aAdd (Self:aReg2121[nPos], Self:cGrupoReg)
aAdd (Self:aReg2121[nPos], "2121")               //01 - REG
aAdd (Self:aReg2121[nPos], {Self:nSQtdeCT,5})    //02 - S_QTDE_C_T 
aAdd (Self:aReg2121[nPos], {Self:nSQtdeCVlM,5})  //03 - S_QTDE_C_VLM 
aAdd (Self:aReg2121[nPos], Self:nSBICMSTVM)      //04 - S_VL_BCST_INT_VLM
aAdd (Self:aReg2121[nPos], {Self:nVlrMUBSTG,3})  //05 - VLM_UNIT_BCST_G

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get2121
 
Método para retornar os registros 2121 gerados.
            
@author Ulisses P. Oliveira
@since 29/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get2121() Class DRCSTBLOC2
Return Self:aReg2121


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 2121

@author Ulisses P. Oliveira
@since 29/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set2121C02(nSQtdeCT) Class DRCSTBLOC2
    Self:nSQtdeCT := nSQtdeCT
Return

Method Set2121C03(nSQtdeCVlM) Class DRCSTBLOC2
    Self:nSQtdeCVlM := nSQtdeCVlM
Return

Method Set2121C04(nSBICMSTVM) Class DRCSTBLOC2
    Self:nSBICMSTVM := nSBICMSTVM
Return

Method Set2121C05(nVlrMUBSTG) Class DRCSTBLOC2
    Self:nVlrMUBSTG := nVlrMUBSTG
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add22130
 
Método para geração do registro 2130 do bloco 2
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2130() Class DRCSTBLOC2

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'2130')

aAdd (Self:aReg2130, {})
nPos := Len(Self:aReg2130)
aAdd (Self:aReg2130[nPos], Self:cGrupoReg)
aAdd (Self:aReg2130[nPos], "2130")                                 //01 - REG
aAdd (Self:aReg2130[nPos], Self:cIndOp)                            //02 - IND_OPER   
aAdd (Self:aReg2130[nPos], Self:cChaveDoc)                         //03 - CHV_NFE    
aAdd (Self:aReg2130[nPos], Iif(Self:cIndOp=='0',Self:dDataMov,'')) //04 - DT_E       
aAdd (Self:aReg2130[nPos], Iif(Self:cIndOp=='1',Self:dDataMov,'')) //05 - DT_NFE     
aAdd (Self:aReg2130[nPos], Self:cCNPJ)                             //06 - CNPJ       
aAdd (Self:aReg2130[nPos], Self:cItem)                             //07 - NUM_ITEM   
aAdd (Self:aReg2130[nPos], Self:cRespRet)                          //08 - COD_RESP_RE
aAdd (Self:aReg2130[nPos], {Self:nQtdMov,5})                       //09 - QTDE       
aAdd (Self:aReg2130[nPos], Self:cUnid)                             //10 - UNID       
aAdd (Self:aReg2130[nPos], {Self:nFatConv,6})                      //11 - FAT_CONV   
aAdd (Self:aReg2130[nPos], {Self:nQtdConv,5})                      //12 - QTDE_C     
aAdd (Self:aReg2130[nPos], Self:nVlrCont)                          //13 - VL_E       
aAdd (Self:aReg2130[nPos], Self:cCFOP)                             //14 - CFOP       
aAdd (Self:aReg2130[nPos], Self:nVlrBICMS)                         //15 - VL_BC_ICMS 
aAdd (Self:aReg2130[nPos], Self:nVlrAICMS)                         //16 - ALIQ_ICMS  
aAdd (Self:aReg2130[nPos], Self:nVlrICMS )                         //17 - VL_ICMS    
aAdd (Self:aReg2130[nPos], Self:nVlrBICMST)                        //18 - VL_BCST    
aAdd (Self:aReg2130[nPos], Self:nVlrBINTST)                        //19 - VL_BCST_INT
aAdd (Self:aReg2130[nPos], Self:nVlrAICMST)                        //20 - ALIQ_ST_E  
aAdd (Self:aReg2130[nPos], Self:nVlrAEFEST)                        //21 - ALIQ_ST_EF 
aAdd (Self:aReg2130[nPos], Self:nVlrCALCST)                        //22 - CAL_ICMS_ST
aAdd (Self:aReg2130[nPos], Self:nVlrICMSST)                        //23 - VL_ICMS_ST 
aAdd (Self:aReg2130[nPos], Self:cCodDA)                            //24 - COD_DA     
aAdd (Self:aReg2130[nPos], Self:cNumDARE)                          //25 - NUM_DARE   
aAdd (Self:aReg2130[nPos], Self:cCodAjuste)                        //26 - COD_AJ C   

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get2130
 
Método para retornar os registros 2130 gerados.
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get2130() Class DRCSTBLOC2
Return Self:aReg2130


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 2130

@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set2130C15(nVlrBICMS) Class DRCSTBLOC2
    Self:nVlrBICMS := nVlrBICMS
Return

Method Set2130C16(nVlrAICMS) Class DRCSTBLOC2
    Self:nVlrAICMS := nVlrAICMS
Return

Method Set2130C17(nVlrICMS) Class DRCSTBLOC2
    Self:nVlrICMS := nVlrICMS
Return

Method Set2130C18(nVlrBICMST) Class DRCSTBLOC2
    Self:nVlrBICMST := nVlrBICMST
Return

Method Set2130C20(nVlrAICMST) Class DRCSTBLOC2
    Self:nVlrAICMST := nVlrAICMST
Return

Method Set2130C23(nVlrICMSST) Class DRCSTBLOC2
    Self:nVlrICMSST := nVlrICMSST
Return

Method Set2130C19(nVlrBINTST) Class DRCSTBLOC2
    Self:nVlrBINTST := nVlrBINTST
Return

Method Set2130C21(nVlrAEFEST) Class DRCSTBLOC2
    Self:nVlrAEFEST := nVlrAEFEST
Return

Method Set2130C22(nVlrCALCST) Class DRCSTBLOC2
    Self:nVlrCALCST := nVlrCALCST
Return

Method Set2130C26(cCodAjuste) Class DRCSTBLOC2
    Self:cCodAjuste := cCodAjuste
Return

Method Set2130C24(cCodDA) Class DRCSTBLOC2
    Self:cCodDA := cCodDA
Return

Method Set2130C25(cNumDARE) Class DRCSTBLOC2
    Self:cNumDARE := cNumDARE
Return

Method Set2130C08(cRespRet) Class DRCSTBLOC2
    Self:cRespRet := cRespRet
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add2132
 
Método para geração do registro 2132 do bloco 2
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2132() Class DRCSTBLOC2

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'2132')

aAdd (Self:aReg2132, {})
nPos := Len(Self:aReg2132)
aAdd (Self:aReg2132[nPos], Self:cGrupoReg)
aAdd (Self:aReg2132[nPos], "2132")          //01 - REG
aAdd (Self:aReg2132[nPos], Self:cCNPJ)      //02 - CNPJ       
aAdd (Self:aReg2132[nPos], Self:cChaveDoc)  //03 - CHV_NFE_REF
aAdd (Self:aReg2132[nPos], Self:dDataMov)   //04 - DT_E_REF   

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get2132
 
Método para retornar os registros 2132 gerados.
            
@author Ulisses P. Oliveira
@since 12/05/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get2132() Class DRCSTBLOC2
Return Self:aReg2132


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add2133
 
Método para geração do registro 2133 do bloco 2
            
@author Ulisses P. Oliveira
@since 29/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2133() Class DRCSTBLOC2

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'2133')

aAdd (Self:aReg2133, {})
nPos := Len(Self:aReg2133)
aAdd (Self:aReg2133[nPos], Self:cGrupoReg)
aAdd (Self:aReg2133[nPos], "2133")          //01 - REG
aAdd (Self:aReg2133[nPos], Self:cChaveDoc)  //02 - CHV_NFE_COMP       
aAdd (Self:aReg2133[nPos], Self:cItem)      //03 - NUM_ITEM_NFE_COMP

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get2133
 
Método para retornar os registros 2133 gerados.
            
@author Ulisses P. Oliveira
@since 29/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get2133() Class DRCSTBLOC2
Return Self:aReg2133


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add2134
 
Método para geração do registro 2134 do bloco 2
            
@author Ulisses P. Oliveira
@since 29/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Add2134() Class DRCSTBLOC2

Local nPos := 0

Self:cGrupoReg := FISA234SEQ(@Self:aNumeracao,Self:cRelac,'2134')

aAdd (Self:aReg2134, {})
nPos := Len(Self:aReg2134)
aAdd (Self:aReg2134[nPos], Self:cGrupoReg)
aAdd (Self:aReg2134[nPos], "2134")               //01 - REG
aAdd (Self:aReg2134[nPos], Self:cCodIndXml)      //02 - COD_IND_XML 

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get2134
 
Método para retornar os registros 2134 gerados.
            
@author Ulisses P. Oliveira
@since 29/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Get2134() Class DRCSTBLOC2
Return Self:aReg2134


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters Registro 2121

@author Ulisses P. Oliveira
@since 29/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method Set2134C02(cCodIndXml) Class DRCSTBLOC2
    Self:cCodIndXml := cCodIndXml
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} NumSignif
 
Função que trata os numeros significativos no arquivo
No sistêmico essa função e foi clonada da FISA104 foi criado como função por que tbm é chamada no FISA241A
            
@author r.cavalcante
@since 30/06/2022

/*/
//-------------------------------------------------------------------
Function NumSignif(nValor, nDecimal)
    Local cNum		:= ''
    Local nVal		:= Val(cValtochar(nValor))
       
    //Caso a quantidade de decimais venha igua a zero, será adotado default que é 2
    If nDecimal == 0
        nDecimal	:= 2
    EndiF    
    
    cNum	:= AllTrim (StrTran (Str (nValor,,nDecimal), ".", ","))   
    
    If nValor <> 0    
        Do Case
        Case nVal >= 100 //
            //Não será necessário fazer controle de número significativo
        Case nVal >=10 .AND. nVal< 100 //
            //Significa que deverá ter que adicionar mais um zero
            cNum += '0'
        Case nVal >=1 .AND. nVal < 10 //
            //Significa que deverá ter que adicionar mais dois zeros
            cNum += '00'
        Case nVal >=0.10 .AND. nVal < 1
            //Significa que deverá ter que adicionar mais três zeros
            cNum += '000'
        Case nVal >=0.01 .AND. nVal < 0.10
            //Significa que deverá ter que adicionar mais quatro zeros
            cNum += '0000'
        Case nVal >=0.001 .AND. nVal < 0.01
            //Significa que deverá ter que adicionar mais cinco zeros
            cNum += '00000'
        Case nVal <=0.001 .And. nVal > 0
            //Significa que deverá ter que adicionar mais cinco zeros
            cNum += '00000'
        Case 	nVal < 0 .And. nVal <= (-10) .And. nVal > (-100)
            cNum += '0'
        Case nVal < 0 .And. nVal <= (-1) .AND. nVal > (-10)
            //Significa que deverá ter que adicionar mais dois zeros
            cNum += '00'
        Case nVal < 0 .And. nVal <= (-0.10) .AND. nVal > (-1)
            //Significa que deverá ter que adicionar mais três zeros
            cNum += '000'
        Case nVal < 0 .And. nVal <= (-0.01) .AND. nVal > (-0.10)
            //Significa que deverá ter que adicionar mais quatro zeros
            cNum += '0000'
        Case nVal < 0 .And. nVal <= (-0.001) .AND. nVal > (-0.01)
            //Significa que deverá ter que adicionar mais cinco zeros
            cNum += '00000'
        EndCase
    EndIF
    
    //Verificação de quantidade de casas decimais no cNum, pois não pode ultrapassar 12 casas decimais
    IF Len(SUBSTR(cNum,AT(",", cNum)+1, len(cNum))) > 12
        //Valor sem estrapolar as 12 casas decimais
        cNum:= Left(cNum, Len(cNum) - (Len(SUBSTR(cNum,AT(",", cNum)+1, len(cNum))) - 12))
    EndIf
    
Return cNum
