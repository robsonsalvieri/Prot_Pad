#include "PROTHEUS.CH"
/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  Ё PLIMPWEB  ╨Autor  ЁAngelo Sperandio    ╨ Data Ё  29/03/05   ╨╠╠
╠╠лммммммммммьмммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Ponto de entrada para impressao de guias incluidas via WEB  ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                          ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

User Function PLIMPWEB()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Recebe parametros                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private lImpGui := paramixb[1]
Private cGuia   := paramixb[2]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis - pergunte()                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private cMatric
Private cRda
Private dDatRef
Private cTipImp
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa parametros do relatorio                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private cRelDir     := GetMv("MV_RELT") 
Private cTamanho    := "P"
Private cTitulo     := "Impressao de Guias via WEB"
Private cDesc1      := "Emite a relacao de guias incluidas via WEB"
Private cDesc2      := ""
Private cDesc3      := ""
Private cAlias      := "BEA"
Private cPerg       := "PLIMPW"
Private nRel        := "PLIMPWEB"
Private lCompres    := .F.
Private lDicion     := .F.
Private lFiltro     := .T.
Private lCrystal    := .F.
Private aOrderns    := {}
Private aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }
Private nLi         := 0
Private lRet        := .T.
Private aGuia       := {}
Private aCab        := {}
Private aIte        := {}
Private aCri        := {}
Private aCam        := {}
Private lGerTxt     := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Solicita parametros                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  FunName() == "PLIMPWEB"
    lGerTxt := .T.
    Pergunte(cPerg,.T.)
Else
    Pergunte(cPerg,.F.)
Endif    
cMatric   := mv_par01
cRda      := mv_par02
dDatRef   := mv_par03
cTipImp   := mv_par04
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta array com guias                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLMonta(cMatric)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Caso seja para nao imprimir a guia, encerra o programa retornando        Ё
//Ё o array com as guias                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  ! lImpGui
    Return({lRet,"",aGuia})
