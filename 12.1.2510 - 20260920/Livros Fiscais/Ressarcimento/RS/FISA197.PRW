#INCLUDE "PROTHEUS.CH"


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA197APURACAO

Classe responsável pela apuração de cada movimento da query principal, controlando:
Estoque / Movimentos / Apuração de Valor a Ressarcir ou Complementar

@author
@since 23/01/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA197APURACAO FROM LongNameClass

//Variaveis
Data lVarejo        As Boolean
Data cMesAno        As Character
Data dDtInv  		As date
Data clivro         As Character 

//Varejo
Data aVJCodCred	  As Array //Credito Entrada
Data aVCodInv    As Array //Credito Estoque
Data aVCodEst    As Array //Estorno - venda não consumidor /isentas e não Tributada
Data aVCodDeb     As Array //Saídas

//Não varejo
Data aNVEst   As Array //Alteraçao de trib final do periodo ou mudança de rejime para varejista
Data aNVDeb    As Array //Debito saída
Data aNVCred   As Array //Credito saída com referença da entrada

//Movimento
Data dDataMov     As Date      //---Data do Movimento
Data cTipoMov     As Character //---Tipo do Movimento (E-Entrada / S-Saída)
Data cNumDoc      As Character //---Número do Documento Fiscal
Data cSerieDoc    As Character //---Série do Documento Fiscal
Data cItemDoc     As Character //---Item do Documento Fiscal
Data cTipoDoc     As Character //---Tipo do Documento (Normal / Devolução / Complemento)
Data cCodProd     As Character //---Código do Produto
Data cCodPart     As Character //---Código do Participante
Data cLojPart     As Character //---Loja do Participante
Data cLote        As Character //---Numero do Lote
Data cLoteCTL     As Character //---Numero do CTL
Data cRegra       As Character //---Regra
Data cCodAjust    As Character //---Código de Ajuste
Data nQtdade      As Numeric   //---Quantidade
Data nICMSEfet	  As Numeric   //---ICMS Efetivo cálculado na saída
Data nICMSPres	  As Numeric   //---ICMS Presumido
Data nICMSDed	  As Numeric   //---ICMS a Estornar
Data nVlrRes	  As Numeric   //---Valor ICMS a ressarcir
Data nVlrComp	  As Numeric   //---Valor ICMS a complementar

//Apuração
Data aTotApur	  As Array   //Array contendo totalizador por regra


//Objetos
Data oInvetario     As Object    //Objeto que controla o inventario
Data oMovimento     As Object    //Objeto que controla o movimento analisado
//Data oApuração      As Object    //Objeto que controla os valores apurados para o movimento e estoque

//Metodos
Method New(cMesAno,lVarejo,dDtInv) CONSTRUCTOR
Method SetaMovim(dDataMov,cTipoMov,cNumDoc,cSerieDoc,cItemDoc,cTipoDoc,cCodProd,cCodPart,cLojPart,cLote,cLoteCTL,nQtdade,cRegra,cCodAjust,nICMSEfet,nICMSPres,nICMSDed,nVlrRes,nVlrComp)
Method CarregaRegra()
Method SetaInventario()
Method SetEntrada()
Method ClearMov()
Method TotApur()

//---Getters e Setters---//
Method GetAnoMes()
Method GetDtInv()
Method GetRegra()
Method GetVCodInv()

//Apuraçao
Method GetTotApur()

//Codigos
Method SetVCodInv(Value)
Method SetVCodCred(Value)
Method SetVCodEst(Value)
Method SetVCodDeb(Value)
Method SetNVEst(Value)
Method SetNVDeb(Value)
Method SetNVCred(Value)

Method SetDtInv(Value)
Method SetRegra(Value)


//Valores
Method SetICMSEfet(Value) 
Method SetICMSPres(Value) 
Method SetICMSDed(Value) 
Method SetVlrRes(Value) 
Method SetVlrComp(Value) 

//Lote
Method SetLote(Value) 
Method SetLoteCTL(Value) 



ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()

Método construtor da Classe FISA197APURACAO

@author
@since
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New(cMesAno,lVarejo,dDtInv,clivro) Class FISA197APURACAO
	Self:cMesAno        := cMesAno
    Self:lVarejo        := lVarejo
    Self:dDtInv         := dDtInv
    Self:clivro         := clivro        

    Self:cRegra         := ""

    Self:aVJCodCred  := {}
    Self:aVCodInv    := {}
    Self:aVCodEst    := {}
    Self:aVCodDeb    := {}

    Self:aNVEst     := {}
    Self:aNVDeb     := {}
    Self:aNVCred    := {}

    Self:aTotApur	:={}    

    Self:oInvetario     := FISA197INVENTARIO():New(dDtInv)
    Self:oMovimento     := FISA197MOVIMENTO():New()
    //Self:oApuração      := FISA197MOVIMENTOAPURACAO():New()

    Self:dDataMov   := CToD("  /  /    ")    
    Self:cTipoMov   := ""
    Self:cNumDoc    := ""
    Self:cSerieDoc  := ""
    Self:cItemDoc   := ""
    Self:cTipoDoc   := ""
    Self:cCodProd   := ""
    Self:cCodPart   := ""
    Self:cLojPart   := ""
    Self:cLote      := ""
    Self:cLoteCTL   := ""
    Self:cRegra     := ""
    Self:cCodAjust  := ""
    Self:nQtdade    := 0
    Self:nICMSEfet  := 0
    Self:nICMSPres  := 0
    Self:nICMSDed   := 0
    Self:nVlrRes    := 0
    Self:nVlrComp   := 0

Return Self

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaRegra()

Método que carrega no objeto o os códigos de ajuste de apuração
Deve ser antes da apuração ou filtro de movimento.

@author
@since
@version 1.0
/*/
Method CarregaRegra() Class FISA197APURACAO
Local aRegra := {}
Local cAliasF3T := GetNextAlias()

BeginSql Alias cAliasF3T
	SELECT F3T_CODIGO,F3T_REGRA,F3T_PARCEL
	FROM  %Table:F3T% F3T
	WHERE
	F3T.F3T_FILIAL=%xFilial:F3T% AND
	F3T.%NotDel%
EndSql

/* Opções carregadas autometicamente e alterada pelo usuario 
01 - Varejista - Apropriação do crédito relativo às mercadorias em estoque'
02 - Varejista - Apropriação de crédito relativo às entradas de mercadoria recebidas'
03 - Varejista - Estorno do crédito pelo inventário'
04 - Varejista - Debito'
05 - Não Varejista - Estorno do crédito anteriormente a partir de inventário.'
06 - Não Varejista - Debito.'
07 - Não Varejista - Apropriação do crédito de mercadoria recebidas com ST.'
*/

While !(cAliasF3T)->(EOF())
	
	If !Empty((cAliasF3T)->F3T_REGRA)
        
        aRegra := {(cAliasF3T)->F3T_REGRA,(cAliasF3T)->F3T_CODIGO}
        
		Do Case
			Case aRegra[1] == "01"
			   Self:SetVCodInv(aRegra)
               Self:oInvetario:SetQtParc((cAliasF3T)->(F3T_PARCEL))
			Case aRegra[1] == "02"
				Self:SetVCodCred(aRegra)
			Case aRegra[1] == "03"
			   Self:SetVCodEst(aRegra)
			Case aRegra[1] == "04"
			   Self:SetVCodDeb(aRegra)
			Case aRegra[1] == "05"
			   Self:SetNVEst(aRegra)
			Case aRegra[1] == "06"
			   Self:SetNVDeb(aRegra)
			Case aRegra[1] == "07"
			   Self:SetNVCred(aRegra)
		EndCase
	Endif
	
   (cAliasF3T)->(dbSkip())
Enddo

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetaInventario()

Método que carrega no objeto o inventario processado na rotina fisa116 para calculo 5
Deve ser chamado uma vez para cada data de fechamento.

@author
@since
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetaInventario() Class FISA197APURACAO
    Self:oInvetario:SetDtInv(Self:dDtInv)
	Self:oInvetario:SetCdAjuste(Self:aVCodInv)
    Self:oInvetario:SetRegra(Self:cRegra)
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetEntrada()

Método que carrega no objeto o inventario processado na rotina fisa116 para calculo 5
Deve ser chamado uma vez para cada data de fechamento.

@author
@since
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetEntrada(cTipoProc) Class FISA197APURACAO
    Self:oMovimento:cCodProd  := Self:cCodProd 
    Self:oMovimento:nQtdade   := Self:nQtdade  
    Self:oMovimento:dDataMov  := Self:dDataMov    
    Self:oMovimento:cTipoProc := cTipoProc
    Self:oMovimento:cNumLote  := Self:cLote 
    Self:oMovimento:cLoteCli  := Self:cLoteCTL 
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetaMovim()

Método que carrega no objeto o movimento a ser analisado.
Deve ser chamado a cada movimento encontrado para o produto em questão.

@author
@since
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method SetaMovim(dDataMov,cTipoMov,cNumDoc,cSerieDoc,cItemDoc,cTipoDoc,cCodProd,cCodPart,cLojPart,cLote,cLoteCTL,nQtdade,cRegra,cCodAjust,nICMSEfet,nICMSPres,nICMSDed,nVlrRes,nVlrComp) Class FISA197APURACAO
    Self:ClearMov()
    Self:dDataMov  :=  dDataMov   //---Data do Movimento    
    Self:cTipoMov  :=  cTipoMov  //---Tipo do Movimento (E-Entrada / S-Saída)
    Self:cNumDoc   :=  cNumDoc   //---Número do Documento Fiscal
    Self:cSerieDoc :=  cSerieDoc //---Série do Documento Fiscal
    Self:cItemDoc  :=  cItemDoc  //---Item do Documento Fiscal
    Self:cTipoDoc  :=  cTipoDoc  //---Tipo do Documento (Normal / Devolução / Complemento)
    Self:cCodProd  :=  cCodProd  //---Código do Produto
    Self:cCodPart  :=  cCodPart  //---Código do Participante
    Self:cLojPart  :=  cLojPart  //---Loja do Participante
    Self:cLote     :=  cLote //---Numero do Lote
    Self:cLoteCTL  :=  cLoteCTL //---Numero do Lote
    Self:cRegra    :=  cRegra    //---Regra
    Self:cCodAjust :=  cCodAjust //---Código de Ajuste
    Self:nQtdade   :=  nQtdade   //---Quantidade
    Self:nICMSEfet :=  nICMSEfet  //---ICMS Efetivo cálculado na saída
    Self:nICMSPres :=  nICMSPres  //---ICMS Presumido
    Self:nICMSDed  :=  nICMSDed    //---ICMS a Estornar
    Self:nVlrRes   :=  nVlrRes      //---Valor ICMS a ressarcir
    Self:nVlrComp  :=  nVlrComp    //---Valor ICMS a complementar
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClearMov
  