Endif    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama SetPrint                                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nRel := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal,,lGerTXT)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Configura impressora                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetPrintFile(nRel)
SetDefault(aReturn,cAlias)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Emite relat╒rio                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLImp()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera filtro                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ms_flush()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//If  lGerTXT
//	RmvToken(cRelDir+nrel+".##R",aDados[7])
//EndIF
Return()

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё PLMonta  Ё Autor Ё Angelo Sperandio      Ё Data Ё 29.03.05 Ё╠╠
╠╠цдддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Gera array com guias incluidas via web                     Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
/*/

Static Function PLMonta(cMat)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local   cFor
Local   cOrdem
Local   cInd    := CriaTrab(Nil,.F.)
Local   cOper   
Local   cCodEmp 
Local   cTipReg 
Local   cMatM   

BA1->( DbSetOrder(5) )                      	
If BA1->( MsSeek(xFilial("BA1")+cMat) )
   cMat := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
EndIf

aRet := PLSDADUSR(cMat,'1',.F.,dDatabase)
If aRet[1]
	cOper   := substr(aRet[2], 1,4)
	cCodEmp := substr(aRet[2], 5,4)
	cTipReg := substr(aRet[2],15,2)
	cMatM   := substr(aRet[2], 9,6) 
Else
	lRet := .F.	
	Return()
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta indregua                                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFor := "BEA_FILIAL = '" + xFilial("BEA") + "' .And. "
cFor += "BEA_OPEUSR = '" + cOper          + "' .And. "
cFor += "BEA_CODEMP = '" + cCodEmp        + "' .And. "
cFor += "BEA_MATRIC = '" + cMatM          + "' .And. "
cFor += "BEA_TIPREG = '" + cTipReg        + "' .And. "
cFor += "BEA_CODRDA = '" + cRda           + "' .And. "
cFor += "BEA_ORIGEM = '1' .And. "
cFor += "(BEA_TIPO = '1' .or. BEA_TIPO = '2')   .And. "
cFor += "dtos(BEA_DTDIGI) = '" + dtos(dDatRef)  + "' "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta ordem                                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cOrdem := "BEA_FILIAL+BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_CODRDA+dtos(BEA_DTDIGI)"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Indregua no BEA                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BEA->(IndRegua("BEA",cInd,cOrdem,nil,cFor,nil,.T.))
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona indices                                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BE2->(dbSetOrder(1))
BB0->(dbSetOrder(1))
BR8->(dbSetOrder(1))         
BD6->(DbSetOrder(1))
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processa guias                                                              Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ! BEA->(Eof())
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Posiciona BB0-Profissionais de Saude                                     Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If  ! Empty(BEA->BEA_CDPFSO)
       BB0->(dbSeek(xFilial("BB0")+BEA->BEA_CDPFSO))
   Endif   
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Monta cabecalho da guia                                                  Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   aCab := {}
   aIte := {}
   aadd(aCab,{"MATRIC","C",BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)})   
   aadd(aCab,{"NOMUSR","C",BEA->BEA_NOMUSR})   
   If  ! Empty(BEA->BEA_CDPFSO)
       aadd(aCab,{"CODREQ","C",BB0->BB0_CODORI})   
       aadd(aCab,{"NOMREQ","C",BB0->BB0_NOME  })   
   Else
       aadd(aCab,{"CODREQ","C",""})   
       aadd(aCab,{"NOMREQ","C",""})   
   Endif   
   aadd(aCab,{"CODRDA","C",BEA->BEA_CODRDA})   
   aadd(aCab,{"NOMRDA","C",BEA->BEA_NOMRDA})   
   aadd(aCab,{"DATPRO","D",BEA->BEA_DATPRO})   
   aadd(aCab,{"HORPRO","C",BEA->BEA_HORPRO})   
   aadd(aCab,{"CID"   ,"C",BEA->BEA_CID   })   
   aadd(aCab,{"NUMGUI","C",BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)})   
   aadd(aCab,{"TIPO"  ,"C",If(BEA->BEA_TIPO=="1","CONSULTA","SADT")})   
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Posiciona BE2-Itens da Guia                                              Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   cChaBE2 := xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
   BE2->(dbSeek(cChaBE2))
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Processa itens da guia                                                   Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   While ! BE2->(Eof()) .And. BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == cChaBE2
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Inicializa variaveis                                                     Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      aCam := {}
      aCri := {}        
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Posiciona BR8-Tabela Padrao                                              Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      BR8->(dbSeek(xFilial("BR8")+BE2->(BE2_CODPAD+BE2_CODPRO)))
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Posiciona do evento do contas medicas p buscar seu valor de PF           Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      BD6->(DbSeek(xFilial("BD6")+BE2->(BE2_OPEMOV+BE2_CODLDP+BE2_CODPEG+BE2_NUMERO)+BEA->BEA_ORIMOV))
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Monta itens da guia                                                      Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      aadd(aCam,{"STATUS","C",BE2->BE2_STATUS})
      aadd(aCam,{"SEQUEN","C",BE2->BE2_SEQUEN})
      aadd(aCam,{"CODPRO","C",BE2->BE2_CODPRO})
      aadd(aCam,{"DESPRO","C",BE2->BE2_DESPRO})
      aadd(aCam,{"QTDPRO","N",BE2->BE2_QTDPRO})
      aadd(aCam,{"VLRTPF","N",BD6->BD6_VLRTPF})
      aadd(aCam,{"CODTAB","C",BD6->BD6_CODTAB})
      If  BE2->BE2_STATUS <> "1"
          BEG->(DbSetOrder(1))
          If  BEG->(DbSeek(xFilial("BEG")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)+BE2->BE2_SEQUEN))
              While ! BEG->(Eof()) .And. BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == ;
                                          xFilial("BEG")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)+BE2->BE2_SEQUEN
                 aadd(aCri,{"SEQUEN","C",BE2->BE2_SEQUEN})
                 aadd(aCri,{"CODGLO","C",BEG->BEG_CODGLO})
                 aadd(aCri,{"DESGLO","C",BEG->BEG_DESGLO})
                 aadd(aCri,{"INFGLO","C",BEG->BEG_INFGLO})
                 BEG->(DbSkip())
              Enddo
          Endif         
      Endif   
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Salva item no array da guia                                              Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      aadd(aIte,{aCam,aCri})
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Acessa proximo registro                                                  Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      BE2->(dbSkip())
   Enddo
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Salva guia no array                                                      Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   aadd(aGuia,{aCab,aIte})
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Acessa proximo registro                                                  Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   BEA->(DbSkip())
Enddo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera impressao                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BEA->(dbClearFilter())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validacao se achou alguma guia											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aGuia) == 0
   lRet := .F.
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё PLImp    Ё Autor Ё Angelo Sperandio      Ё Data Ё 29.03.05 Ё╠╠
╠╠цдддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Gera relatorio com guias incluidas via web                 Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/

Static Function PLImp()
LOCAL I := 0
LOCAL G := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For g := 1 to len(aGuia)
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Imprime cabecalho da guia                                                   Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    aCab   := aGuia[g,1]
    cMATRIC := Eval( { || nPos := Ascan(aCab,{|x| x[1] = "MATRIC"}), IF(nPos>0,aCab[nPos,3],"") })
    cNOMUSR := Eval( { || nPos := Ascan(aCab,{|x| x[1] = "NOMUSR"}), IF(nPos>0,aCab[nPos,3],"") })
    cCODREQ := Eval( { || nPos := Ascan(aCab,{|x| x[1] = "CODREQ"}), IF(nPos>0,aCab[nPos,3],"") })
    cNOMREQ := Eval( { || nPos := Ascan(aCab,{|x| x[1] = "NOMREQ"}), IF(nPos>0,aCab[nPos,3],"") })
    cCODRDA := Eval( { || nPos := Ascan(aCab,{|x| x[1] = "CODRDA"}), IF(nPos>0,aCab[nPos,3],"") })
    cNOMRDA := Eval( { || nPos := Ascan(aCab,{|x| x[1] = "NOMRDA"}), IF(nPos>0,aCab[nPos,3],"") })
    dDATPRO := Eval( { || nPos := Ascan(aCab,{|x| x[1] = "DATPRO"}), IF(nPos>0,aCab[nPos,3],"") })
    cHORPRO := Eval( { || nPos := Ascan(aCab,{|x| x[1] = "HORPRO"}), IF(nPos>0,aCab[nPos,3],"") })
    cCID    := Eval( { || nPos := Ascan(aCab,{|x| x[1] = "CID"   }), IF(nPos>0,aCab[nPos,3],"") })

    cLinha := "COMPROVANTE DE AUTORIZACAO"
    @ nLi++, 0 pSay cLinha
    cLinha := "DE SERVICOS MEDICOS"
    @ nLi++, 0 pSay cLinha
    cLinha := "Numero Transacao: " 
    @ nLi++, 0 pSay cLinha
    nLi++
    cLinha := "Beneficiario: " + transform(cMATRIC,"@R !!!!.!!!!.!!!!!!.!!-!")
    @ nLi++, 0 pSay cLinha
    cLinha := cNOMUSR
    @ nLi++, 0 pSay cLinha
    cLinha := "Requisitante: " + transform(cCODREQ,"@R !!!.!!!!!!!!-!")
    @ nLi++, 0 pSay cLinha
    cLinha := cNOMREQ
    @ nLi++, 0 pSay cLinha
    cLinha := "Prestador: " + transform(cCODRDA,"@R !!!!!!")
    @ nLi++, 0 pSay cLinha
    cLinha := cNOMRDA
    @ nLi++, 0 pSay cLinha
    cLinha := "Data: " + dtoc(dDATPRO) + "   Horario: " + transform(cHORPRO,"@R !!:!!") + " CID: " + cCID
    @ nLi++, 0 pSay cLinha
    nLi++
    cLinha := "Servido/Qtd"
    @ nLi++, 0 pSay cLinha
    nLi++
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Imprime itens da guia                                                       Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    aIte  := aGuia[g,2]
    For i := 1 to len(aIte)
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Busca campos                                                             Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       aCam := aIte[i,1]
       cSEQUEN := Eval( { || nPos := Ascan(aCam,{|x| x[1] = "SEQUEN"}), IF(nPos>0,aCam[nPos,3],"") })
       cCODPRO := Eval( { || nPos := Ascan(aCam,{|x| x[1] = "CODPRO"}), IF(nPos>0,aCam[nPos,3],"") })
       cDESPRO := Eval( { || nPos := Ascan(aCam,{|x| x[1] = "DESPRO"}), IF(nPos>0,aCam[nPos,3],"") })
       nQTDPRO := Eval( { || nPos := Ascan(aCam,{|x| x[1] = "QTDPRO"}), IF(nPos>0,aCam[nPos,3],0 ) })
       cVLRTPF := Eval( { || nPos := Ascan(aCam,{|x| x[1] = "VLRTPF"}), IF(nPos>0,aCam[nPos,3],0 ) })
       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Posiciona BE2-Itens da Guia                                              Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       cLinha := substr(cCODPRO,1,8) + "/" + strzero(nQTDPRO,2) + " " + substr(cDESPRO,1,30)
       @ nLi++, 0 pSay cLinha
    Next
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Imprime rodape da guia                                                   Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    nLi++
    cLinha := "TRANSACAO NEGADA"
    @ nLi++, 0 pSay cLinha
    nLi++
    nLi++
    nLi++
Next    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera impressao                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  aReturn[5] == 1
    Set Printer To
	IIF(!lGerTxt,OurSpool(nrel),.t.)
End
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim do Relat╒rio                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