Método que limpa os valores do movimento.

@author Ulisses P. Oliveira
@since 12/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearMov() Class FISA197APURACAO
    Self:dDataMov   := CToD("  /  /    ")    
    Self:cTipoMov   := ""
    Self:cNumDoc    := ""
    Self:cSerieDoc  := ""
    Self:cItemDoc   := ""
    Self:cTipoDoc   := ""
    Self:cCodProd   := ""
    Self:cCodPart   := ""
    Self:cLojPart   := ""
    Self:cLote      := ""
    Self:cLoteCTL   := ""
    Self:cRegra     := ""
    Self:cCodAjust  := ""
    Self:nQtdade    := 0
    Self:nICMSEfet  := 0
    Self:nICMSPres  := 0
    Self:nICMSDed   := 0
    Self:nVlrRes    := 0
    Self:nVlrComp   := 0
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters FISA197APURACAO

@author
@since
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
//Setters
Method SetVCodCred(Value) Class FISA197APURACAO
	Self:aVJCodCred := Value
Return 

Method SetVCodInv(Value) Class FISA197APURACAO
	Self:aVCodInv := Value
Return 

Method SetVCodEst(Value) Class FISA197APURACAO
	Self:aVCodEst := Value
Return 

Method SetVCodDeb(Value) Class FISA197APURACAO
	Self:aVCodDeb := Value
Return 

Method SetNVEst(Value) Class FISA197APURACAO
	Self:aNVEst := Value
Return 

Method SetNVDeb(Value) Class FISA197APURACAO
	Self:aNVDeb := Value
Return 

Method SetNVCred(Value) Class FISA197APURACAO
	Self:aNVCred := Value
Return

Method SetDtInv(Value) Class FISA197APURACAO
	Self:dDtInv := Value
Return

Method SetRegra(Value) Class FISA197APURACAO
	Self:cRegra := Value
Return

Method SetICMSEfet(Value) Class FISA197APURACAO
	Self:nICMSEfet := Value
Return

Method SetICMSPres(Value) Class FISA197APURACAO
	Self:nICMSPres := Value
Return

Method SetICMSDed(Value) Class FISA197APURACAO
	Self:nICMSDed := Value
Return

Method SetVlrRes(Value) Class FISA197APURACAO
	Self:nVlrRes := Value
Return

Method SetVlrComp(Value) Class FISA197APURACAO
	Self:nVlrComp := Value
Return

Method SetLote(Value) Class FISA197APURACAO
	Self:cLote := Value
Return

Method SetLoteCTL(Value) Class FISA197APURACAO
	Self:cLoteCTL := Value
Return

//Getters
Method GetAnoMes() Class FISA197APURACAO
Return Self:cAnoMes

Method GetDtInv() Class FISA197APURACAO
Return Self:dDtInv

Method GetRegra() Class FISA197APURACAO
Return Self:cRegra

Method GetTotApur() Class FISA197APURACAO
Return Self:aTotApur

Method GetVCodInv() Class FISA197APURACAO
Return Self:aVCodInv


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Method TotApur

Classe responsável por controlar saldos inventario

@author
@since
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method TotApur() Class FISA197APURACAO

    Local nPos := 0

    If !Empty(Self:cRegra)
        If (nPos := Ascan(Self:aTotApur,{|x| x[1]==Self:cRegra}))==0
            aAdd(Self:aTotApur, {})
            nPos :=	Len(Self:aTotApur)

            aAdd(Self:aTotApur[nPos],Self:cRegra)
            aAdd(Self:aTotApur[nPos],0)
            aAdd(Self:aTotApur[nPos],0)
            aAdd(Self:aTotApur[nPos],0)
            aAdd(Self:aTotApur[nPos],0)
            aAdd(Self:aTotApur[nPos],0)
            aAdd(Self:aTotApur[nPos],0)       
            aAdd(Self:aTotApur[nPos],0)
            aAdd(Self:aTotApur[nPos],0)
            aAdd(Self:aTotApur[nPos],0)
        Endif

        
        If Self:cRegra == Self:aVCodInv[1] //Inventario
            Self:aTotApur[nPos][3] += Self:nICMSPres
            Self:aTotApur[nPos][5] += Self:nVlrRes            
            Self:aTotApur[nPos][7]  += Self:oInvetario:nVlrTotal
            Self:aTotApur[nPos][8]  += Self:oInvetario:nVlrParc
            Self:aTotApur[nPos][9]  += Self:oInvetario:nQtParc
            Self:aTotApur[nPos][10] += Self:oInvetario:nParcUtl            
        Else  //Movimento
            Self:aTotApur[nPos][2] += Self:nICMSEfet
            Self:aTotApur[nPos][3] += Self:nICMSPres
            Self:aTotApur[nPos][4] += Self:nICMSDed
            Self:aTotApur[nPos][5] += Self:nVlrRes
            Self:aTotApur[nPos][6] += Self:nVlrComp        
        Endif
    Endif


Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA197INVENTARIO

Classe responsável por controlar saldos inventario

@author
@since
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA197INVENTARIO FROM LongNameClass

Data dDtInv  As date    //Data do Inventario
Data nVlrTotal    As Numeric //Valor total Apurado pela rotina FISA116 calculo 5
Data nQtParc    As Numeric //Quantidade de parcelas que sera dividido valor total
Data nParcUtl    As Numeric //Parcelas Utilizada
Data nVlrParc  As Numeric //Valor resultado da divisão nVlrTotal / nQtParc
Data aCdAjuste     As Array  //Código de Ajuste utilizado para Parcelas
Data cRegra     As Character


Method New(dDtInv) CONSTRUCTOR
Method ApuraEstoque()
Method ParcelaTotal()
Method ClearInv()


//---Getters e Setters---//
Method SetDtInv(value)

Method SetVlrTotal(value)
Method SetQtParc(value)
Method SetParcUtl(value)
Method SetVlrParc(value)
Method SetCdAjuste(value)
Method SetRegra(value)

Method GetVlrTotal()
Method GetQtParc()
Method GetVlrParc()
Method GetCdAjuste()

ENDCLASS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()

Método construtor da Classe FISA197APURACAO

@author
@since
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New(dDtInv) Class FISA197INVENTARIO

    Self:dDtInv  := dDtInv
    Self:aCdAjuste     := {}
    Self:nVlrTotal    := 0
    Self:nQtParc    := 0
    Self:nVlrParc  := 0
    Self:nParcUtl   := 0
    Self:cRegra     := ""

Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ApuraEstoque() FISA197INVENTARIO

Método que Carrega total calculado na F0M - FISA116 pela filial e data de fechamento de estoque indicado

@author
@since
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ApuraEstoque() Class FISA197INVENTARIO    
	Local cFiltro		:= ""
	Local cAliasF0M		:= GetNextAlias()
	
	cFiltro = "%"
	cFiltro += "F0M.F0M_FILIAL		= '"	+ xFilial('F0M')				+ "' AND "
	cFiltro += "F0M.F0M_DTFECH		= '" 	+ %Exp:DToS (Self:dDtInv)%	+ "' AND "
    cFiltro += "F0M.F0M_REGRA	= '5' "
	cFiltro += "%"	
		
	BeginSql Alias cAliasF0M
		
		SELECT
			SUM(F0M.F0M_TOTICM) F0M_TOTICM
		FROM
			%TABLE:F0M% F0M			
		WHERE
			%Exp:cFiltro% 
            AND F0M.%NotDel%
	EndSql
		
	
	If !(cAliasF0M)->(EOF())
		//Grava Valor total    
		Self:SetVlrTotal((cAliasF0M)->F0M_TOTICM)
	Endif
	
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ParcelaTotal() FISA197INVENTARIO

Método que Parcela valor total do estoque a Restituir

@author
@since
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ParcelaTotal() Class FISA197INVENTARIO
    Local nTotal    := Self:GetVlrTotal()
    Local nParc     := Self:GetQtParc()
    Local nValParc  := nTotal

    If nParc > 0
        nValParc := nTotal / nParc
    EndIf
    
    //Grava valor Parcelas
    Self:SetVlrParc(nValParc)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClearInv
  
Método que limpa os valores do movimento.

@author Ulisses P. Oliveira
@since 12/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearInv() Class FISA197INVENTARIO
    Self:dDtInv     := dDtInv
    Self:aCdAjuste  := {}
    Self:nVlrTotal  := 0
    Self:nQtParc    := 0
    Self:nVlrParc   := 0
    Self:nParcUtl   := 0
    Self:cRegra     := ""
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Getters e Setters FISA197INVENTARIO

@author
@since
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
//Setters
Method SetDtInv(Value) Class FISA197INVENTARIO
    Self:dDtInv := Value
Return

Method SetVlrTotal(Value) Class FISA197INVENTARIO
    Self:nVlrTotal := Value
Return

Method SetQtParc(Value) Class FISA197INVENTARIO
    Self:nQtParc := Value
Return

Method SetParcUtl(Value) Class FISA197INVENTARIO
    Self:nParcUtl := Value
Return


Method SetVlrParc(Value) Class FISA197INVENTARIO
    Self:nVlrParc := Value
Return

Method SetCdAjuste(Value) Class FISA197INVENTARIO
    Self:aCdAjuste := Value
Return

Method SetRegra(Value) Class FISA197INVENTARIO
    Self:cRegra := Value
Return

//Getters
Method GetVlrTotal() Class FISA197INVENTARIO   
Return Self:nVlrTotal

Method GetQtParc() Class FISA197INVENTARIO    
Return Self:nQtParc

Method GetVlrParc() Class FISA197INVENTARIO    
Return Self:nVlrParc




//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Classe FISA197MOVIMENTO
  
@author Eduardo Vicente da Silva
@since 22/01/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
CLASS FISA197MOVIMENTO FROM LongNameClass

Data cCodProd       As Character 
Data nQtdade        As Numeric   
Data dDataMov       As Date      
Data cTipoProc      As Character //Tipo de processamento: M - Média Ponderada, U - Última Entrada, L - Lote
Data cNumLote       As Character
Data cLoteCli       As Character
Data nVlrICMSUnit   As Numeric   
Data aSldVlrDet     As Array
Data lApurBase      As Boolean
Data lUsaRegra      As Boolean 

Method New() CONSTRUCTOR
Method ICMSUnitEnt()
Method ClearEntrada()
Method SetlApurBase()
Method GetlApurBase()
Method SetlUsaRegra()

ENDCLASS


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
  
Método construtor da Classe FISA197MOVIMENTO

@author Eduardo Vicente da Silva
@since 22/01/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method New() Class FISA197MOVIMENTO
    Self:cCodProd     := ""
    Self:nQtdade      := 0
    Self:dDataMov     := CToD("  /  /    ")
    Self:cTipoProc    := ""
    Self:cNumLote     := ""
    Self:cLoteCli     := ""    
    Self:nVlrICMSUnit := 0
    Self:aSldVlrDet   := {}
    Self:lApurBase    := .F.
    Self:lUsaRegra    := .F.
Return Self


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ICMSUnitEnt() FISA197MOVIMENTO
  
Método que define a base de calculo do ICMS à partir das Entradas. 

@author Eduardo Vicente da Silva
@since 22/01/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ICMSUnitEnt() Class FISA197MOVIMENTO
    Local cCodProd    := Self:cCodProd
    Local nQtdade     := Self:nQtdade
    Local dDataMov    := Self:dDataMov
    Local cTipoProc   := Self:cTipoProc
    Local cNumLote    := Self:cNumLote
    Local cLoteCli    := Self:cLoteCli
    Local lApurBase   := Self:lApurBase
    Local lUsaRegra   := Self:lUsaRegra
    Local aArea  	  := GetArea()
    Local cAlias 	  := GetNextAlias()
    Local cAliasSD1   := ''
    Local dDataDe     := FirstDay(dDataMov)
    Local dDataAte    := dDataMov
    Local lAchouFT	  := .F.
    Local aSldVlrDet  := {}
    Local nRetorno    := 0
    Local nQtdadePro  := 0
    Local nValorPro   := 0
    Local nVlrICMS    := 0
    Local nBaseIcm    := 0
    Local nValICM     := 0
    Local nAlqICM     := 0
    Local lLei2741    := .T.
    Local nValST      := 0
    Local nAliqICMS   := 0
    Local nAliqST     := 0
    Local nMVICMPAD   := SuperGetMV('MV_ICMPAD')
    Local nMVULTAPER  := SuperGetMv("MV_ULTAPER",,24)
    Local dDtLimit    := MonthSub(dDataDe, nMVULTAPER) //---Definição da data limite para pesquisa das últimas entradas através do parâmetro MV_ULTAPER---//
    Local cCST        := ""
    Local cSGBD       := TCGetDB()
    Local cSubStrBD   := ''
    Local cSlcRegra   := ''
    Local cFrmRegra1  := ''
    Local cFrmRegra2  := ''
    Local cjoinCFOP   := ''

    If cTipoProc == 'L'
    
        SPEDRastro2(cNumLote,cLoteCli,cCodProd,@nBaseIcm,@nValICM,,,,nAlqICM,,lLei2741,,,,,,,@nValST)

        If nValICM > 0 .Or. nValST > 0
    
            dbSelectArea("SB8")
            dbSetOrder(2)
            If SB8->(MsSeek(xFilial("SB8")+cNumLote+cLoteCli+cCodProd))
            
                dbSelectArea("SD1")
                dbSetOrder(11)

                If SD1->(MsSeek(xFilial("SD1")+SB8->B8_DOC+SB8->B8_SERIE+SB8->B8_CLIFOR+SB8->B8_LOJA+cCodProd+cLoteCli+cNumLote))


                    nQtdadePro := Iif(nValICM > 0, SB8->B8_QTDORI, D1_QUANT)

                    If !lApurBase
                        nValorPro  := Iif(nValICM > 0, nValICM, nValST)
                        
                    Else
                        //Quando operação indireta considera aliquota do produto
                        If SD1->D1_ALQNDES > 0 
                            //Casos tenha sido informado aliquota do recolhimento anterior, utiliza esta aliquota para calculo.
                            nAliqST := SD1->D1_ALQNDES
                        Else
                            nAliqST := SD1->D1_ALIQSOL
                        Endif
                            
                        // Caso a aliquota esteja zerada buscar pelos cadastros 
                        If nAliqST == 0 .And. SB1->(MsSeek(xFilial("SB1")+SD1->D1_COD))
                            nAliqST := SB1->B1_PICM
                            If nAliqST == 0 
                                nAliqST := nMVICMPAD
                            EndIf 
                        EndIf

                        //Rio Grande do Sul
                        /*Pelo contribuinte varejista:
                        a) o montante do imposto presumido, que corresponderá ao valor obtido pela aplicação da alíquota interna sobre o valor da base de cálculo utilizada para o cálculo
                        do débito de responsabilidade por substituição tributária, informado nos documentos fiscais de aquisição das mercadorias, 
                        deduzido o valor correspondente às mercadorias que não sejam objeto de saídas destinadas a consumidor final deste Estado, 
                        ou cuja saída a consumidor final deste Estado seja isenta ou não tributada;*/

                        /*Pelo contribuinte não varejista:
                        o montante do imposto presumido, que corresponderá ao valor obtido pela 
                        aplicação da alíquota interna sobre o valor da base de cálculo do débito de substituição tributária, 
                        informado nos documentos fiscais de aquisição das mercadorias submetidas ao regime de substituição tributária que 
                        foram objeto de operações de saídas destinadas a consumidor final deste Estado, exceto se isentas ou não tributadas.*/
                        
                      //Quando ICMS ST BASNDES calcular pela Base de ICMS Retido Ant.
                    
                        IF SD1->D1_BASNDES > 0 
                            nValorPro := ((SD1->D1_BASNDES * nAliqST) / 100) /nQtdadePro                   
                        Else                        
                            nValorPro := ((SD1->D1_BRICMS * nAliqST) / 100) /nQtdadePro
                        Endif  

                    EndIf   

                    
                    nRetorno   := nValorPro
                    
                    dbSelectArea("SF1")
                    SF1->(dbSetOrder(1))
                    SF1->(MsSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO))
                    cChvNFE := SF1->F1_CHVNFE
                    cEspecie := SF1->F1_ESPECIE

                    aAdd(aSldVlrDet,{   SD1->D1_DOC,;
                                        SD1->D1_SERIE,;
                                        SD1->D1_FORNECE,;
                                        SD1->D1_LOJA,;
                                        SD1->D1_ITEM,;
                                        SD1->D1_COD,; 
                                        nQtdadePro,; 
                                        Round((nValorPro*nQtdadePro),2),;
                                        nValorPro,;
                                        SD1->D1_LOTECTL,; //10
                                        "E",;
                                        SD1->D1_DTDIGIT,; //12
                                        cChvNFE,;
                                        cEspecie})
                EndIf
            EndIf
        EndIf

    ElseIf cTipoProc == 'M' .Or. cTipoProc == 'U'
        cFrmRegra1 := RetSqlName( "SD1" ) + " SD1"

        cFrmRegra2 := RetSqlName( "SD1" ) + " SD1" +;
            " INNER JOIN " + RetSQLName("SFT") + " SFT ON (SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "' AND SD1.D1_DOC = SFT.FT_NFISCAL AND SD1.D1_SERIE = SFT.FT_SERIE AND SD1.D1_FORNECE = SFT.FT_CLIEFOR AND SD1.D1_LOJA = SFT.FT_LOJA AND SD1.D1_ITEM = SFT.FT_ITEM AND SFT.D_E_L_E_T_ = ' ') "

        cSlcRegra := "SD1.D1_DOC," + CRLF +;
            "SD1.D1_SERIE," + CRLF +;
            "SD1.D1_FORNECE," + CRLF +;
            "SD1.D1_LOJA," + CRLF +;
            "SD1.D1_ITEM," + CRLF +;
            "SD1.D1_COD," + CRLF +;
            "SD1.D1_ALIQSOL," + CRLF +;
            "SD1.D1_ALQNDES," + CRLF +;
            "SD1.D1_LOTECTL," + CRLF +;
            "SD1.D1_DTDIGIT," + CRLF +;
            "SD1.D1_PICM," + CRLF +;
            "SD1.D1_BASNDES," + CRLF +;
            "SD1.D1_BRICMS," + CRLF +;
            "SFT.FT_VALICM," + CRLF +;
            "SFT.FT_CLASFIS," + CRLF +;
            "SFT.FT_CHVNFE," + CRLF +;
            "SFT.FT_ESPECIE," + CRLF +;
            "SFT.FT_NRLIVRO," + CRLF +;
            "(CASE WHEN SD1.D1_BASEICM > 0 THEN SD1.D1_BASEICM ELSE (SD1.D1_TOTAL + SD1.D1_VALFRE + SD1.D1_SEGURO + SD1.D1_DESPESA - SD1.D1_VALDESC) END) AS BASE," + CRLF +;
            "SD1.D1_QUANT    AS QUANT," + CRLF +;
            "SD1.D1_VALICM   AS VLICMS," + CRLF +;
            "(CASE WHEN SD1.D1_ICMSRET > 0 THEN (SD1.D1_ICMSRET) ELSE (SD1.D1_ICMNDES) END)  AS VLICMSST
        If lUsaRegra
            If cSGBD = 'ORACLE'
                cSubStrBD := 'SUBSTR(SD1.D1_CLASFIS,2,2)'
            Else
                cSubStrBD := 'RIGHT(SD1.D1_CLASFIS,2)'
            EndIf

            cJoinCFOP := " INNER JOIN " + RetSQLName("F2W") + " F2W ON (F2W.F2W_FILIAL = '" + xFilial( "F2W" ) + "' AND F2W.F2W_CFOP = SD1.D1_CF AND F2W.D_E_L_E_T_ = ' ') " +;
                "INNER JOIN " + RetSQLName("F3M") + " F3M ON (F3M.F3M_FILIAL = '" + xFilial( "F3M" ) + "' AND F3M.F3M_IDF2W = F2W.F2W_IDTAB AND F3M.F3M_CSTICM = " + cSubStrBD + " AND F3M.D_E_L_E_T_ = ' ') "
        EndIf

        cSlcRegra := "%" + cSlcRegra + "%"
        cFrmRegra1 := "%" + cFrmRegra1 + cJoinCFOP + "%"
        cFrmRegra2 := "%" + cFrmRegra2 + cJoinCFOP + "%"
    
        //Ajusta a quantidade de procura para 1, pois precisa processar apenas a ultima nota encontrada.
        If cTipoProc == 'U'
            nQtdade := 1
        EndIf

        //Verifica se existe quantidade suficiente na movimentação de entrada para compor valores para o produto
        BeginSql Alias cAlias
        COLUMN D1_DTDIGIT AS DATE

            SELECT SUM(SD1.D1_QUANT) QUANT
            FROM %Exp:cFrmRegra1%
            WHERE  SD1.D1_FILIAL=%XFILIAL:SD1%       
            AND    SD1.D1_COD = %EXP:cCodProd%   
            AND    SD1.D1_TIPO NOT IN('B','D','P','I','C')
            AND    SD1.D1_NFORI = ' ' 
            AND    SD1.D1_SERIORI = ' ' 
            AND    SD1.D1_ITEMORI = ' ' 
            AND    SD1.D1_FORMUL <> 'S'              
            AND    SD1.D1_DTDIGIT BETWEEN %Exp:dDtLimit% AND %EXP:dDataAte%            
            AND    SD1.%NOTDEL%	
        EndSql

        dbSelectArea(cAlias)
        If (cAlias)->QUANT >= nQtdade
            lAchouFT := .T.	
        EndIf
        (cAlias)->(dbCloseArea()) 

        If lAchouFT            
            While nQtdade > 0
                cAliasSD1 := GetNextAlias()

                BeginSql Alias cAliasSD1
                COLUMN D1_DTDIGIT AS DATE
                
                    SELECT 
                        %Exp:cSlcRegra%
                    FROM
                        %Exp:cFrmRegra2%
                    WHERE   SD1.D1_FILIAL   = %XFILIAL:SD1%
                    AND     SD1.D1_COD      = %EXP:cCodProd%
                    AND     SD1.D1_TIPO     NOT IN('B','D','P','I','C')
                    AND     SD1.D1_NFORI    = ' ' 
                    AND     SD1.D1_SERIORI  = ' ' 
                    AND     SD1.D1_ITEMORI  = ' ' 
                    AND     SD1.D1_FORMUL   <> 'S'
                    AND     SD1.D1_DTDIGIT BETWEEN %Exp:dDtLimit% AND %EXP:dDataAte%               
                    AND     SD1.%NOTDEL%
                    ORDER BY SD1.D1_DTDIGIT DESC, SD1.D1_NUMSEQ DESC
                EndSql

                DbSelectArea(cAliasSD1)
                While !(cAliasSD1)->(Eof()) .And. nQtdade > 0

                    //Quando operação indireta considera aliquota do produto
                    If (cAliasSD1)->D1_ALQNDES > 0 
                        //Casos tenha sido informado aliquota do recolhimento anterior, utiliza esta aliquota para calculo.
                        nAliqST := (cAliasSD1)->D1_ALQNDES
                    Else
                        nAliqST := (cAliasSD1)->D1_ALIQSOL
                    Endif
                        
                    // Caso a aliquota esteja zerada buscar pelos cadastros 
                    If nAliqST == 0 .And. SB1->(MsSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
                        nAliqST := SB1->B1_PICM
                        If nAliqST == 0 
                            nAliqST := nMVICMPAD
                        EndIf 
                    EndIf
                    
                    If !lApurBase
                        // Atribui o percentual de ICMS informado no nocumento, caso não exista utiliza a aliquota definida para o ST. 
                        // Isso ocorre com fornecedor substituido, onde não há aliquota de calculo pelo fato de não existir ICMS
                        nAliqICMS := Iif((cAliasSD1)->D1_PICM > 0, (cAliasSD1)->D1_PICM, nAliqST)
    
                        //Caso o valor do ICMS não estaja informado no documento faz o calculo considerando a base e aliquota.                    
                        If (cAliasSD1)->VLICMS > 0
                            nVlrICMS := (cAliasSD1)->VLICMS
                        Else
                            nVlrICMS := (((cAliasSD1)->BASE * nAliqICMS) / 100)
                        EndIf

                        cCST := Substr((cAliasSD1)->FT_CLASFIS,2,3)
                        nVlrICMS := IiF((cAliasSD1)->FT_VALICM == 0 .and. cCST =='10',nVlrICMS,(cAliasSD1)->FT_VALICM)
                        
                        nVlrICMS += (cAliasSD1)->VLICMSST
                    Else 
                        //Rio Grande do Sul
                        /*Pelo contribuinte varejista:
                        a) o montante do imposto presumido, que corresponderá ao valor obtido pela aplicação da alíquota interna sobre o valor da base de cálculo utilizada para o cálculo
                        do débito de responsabilidade por substituição tributária, informado nos documentos fiscais de aquisição das mercadorias, 
                        deduzido o valor correspondente às mercadorias que não sejam objeto de saídas destinadas a consumidor final deste Estado, 
                        ou cuja saída a consumidor final deste Estado seja isenta ou não tributada;*/

                        /*Pelo contribuinte não varejista:
                        o montante do imposto presumido, que corresponderá ao valor obtido pela 
                        aplicação da alíquota interna sobre o valor da base de cálculo do débito de substituição tributária, 
                        informado nos documentos fiscais de aquisição das mercadorias submetidas ao regime de substituição tributária que 
                        foram objeto de operações de saídas destinadas a consumidor final deste Estado, exceto se isentas ou não tributadas.*/
                        
                      //Quando ICMS ST BASNDES calcular pela Base de ICMS Retido Ant.
                    
                        IF (cAliasSD1)->D1_BASNDES > 0 
                            nVlrICMS := (((cAliasSD1)->D1_BASNDES * nAliqST) / 100)                       
                        Else                        
                            nVlrICMS := (((cAliasSD1)->D1_BRICMS * nAliqST) / 100)
                        Endif                        
                    EndIf                                                                              
    
                    If (cAliasSD1)->QUANT <= nQtdade
                        nValorPro  := nVlrICMS
                        nQtdadePro := (cAliasSD1)->QUANT
                    Else
                        nValorPro  := (nVlrICMS / (cAliasSD1)->QUANT) * nQtdade
                        nQtdadePro := nQtdade
                    EndIf

                    nRetorno += Round((nValorPro/nQtdadePro),2)
                    nQtdade  -= nQtdadePro

                    aAdd(aSldVlrDet,{   (cAliasSD1)->D1_DOC,; //1
                                        (cAliasSD1)->D1_SERIE,; 
                                        (cAliasSD1)->D1_FORNECE,;
                                        (cAliasSD1)->D1_LOJA,;
                                        (cAliasSD1)->D1_ITEM,;//5
                                        (cAliasSD1)->D1_COD,; 
                                        nQtdadePro,; //7
                                        Round((nValorPro/nQtdadePro),2),;
                                        nValorPro,;
                                        (cAliasSD1)->D1_LOTECTL,; //10
                                        "E",;
                                        (cAliasSD1)->D1_DTDIGIT,;
                                        (cAliasSD1)->FT_CHVNFE,;
                                        (cAliasSD1)->FT_ESPECIE})



                    (cAliasSD1)->(dbSkip())
                EndDo
                (cAliasSD1)->(dbCloseArea()) 

                //---Período Anterior---//
                dDataDe	 := FirstDay(dDataDe-1)
                dDataAte := LastDay(dDataDe)
            EndDo

        EndIf

    EndIf

    Self:nVlrICMSUnit   := nRetorno
    Self:aSldVlrDet     := aSldVlrDet

    RestArea(aArea)

Return



//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClearEntrada() FISA197MOVIMENTO
  
Método que Limpa dados da nota de entrada procesada

@author Eduardo Vicente da Silva
@since 22/01/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Method ClearEntrada() Class FISA197MOVIMENTO
    Self:nVlrICMSUnit   := 0
    Self:aSldVlrDet     := {}
Return


Method SetlApurBase(value) Class FISA197MOVIMENTO
    Self:lApurBase := value
Return

Method GetlApurBase() Class FISA197MOVIMENTO
Return Self:lApurBase

Method SetlUsaRegra(value) Class FISA197MOVIMENTO
    Self:lUsaRegra := value
Return
