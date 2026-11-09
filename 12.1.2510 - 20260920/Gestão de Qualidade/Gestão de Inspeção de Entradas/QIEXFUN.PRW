#include "TOTVS.CH"
#include "QIEXFUN.CH"

#define  Confirma 1
#define  Redigita 2
#define  Abandona 3

/*/{Protheus.doc} QIEXFunAuxClass
Classe agrupadora de mÈtodos auxiliares do SIGAQIE
@author rafael.kleestadt
@since 07/12/2022
@version 1.0
/*/
CLASS QIEXFunAuxClass FROM LongNameClass

    METHOD new() Constructor
    METHOD PosicionaNaQEGeRetornaCategoriaMaisProximaDoIQFEncontrado(nIQFSup, nIQSFornec, nMVIdioma)
    
ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@since 07/12/2022
@version 1.0
@param param_name, param_type, param_descr
@return Self, objeto, instancia da Classe QIEXFunAuxClass
/*/
METHOD new() CLASS QIEXFunAuxClass
Return Self

/*/{Protheus.doc} PosicionaNaQEGeRetornaCategoriaMaisProximaDoIQFEncontrado
//Posiciona QEG (Sit. Produto X Fornecedor) no valor mais prÛximo do IQF encontrado e retorna a classificao atual.
@author rafael.kleestadt
@since 07/12/2022
@version 1.0
@param nIQFSup, Numerico, IQF Superior
@param nIQSFornec, Numerico, Nota IQS definida para o fornecedor
@param nMVIdioma, Numerico, Idioma para impress„o da categoria 1=QEG_NIVEL(Por), 2=QEG_NIVING(Eng), 3=QEG_NIVESP(Esp)
@return cCategoria, caracter, categoria encontrada para o forncedor.
/*/
Method PosicionaNaQEGeRetornaCategoriaMaisProximaDoIQFEncontrado(nIQFSup, nIQSFornec, nMVIdioma) CLASS QIEXFunAuxClass
Local cCategoria := ""
Local cQassIqs   := SuperGetMv("MV_QASSIQS",.F.,"N")
Local lIQSFornec := IIF(nIQSFornec == 0 .Or. nIQSFornec == 999.99, .F., .T.)

DbSelectArea("QEG")
QEG->(DbSetOrder(2)) //QEG_FILIAL+STR(QEG_IQI_S,6,2)
If QEG->(MsSeek(xFilial("QEG")+Str(nIQFSup,6,2),.T.))
	If QEG->QEG_CATEG == "1" .And. !lIQSFornec .And. cQassIqs == "N" 
		QEG->(dbSetOrder(1)) //QEG_FILIAL+QEG_SITU
		QEG->(MsSeek(xFilial("QEG")))
		While QEG->(!Eof()) .And. QEG->QEG_FILIAL == xFilial("QEG")
			If QEG->QEG_CATEG > "1"
				cCategoria := If(nMVIdioma==1,QEG->QEG_NIVEL,If(nMVIdioma==2,QEG->QEG_NIVING,QEG->QEG_NIVESP))
				Exit
			EndIf
			QEG->(dbSkip())
		EndDo
	Else
		cCategoria := If(nMVIdioma==1,QEG->QEG_NIVEL,If(nMVIdioma==2,QEG->QEG_NIVING,QEG->QEG_NIVESP))
		EndIf
EndIf
	
Return cCategoria

/* 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥ QIEXFUN  ≥ Autor ≥ Vera Lucia S. Simoes  ≥ Data ≥ 18/02/98 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ 															  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso		 ≥ Generico 												  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ STR		 ≥ 															  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥			ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL.			  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Programador ≥ Data	≥ BOPS ≥  Motivo da Alteracao 					  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Paulo Emidio≥17/07/00≥------≥ Retirada da funcao QIEXDEER.			  ≥±±
±±≥Paulo Emidio≥17/07/00≥------≥ Criacao da Funcao qRetApeNom.	          ≥±±
±±≥Paulo Emidio≥20/09/00≥------≥ Remocao da funcao QE_CHKSIX().		  	  ≥±±
±±≥Cleber Souza≥20/05/03≥------≥ AlteraÁ„o na rotina qAtuPlAmEn para que a≥±±
±±≥            ≥        ≥------≥ mesma identifique notas de Dev./Benef.   ≥±±
±±≥            ≥        ≥------≥ e geraÁ„o da tabela QF6 (Prod x Cliente) ≥±±
±±≥            ≥        ≥------≥ AlteraÁ„o na rotina qComMovPAE para que a≥±±
±±≥            ≥        ≥------≥ mesma identifique notas de Dev./Benef.   ≥±±
±±≥            ≥        ≥------≥ e geraÁ„o da tabela QF6 (Prod x Cliente) ≥±±
±±≥Cleber Souza≥06/08/03≥------≥ Criacao da funcao QAtuShelf().		  	  ≥±±
±±≥Cleber Souza≥07/08/03≥------≥ Criacao da funcao QJustTxt().		  	  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ QIEXDeFo ≥ Autor ≥ Vera Lucia S. Simoes  ≥ Data ≥ 05/06/98 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Mostra a Razao Social/Nome Reduzido do Fornecedor          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QIEXDeFo(ExpC1,ExpC2,ExpN1)                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpC1 = Codigo do Fornecedor                               ≥±±
±±≥          ≥ ExpC2 = Loja do Fornecedor                                 ≥±±
±±≥          ≥ ExpN1 = 1 para Razao Social                                ≥±±
±±≥          ≥         2 para Nome Reduzido                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function QIEXDeFo(cFor, cLojFor, nTipo)

Local cNome 

nTipo := Iif(nTipo==NIL,2,nTipo)
SA2->(dbSetOrder(1))

If cLojFor <> NIL
	SA2->(dbseek(xFilial("SA2")+cFor+cLojFor))
Else
	SA2->(dbseek(xFilial("SA2")+cFor))
EndIf	
cNome := Iif(nTipo==1,SA2->A2_NOME,SA2->A2_NREDUZ)
Return(cNome)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ QIEXDePr ≥ Autor ≥ Vera Lucia S. Simoes  ≥ Data ≥ 05/06/98 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Mostra a Descricao do Produto (ultima revisao) do QE6      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QIEXDePr(ExpC1,ExpN1)                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpC1 = Codigo do Produto                                  ≥±±
±±≥          ≥ ExpN1 = Tamanho da Descricao                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function QIEXDePr(cPro, nTam)

nTam := If(nTam==NIL,Space(TamSX3("QE6_DESCPO")[1]),nTam)

QE6->(dbSetOrder(1))
QE6->(dbseek(xFilial("QE6") + cPro))
Return(QE6->QE6_DESCPO)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ QIEXDeEn ≥ Autor ≥ Vera Lucia S. Simoes  ≥ Data ≥ 05/06/98 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna a Descricao do Ensaio                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QIEXDeEn(ExpC1)                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpC1 = Codigo do Ensaio                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function QIEXDeEn(cEns)
Local cRet := Space(TamSX3("QEH_ENSAIO")[1])

QE1->(dbSetOrder(1))
If QE1->(dbseek(xFilial("QE1") + cEns))
	cRet := QE1->QE1_DESCPO
Endif	
Return(cRet)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ QIEXDeGr ≥ Autor ≥ Vera Lucia S. Simoes  ≥ Data ≥ 09/06/98 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna a Descricao do Grupo de Produtos                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QIEXDeGr(ExpC1)                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpC1 = Codigo do Grupo de Produtos                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function QIEXDeGr(cGrupo)
Local cRet := Space(TamSX3("QE3_DESCRI")[1])
                                                 
QE3->(dbSetOrder(1))
If QE3->(dbseek(xFilial("QE3") + cGrupo))
	cRet := QE3->QE3_DESCRI
Endif
Return(cRet)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo	 ≥ FQIE_USR ≥ Autor ≥ Marcos Cesar		    ≥ Data ≥ 28/12/98 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Verifica Pendencia das Permissoes de Uso e Follow-up NNCs  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function FQIE_USR()
Local nCount	  := 0
Local nCount1	  := 0
Local lReDemPU	  := .F.
Local lReDemFN	  := .F.
Local aArea := GetArea()
Local cMVQELAUSQ := GetMv("MV_QELAUSQ")

RestArea(aArea)


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ P.U.:                                                  ≥
//≥ Seleciona as PUs com status Em aberto. Se o Usuario da ≥
//≥ Qualidade ou os Destinatarios tiverem sido demitidos,  ≥
//≥ eles deverao ser substituidos. Isto devera ser feito   ≥
//≥ na opcao Transferencia de Pendencias, no menu Miscela- ≥
//≥ nea, por uma pessoa com nivel de acesso devido.        ≥
//≥ Se existir uma PU aberta que o emissor tiver sido demi-≥
//≥ tido, nao troca, porque fica como historico da PU.     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ	
QF3->(dbSetOrder(1))

dbSelectArea("QF2")
dbSetOrder(1)
dbSeek(xFilial("QF2"))

While !Eof() .And. QF2_FILIAL == xFilial("QF2")

	If QF2->QF2_STATUS == "E"	// Pu com status Em Aberto
	   	// Verifica se o Usuario da Qualidade esta demitido
		QAA->(dbSetOrder(1))
   		If 	QAA->(dbSeek(QF2->QF2_FILQLD+QF2->QF2_MATQLD)) .And. ;
   			! QA_SitFolh()
   			lReDemPU := .T.	
   			Exit
   		Else
   			// Verifica se os Destinatarios desta PU estao demitidos
  			If QF3->(dbSeek(xFilial("QF3")+QF2->QF2_FORNEC+QF2->QF2_LOJFOR+;
  						QF2->QF2_PRODUT+DtoS(QF2->QF2_DTENTR)+QF2->QF2_LOTE+;
  						QF2->QF2_NUMERO))
  					While QF3->QF3_FILIAL+QF3->QF3_FORNEC+QF3->QF3_LOJFOR+;
  							QF3->QF3_PRODUT+DtoS(QF3->QF3_DTENTR)+QF3->QF3_LOTE+;
  							QF3->QF3_NUMERO == xFilial("QF3")+QF2->QF2_FORNEC+;
  							QF2->QF2_LOJFOR+QF2->QF2_PRODUT+DtoS(QF2->QF2_DTENTR)+;
  							QF2->QF2_LOTE+	QF2->QF2_NUMERO .And. !QF3->(Eof())

					// Se o destinatario nao tiver dado laudo
					If QF3->QF3_STATUS == "E"
						QAA->(dbSetOrder(1))
	   					If 	QAA->(dbSeek(QF3->QF3_FILMAT+QF3->QF3_MAT)) .And. ;
   							! QA_SitFolh()
	   						lReDemPU := .T.	
   							Exit
   						EndIf	
   					EndIf	
   					QF3->(dbSkip())
   				EndDo	
			EndIf
		EndIf	
		EndIf
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Verifica se existem Pendencias para o Usuario Qual. (laudo) para Baixar ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If cMVQELAUSQ == "S" .And.;
			 QF2->QF2_STATUS == "P" .And. !lReDemPU
   	// Verifica se o Usuario da Qualidade esta demitido
		QAA->(dbSetOrder(1))
   		If 	QAA->(dbSeek(QF2->QF2_FILQLD+QF2->QF2_MATQLD)) .And. ;
   			! QA_SitFolh()
   			lReDemPU := .T.	
   			Exit
		EndIf
		EndIf
	
	dbSelectArea("QF2")
	dbSkip()
EndDo
   
If lReDemPU
	MessageDlg(STR0001+STR0006,,2)	//"Ha responsaveis demitidos associados a Equipes de Follow-up." #### "Execute a Transferencia de Pendencias, no menu Atualizacoes (Responsaveis) no ambiente de InspeÁ„o de Entradas."
EndIf	

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Follow-up de NNCs:                                     ≥
//≥ Verifica o arquivo de associacao de Responsaveis a     ≥
//≥ Equipes de Follow-up (QE5), e se algum foi demitido,   ≥
//≥ deve ser substituido.                                  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ	
QAA->(dbSetOrder(1))

QE5->(dbSetOrder(1))
QE5->(dbSeek(xFilial("QE5")))
While !QE5->(Eof())
	// Verifica se o Responsavel associado a equipe esta demitido
  	If 	QAA->(dbSeek(QE5->QE5_FILRES+QE5->QE5_RESPON)) .And. ;
  		! QA_SitFolh()
  		lReDemFN := .T.	
  		Exit
  	EndIf
  	QE5->(dbSkip())	
EndDo
   
If lReDemFN
	MessageDlg(STR0005 + STR0006,,2)	// "Ha responsaveis demitidos associados a Equipes de Follow-up."
EndIf

Return(nCount+nCount1)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ QIEXLdLU ≥ Autor ≥ Vera Lucia S. Simoes  ≥ Data ≥ 19/10/99 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna se o Laudo tem Categoria Liberado Urgente          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QIEXLdLU(ExpC1)                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpC1 = Laudo                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function QIEXLdLU(cLaudo)
Local lRet		:= .F.
Local nOrdQED	:= QED->(IndexOrd())

QED->(dbSetOrder(1))
QED->(dbSeek(xFilial("QED")+cLaudo))
If QED->QED_CATEG == "4"	// Liberado Urgente
	lRet := .T.
EndIf
QED->(dbSetOrder(nOrdQED))
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ QieAmoIni≥ Autor ≥ Paulo Emidio de Barros≥ Data ≥ 21/11/01 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Verifica se a Entrada a Inspecionar e Amostra Inicial 	  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QieAmoIni(EXPC1,EXPC2,EXPC3,EXPC4,EXPC5)					  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ EXPC1 = Codigo do Fornecedor								  ≥±±
±±≥          ≥ EXPC2 = Loja do Fornecedor								  ≥±±
±±≥          ≥ EXPC3 = Codigo do Produto								  ≥±±
±±≥          ≥ EXPC4 = Identificador invertido da Entrada a Inspecionar   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ EXPL1 = .T. = Amostra Inicial, .F. = Amostra Normal        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function QieAmoIni(cFornece,cLoja,cProduto,cIdeInv)
Local nQtdEnt  := 0
Local aAreaAnt := GetArea()
Local aAreaQEK := QEK->(GetArea())
Local lRetorno := .T.                              
Local cSeek    := ""

dbSelectArea("QEK") 
dbSetOrder(2)
If dbSeek(xFilial("QEK")+cFornece+cLoja+cProduto+cIdeInv)         
    cSeek   := QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_REVI
    While !Eof() .And. cSeek ==;
    	(QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_REVI)
    	If nQtdEnt > 1		
    		Exit   
		Elseif QEK->QEK_VERIFI == 1
	  	 	nQtdEnt++             
  	 	EndIf
	 	dbSkip()
	EndDo    	
EndIf                 

If nQtdEnt > 1
    lRetorno := .F.
EndIf
	
RestArea(aAreaQEK)
RestArea(aAreaAnt)
Return(lRetorno)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥QieSkpTst ≥ Autor ≥Paulo Emidio de Barros ≥ Data ≥17/01/2002≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Verifica se o ensaio selecionado no Laboratorio corrente,  ≥±±
±±≥			 ≥ sera aplicado o Skip-Teste (Individual/Grupo)			  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QieSkpTst(EXPC1,EXPC2,EXPC3,EXPC4,EXPD1,EXPC5)			  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ EXPC1 = Codigo do Fornecedor 							  ≥±±
±±≥	 	     ≥ EXPC2 = Loja do Fornecedor								  ≥±±
±±≥	 		 ≥ EXPC3 = Codigo do Produto 								  ≥±±
±±≥	 		 ≥ EXPC4 = Ensaio Corrente 									  ≥±±
±±≥	 		 ≥ EXPD1 = Data da Entrada do Material 						  ≥±±
±±≥	 		 ≥ EXPC5 = Numero do Lote	 								  ≥±±
±±≥	 		 ≥ EXPL1 = Indica se o retorno do status do Skip-Teste sera   ≥±±
±±≥	 		 ≥         abreviado.									      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno	 ≥ EXPC1 = "Inspecionar"/"Certificar"/"N/A"					  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso		 ≥ Generico 												  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function QieSkpTst(cFornece,cLoja,cProduto,cEnsaio,dEntrada,cLote,lAbrev,cNiseri,cTipoNF)
Local cRetorno  := "N/A"
Local cGrupo    := ""
Local cSeek     := ""
Local cNotaF    := SubStr(cNiseri,1,TamSX3("QEK_NTFISC")[1])
Local cSeriNF   := SubStr(cNiseri,TamSX3("QEK_NTFISC")[1]+1,TamSX3("QEK_SERINF")[1])
Local cIteNF    := SubStr(cNiseri,TamSX3("QEK_NTFISC")[1]+TamSX3("QEK_SERINF")[1]+1,TamSX3("QEK_ITEMNF")[1])

Default lAbrev := .F.

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Pesquisa por Grupo 												≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
QEA->(dbSetOrder(2))

If QEA->(dbSeek(xFilial("QEA")+cProduto))
	cGrupo := QEA->QEA_GRUPO
EndIf

QEH->(dbSetOrder(1))
If QEH->(dbSeek(xFilial("QEH")+cFornece+cLoja+cProduto+cEnsaio))
	cRetorno := QieDescSkT(lAbrev,QEH->QEH_SKPTES,cFornece,cLoja,cProduto)
Else

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Verifica se existe skip-teste por grupo definido 			≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	QEI->(dbSetOrder(1))
	If QEI->(dbSeek(xFilial("QEI")+cFornece+cLoja+cGrupo+cEnsaio))

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Se a Entrada existe no historico, Ç porque Ç p/ inspecionar ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		cSeek   := xFilial("QEZ")+cFornece+cLoja+cProduto+cNotaF+cSeriNF+cIteNF+cTipoNF+cLote+cEnsaio
		QEZ->(dbSetOrder(3))
		If QEZ->(dbSeek(xFilial("QEZ")+cFornece+cLoja+cGrupo+dTos(dEntrada)+cLote+cEnsaio))
			If lAbrev 
				cRetorno := "CER"
			Else
				cRetorno := OemToAnsi(STR0008) //"Certificar"
			EndIf	
		Else
			cRetorno := QieDescSkT(lAbrev,QEI->QEI_SKPTES,cFornece,cLoja,cProduto)
		EndIf                                                                        
		EndIf
EndIf

Return(cRetorno)
                
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥qAtuPlAmEn≥ Autor ≥Paulo Emidio de Barros ≥ Data ≥17/01/2002≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Aplica o Plano de Amostragem por Ensaios					  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QAtuPlAmEn(EXPC1,EXPC2,EXPC3,EXPC4,EXPC5,EXPC6,EXPN1)	  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ EXPC1 = Codigo do Fornecedor 							  ≥±±
±±≥	 	     ≥ EXPC2 = Loja do Fornecedor								  ≥±±
±±≥	 		 ≥ EXPC3 = Codigo do Produto 								  ≥±±
±±≥	 		 ≥ EXPC4 = Revisao do Produto							 	  ≥±±
±±≥	 		 ≥ EXPC5 = Chave da Entrada a Inspecionar 	  				  ≥±±
±±≥	 		 ≥ EXPC6 = Tamanho da Amostra a Inspecionar					  ≥±±
±±≥	 		 ≥ EXPC1 = Tipo da Nota Fiscal								  ≥±±
±±≥	 		 ≥ EXPN1 = 1 = Inclui										  ≥±±
±±≥	 		 ≥         2 = Exclui										  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno	 ≥ NIL														  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso		 ≥ SIGAQIE													  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function qAtuPlAmEn(cFornece,cLoja,cProduto,cRevi,cChave,cTamAmo,cTipoNF,nOpcao)
Local nAce11    := 0
Local nRej11    := 0
Local nTamA11   := 0
Local nAce12    := 0
Local nRej12    := 0
Local nTamA12   := 0
Local cCondicao := ""
Local cTabela   := ""
Local cAlias    := ""
Local cCodNorma := ""
Local aAmostra  := {}

//Tratamento p/ o cliente Laboris
If cTipoNF$'BD'                                 
   cCondicao := "QF6_CLIENT+QF6_LOJCLI+QF6_PRODUT+QF6_REVI"
   cTabela   := "QF6"
   cAlias    := "QF6->QF6_"
Else
   cCondicao := "QF4_FORNEC+QF4_LOJFOR+QF4_PRODUT+QF4_REVI"
   cTabela   := "QF4"
   cAlias    := "QF4->QF4_"
EndIf

dbSelectArea(cTabela)
dbSetOrder(1)
dbSeek(xFilial(cTabela)+cFornece+cLoja+cProduto+cRevi,.T.)
While !Eof() .And. &(cAlias+"FILIAL") == xFilial(cTabela) .And.;
	(cFornece+cLoja+cProduto+cRevi) == &cCondicao
	
	If !Empty(&(cAlias+"PLAMO"))

		cCodNorma := QA_Plano(&(cAlias+"TIPAMO"))

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Realiza a atualizacao do Plano de Amostragem por Ensaios	≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If (nOpcao == 1) 
		       
			//Retorna a Amostra, Aceite e Rejeite, basendo-se na codificacao do Plano de Amostragem selecionado
			aAmostra := Qep_RetAmostra(&(cAlias+"TIPAMO"),&(cAlias+"PLAMO"),&(cAlias+"NIVEL") ,&(cAlias+"NQA"),cTamAmo,"QEK_TAMAMO",.F.)
		                                             
		    If &(cAlias+"TIPAMO") == "3" //Plano Interno                  
		    	//Obtem somente a primeira sequencia do Plano de Amostragem
		    	nTamA11  := aAmostra[1,3] 
				nAce11   := aAmostra[1,1]
				nRej11   := aAmostra[1,2]
				nTamA12  := aAmostra[1,6]
				nAce12   := aAmostra[1,4]
			  	nRej12   := aAmostra[1,5]
			Else	   
		    	nTamA11  := aAmostra[1]
				nAce11   := aAmostra[2]
				nRej11   := aAmostra[3]
				nTamA12  := aAmostra[4]
				nAce12   := aAmostra[5]
			  	nRej12   := aAmostra[6]
		    EndIf
		   
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Grava o Plano de Amostragem por Ensaio						≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			dbSelectArea("QF5")
			dbSetorder(2)
			If dbSeek(xFilial("QF5")+&(cAlias+"ENSAIO")+cChave)
			   	RecLock("QF5",.F.)                                                  
			Else
				RecLock("QF5",.T.)
			EndIf               
			QF5->QF5_FILIAL := xFilial("QF5")    
			QF5->QF5_FORNEC := cFornece
			QF5->QF5_LOJFOR := cLoja
			QF5->QF5_PRODUT := cProduto
			QF5->QF5_REVI   := cRevi
			QF5->QF5_CHAVE  := cChave
			QF5->QF5_ENSAIO := &(cAlias+"ENSAIO")
			QF5->QF5_TAMA1  := nTamA11
			QF5->QF5_ACEI1  := nAce11
			QF5->QF5_REJEI1 := nRej11
			QF5->QF5_TAMA2  := nTamA12
			QF5->QF5_ACEI2  := nAce12
			QF5->QF5_REJEI2 := nRej12
			QF5->QF5_TIPO   := cTipoNF
		    MsUnlock()
			
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Realiza a exclusao do Plano de Amostragem por Ensaios		≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		ElseIf (nOpcao == 2)

			dbSelectArea("QF5")
			dbSetorder(2)
			If dbSeek(xFilial("QF5")+&(cAlias+"ENSAIO")+cChave)
				RecLock("QF5",.F.)
				dbDelete()
				MsUnLock()
			EndIf	
					
		EndIf
		
		EndIf
	    
	dbSelectArea(cTabela)
	dbSetorder(1)
	dbSkip()	 
	
EndDo	

Return(NIL)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥QComMovPAE≥ Autor ≥Paulo Emidio de Barros ≥ Data ≥04/04/2002≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Compatibiliza o Plano de Amostragem por Ensaios de acordo  ≥±±
±±≥			 ≥ com a nova revisao do Produto x Fornecedor. 				  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QComMovPAE(cProduto,cRevAtu,aEnsAtu,lDelPAE,nOpc)		  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ EXPC1 = Codigo do Produto								  ≥±±
±±≥	 	     ≥ EXPC2 = Revisao atual do Produto							  ≥±±
±±≥	 	     ≥ EXPA1 = Vetor contendo os ensaios da Revisao atual		  ≥±±
±±≥	 	     ≥ EXPL1 = Indica se os Planos de Amostragens associados serao≥±±
±±≥	 	     ≥ 		   excluidos sem critica.							  ≥±±
±±≥	 	     ≥ EXPN1 = 1 = Inclui										  ≥±±
±±≥	 	     ≥ 		   2 = Exclui										  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno	 ≥ Nulo														  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso		 ≥ SIGAQIE													  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function QComMovPAE(cProduto,cRevAtu,aEnsAtu,lDelPAE,nOpc)
Local aAreaAnt   := GetArea()
Local nIniEns    := 0
Local cRevAnt    := ""
Local aRegistro  := {}
Local lContinua    
Local nY
Local cTab1      := ""
Local cCam1      := ""
Local cTab2      := ""
Local cCam2      := ""           
Local cPesq      := ""

lDelPAE := If(lDelPAE==NIL,.F.,lDelPAE)

//Armazena a revisao Anterior do Produto
cRevAnt := QieRevAnt(cProduto,cRevAtu)

If nOpc == 1 //Inclusao

	For nY:=1 to 2
		
		If nY==1
			cTab1 := "SA5"
			cCam1 := "SA5->A5_"
			cTab2 := "QF4"
			cCam2 := "QF4->QF4_"
			cPesq := "SA5->A5_FORNECE+SA5->A5_LOJA"
		Else
			cTab1 := "SA7"
			cCam1 := "SA7->A7_"
			cTab2 := "QF6"
			cCam2 := "QF6->QF6_"
			cPesq := "SA7->A7_CLIENTE+SA7->A7_LOJA"
		EndIf
		
		dbSelectArea(cTab1)
        dbSetOrder(2)
		dbSeek(xFilial(cTab1)+cProduto)
		While &(cCam1+"FILIAL") == xFilial(cTab1) .And. (&(cCam1+"PRODUTO") == cProduto)
			
			For nIniEns := 1 to Len(aEnsAtu)
				
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Grava a especificacao, somente se nao houver Entradas com o ≥
				//≥ Plano de Amostragem associado ao ensaio na revisao corrente.≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				aRegistro := Array(&(cTab2+"->(fCount())"))
					
				//Pesquisa a revisao anterior da Especificacao do Produto
				dbSelectArea(cTab2)
				dbSetOrder(3)
				If dbSeek(xFilial(cTab2)+cProduto+cRevAnt+aEnsAtu[nIniEns,1]+&(cPesq))
						
					//Armazena o registro do ensaio na revisao anterior
					Aeval(aRegistro,{|x,y|aRegistro[y]:=&(cTab2+"->"+FieldName(y))})
						
					//Pesquisa a revisao atual da Especificacao do Produto
					dbSelectArea(cTab2)
					dbSetOrder(3)
					If !dbSeek(xFilial(cTab2)+cProduto+cRevAtu+aEnsAtu[nIniEns,1]+&(cPesq))
							
						RecLock(cTab2,.T.)
						Aeval(aRegistro,{|x,y|FieldPut(FieldPos(FieldName(y)),aRegistro[y])})
							
						//Grava a revisao atual
						&(cCam2+"REVI") := cRevAtu
						MsUnLock()
					Else
						If aEnsAtu[nIniEns,2] //marcado para exclusao
							RecLock(cTab2,.F.)
							&(cTab2+"->(dbDelete())")
							MsUnLock()
						EndIf
					EndIf
						
				EndIf
					
			Next nIniEns
			
			dbSelectArea(cTab1)
            dbSkip()
		EndDo
	Next nY
	
ElseIf nOpc == 2 //Exclusao
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Exclue somente se nao houver Entradas associadas ao Plano de≥
	//≥ Amostragem por ensaios.										≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	
	For nY:=1 to 2
		
		If nY==1
			cTab1 := "SA5"
			cCam1 := "SA5->A5_"
			cTab2 := "QF4"
			cCam2 := "QF4->QF4_"
			cPesq := "SA5->A5_FORNECE+SA5->A5_LOJA"
		Else
			cTab1 := "SA7"
			cCam1 := "SA7->A7_"
			cTab2 := "QF6"
			cCam2 := "QF6->QF6_"
			cPesq := "SA7->A7_CLIENTE+SA7->A7_LOJA"
		EndIf
		
		dbSelectArea(cTab2)
		dbSetOrder(3)
		If dbSeek(xFilial(cTab2)+cProduto+cRevAtu)
			
			lContinua := .T.
			
			If cTab1 == "SA5"
				//Verifica o Historico referente as Notas Fiscais do Tipo Normal
				QF5->(dbSetOrder(5))
				If QF5->(dbSeek(xFilial("QF5")+&(cCam2+"PRODUT")+&(cCam2+"REVI")+"N"))
					If !lDelPAE
						lContinua := .F.
					EndIf
				EndIf
				
			Else
				//Verifica o Historico referente as Notas Fiscais do Tipo Devolucao
				QF5->(dbSetOrder(5))
				If QF5->(dbSeek(xFilial("QF5")+&(cCam2+"PRODUT")+&(cCam2+"REVI")+"D"))
					If !lDelPAE
						lContinua := .F.
					EndIf
				EndIf                                                                   
				
				//Verifica o Historico referente as Notas Fiscais do Tipo Beneficiamento
				If QF5->(dbSeek(xFilial("QF5")+&(cCam2+"PRODUT")+&(cCam2+"REVI")+"B"))
					If !lDelPAE
						lContinua := .F.
					EndIf
				EndIf
			EndIf
			
			While lContinua .And. &(cTab2+"->(!Eof())") .And. &(cCam2+"FILIAL") == xFilial(cTab2) .And.;
				&(cCam2+"PRODUT")+&(cCam2+"REVI") == (cProduto+cRevAtu)
				RecLock(cTab2,.F.)
				&(cTab2+"->(dbDelete())")
				MsUnLock()
				
				dbSelectArea(cTab2)
				dbSkip()
			EndDo
			
		EndIf
	Next nY
EndIf

RestArea(aAreaAnt)

Return(NIL)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥QieRevAnt ≥ Autor ≥Paulo Emidio de Barros ≥ Data ≥04/04/2002≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Retorna a revisao anterior da Especificacao do Produto.    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QieRevAnt(cProduto,cRevAtu)								  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ EXPC1 = Codigo do Produto								  ≥±±
±±≥	 	     ≥ EXPC2 = Revisao atual do Produto							  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno	 ≥ EXPC3 = Revisao anterior da Especificacao do Produto		  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso		 ≥ SIGAQIE													  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function QieRevAnt(cProduto,cRevAtu)
Local aAreaAnt := GetArea()
Local cRevAnt  := " "

dbSelectArea("QE6")
dbSetOrder(1)
If dbSeek(xFilial("QE6")+cProduto+Inverte(cRevAtu))
	dbSkip()
	If (QE6_FILIAL == xFilial("QE6")) .And. (QE6_PRODUT == cProduto)
		cRevAnt := QE6_REVI	
		EndIf
EndIf
                  
If Empty(cRevAnt)
	cRevAnt := cRevAtu
EndIf
	 
RestArea(aAreaAnt)

Return(cRevAnt)                            

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥QieAtuNNC ≥ Autor ≥Paulo Emidio de Barros ≥ Data ≥18/07/2002≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Realiza a Atualizacao das Notificacoes das nao-conformidades≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QieAtuNNC(nOpc)											  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ EXPN1 = 1) Inclusao da NNC								  ≥±±
±±≥			 ≥         2) Exclusao da NNC								  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno	 ≥ EXPC1 = Numero da Notificacao da nao-conformidade          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso		 ≥ SIGAQIE													  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function QieAtuNNC(nOpc,cProg)
Local cNNC      := QEK->QEK_NNC
Local aAreaQEM 
Local cChave
Local lBaixaNNC := GetMV("MV_QBXANNC")
Local lIntQNC   := If(GetMV("MV_QINTQNC")=="S",.T.,.F.)
Local cEspecie  := "QIEA220 "           
Local aTexto    := {}
Local cTexto    := '' 

Default cProg   := ""

If nOpc == 1 //Inclusao                 
	If Empty(cNNC) .OR. cProg == "QIER030"
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Caso nao exista a NNC, realiza a Atualizacao da mesma, o QEK≥ 
		//≥ devera estar posicionado.									≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		QEM->(dbSetOrder(1))
		If !QEM->(dbSeek(xFilial("QEM")+cNNC))
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Grava o Numero da Notificacao das nao-conformidades			≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			cNNC := QA_SEQU("QIE_NNCO" + Str(Year(dDataBase),4),TamSX3("QEK_NNC")[1],"S",OemToAnsi(STR0009))

			RecLock("QEK",.F.)
			QEK->QEK_NNC    := cNNC
			QEK->QEK_NNCINV := Right(cNNC,4)+Left(cNNC,7)
			MsUnlock()
			
			//Gera a chave da naotificacao da NNC
			aAreaQEM := QEM->(GetArea())
			cChave := QA_NewChave(,"QEM",2)
		    RestArea(aAreaQEM)   

			RecLock("QEM",.T.)
			QEM->QEM_FILIAL := xFilial("QEM")
			QEM->QEM_NNC    := cNNC
			QEM->QEM_DTNNC  := dDataBase
			QEM->QEM_FORNEC := QEK->QEK_FORNEC
			QEM->QEM_LOJFOR := QEK->QEK_LOJFOR
			QEM->QEM_PRODUT := QEK->QEK_PRODUT
			QEM->QEM_LOTE   := QEK->QEK_LOTE
			QEM->QEM_DTENTR := QEK->QEK_DTENTR
			QEM->QEM_GRUPO  := QEK->QEK_GRUPO
			QEM->QEM_CHAVE  := cChave
			MsUnLock()
			FkCommit()
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Realiza a baixa das Notificacoes das Nao-conformidades    	≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If lIntQNC //Verifica se existe integracao
			
				If lBaixaNNC //Verifica se as NNCs serao baixadas
				
					RecLock("QEM",.F.)
					QEM->QEM_DTRESP := dDataBase
					QEM->QEM_DTFECH := dDataBase
					MsUnLock()
					
					cTexto += OemToAnsi(STR0010) //"A Notificacao das Nao-conformidades apontadas no Lote :"
					cTexto += QEK->QEK_LOTE+OemToAnsi(STR0011) //", foi encerrada automaticamente pelo sistema,"
					cTexto += OemToAnsi(STR0012) //" as mesmas deverao ser tratadas atraves do modulo : "
					cTexto += OemToAnsi(STR0013) //"SIGAQNC(Controle de Nao-Confomidades)"				                               
					
					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥ Atualiza o texto das Notificacoes das NCs	  			 ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					Aadd(aTexto,{1,cTexto})
					QA_GrvTxt(cChave,cEspecie,1,@aTexto)    
				
				EndIf
			EndIf	
		EndIf     
		EndIf   
	
ElseIf nOpc == 2
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Realiza a exclusao das NNCs vinculadas					   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If !Empty(cNNC)
		dbSelectArea('QEM')
		dbSetOrder(1)
		dbSeek( xFilial("QEM")+cNNC)
		While !EOF() .And. QEM_FILIAL+QEM_NNC == xFilial("QEM")+cNNC

			//Exclui o Texto das observacoes da Notificacao das nao-conformidades
			If !Empty(QEM->QEM_CHAVE)                        
				QA_DelTxt(QEM->QEM_CHAVE,"QIEA220 ")   
			EndIf   
			
			//Elimina o Numero da Notificacao da NNC no cadastro das Entradas Inspecionadas
			RecLock("QEK",.F.)
			QEK->QEK_NNC    := " "
			QEK->QEK_NNCINV := " "
			MsUnLock()

			RecLock("QEM",.F.,.T.)
			dbDelete()
			MsUnLock()         
			
			dbSelectArea('QEM')
			dbSetorder(1)
			dbSkip()
			
		EndDo          
		EndIf
EndIf	

Return(cNNC)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥QieSkipLote≥ Autor ≥Paulo Emidio de Barros≥ Data ≥ 06/06/03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Aplica o Skip-Lote para as Entradas						  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QieSkipLote(cFornece,cLoja,cProduto,cGrupo,dEntrada,;  	  ≥±±
±±≥			 ≥ cLote,cDocEnt,aMsg)										  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ EXPC1 = Fornecedor                	 					  ≥±±
±±≥			 ≥ EXPC2 = Loja												  ≥±±
±±≥			 ≥ EXPC3 = Produto											  ≥±±
±±≥			 ≥ EXPC4 = Grupo											  ≥±±
±±≥			 ≥ EXPD1 = Data de Entradas								      ≥±±
±±≥			 ≥ EXPC5 = Numero do Lote									  ≥±±
±±≥			 ≥ EXPC6 = Documento de Entrada								  ≥±±
±±≥			 ≥ EXPA1 = Mensagens da Justificativa		  				  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno	 ≥ EXPL1 = .T. - Inspeciona .F. - Certifica			  		  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso		 ≥ SIGAQIE													  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function QieSkipLote(cFornece,cLoja,cProduto,cGrupo,dEntrada,cLote,cDocEnt,aMsg)
Local aAreaAnt    := GetArea()
Local aAreaQEK    := QEK->(GetArea())
Local aAreaSA5    := SA5->(GetArea())
Local cLabor      := Space(TamSX3("QEL_LABOR")[1])
Local nEntradas   := 0                   
Local nRecusadas  := 0
Local nEntIns     := 0
Local nVerifica   := 1  //Define se a Entrada atual sera Inspecionada
Local dLimite   
Local lContinua   := .F.
Local cSeek       := ""
Local cNiseri	  := ""
Local lQESEMSKPLT := ExistBlock("QESEMSKPLT")
aMsg := {}              

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Identifica a Aplicacao da Unidade do Skip-Lote				 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

//Posiciona na Amarracao Produto x Fornecedor
dbSelectArea("SA5")
dbSetOrder(2)
If dbSeek(xFilial("SA5")+cProduto+cFornece+cLoja)
	If !Empty(SA5->A5_SKPLOT)
		dbSelectArea("QEF")
		dbSetOrder(1)
		If MsSeek(xFilial("QEF")+SA5->A5_SKPLOT)
			lContinua := .T.	
	    EndIf                    
    EndIf
EndIf       
         
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Ponto de Entrada que executa ou nao a rotina de SkipLote	 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If lContinua .and. ExistBlock("QESEMSKPLT")
	lContinua := ExecBlock("QESEMSKPLT",.F.,.F.,{cFornece,cLoja,cProduto,dEntrada,cLote,cDocEnt,"I",QEF->QEF_UNSKLT})  
EndIf

If !lContinua
	//Restaura as areas correntes
	RestArea(aAreaQEK)
	RestArea(aAreaSA5)
	RestArea(aAreaAnt)
	Return(nVerifica)
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Identifica o Numero de Entradas a Inspecionar, referentes ao ≥
//≥ fator REJEITADO TOTALMENTE.									 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nEntIns := Fator("3",.F.) //Rejeitado Totalmente

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Controle por Documento de Entrada         					 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If QEF->QEF_UNSKLT == "L" 
	   
	//Verifica se nao ha Skip-Teste definido por Grupo
	QEI->(dbSetorder(1))
	If !QEI->(MsSeek(xFilial("QEI")+cFornece+cLoja+cGrupo))
		nEntradas  := 0
		nRecusadas := 1
	
		dbSelectArea("QEK")
		dbSetOrder(4)
		If MsSeek(xFilial("QEK")+cDocEnt+cFornece+cLoja+cProduto)
		
			nVerifica := 2 //Certifica a Entrada Atual
			While !Eof() .And. QEK_FILIAL==xFilial("QEK") .And. QEK_DOCENT==cDocEnt .And. QEK_FORNEC==cFornece .And. QEK_LOJFOR==cLoja .And. QEK_PRODUT==cProduto
	
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Ponto de Entrada que executa ou nao a rotina de SkipLote	 ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				If lQESEMSKPLT
					If !ExecBlock("QESEMSKPLT",.F.,.F.,{QEK_FORNEC,QEK_LOJFOR,QEK_PRODUT,QEK_DTENTR,QEK_LOTE,QEK_DOCENT,"P",QEF->QEF_UNSKLT})  
						QEK->(dbSkip())
						Loop
					EndIF
				EndIf
				
				//Posiciona no Laudo da Entrada Inspecionada	
				cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
				QEL->(dbSetOrder(3))
				cSeek  := (QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)+cNiseri+(QEK->(QEK_TIPONF+DtOS(QEK_DTENTR)+QEK_LOTE)))
				If QEL->(MsSeek(xFilial("QEL")+cSeek+cLabor))
		
					//Verifica se o fator do Laudo da Entrada possui Entradas a Inspecionar
					QED->(dbSetOrder(1))
					If QED->(dbSeek(xFilial("QED")+QEL->QEL_LAUDO))	       
						If QED->QED_ENTINS > 0 .And. nEntradas <= (QED->QED_ENTINS-1)
							nRecusadas := 2
							Exit
					    EndIf
					EndIf
				EndIf
	           
				nEntradas++ //Incrementa o numero de Entradas
	    	
				If nEntradas > 5
					Exit
				EndIf
	        	dbSkip()
			EndDo				
	    EndIf
	
	Else
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Controle por Lote (Documento de Entrada) - Grupo			 ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		dbSelectArea("QEA")
		dbSetOrder(1)
		MsSeek(xFilial("QEA")+cGrupo)
		While QEA_FILIAL==xFilial("QEA") .And. QEA_GRUPO==cGrupo .And. !Eof()
			dbSelectArea("QEK")
			dbSetOrder(4)
			If MsSeek(xFilial("QEK")+cDocEnt+cFornece+cLoja+QEA->QEA_PRODUT)
				nVerifica := 2
				Exit
		    EndIf 
			dbSkip()
		EndDo
		
		If nVerifica == 2
			nEntradas  := 0
			nRecusadas := 1
		
			dbSelectArea("QEK")
			dbSetOrder(4)
			While !Eof() .And. QEK_FILIAL==xFilial("QEK") .And. QEK_DOCENT==cDocEnt .And. QEK_FORNEC==cFornece .And. QEK_LOJFOR==cLoja 
				
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Ponto de Entrada que executa ou nao a rotina de SkipLote	 ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				If lQESEMSKPLT
					If !ExecBlock("QESEMSKPLT",.F.,.F.,{QEK_FORNEC,QEK_LOJFOR,QEK_PRODUT,QEK_DTENTR,QEK_LOTE,QEK_DOCENT,"P",QEF->QEF_UNSKLT})  
						QEK->(dbSkip())
						Loop
					EndIF
				EndIf
				
				QEA->(dbSetOrder(2))
				QEA->(MsSeek(xFilial("QEA")+QEK->QEK_PRODUT))
				If QEA->QEA_GRUPO<>cGrupo
					dbSkip()
					Loop
				EndIf
				cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
				QEL->(dbSetOrder(3))
				cSeek  := (QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)+cNiseri+QEK->(QEK_TIPONF+DtOS(QEK_DTENTR)+QEK_LOTE))
				If QEL->(MsSeek(xFilial("QEL")+cSeek+cLabor))

					//Verifica se o fator do Laudo da Entrada possui Entradas a Inspecionar
					QED->(dbSetOrder(1))
					If QED->(dbSeek(xFilial("QED")+QEL->QEL_LAUDO))	       
						If QED->QED_ENTINS > 0 .And. nEntradas <= (QED->QED_ENTINS-1)
							nRecusadas := 2
							Exit
					    EndIf
					EndIf
					
				EndIf

				nEntradas++
				If nEntradas > 5
					Exit
				EndIf
	            dbSkip()
			EndDo		
			
		EndIf
		EndIf

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Caso haja entradas anteriores com Laudo reprovados, a Entrada≥
	//≥ atual sera inspecionada.									 ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If nRecusadas > 1
		nVerifica := 1
		EndIf
    
Else
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Controle por Entradas ou Dias         						 ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	nEntradas  := 0 //contador de Entradas
	nRecusadas := 1 //contador de Entradas recusadas
	
	dbSelectArea("QEK")
	dbSetOrder(2)
	dbSeek(xFilial("QEK")+cFornece+cLoja+cProduto)	
	While QEK_FILIAL==xFilial("QEK") .And.	QEK_FORNEC==cFornece .And.;
		 QEK_LOJFOR==cLoja .And. QEK_PRODUT==cProduto	
	
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Ponto de Entrada que executa ou nao a rotina de SkipLote	 ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If lQESEMSKPLT
			If !ExecBlock("QESEMSKPLT",.F.,.F.,{QEK_FORNEC,QEK_LOJFOR,QEK_PRODUT,QEK_DTENTR,QEK_LOTE,QEK_DOCENT,"P",QEF->QEF_UNSKLT})  
				QEK->(dbSkip())
				Loop
			EndIF
		EndIf
		
		//Posiciona no Laudo da Entrada Inspecionada	
		QEL->(dbSetOrder(3))
		cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
		cSeek   := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+cNiseri+QEK_TIPONF+DtOS(QEK_DTENTR)+QEK_LOTE)
		If QEL->(MsSeek(xFilial("QEL")+cSeek+cLabor))

			//Verifica se o fator do Laudo da Entrada possui Entradas a Inspecionar
			QED->(dbSetOrder(1))
			If QED->(MsSeek(xFilial("QED")+QEL->QEL_LAUDO))	       
				If QED->QED_ENTINS > 0 .And. nEntradas <= (QED->QED_ENTINS-1)
					nRecusadas := 2
					Exit
			    EndIf
			EndIf
		EndIf
		nEntradas++ //Incrementa o numero de Entradas

		If nEntradas > nEntIns
			Exit
		EndIf
	    dbSkip()	
	    
	EndDo    
    
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Caso haja entradas anteriores com Laudo reprovados, a Entrada≥
	//≥ atual sera inspecionada.									 ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If nRecusadas  >  1
		nVerifica := 1
	Else	                      
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Controle por Unidade DIA									 ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If QEF->QEF_UNSKLT == "D" 
	                                    
			//Data limite para que a Entrada seja inspecionada novamente	                                	
			dLimite := (dEntrada-(QEF->QEF_QTDE-1))

			//Busca a Entrada com data anterior a Atual
			dbSelectArea("QEK")                  
			dbSetOrder(2)    
			MsSeek(xFilial("QEK")+cFornece+cLoja+cProduto)
			While !Eof() .And. QEK_FILIAL==xFilial("QEK") .And. QEK_FORNEC==cFornece .And. QEK_LOJFOR==cLoja .And. QEK_PRODUT==cProduto 
			
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Ponto de Entrada que executa ou nao a rotina de SkipLote	 ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				If lQESEMSKPLT
					If !ExecBlock("QESEMSKPLT",.F.,.F.,{QEK_FORNEC,QEK_LOJFOR,QEK_PRODUT,QEK_DTENTR,QEK_LOTE,QEK_DOCENT,"P",QEF->QEF_UNSKLT})  
						QEK->(dbSkip())
						Loop
					EndIF
				EndIf
	
				//Se nao houve Inspecao no Periodo, a Entrada atual sera Inspecionada
				If QEK_DTENTR < dLimite
					nVerifica := 1
					Exit
			    EndIf   
			                   
			    //Se houve inspecao no Periodo,  a Entrada atual sera Certificada
			    If QEK_VERIFI <> 2
			    	nVerifica := 2
			    	Exit	
			    EndIf
			    dbSkip()
			    
			EndDo
        
        Else
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Controle por Unidade ENTRADA								 ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			
			If QEF->QEF_QTDE == 9999 //Situacao FREE-PASS, sera certificado sempre
				nVerifica := 2
			Else
				nEntradas := 0
				dbSelectArea("QEK")
				dbSetOrder(2)
				MsSeek(xFilial("QEK")+cFornece+cLoja+cProduto)
				While !Eof() .And. QEK_FILIAL==xFilial("QEK") .And. QEK_FORNEC==cFornece .And. QEK_LOJFOR==cLoja .And. QEK_PRODUT==cProduto 

					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥ Ponto de Entrada que executa ou nao a rotina de SkipLote	 ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					If lQESEMSKPLT
						If !ExecBlock("QESEMSKPLT",.F.,.F.,{QEK_FORNEC,QEK_LOJFOR,QEK_PRODUT,QEK_DTENTR,QEK_LOTE,QEK_DOCENT,"P",QEF->QEF_UNSKLT})  
							QEK->(dbSkip())
							Loop
						EndIF
					EndIf
		
				    nEntradas++	        
					
					dbSkip()
				EndDo		
				nVerifica := If(At(".", STR(nEntradas/QEF->QEF_QTDE)) == 0 , 1, 2)
				
			EndIf
        
        EndIf
        
		EndIf
  
EndIf

If nRecusadas > 1
	//Verifica a existencia de Laudos Condicionais e Reprovados 
	Aadd(aMsg,STR0014) //"Devido ‡ definiÁ„o existente nos Fatores do IQP"
	Aadd(aMsg,STR0015) //"a entrada atual dever· ser inspecionada."
EndIf

If nVerifica == 1
	//Justificativa para o Skip-Lote a Inspecionar                 
	If Len(aMsg) == 0
		Aadd(aMsg,STR0017) //"A Entrada atual dever† ser inspecionada,"
		Aadd(aMsg,STR0018) //"pela Avaliacao do Skip-Lote.            "
    EndIf
Else
	//Justificativa para o Skip-Lote a Certificar
	Aadd(aMsg,STR0019) //"A Entrada atual poder† ser aprovada em "
	Aadd(aMsg,STR0020) //"Regime de Skip-Lote automatico.        "
  
EndIf

//Restaura as areas correntes
RestArea(aAreaQEK)
RestArea(aAreaSA5)
RestArea(aAreaAnt)
  
Return(nVerifica)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥Fator     ≥ Autor ≥Paulo Emidio de Barros ≥ Data ≥06/06/2003≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Retorna o Fator do IQP									  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ Fator(EXPC1,EXPL1)										  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ EXPC1 = Categoria a ser verificada						  ≥±±
±±≥	 	     ≥ EXPL1 = T - Retorna a Categoria                            ≥±±
±±≥	 	     ≥ 		   F - Retorna Quantidade de Entradas a Inspecionar   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno	 ≥ EXPX1 = Categoria ou Quantidade a Inspecionar			  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso		 ≥ SIGAQIE													  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function Fator(cCategoria,lCategoria)
Local aAreaAnt := GetArea()
Local cFator   := Space(TamSX3("QED_CODFAT")[1])
Local nEntIns  := 0

lCategoria := If(lCategoria==NIL,.T.,lCategoria)

dbSelectArea("QED")
dbSetOrder(1)
dbSeek(xFilial("QED"))
While !Eof() .And. QED_FILIAL==xFilial("QED")
	If QED_CATEG == cCategoria
		If lCategoria
			cFator := QED_CODFAT
		Else
		    nEntIns := QED_ENTINS
		EndIf				
		Exit
		EndIf
	QED->(dbSkip())
EndDo

RestArea(aAreaAnt)
Return(If(lCategoria,cFator,nEntIns))     

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao	 ≥ QAtuShelf   ≥ Autor ≥ Cleber L. Souza        ≥ Data ≥06/08/2003≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Calcula dias de Validade atravÈs do Shelf Life                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ EXPC1 = Produto      										  ≥±±
±±≥			 ≥ EXPC2 = Revisao                           					  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno	 ≥ NIL														  	  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso		 ≥ Geral											         	  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/                              
Function QAtuShelf(cProduto,cRevi)

Local aArea         := GetArea()
Local cChaveQEK	:= cPRODUTO+Inverte(cREVI)
Local nDias         := 0

dbSelectArea("QE6")
dbSetOrder(1)
If dbSeek(xFilial("QE6")+cChaveQEK)
	If QE6->QE6_SHLF > 0
		If QE6->QE6_UNSHEL == "1"  // Dia
			nDias := QE6->QE6_SHLF
		Else
			If QE6->QE6_UNSHEL == "2" // Mes
				nDias := QE6->QE6_SHLF * 30
			Else
				nDias := QE6->QE6_SHLF * 365
			EndIf
		EndIf
		EndIf
EndIf
          
RestArea(aArea)          
                        
Return(nDias) 
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao	 ≥ QJustTxt    ≥ Autor ≥ Cleber L. Souza        ≥ Data ≥06/08/2003≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Justifica um texto e devolve o mesmo em n linhas				  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ EXPC1 = String q vai ser justificado							  ≥±±
±±≥			 ≥ EXPN2 = Tamanho da Coluna que sera justificado.				  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno	 ≥ EXPA1 = Array com o texto justificado    				  	  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso		 ≥ Geral											         	  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/        
Function QJustTxt(cString,nTamanho)    
Return(JustificaTXT(cString,nTamanho))  

/*/{Protheus.doc} QIELOADEXEC
    Chamada das funcoes necessarias para inicializacao e validaÁıes do modulo SIGAQIE
	ExecuÁ„o antes das funÁıes do Modulo SIGAPPA                   	
    @type  Function
	@author Jamer N. Pedroso 
	@since 30/06/2023
	@version 1.0
/*/

Function QIELOADEXEC()

QA_TRAVUSR()  //Verificacao de Usuario Ativo

Return(NIL)


/*/{Protheus.doc} QIELOAD
Rotinas que sao executadas ao entrar no modulo.
@author Cleber Souza
@since 05/01/2004
@Uso SIGAQIE
/*/
Function QIELOAD()   

	Local lRelease    := If( GetRPORelease() < "12.1.2610", .T., .F. )
	Local oQLTManager := Nil

	If lRelease // ProteÁ„o para as chamadas das functions em ambiente inferior a release 12.1.2610. 

		// MA215CHECK - Funcao utilizada para verificar se no momento da abertura
		//              do modulo existem tabelas exclusivas abertas pela rotina 
		//              MATA215 ou por outro processo.
		MA215CHECK()

		dbSelectArea("SD1")
		dbSelectArea("QEK")
		dbSelectArea("QER")

		//Verifica se o tratamento da Reinspecao de Produtos no mesmo Dia, se foi aplicada.
		QIEReinsp()

		oQLTManager := QLTQueryManager():New()		
		
		// Bloqueio no sistema  caso os  campos  compostos estejam inconsistentes
		If oQLTManager:gravaCamposNISERI()
			If (!oQLTManager:validaTamanhoCamposChaveNF("QEK", "QEL", "QEL_NISERI", "QEK")  .OR.;
				!oQLTManager:validaTamanhoCamposChaveNF("QEK", "QER", "QER_NISERI", "QEK")  .OR.;
				!oQLTManager:validaTamanhoCamposChaveNF("D1" , "QER", "QER_NISERI", "D1" )  .OR.;
				!oQLTManager:validaTamanhoCamposChaveNF("D1" , "QEL", "QEL_NISERI", "D1" ))
			    Return Nil
			EndIf
		EndIf

		FQIE_USR()

		//Atualiza Status QEK_SITENT
		If oQLTManager:ConfirmaNecessidadeDeExecucaoMensalViaSemaforo("005", "UPQEKSITEN", Nil, 9999) //9999 meses - 833 anos
			FwMsgRun(,{|| UPQEKSITEN() }, Nil, STR0031) //"Aguarde, atualizando os status das inspeÁıes..."
		EndIf

		If oQLTManager:gravaCamposNISERI()

			//Chama Thread de AtualizaÁ„o Campos QEL_NTFISC, QEL_SERINF, QEL_ITEMNF - Conforme instruÁ„o Nilton Rodrigues e Ernani
		    StartJob("UQELNISERI" , GetEnvServer() , .F. , cEmpAnt, cFilAnt, cModulo)

		    //Chama Thread de AtualizaÁ„o Campos QER_NTFISC, QER_SERINF, QER_ITEMNF - Conforme instruÁ„o Nilton Rodrigues e Ernani
		    StartJob("UQERNISERI" , GetEnvServer() , .F. , cEmpAnt, cFilAnt, cModulo)

			//Chama Thread de AtualizaÁ„o Campos QEL_NISERI, com base em QEL_NTFISC, QEL_SERINF, QEL_ITEMNF
		    StartJob("UQELNICONC" , GetEnvServer() , .F. , cEmpAnt, cFilAnt, cModulo)

		    //Chama Thread de AtualizaÁ„o Campos QER_NISERI, com base em QER_NTFISC, QER_SERINF, QER_ITEMNF
		    StartJob("UQERNICONC" , GetEnvServer() , .F. , cEmpAnt, cFilAnt, cModulo)


			

		EndIf
		
	EndIf
            
Return Nil

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ QIEINITFUN ∫Autor  ≥ TOTVS S/A        ∫ Data ≥  21/01/2014 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Executa as funcoes de inicializacao do modulo SIGAQIE       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ SIGAQIE                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function QIEINITFUN()

	Local lRelease := If( GetRPORelease() < "12.1.2610", .T., .F. )

	If lRelease // ProteÁ„o para as chamadas das functions em ambiente inferior a release 12.1.2610. 
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ MA215CHECK - Funcao utilizada para verificar se no momento da abertura  |
		//≥              do modulo existem tabelas exclusivas abertas pela rotina   |
		//|              MATA215 ou por outro processo.                             |
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		MA215CHECK()
		EndIf

Return

/*/{Protheus.doc} QieAtuLaudo
Atualiza o Laudo para Entradas Certificadas por Skip-Lote
@author Paulo Emidio de Barros
@since 01/06/2004
@Uso SIGAQIE
@param		nOpc  , numerico, 1 para incluir ou 2 para excluir o laudo.
@Return		LÛgico, .T. para atualizado ou .F. para n„o atualizado.

@ObservaÁ„o: Para utilizaÁ„o desta funÁ„o, o registro do QEK, dever· estar gravado e posicionado,
			 caso contr·rio, o Laudo ser· gravado incorretamente.
/*/
Function QieAtuLaudo(nOpc)

	Local aAreaAnt  := GetArea()
	Local cCerQua   := " "
	Local cChave    := " "
	Local cFatApr   := Fator( '1' ,.T.) //Aprovado Total
	Local cLabor    := " "
	Local cNiseri   := ""
	Local dValidade := dDataBase
	Local lQReinsp  := QieReinsp()
	Local lRetorno  := .F.
	Local nDias     := 0
	Local oManager  := QLTQueryManager():New()

	Private lInsAmoIni := GetMv("MV_QAMOINI")

	If QEK->QEK_VERIFI == 2 //Ataualiza o Laudo somenta para entradas certificadas
		cQEL_JUSTLA := GetMv("MV_QEJUSLA")

		cLabor := CriaVar("QEL_LABOR")

		cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
		QEL->(dbSetOrder(3))
		cChave := (QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT))+cNiseri+(QEK->(QEK_TIPONF+DtOS(QEK_DTENTR)+QEK_LOTE))
		//Verifica a existencia do Laudo a ser atualizado
		QEL->(dbSeek(xFilial("QEL")+cChave))
		If nOpc == 1 //Inclusao
		
			If !QEL->(dbSeek(xFilial("QEL")+cChave))  //Caso o Laudo exista, o mesmo nao sera criado
				
				If lQReinsp
					While QEL->(Eof()) .And. QEL->(QEL_FILIAL+QEL_FORNEC+QEL_LOJFOR+QEL_PRODUT+&(oManager:retornaCamposDaNotaFiscalParaChaveDePesquisa("QEL", .F.))+QEL_TIPONF+DTOS(QEL_DTENTR)+QEL_LOTE) == xFilial("QEL")+cChave
						If QEL->QEL_NUMSEQ == QEK->QEK_NUMSEQ
							Exit
						Endif
						QEL->(dbSkip())
					Enddo				
				Endif
				
				// Define a data de validade do Laudo da Entrada
				// QE6_UNSHEL  1 = Dia							
				// QE6_UNSHEL  2 = Mes							
				// QE6_UNSHEL  3 = Ano
				QE6->(dbSetOrder(1))
				QE6->(dbSeek(xFilial("QE6")+QEK->QEK_PRODUT+Inverte(QEK->QEK_REVI)))
				If QE6->(!Eof())
					If QE6->QE6_SHLF <> 0
						//Verifica a Unidade do Shelf-Life
					nDias := If(QE6->QE6_UNSHEL=="1",QE6->QE6_SHLF,;   //Dia
						If(QE6->QE6_UNSHEL=="2",QE6->QE6_SHLF*30,;	   //Mes
						If(QE6->QE6_UNSHEL=="3",QE6->QE6_SHLF*365,0))) //Ano
							
						dValidade += nDias //Calcula a Validade do Laudo
					EndIf
				EndIf
								
				//Grava o Laudo da Entrada	
				RecLock("QEL",.T.)
				QEL->QEL_FILIAL := xFilial("QEL")
				QEL->QEL_PRODUT := QEK->QEK_PRODUT
				QEL->QEL_REVI   := QEK->QEK_REVI
				QEL->QEL_FORNEC := QEK->QEK_FORNEC
				QEL->QEL_LOJFOR := QEK->QEK_LOJFOR
				QEL->QEL_DTENTR := QEK->QEK_DTENTR
				QEL->QEL_LOTE   := QEK->QEK_LOTE
				QEL->QEL_LABOR  := Space(TamSX3("QEL_LABOR")[1])
				QEL->QEL_TAMLOT := QEK->QEK_TAMLOT
				QEL->QEL_DTENLA := dDataBase
				QEL->QEL_HRENLA := Left(Time(),5)
				QEL->QEL_LAUDO  := cFatApr
				QEL->QEL_DTLAUD := dDataBase
				QEL->QEL_HRLAUD := Left(Time(),5)
				QEL->QEL_DTVAL  := dValidade
				QEL->QEL_JUSTLA := cQEL_JUSTLA 
				QEL->QEL_DTDILA := dDataBase
				QEL->QEL_HRDILA := Left(Time(),5)

				If oManager:gravaCamposNISERI()
					QEL->QEL_NISERI := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
				EndIf

				QEL->QEL_NTFISC := QEK->QEK_NTFISC
				QEL->QEL_SERINF := QEK->QEK_SERINF
				QEL->QEL_ITEMNF := QEK->QEK_ITEMNF
				QEL->QEL_TIPONF := QEK->QEK_TIPONF
				QEL->QEL_NUMSEQ := QEK->QEK_NUMSEQ			
				MsUnLock()
							
				// Obtem e grava o Codigo do Certificado de Qualidade
				cCerQua := QA_SEQUSX6("QIE_CEQU",TamSX3("QEK_CERQUA")[1],"S",OemToAnsi(STR0021)) //"Certificado de Qualidade"
				
				RecLock("QEK",.F.)
					//Verifica se o numero do Certificado de Qualidade foi gerado corretamente	
					If Empty(cCerQua)
						QEK->QEK_VERIFI := 1	   //Situacao da Entrada como 'Inspecionar'
						QEK->QEK_SITENT := "1"     //Situacao da Entrada como 'Pendente'
						lRetorno := .F.            //tratar retorno como inspeÁ?o
					Else
						QEK->QEK_CERQUA := cCerQua //Numero do Certificado da Entrada
						QEK->QEK_SITENT := "2"     //Situacao da Entrada como 'Aprovado'
						lRetorno := .T.
					EndIf
				QEK->(MsUnLock())
				
			EndIf
			
		ElseIf nOpc == 2 //Exclusao
		
			If QEL->(dbSeek(xFilial("QEL")+cChave))  //Caso o Laudo exista, o mesmo nao sera criado
				RecLock("QEL",.F.,.T.)
				dbDelete()
				MsUnLock()
				lRetorno := .T.
			EndIf	
			
			EndIf
	EndIf

	RestArea(aAreaAnt)

Return(lRetorno)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥QieAtuSkpTst≥Autor ≥Paulo Emidio de Barros≥ Data ≥01/06/2004≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Atualiza os registros do Skip-Teste						  ≥±±
±±≥			 ≥ Obs.: Para utilizacao desta funcao, o registro do QEK, de- ≥±±
±±≥			 ≥ 		 vera estar agravado e posicionado,caso contrario, o  ≥±±
±±≥			 ≥ 		 Skip-Teste sera gravado incorretamente.			  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QieAtuSkpTst(EXPN1,EXPA1)						 		  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ EXPN1 = 1) Inclusao										  ≥±±
±±≥			 ≥ 		   2) Exclusao										  ≥±±
±±≥			 ≥ EXPA1 = Vetor com os Ensaios marcados com o Skip-Teste     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno	 ≥ EXPL1 = T - Atualizou									  ≥±±
±±≥			 ≥         F - Nao atualizou				  				  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso		 ≥ SIGAQIE													  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function QieAtuSkpTst(nOpc,aEnsInsp)
Local lRetorno   := .T.
Local aAreaAnt   := GetArea()                                 
Local cSkpTes    := " "                         
Local cPsqSkpTst := " " 
Local cPsqSkpGrp := " "
Local nSkp       := 0  
Local cSeekQEY   := " "
Local cSeekQEZ   := " "
Local cNiseri	 := ""
If nOpc == 2  //Exclusao

	aEnsInsp := {} //define o vetor para as marcacoes
			
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Identifica os Ensaios referentes a Revisao do Produto		 ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	QE7->(dbsetOrder(1))
	QE7->(dbSeek(xFilial("QE7")+QEK->(QEK_PRODUT+QEK_REVI))) 
	While QE7->(!Eof()) .And. QE7->QE7_FILIAL==xFilial("QE7") .And. QE7->(QE7_PRODUT+QE7_REVI)==QEK->(QEK_PRODUT+QEK_REVI)
		Aadd(aEnsInsp,{QE7->QE7_ENSAIO})
		QE7->(dbSkip())
	EndDo
	
	QE8->(dbsetOrder(1))
	QE8->(dbSeek(xFilial("QE8")+QEK->(QEK_PRODUT+QEK_REVI)))
	While QE8->(!Eof()) .And. QE8->QE8_FILIAL==xFilial("QE8") .And. QE8->(QE8_PRODUT+QE8_REVI)==QEK->(QEK_PRODUT+QEK_REVI)
		Aadd(aEnsInsp,{QE8->QE8_ENSAIO})
		QE8->(dbSkip())
	EndDo

EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Controle do Skip-Teste: 1) Todas as Entradas       			 ≥
//≥                         2) Somente as Entradas Inspecionadas ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
cSkpTes := GetMv("MV_QSKPTES")
	
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Caso o vetor com os ensaios marcados para o Skip-Teste nao   ≥
//≥ esteja definido, nao havera atualizacao do mesmo.			 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If (aEnsInsp==NIL) .Or. (Len(aEnsInsp)==0)
	lRetorno := .F.
EndIf
                                   
If lRetorno .And. ((cSkpTes=="1") .Or. (cSkpTes=="2" .And. QEK->QEK_VERIFI<>2))	
						
	// Atualiza os controles do skip-teste
	For nSkp := 1 to Len(aEnsInsp)
							
		//Verifica se h† skip-teste individual definido
		cPsqSkpTst := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)+aEnsInsp[nSkp,1]
	
		QEH->(dbSetOrder(1))
		QEH->(MsSeek(xFilial("QEH")+cPsqSkpTst))
		If QEH->(!Eof())
								
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Atualiza o controle do Skip-Teste individual				   ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			QEN->(dbSetOrder(1))
			QEN->(MsSeek(xFilial("QEN")+cPsqSkpTst))
			If QEN->(Eof())
				If nOpc == 1 //Atualizacao
					RecLock("QEN",.T.)
					QEN->QEN_FILIAL	:= xFilial("QEN")
					QEN->QEN_FORNEC	:= QEK->QEK_FORNEC
					QEN->QEN_LOJFOR	:= QEK->QEK_LOJFOR
					QEN->QEN_PRODUT	:= QEK->QEK_PRODUT
					QEN->QEN_ENSAIO	:= aEnsInsp[nSkp,1]
					QEN->QEN_CONTAD	:= 1
	    			QEN->(MsUnLock())
		        EndIf
			Else
				RecLock("QEN",.F.)
				If nOpc == 1 //Atualizacao
					QEN->QEN_CONTAD := aEnsInsp[nSkp,2]
						
				ElseIf nOpc == 2 //Exclusao
					QEN->QEN_CONTAD := If(QEN->QEN_CONTAD<>1,QEN->QEN_CONTAD--,QEH->QEH_SKPTES)
				EndIf	
				QEN->(MsUnLock())
			EndIf
		
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Atualiza o Historico do Skip-Teste individual				   ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If nOpc == 1 //Atualizacao
				If aEnsInsp[nSkp,2] == 1	 //Inspecionou a Entrada
					RecLock("QEY",.T.)
					QEY->QEY_FILIAL	:= xFilial("QEY")
					QEY->QEY_FORNEC	:= QEK->QEK_FORNEC
					QEY->QEY_LOJFOR	:= QEK->QEK_LOJFOR
					QEY->QEY_PRODUT	:= QEK->QEK_PRODUT
					QEY->QEY_DTENTR	:= QEK->QEK_DTENTR
					QEY->QEY_LOTE  	:= QEK->QEK_LOTE
					QEY->QEY_ENSAIO	:= aEnsInsp[nSkp,1]
					QEY->QEY_NTFISC := QEK->QEK_NTFISC
					//QEY->QEY_SERINF := QEK->QEK_SERINF
					SerieNfID ("QEY",1,"QEY_SERINF",,,,QEK->QEK_SERINF)
					QEY->QEY_ITEMNF := QEK->QEK_ITEMNF
					QEY->QEY_TIPONF := QEK->QEK_TIPONF
					QEY->(MsUnLock())
				EndIf
					
			ElseIf nOpc == 2 //Exclusao
				                                        
				//Subtrai o contador do Historico do Skip-Teste Individual
				cSeekQEY := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+dTos(QEK_DTENTR)+QEK_LOTE)+aEnsInsp[nSkp,1]
				QEY->(dbsetOrder(4))
				QEY->(dbSeek(xFilial("QEY")+cSeekQEY))
				If QEY->(!Eof())
					RecLock("QEY",.F.)
					dbDelete()
					MsUnLock()
			    EndIf
				    
			EndIf
						
		Else                       
					
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Realiza a verificacao na exclusao do Skip-Teste por Grupo, so- ≥
			//≥ mente para a primeira ocorrencia do Documento de Entrada.      ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			lRetorno := QEK->QEK_SKLDOC
				
			If lRetorno
				
				//Verifica a existencia do Skip-Teste por grupo
				cPsqSkpGrp := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_GRUPO)+aEnsInsp[nSkp,1]					
	
				QEI->(dbSetOrder(1))
				QEI->(MsSeek(xFilial("QEI")+cPsqSkpGrp))
				If QEI->(!Eof())
							
					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥ Atualiza o controle do skip-teste por Grupo					   ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					QEO->(dbSetOrder(1))
					QEO->(MsSeek(xFilial("QEO")+cPsqSkpGrp))
					If QEO->(Eof())
						If nOpc == 1 //Atualizacao
							RecLock("QEO",.T.)
							QEO->QEO_FILIAL	:= xFilial("QEO")
							QEO->QEO_FORNEC	:= QEK->QEK_FORNEC
							QEO->QEO_LOJFOR	:= QEK->QEK_LOJFOR
							QEO->QEO_GRUPO 	:= QEK->QEK_GRUPO
							QEO->QEO_ENSAIO	:= aEnsInsp[nSkp,1]
							QEO->QEO_DTENTR	:= QEK->QEK_DTENTR
							QEO->QEO_CONTAD	:= 1 
							MsUnLock()            
						EndIf	
					Else
						RecLock("QEO",.F.)
						If nOpc == 1 //Atualizacao                  
							QEO->QEO_CONTAD := aEnsInsp[nSkp,2]    
							
						ElseIf nOpc == 2 //Exclusao
							QEO->QEO_CONTAD := If(QEO->QEO_CONTAD<>1,QEO->QEO_CONTAD--,QEI->QEI_SKPTES)
						EndIf
						MsUnLock()
	
					EndIf
								 
					//Armazena a Data da Entrada qual ensaio devera ser inspecionado
					If nOpc == 1 //Atualizacao
						If QEO->QEO_CONTAD==1 
							RecLock("QEO",.F.)
							QEO->QEO_DTENTR	:= QEK->QEK_DTENTR
							MsUnLock()
						EndIf
					EndIf	

					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥ Atualiza o historico do Skip-Teste por Grupo				   ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					If nOpc == 1 //Atualizacao
						If aEnsInsp[nSkp,2]==1	//Indica que inspecionou
							RecLock("QEZ", .T.)
							QEZ->QEZ_FILIAL := xFilial("QEZ")
							QEZ->QEZ_FORNEC := QEK->QEK_FORNEC
							QEZ->QEZ_LOJFOR := QEK->QEK_LOJFOR
							QEZ->QEZ_GRUPO  := QEK->QEK_GRUPO
							QEZ->QEZ_DTENTR := QEK->QEK_DTENTR
							QEZ->QEZ_LOTE   := QEK->QEK_LOTE
							QEZ->QEZ_ENSAIO := aEnsInsp[nSkp,1]
							QEZ->QEZ_PRODUT := QEK->QEK_PRODUT
							QEZ->QEZ_NTFISC := QEK->QEK_NTFISC
							//QEZ->QEZ_SERINF := QEK->QEK_SERINF
							SerieNfID ("QEZ",1,"QEZ_SERINF",,,,QEK->QEK_SERINF)
							QEZ->QEZ_ITEMNF := QEK->QEK_ITEMNF 
//							QEZ->QEZ_NISERI := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF								
							QEZ->QEZ_TIPONF := QEK->QEK_TIPONF
							MsUnLock()
						EndIf                            
					ElseIf nOpc == 2 //Exclusao
						                                                            
						cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
						cSeekQEZ := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)+cNiseri+QEK->(QEK_TIPONF+dTos(QEK_DTENTR)+QEK_LOTE)+aEnsInsp[nSkp,1]
						QEY->(dbsetOrder(3))
							
						//Subtrai o contador do Historico do Skip-Teste em Grupo
						QEZ->(dbSetOrder(1))
						QEZ->(dbSeek(xFilial("QEZ")+cSeekQEZ))
						If QEZ->(!Eof())
							RecLock("QEZ", .F.)
							dbDelete()
							MsUnLock()
						EndIf	
							
					EndIf
												
				EndIf
				
			EndIf
						
		EndIf
					
	Next nSkp
				
EndIf             
	      
RestArea(aAreaAnt)

Return(lRetorno)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥QieSitFornec≥Autor ≥Cleber Souza          ≥ Data ≥21/06/2004≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Verifica se o Produto x Fornecedor n„o foi bloqueado atra- ≥±±
±±≥			 ≥ ves do modulo de InspeÁ„o de Processo.					  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QieSitFornec(EXPC1,EXPC2,EXPC3,EXPL1)	         		  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ EXPC1 = Codigo do Fornecedor								  ≥±±
±±≥			 ≥ EXPC2 = Loja do Fornecedor							      ≥±±
±±≥			 ≥ EXPC3 = Codigo do Produto							      ≥±±
±±≥			 ≥ EXPL1 = Verifica se apresenta mensagens de erro.		      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno	 ≥ EXPL1 = T - Fornecedor Liberado							  ≥±±
±±≥			 ≥         F - Fornecedor Bloqueado			  				  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso		 ≥ SIGAQIE													  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function QieSitFornec(cFornecedor,cLoja,cProduto,lMensagem)
   
Local lRet      := .T.
Local aAreaSB1  := SB1->(GetArea())
Local aAreaSA5  := SA5->(GetArea())
Local aAreaQEG  := QEG->(GetArea())
Local lVerifica := GetMV("MV_QBLQFOR",,"N") == "S"

lMensagem := If(lMensagem==NIL,.T.,lMensagem) 
     
//Verifica se o parametro MV_QBLQFOR indica que o fornecedor deve ser validado pela rotina.               
If !lVerifica
	Return(lRet)
EndIF	

//Validacao Produto
If cProduto == NIL .or. Empty(cProduto) 
	lRet := .F.
	If lMensagem
		Help(" ",1,"QESPROD") //"… ObrigatÛrio Informar o CÛdigo do Produto."
		EndIf
EndIF
     
//Valida Fornecedor e Loja
If lRet   
	If (cFornecedor == NIL .or. Empty(cFornecedor)) .or. (cLoja == NIL .or. Empty(cLoja))
		lRet := .F.
		If lMensagem
			Help(" ",1,"QESFORN")  //… ObrigatÛrio Informar o CÛdigo e Loja do Fornecedor.
		EndIf
	EndIF
EndIF

//Valida AmarraÁ„o Produto x Fornecedor
If lRet
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+cProduto)                                  
		If RetFldProd(SB1->B1_COD,"B1_TIPOCQ")=='Q' //-- CQ Quality   
			dbSelectArea("SA5")
			dbSetOrder(1)
			If dbSeek(xFilial("SA5")+cFornecedor+cLoja+cProduto)
				If !Empty(SA5->A5_SITU)
					dbSelectArea("QEG")
					dbSetOrder(1)
					dbSeek(xFilial("QEG")+SA5->A5_SITU)
					If QEG->QEG_CATEG == "4" //Categoria para Produto x Fornecedor com Situacao: Nao-Habilitado
						lRet := .F.
						If lMensagem
							Help(" ",1,"QEBLOQF") //N„o sera possivel incluir o produto pois o mesmo foi bloqueado para o Fornecedor selecionado devido bloqueio feito pela qualidade na InspeÁ„o da Entrada. 
						EndIf
					EndIF
	        	EndIF
			EndIf
        EndIF
	Else                             
		lRet := .F.
		If lMensagem
			Help(" ",1,"QESPSB1")//Produto informado n„o esta cadastrado. 
		EndIf
	EndIF
EndIF            

RestArea(aAreaSB1)
RestArea(aAreaSA5)
RestArea(aAreaQEG)

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥QIEC050   ∫Autor  ≥Cicero Cruz         ∫ Data ≥  12/04/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ValidaÁıes do quality						                  ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ IntegraÁ„o com Materias                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function QIEVDOCENT(aCols)
Local aAreaSA5 := SA5->(GetArea())
Local lRet := .T.
Local nPosLF  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOTEFOR"})
Local nPosCod := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})

//Posiciona na Amarracao Produto x Fornecedor

dbSelectArea("SA5")
dbSetOrder(2)
If dbSeek(xFilial("SA5")+aCols[n][nPosCod]+cA100For+cLoja)
	If !Empty(SA5->A5_SKPLOT) 
		If AllTrim(SA5->A5_SKPLOT) == "27" .AND. Empty(Alltrim(aCols[n][nPosLF]))
			lRet := .F.
			MsgInfo( OemToAnsi(STR0023), OemToAnsi(Capital(STR0003)) ) // "O Skip-Lote por Documento de Entrada esta ativado para este produto. Sera necess·rio informar o campo 'Lote Fornecedor' (D1_LOTEFOR)." ### "AVISO"
        EndIf
    EndIf
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica a compatibilidade dos tamanho dos campos D1_LOTECTL x QEK_LOTE ≥	
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If TamSX3("D1_LOTECTL")[1] != (TamSX3("QEK_LOTE")[1] - TamSX3("D1_NUMLOTE")[1] )
	Aviso(STR0028,OemToAnsi(STR0029),{"Ok"},3)//"O campo QEK_LOTE, deve ter o tamanho igual ao campo D1_LOTECTL + D1_NUMLOTE . Favor efetuar o ajuste do grupo de campo 069, conforme procedimentos descritos em Boletim TÈcnico."
	lRet := .F.	
EndIf

RestArea(aAreaSA5)

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥QieVldRef   ∫Autor  ≥Sandra Ribeiro     Data ≥  15/12/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ValidaÁ„o do campo A5_REFGRD                                ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ InspeÁ„o de Entradas                                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂ
*/
Function QieVldRef() 

Local lRetu := .T.

If nModulo == 21
	lRetu := .F.	
EndIf

Return lRetu 


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥QIEREINSP ≥ Autor ≥ Sergio S. Fuzinaka    ≥ Data ≥ 15.05.09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥Verifica se foi habilitado o Processo de Reinspecao de      ≥±±
±±≥          ≥Produto no mesmo Dia.                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function QIEReinsp()

Local aArea		:= GetArea()
Local aAreaSIX	:= SIX->(GetArea())
Local lQReinsp	:= GetNewPar("MV_QREINSP",.F.)
Local lRet		:= .F.
Local cX2Uniq

If lQReinsp
	SIX->(dbSelectArea("SIX"))
	SIX->(dbSetOrder(1))
	If SIX->(dbSeek("QEL3"))
		If "QEL_NUMSEQ" $ Upper(SIX->CHAVE)
			lRet := .T.
		Else
			lRet := .F.
		Endif
	Endif
	If lRet
		If SIX->(dbSeek("QER5"))
			If "QER_NUMSEQ" $ Upper(SIX->CHAVE)
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Endif
	Endif

	If lRet
		cX2Uniq := UPPER(ArrTokStr(FWFormStruct(3,"QEL",NIL,.F.)[6][2],"+"))
		If "QEL_NUMSEQ" $ cX2Uniq
			lRet := .T.
		Else
			lRet := .F.
		Endif
		If lRet
			cX2Uniq := UPPER(ArrTokStr(FWFormStruct(3,"QER",NIL,.F.)[6][2],"+"))
			If "QER_NUMSEQ" $ cX2Uniq
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Endif
	Endif
	If !lRet
		MsgStop(OemToAnsi(STR0024)+CHR(13)+;			//"O processo de ReinspeÁ„o de Produto no mesmo Dia, foi habilitado atravÈs do par‚metro"
				OemToAnsi(STR0025)+CHR(13)+CHR(13)+;	//"'MV_QREINSP', porÈm h· dados que n„o foram atualizados."
				OemToAnsi(STR0026),OemToAnsi(STR0027))	//"Favor executar os procedimentos descritos no Boletim TÈcnico ReinspeÁ„o de Produtos."##"ATEN«√O!"
	Endif
Endif

RestArea(aAreaSIX)
RestArea(aArea)

Return( lRet )

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    QieDescSkT ≥ Autor ≥ Marcos Wagner Jr      ≥ Data ≥ 07.04.20 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥Retorna a descriÁ„o do SkipTeste - Certificar ou Inspecionar≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function QieDescSkT(lAbrev,nSkipTeste,cFornece,cLoja,cProduto)
Local cRetorno   := ''
Local nRegAtual  := QEK->(Recno())
Local cNextAlias := GetNextAlias()
Local nContQEK   := 0
Local lPrimeiro	 := .T.

If lAbrev
	cRetorno := "CER"
Else
	cRetorno := OemToAnsi(STR0008) //"Certificar"
EndIf

cQuery := "SELECT R_E_C_N_O_ "
cQuery += " FROM " + RetSqlName("QEK") + " WHERE "
cQuery += " QEK_FILIAL = '" + xFilial("QEK") + "' AND "
cQuery += " QEK_FORNEC = '" + cFornece + "' AND "
cQuery += " QEK_LOJFOR = '" + cLoja + "' AND "
cQuery += " QEK_PRODUT = '" + cProduto + "' AND "
cQuery += " D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY R_E_C_N_O_ "
cQuery := ChangeQuery(cQuery)
cNextAlias := GetNextAlias()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)
While !( (cNextAlias)->(Eof()) )
	If lPrimeiro
		If lAbrev														// Entradas 6
			cRetorno := "INS"											// Skip 5
		Else															// Ele testar· passar· todos os 6 Recno validando se s„o iguais			
			cRetorno := OemToAnsi(STR0007) //"Inspecionar"				// antes de abrir a tela d/ QIEA215
		EndIf

		lPrimeiro := .f.
	Else
		If nContQEK == nSkipTeste
			If lAbrev
				cRetorno := "INS"
			Else
				cRetorno := OemToAnsi(STR0007) //"Inspecionar"
			EndIf
			
			nContQEK := 0
		Else
			If lAbrev
				cRetorno := "CER"
			Else
				cRetorno := OemToAnsi(STR0008) //"Certificar"
			EndIf
		EndIf
		EndIf
	nContQEK++

	If (cNextAlias)->R_E_C_N_O_ == nRegAtual
		Exit //Quando achou o registro posicionado n„o h· necessidade de continuar.
		EndIf
	(cNextAlias)->(dbSkip())
Enddo
(cNextAlias)->(dbCloseArea())

Return cRetorno

/*/{Protheus.doc} UPQEKSITTH
BAKA para AtualizaÁ„o do Status QEK_SITENT
@author brunno.costa
@since 22/01/2026
@version 1.0
@param 01 - cEmpAux - CÛdigo da Empresa
@param 02 - cFilAux - CÛdigo da Filial
@param 03 - cSiglaModu - Sigla do MÛdulo
/*/
Function UPQEKSITTH(cEmpAux, cFilAux, cSiglaModu)

	Local oQLTManager := Nil

	RPCSetType(3) //Sem licenÁa de uso
	lAmbiente   := RpcSetEnv(cEmpAux, cFilAux,,,cSiglaModu)

	If lAmbiente
		
		oQLTManager := QLTQueryManager():New()

		//Atualiza Status QEK_SITENT
		If oQLTManager:ConfirmaNecessidadeDeExecucaoMensalViaSemaforo("005", "UPQEKSITEN", Nil, 9999) //9999 meses - 833 anos
			UPQEKSITEN()
		EndIf

		RpcClearEnv() // Limpa o ambiente
		EndIf

Return

/*/{Protheus.doc} UPQEKSITEN
BAKA para AtualizaÁ„o do Status QEK_SITENT
@author brunno.costa
@since 08/11/2024
@version 1.0
/*/
Function UPQEKSITEN()

	Local aCorrecoes  := {}
	Local cAlias      := Nil
	Local cBanco      := Nil
	Local cIniQuery   := ""
	Local cIniUpdate  := ""
	Local cQuery      := ""
	Local cUpdate     := ""
	Local oErrorBlock := Nil
	Local oQLTManager := QLTQueryManager():New()

	cBanco          := TcGetDb()

	oErrorBlock := ErrorBlock({|| FWLogMsg('WARN',, 'SIGAQIE', funName(), '', '01', "UPQEKSITEN Fail", 0, 0, {}) })

	DbSelectArea("QEK")
	DbSelectArea("QEL")
	DbSelectArea("SD7")

	cIniUpdate += " UPDATE " + RetSqlName("QEK") + Iif(cBanco $ "POSTGRES", " QEKU ", "")
	cIniUpdate += " SET QEK_SITENT =  "
	cIniUpdate +=   " (CASE WHEN COALESCE(ESTOQUE.SALDO, 0) = 0 OR COALESCE(DADOS.NOVO, ' ') = ' ' THEN "
	cIniUpdate +=                    " (CASE WHEN COALESCE(DADOS.NOVO, ' ') = ' ' "
	cIniUpdate +=                     " THEN (CASE WHEN QER_RESULT IS NULL THEN ' ' "
	cIniUpdate +=                     " ELSE '1' END) "
	cIniUpdate +=                 " ELSE COALESCE(DADOS.NOVO, ' ')  END) "
	cIniUpdate +=   " ELSE '6' END) "

	cIniQuery += " SELECT "
	cIniQuery +=  "	DISTINCT QEK.R_E_C_N_O_ RECNOQEK, "
	cIniQuery +=  	" (CASE WHEN COALESCE(ESTOQUE.SALDO, 0) = 0 OR COALESCE(DADOS.NOVO, ' ') = ' ' "
	cIniQuery +=  	 " THEN (CASE WHEN COALESCE(DADOS.NOVO, ' ') = ' '  "
	cIniQuery +=  	       " THEN (CASE WHEN QER_RESULT IS NULL THEN ' ' "
	cIniQuery +=  		         " ELSE '1' END)  "
	cIniQuery +=  		   " ELSE COALESCE(DADOS.NOVO, ' ')  END)	 "
	cIniQuery +=     " ELSE '6' END) "
	cIniQuery +=  	" NOVO, "
	cIniQuery +=  "	QEK_SITENT "

	cQuery +=  " FROM " + RetSqlName("QEK")+ " QEK "
	cQuery +=  " LEFT JOIN  "
	cQuery +=  " (SELECT R_E_C_N_O_, (CASE  "
	cQuery +=                       " WHEN QEK_SITENT != '3' AND COALESCE(QED_CATEG, ' ') = '1' THEN '2' "
	cQuery +=                       " WHEN COALESCE(QED_CATEG, ' ') = '3' THEN '3' "
	cQuery +=                       " WHEN QEK_SITENT != '3' AND COALESCE(QED_CATEG, ' ') = '2' THEN '5' "
	cQuery +=                       " WHEN QEK_SITENT != '3' AND COALESCE(QED_CATEG, ' ') = '4' THEN '4' "
	cQuery +=                       " ELSE ' ' "
	cQuery +=                       " END) NOVO "
	cQuery +=  " FROM "
	
	cQuery +=  " (SELECT "
	cQuery +=         " INSPECOES.R_E_C_N_O_, "
	cQuery +=         " QEK_SITENT,  "
	cQuery +=         " COALESCE(QEL_LAUDO, ' ') QEL_LAUDO, "
	cQuery +=         " QED_CATEG "
	cQuery +=  " FROM ( "
	cQuery +=        " SELECT "
	cQuery +=        	 " QEK_FILIAL, "
	cQuery +=            " QEK_PRODUT, "
	cQuery +=            " QEK_REVI, "
	cQuery +=  	         " QEK_FORNEC, "
	cQuery +=  	         " QEK_LOJFOR, "
	cQuery +=            " QEK_NTFISC, "
	cQuery +=            " QEK_SERINF, "
	cQuery +=            " QEK_ITEMNF, "
	cQuery +=            " QEK_TIPONF, "
	cQuery +=            " QEK_LOTE, "
	cQuery +=            " QEK_NUMSEQ, "
	cQuery +=            " QEK_DTENTR, "
	cQuery +=        	 " QEK_SITENT, "
	cQuery +=        	 " R_E_C_N_O_ "
	cQuery +=        " FROM (SELECT "
	cQuery +=        	        " QEK.QEK_FILIAL, "
	cQuery +=        	        " QEK.QEK_PRODUT, "
	cQuery +=        	        " QEK.QEK_REVI, "
	cQuery +=        	        " QEK.QEK_FORNEC, "
	cQuery +=        	        " QEK.QEK_LOJFOR, "
	cQuery +=        	        " QEK.QEK_NTFISC, "
	cQuery +=        	        " QEK.QEK_SERINF, "
	cQuery +=        	        " QEK.QEK_ITEMNF, "
	cQuery +=        	        " QEK.QEK_TIPONF, "
	cQuery +=        	        " QEK.QEK_LOTE, "
	cQuery +=        	        " QEK.QEK_NUMSEQ, "
	cQuery +=        	        " QEK.QEK_DTENTR, "
	cQuery +=        	        " QEK.QEK_SITENT, "
	cQuery +=        	        " QEK.R_E_C_N_O_ "
	cQuery +=                " FROM (SELECT "
	cQuery +=        	                 " QEK_FILIAL, "
	cQuery +=                            " QEK_PRODUT, "
	cQuery +=                            " QEK_REVI, "
	cQuery +=                            " QEK_FORNEC, "
	cQuery +=                            " QEK_LOJFOR, "
	cQuery +=                            " QEK_NTFISC, "
	cQuery +=                            " QEK_SERINF, "
	cQuery +=                            " QEK_ITEMNF, "
	cQuery +=                            " QEK_TIPONF, "
	cQuery +=                            " QEK_LOTE, "
	cQuery +=                            " QEK_NUMSEQ, "
	cQuery +=                            " QEK_DTENTR, "
	cQuery +=        	                 " QEK_SITENT, "
	cQuery +=                            " R_E_C_N_O_ "
	cQuery +=                      " FROM " + RetSqlName("QEK")
	cQuery +=                      " WHERE (D_E_L_E_T_ = ' ')) QEK "

	cQuery +=               ") DADOS "
	cQuery +=         ") INSPECOES "
	
	cQuery += " LEFT JOIN ( "
	cQuery +=  " SELECT "
	cQuery +=  	      " QEL_FILIAL, QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT,"+StrTran(oQLTManager:retornaCamposDaNotaFiscalParaChaveDePesquisa("QEL", .F.),"+",",")+", QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR, "
	cQuery +=  	      " QEL_LAUDO "

	cQuery +=  " FROM (SELECT "
	cQuery +=  	            " QEL_FILIAL, QEL_FORNEC, QEL_LOJFOR, QEL_PRODUT,"+StrTran(oQLTManager:retornaCamposDaNotaFiscalParaChaveDePesquisa("QEL", .F.),"+",",")+", QEL_TIPONF, QEL_LOTE, QEL_NUMSEQ, QEL_DTENTR, "
	cQuery +=  	            " QEL_LAUDO "
	cQuery +=        " FROM "+ RetSqlName("QEL")
	cQuery +=        " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=          " AND (QEL_LAUDO <> ' ') "
	cQuery +=          " AND (QEL_LABOR = ' ')) LAUDOS) LAUDO "

	cQuery += " ON "  + oQLTManager:MontaQueryComparacaoFiliais("QEL", "QEK", "LAUDO", "INSPECOES")
	cQuery += " AND " + oQLTManager:MontaRelationArraysCampos("INSPECOES", {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
															  "LAUDO"    , {"QEL_FORNEC","QEL_LOJFOR","QEL_PRODUT",StrTran(oQLTManager:retornaCamposDaNotaFiscalParaChaveDePesquisa("QEL", .F.), " ", "") ,;
																		    "QEL_TIPONF","QEL_LOTE"  ,"QEL_DTENTR"})

	If QIEReinsp()
		cQuery += " AND (INSPECOES.QEK_NUMSEQ = LAUDO.QEL_NUMSEQ OR LAUDO.QEL_NUMSEQ = ' ') "
		EndIf

	cQuery += " LEFT JOIN " + RetSqlName("QED") + " QED"
	cQuery += " ON "  + oQLTManager:MontaQueryComparacaoFiliais("QED", "QEK", "QED", "INSPECOES")
	cQuery +=   " AND QED.QED_CODFAT =  LAUDO.QEL_LAUDO "
	cQuery +=   " AND QED.D_E_L_E_T_ =  ' ' "

	cQuery +=       " ) TMP    "

	cQuery += " ) DADOS "
	cQuery += " ON DADOS.R_E_C_N_O_ = QEK.R_E_C_N_O_ "
	
	cQuery += " LEFT JOIN  "
	cQuery += " ( "
	cQuery +=  " SELECT "
	cQuery +=         " SD7_ORIG.D7_FILIAL, "
	cQuery +=         " SD7_ORIG.D7_PRODUTO, "
	cQuery +=         " SALDO_SD7.D7_NUMERO, "
	cQuery +=         " SALDO_SD7.SALDO "
	cQuery +=  " FROM "
	
	cQuery +=      " (SELECT D7_FILIAL, D7_NUMSEQ, D7_PRODUTO, D7_NUMERO "
	cQuery +=     	  " FROM "+ RetSqlName("SD7")
	cQuery +=     	  " WHERE D_E_L_E_T_=' ' AND D7_TIPO = '0') SD7_ORIG "
	
	cQuery +=      " INNER JOIN "
	
	cQuery +=      " (SELECT SD7_ORIG.D7_FILIAL, SD7_ORIG.D7_NUMERO, SD7_ORIG.ORIGINAL - ISNULL(SD7_BAIXA.BAIXA, 0) SALDO "
	cQuery +=       " FROM "
	cQuery +=           " (SELECT D7_FILIAL, D7_NUMERO, D7_PRODUTO, D7_SALDO ORIGINAL "
	cQuery +=            " FROM " + RetSqlName("SD7")
	cQuery +=            " WHERE D_E_L_E_T_=' ' AND D7_TIPO = '0') SD7_ORIG "
	
	cQuery +=           " LEFT JOIN "
	
	cQuery +=           " (SELECT D7_FILIAL, D7_NUMERO, D7_PRODUTO, SUM(D7_QTDE) BAIXA "
	cQuery +=            " FROM " + RetSqlName("SD7")
	cQuery +=            " WHERE D_E_L_E_T_=' ' AND D7_TIPO <> '0' AND D7_ESTORNO = ' ' "
	cQuery +=            " GROUP BY D7_FILIAL, D7_NUMERO, D7_PRODUTO) SD7_BAIXA "
	
	cQuery +=           " ON  SD7_ORIG.D7_PRODUTO = SD7_BAIXA.D7_PRODUTO "
	cQuery +=           " AND SD7_ORIG.D7_NUMERO  = SD7_BAIXA.D7_NUMERO "
	cQuery +=           " AND " + oQLTManager:MontaQueryComparacaoFiliais("SD7", "SD7", "SD7_ORIG", "SD7_BAIXA")
	cQuery +=     " ) SALDO_SD7 "

	cQuery +=     " ON SALDO_SD7.D7_NUMERO = SD7_ORIG.D7_NUMERO "
	
	cQuery += " ) ESTOQUE "
	
	cQuery += " ON    ESTOQUE.D7_NUMERO  = QEK_CERFOR "
	cQuery +=   " AND ESTOQUE.D7_PRODUTO = QEK_PRODUT "
	cQuery +=   " AND " + oQLTManager:MontaQueryComparacaoFiliais("SD7", "QEK", "ESTOQUE", "QEK")
	
	cQuery += " LEFT JOIN " + RetSqlName("QER") + " QER "
	cQuery += " ON  "
	cQuery +=           oQLTManager:MontaQueryComparacaoFiliais("QER", "QEK", "QER", "QEK")
	cQuery += " AND " + oQLTManager:MontaRelationArraysCampos("QEK" , {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_NTFISC+QEK_SERINF+QEK_ITEMNF","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
															  "QER" , {"QER_FORNEC","QER_LOJFOR","QER_PRODUT",StrTran(oQLTManager:retornaCamposDaNotaFiscalParaChaveDePesquisa("QER", .F.), " ", ""),;
															  		   "QER_TIPONF","QER_LOTE"  ,"QER_DTENTR"})

	If QIEReinsp()
		cQuery += " AND (QEK.QEK_NUMSEQ = QER.QER_NUMSEQ OR QER.QER_NUMSEQ = ' ' ) "
		EndIf

	cQuery += " AND (QER.QER_RESULT <> ' ') "
	cQuery += " AND (QER.D_E_L_E_T_ = ' ') "

	cQuery += " WHERE "
	
	cQuery +=    " (CASE WHEN COALESCE(ESTOQUE.SALDO, 0) = 0 OR COALESCE(DADOS.NOVO, ' ') = ' ' THEN "
	cQuery +=     	 " (CASE WHEN COALESCE(DADOS.NOVO, ' ') = ' '  "
	cQuery +=     	 "  THEN (CASE WHEN QER_RESULT IS NULL THEN ' ' "
	cQuery +=     	 "        ELSE '1' END)  "
	cQuery +=     	 "  ELSE COALESCE(DADOS.NOVO, ' ')  END) "
	cQuery +=    "	ELSE '6' END) <> QEK.QEK_SITENT "

	If cBanco $ "POSTGRES"
		cUpdate := cIniUpdate + cQuery + " AND QEKU.R_E_C_N_O_ = QEK.R_E_C_N_O_ "

	ElseIf cBanco $ "ORACLE"
		cUpdate := " MERGE INTO " + RetSqlName("QEK") + " QEKU "
		cUpdate += " USING ( "
		cUpdate += cIniQuery + cQuery
		cUpdate += " ) USED "
		cUpdate += " ON (QEKU.R_E_C_N_O_ = USED.RECNOQEK) "
		cUpdate += " WHEN MATCHED THEN "
		cUpdate += "     UPDATE "
		cUpdate +=     " SET QEKU.QEK_SITENT = USED.NOVO "

	Else 
		cUpdate := cIniUpdate + cQuery

		EndIf

	cUpdate := oQLTManager:changeQuery(cUpdate)
	cQuery  := oQLTManager:changeQuery(cIniQuery + cQuery)
	cAlias  := oQLTManager:executeQuery(cQuery)

	aAdd(aCorrecoes, "Correcoes status QEK_SITENT:") //"Correcoes status QEK_SITENT:"
	While (cAlias)->(!Eof())
		aAdd(aCorrecoes, " - NOVO: '" + (cAlias)->NOVO + "', ANTERIOR: '" + (cAlias)->QEK_SITENT + "', RECNO '" + cValToChar((cAlias)->RECNOQEK) + "'.") //"Excluindo registro referente Laudo Geral SEM LOTE"
		(cAlias)->(DbSkip())
	EndDo

	nStatus := TcSQLExec(cUpdate)

	aAdd(aCorrecoes, " - QUERY: "  + cQuery)
	aAdd(aCorrecoes, " - UPDATE: " + cUpdate)
	aAdd(aCorrecoes, " - STATUS TcSQLExec: " + cValToChar(nStatus))
	
	oQLTManager:ConfirmaNecessidadeDeExecucaoMensalViaSemaforo("005", "UPQEKSITEN", aCorrecoes, 9999) //9999 meses - 833 anos
	
	FWLogMsg('WARN',, 'SIGAQIE', funName(), '', '01', IIf(nStatus < 0, "UPQEKSITEN: " + cUpdate, "UPQEKSITEN - OK") , 0, 0, {})

	(cAlias)->(DbCloseArea())
	QEK->(DbCloseArea())
	QEL->(DbCloseArea())
	SD7->(DbCloseArea())

	ErrorBlock(oErrorBlock)
Return

/*/{Protheus.doc} UQELNISERI
BAKA para AtualizaÁ„o dos campos vazios: QEL_NTFISC, QEL_SERINF e QEL_ITEMNF
@author brunno.costa
@since 24/04/2025
@version 1.0
@param 01 - cEmpAux   , caracter, cÛdigo da empresa
@param 02 - cFilAux   , caracter, cÛdigo da filial
@param 03 - cSiglaModu, caracter, sigla do mÛdulo
@param 04 - lRBE      , lÛgico  , se È RBE ou n„o
/*/
Function UQELNISERI(cEmpAux, cFilAux, cSiglaModu, lRBE)

	Local cAlias        := ""
	Local cAliasNIS     := ""
	Local cIniNISUpd    := ""
	Local cIniQuery     := ""
	Local cIniQueryNIS  := ""
	Local cIniUpdate    := ""
	Local cQuery        := ""
	Local cQueryNIS     := ""
	Local cUpdate       := ""
	Local cUpdateNIS    := ""
	Local cWhereNIS     := ""
	Local lAmbiente     := .T.
	Local lLock         := Nil
	Local nStatus       := Nil
	Local nTamItemnf    := 0
	Local nTamNtfisc    := 0
	Local nTamSerinf    := 0
	Local oQueryManager := Nil

	Default lRBE := .F.

	If !lRBE
		RPCSetType(3)
		lAmbiente   := RpcSetEnv(cEmpAux, cFilAux,,,cSiglaModu)
		EndIf

	If lAmbiente; 
	   .And. FindFunction("QLTQueryManager")
	
		oQueryManager := QLTQueryManager():New()

		If (FWSIXUtil():ExistIndex( "QEL" , "4" ) .Or. !oQueryManager:validaIndiceNotaAvulsoNaQEL() .OR. lRBE .Or. dDataBase >= StoD("20260601")) //Confirma existÍncia indice 4 na SIX: QEL_NTFISC+QEL_SERINF+QEL_ITEMNF

			DbSelectArea("QEK")
			DbSelectArea("QEL")

			If    QEL->(FieldPos('QEL_NTFISC')) > 0 ; //Confirma existÍncia do campo na SX3
			.And. QEL->(FieldPos('QEL_SERINF')) > 0 ; //Confirma existÍncia do campo na SX3
			.And. QEL->(FieldPos('QEL_ITEMNF')) > 0 ; //Confirma existÍncia do campo na SX3

				//ProteÁ„o de execuÁ„o simult‚nea conforme instruÁ„o de Nilton Rodrigues
				lLock := LockByName("QIEXFUN_UQELNISERI_A", .T., .F.)

				If lLock

					
					cIniUpdate += " UPDATE " + RetSqlName("QEL") + Iif(oQueryManager:cBanco $ "POSTGRES", " QELU ", "")
					cIniUpdate += " SET QEL_NTFISC = QEK_NTFISC , "
					cIniUpdate +=     " QEL_SERINF = QEK_SERINF , "
					cIniUpdate +=     " QEL_ITEMNF = QEK_ITEMNF  "

					cIniQuery  +=  " SELECT QEL.R_E_C_N_O_ RECNOQEL, QEL.QEL_NISERI, QEK.QEK_NTFISC, QEK.QEK_SERINF, QEK.QEK_ITEMNF "

					cQuery     +=   " FROM "       + RetSQLName("QEK") + " QEK "
					cQuery     +=   " INNER JOIN " + RetSQLName("QEL") + " QEL "

					cQuery     += " ON "  + oQueryManager:MontaQueryComparacaoFiliais("QEK", "QEL", "QEK", "QEL")
					cQuery     += " AND " + oQueryManager:MontaRelationArraysCampos("QEK", {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
																					"QEL", {"QEL_FORNEC","QEL_LOJFOR","QEL_PRODUT","QEL_TIPONF","QEL_LOTE","QEL_DTENTR"})
					cQuery     += " AND (" + oQueryManager:acertaConcatenacaoComConcat("QEK.", "QEK_NTFISC+QEK_SERINF+QEK_ITEMNF") + " = QEL.QEL_NISERI) " //ComparaÁ„o explÌcita cross-database: imune ‡ troca do Ìndice 3

					cQuery     +=   " WHERE (QEL.QEL_NISERI <> '" + Space(GetSx3Cache("QEL_NISERI", "X3_TAMANHO")) + "') "	
					cQuery     +=     " AND (QEL.QEL_NTFISC = '"  + Space(GetSx3Cache("QEL_NTFISC", "X3_TAMANHO")) + "') "
					cQuery     +=     " AND (QEK.D_E_L_E_T_ = ' ') "
					cQuery     +=     " AND (QEL.D_E_L_E_T_ = ' ') "
				
					If oQueryManager:cBanco $ "POSTGRES"
						cUpdate := cIniUpdate + cQuery + " AND QELU.R_E_C_N_O_ = QEL.R_E_C_N_O_ "

					ElseIf oQueryManager:cBanco $ "ORACLE"
						cUpdate := " MERGE INTO " + RetSqlName("QEL") + " QELU "
						cUpdate += " USING ( "
						cUpdate += cIniQuery + cQuery
						cUpdate += " ) USED "
						cUpdate += " ON (QELU.R_E_C_N_O_ = USED.RECNOQEL) "
						cUpdate += " WHEN MATCHED THEN "
						cUpdate += "     UPDATE "
						cUpdate +=     " SET QELU.QEL_NTFISC = USED.QEK_NTFISC , "
						cUpdate +=         " QELU.QEL_SERINF = USED.QEK_SERINF , "
						cUpdate +=         " QELU.QEL_ITEMNF = USED.QEK_ITEMNF  "

					Else 
						cUpdate := cIniUpdate + cQuery

					EndIf

					//Valida existÍncia de dados para atualizaÁ„o
					//Registros com campos vazios "QEL_NTFISC, QEL_SERINF e QEL_ITEMNF" e com QEL_NISERI preenchido
					cQuery  := oQueryManager:changeQuery(cIniQuery + cQuery)
					cAlias  := oQueryManager:executeQuery(cQuery)
					If !(cAlias)->(Eof())

						//Atualiza os campos QEL_NTFISC, QEL_SERINF e QEL_ITEMNF vazios quando QEL_NISERI preenchido
						cUpdate := oQueryManager:changeQuery(cUpdate)
						nStatus := TcSQLExec(cUpdate)
						Iif(nStatus <> 0 , UserException(TcSqlError()), Nil)

					EndIf
					
					//Complemento: atualiza QEL_NTFISC, QEL_SERINF e QEL_ITEMNF com base no QEL_NISERI
					nTamNtfisc := GetSx3Cache("QEL_NTFISC", "X3_TAMANHO")
					nTamSerinf := GetSx3Cache("QEL_SERINF", "X3_TAMANHO")
					nTamItemnf := GetSx3Cache("QEL_ITEMNF", "X3_TAMANHO")

					cIniNISUpd += " UPDATE " + RetSqlName("QEL")
					cIniNISUpd += " SET QEL_NTFISC = SUBSTRING(QEL_NISERI, 1, " + cValToChar(nTamNtfisc) + ") , "
					cIniNISUpd += " QEL_SERINF = SUBSTRING(QEL_NISERI, " + cValToChar(nTamNtfisc + 1) + ", " + cValToChar(nTamSerinf) + ") , "
					cIniNISUpd += " QEL_ITEMNF = SUBSTRING(QEL_NISERI, " + cValToChar(nTamNtfisc + nTamSerinf + 1) + ", " + cValToChar(nTamItemnf) + ") "

					cWhereNIS     += " WHERE (QEL_NISERI <> '" + Space(GetSx3Cache("QEL_NISERI", "X3_TAMANHO")) + "') "
					cWhereNIS     += " AND (QEL_NTFISC = '"  + Space(GetSx3Cache("QEL_NTFISC", "X3_TAMANHO")) + "') "
					cWhereNIS     += " AND (D_E_L_E_T_ = ' ') "

					cIniQueryNIS  += " SELECT R_E_C_N_O_ RECNOQEL, QEL_NISERI "
					cQueryNIS     += " FROM " + RetSQLName("QEL") + cWhereNIS

					cQueryNIS  := oQueryManager:changeQuery(cIniQueryNIS + cQueryNIS)
					cAliasNIS  := oQueryManager:executeQuery(cQueryNIS)
					If !(cAliasNIS)->(Eof())

						cUpdateNIS := oQueryManager:changeQuery(cIniNISUpd + cWhereNIS)
						nStatus    := TcSQLExec(cUpdateNIS)
						Iif(nStatus <> 0 , UserException(TcSqlError()), Nil)

					EndIf
					FreeObj(oQueryManager)

					(cAlias)->(DbCloseArea())
					(cAliasNIS)->(DbCloseArea())

					UnLockByName("QIEXFUN_UQELNISERI_A", .T., .F.)
				EndIf

			EndIF

			QEL->(DbCloseArea())
			QEK->(DbCloseArea())

		EndIf

	EndIf

Return


/*/{Protheus.doc} UQERNISERI
BAKA para AtualizaÁ„o dos campos vazios: QER_NTFISC, QER_SERINF e QER_ITEMNF
@author thiago.rover
@since 17/07/2025
@param 01 - cEmpAux   , caracter, cÛdigo da empresa
@param 02 - cFilAux   , caracter, cÛdigo da filial
@param 03 - cSiglaModu, caracter, sigla do mÛdulo
@param 04 - lRBE      , lÛgico  , se È RBE ou n„o
/*/
Function UQERNISERI(cEmpAux, cFilAux, cSiglaModu, lRBE)

	Local cAlias        := ""
	Local cAliasNIS     := ""
	Local cIniNISUpd    := ""
	Local cIniQuery     := ""
	Local cIniQueryNIS  := ""
	Local cIniUpdate    := ""
	Local cQuery        := ""
	Local cQueryNIS     := ""
	Local cUpdate       := ""
	Local cUpdateNIS    := ""
	Local cWhereNIS     := ""
	Local lAmbiente     := .T.
	Local lLock         := Nil
	Local nStatus       := Nil
	Local nTamItemnf    := 0
	Local nTamNtfisc    := 0
	Local nTamSerinf    := 0
	Local oQueryManager := Nil

	Default lRBE := .F.

	If !lRBE
		RPCSetType(3)
		lAmbiente   := RpcSetEnv(cEmpAux, cFilAux,,,cSiglaModu)
		EndIf

	If lAmbiente; 
	   .And. FindFunction("QLTQueryManager")
			
		oQueryManager := QLTQueryManager():New() 

		If (FWSIXUtil():ExistIndex( "QER" , "6" ) .Or. !oQueryManager:validaIndiceNotaAvulsoNaQER() .OR. lRBE .Or. dDataBase >= StoD("20260601")) //Confirma existÍncia do Ìndice 6 na SIX (QER_NTFISC+QER_SERINF+QER_ITEMNF), sinal de que o dicion·rio est· pronto para a migraÁ„o

			DbSelectArea("QEK")
			DbSelectArea("QER")

			If    QER->(FieldPos('QER_NTFISC')) > 0 ; //Confirma existÍncia do campo na SX3
			.And. QER->(FieldPos('QER_SERINF')) > 0 ; //Confirma existÍncia do campo na SX3
			.And. QER->(FieldPos('QER_ITEMNF')) > 0 ; //Confirma existÍncia do campo na SX3

				//ProteÁ„o de execuÁ„o simult‚nea conforme instruÁ„o de Nilton Rodrigues
				lLock := LockByName("QIEXFUN_UQERNISERI_A", .T., .F.)

				If lLock

					
					cIniUpdate += " UPDATE " + RetSqlName("QER") + Iif(oQueryManager:cBanco $ "POSTGRES", " QERU ", "")
					cIniUpdate += " SET QER_NTFISC = QEK_NTFISC , "
					cIniUpdate +=     " QER_SERINF = QEK_SERINF , "
					cIniUpdate +=     " QER_ITEMNF = QEK_ITEMNF  "

					cIniQuery  +=  " SELECT QER.R_E_C_N_O_ RECNOQER, QER.QER_NISERI, QEK.QEK_NTFISC, QEK.QEK_SERINF, QEK.QEK_ITEMNF "

					cQuery     +=   " FROM "       + RetSQLName("QEK") + " QEK "
					cQuery     +=   " INNER JOIN " + RetSQLName("QER") + " QER "

					cQuery     += " ON "  + oQueryManager:MontaQueryComparacaoFiliais("QEK", "QER", "QEK", "QER")
					cQuery     += " AND " + oQueryManager:MontaRelationArraysCampos("QEK", {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_TIPONF","QEK_LOTE","QEK_DTENTR"},;
																					"QER", {"QER_FORNEC","QER_LOJFOR","QER_PRODUT","QER_TIPONF","QER_LOTE","QER_DTENTR"})
					cQuery     += " AND (" + oQueryManager:acertaConcatenacaoComConcat("QEK.", "QEK_NTFISC+QEK_SERINF+QEK_ITEMNF") + " = QER.QER_NISERI) " //ComparaÁ„o explÌcita cross-database: imune ‡ troca do Ìndice 5

					cQuery     +=   " WHERE (QER.QER_NISERI <> '" + Space(GetSx3Cache("QER_NISERI", "X3_TAMANHO")) + "') "	
					cQuery     +=     " AND (QER.QER_NTFISC = '"  + Space(GetSx3Cache("QER_NTFISC", "X3_TAMANHO")) + "') "	
					cQuery     +=     " AND (QEK.D_E_L_E_T_ = ' ') "
					cQuery     +=     " AND (QER.D_E_L_E_T_ = ' ') "
				
					If oQueryManager:cBanco $ "POSTGRES"
						cUpdate := cIniUpdate + cQuery + " AND QERU.R_E_C_N_O_ = QER.R_E_C_N_O_ "

					ElseIf oQueryManager:cBanco $ "ORACLE"
						cUpdate := " MERGE INTO " + RetSqlName("QER") + " QERU "
						cUpdate += " USING ( "
						cUpdate += cIniQuery + cQuery
						cUpdate += " ) USED "
						cUpdate += " ON (QERU.R_E_C_N_O_ = USED.RECNOQER) "
						cUpdate += " WHEN MATCHED THEN "
						cUpdate += "     UPDATE "
						cUpdate +=     " SET QERU.QER_NTFISC = USED.QEK_NTFISC , "
						cUpdate +=         " QERU.QER_SERINF = USED.QEK_SERINF , "
						cUpdate +=         " QERU.QER_ITEMNF = USED.QEK_ITEMNF  "

					Else 
						cUpdate := cIniUpdate + cQuery

					EndIf

					//Valida existÍncia de dados para atualizaÁ„o
					//Registros com campos vazios "QER_NTFISC, QER_SERINF e QER_ITEMNF" e com QER_NISERI preenchido
					cQuery  := oQueryManager:changeQuery(cIniQuery + cQuery)
					cAlias  := oQueryManager:executeQuery(cQuery)
					If !(cAlias)->(Eof())

						//Atualiza os campos QER_NTFISC, QER_SERINF e QER_ITEMNF vazios quando QER_NISERI preenchido
						cUpdate := oQueryManager:changeQuery(cUpdate)
						nStatus := TcSQLExec(cUpdate)
						Iif(nStatus <> 0 , UserException(TcSqlError()), Nil)

					EndIf
					
					//Complemento: atualiza QER_NTFISC, QER_SERINF e QER_ITEMNF com base no QER_NISERI
					nTamNtfisc := GetSx3Cache("QER_NTFISC", "X3_TAMANHO")
					nTamSerinf := GetSx3Cache("QER_SERINF", "X3_TAMANHO")
					nTamItemnf := GetSx3Cache("QER_ITEMNF", "X3_TAMANHO")

					cIniNISUpd += " UPDATE " + RetSqlName("QER")
					cIniNISUpd += " SET QER_NTFISC = SUBSTRING(QER_NISERI, 1, " + cValToChar(nTamNtfisc) + ") , "
					cIniNISUpd += " QER_SERINF = SUBSTRING(QER_NISERI, " + cValToChar(nTamNtfisc + 1) + ", " + cValToChar(nTamSerinf) + ") , "
					cIniNISUpd += " QER_ITEMNF = SUBSTRING(QER_NISERI, " + cValToChar(nTamNtfisc + nTamSerinf + 1) + ", " + cValToChar(nTamItemnf) + ") "

					cWhereNIS     += " WHERE (QER_NISERI <> '" + Space(GetSx3Cache("QER_NISERI", "X3_TAMANHO")) + "') "
					cWhereNIS     += " AND (QER_NTFISC = '"  + Space(GetSx3Cache("QER_NTFISC", "X3_TAMANHO")) + "') "
					cWhereNIS     += " AND (D_E_L_E_T_ = ' ') "

					cIniQueryNIS  += " SELECT R_E_C_N_O_ RECNOQER, QER_NISERI "
					cQueryNIS     += " FROM " + RetSQLName("QER") + cWhereNIS

					cQueryNIS  := oQueryManager:changeQuery(cIniQueryNIS + cQueryNIS)
					cAliasNIS  := oQueryManager:executeQuery(cQueryNIS)
					If !(cAliasNIS)->(Eof())

						cUpdateNIS := oQueryManager:changeQuery(cIniNISUpd + cWhereNIS)
						nStatus    := TcSQLExec(cUpdateNIS)
						Iif(nStatus <> 0 , UserException(TcSqlError()), Nil)

					EndIf
					FreeObj(oQueryManager)

					(cAlias)->(DbCloseArea())
					(cAliasNIS)->(DbCloseArea())

					UnLockByName("QIEXFUN_UQERNISERI_A", .T., .F.)
				EndIf

			EndIF

			QER->(DbCloseArea())
			QEK->(DbCloseArea())
		EndIf

	EndIf

Return


/*/{Protheus.doc} UQELNICONC
BAKA para AtualizaÁ„o do campo QEL_NISERI vazio com a concatenaÁ„o de QEL_NTFISC, QEL_SERINF e QEL_ITEMNF
@author brunno.costa
@since 19/03/2026
@version 1.0
@param 01 - cEmpAux   , caracter, cÛdigo da empresa
@param 02 - cFilAux   , caracter, cÛdigo da filial
@param 03 - cSiglaModu, caracter, sigla do mÛdulo
@param 04 - lRBE      , lÛgico  , se È RBE ou n„o
/*/
Function UQELNICONC(cEmpAux, cFilAux, cSiglaModu, lRBE)

	Local cAlias        := ""
	Local cIniQuery     := ""
	Local cIniUpdate    := ""
	Local cQuery        := ""
	Local cUpdate       := ""
	Local cWhere        := ""
	Local lAmbiente     := .T.
	Local lLock         := Nil
	Local nStatus       := Nil
	Local oQueryManager := Nil

	Default lRBE := .F.

	If !lRBE
		RPCSetType(3)
		lAmbiente := RpcSetEnv(cEmpAux, cFilAux,,,cSiglaModu)
	EndIf

	If lAmbiente .And. FindFunction("QLTQueryManager")

		DbSelectArea("QEL")

		If    QEL->(FieldPos('QEL_NISERI')) > 0 ; //Confirma existÍncia do campo na SX3
		.And. QEL->(FieldPos('QEL_NTFISC')) > 0 ; //Confirma existÍncia do campo na SX3
		.And. QEL->(FieldPos('QEL_SERINF')) > 0 ; //Confirma existÍncia do campo na SX3
		.And. QEL->(FieldPos('QEL_ITEMNF')) > 0 ; //Confirma existÍncia do campo na SX3

			//ProteÁ„o de execuÁ„o simult‚nea conforme instruÁ„o de Nilton Rodrigues
			lLock := LockByName("QIEXFUN_UQELNICONC_A", .T., .F.)

			If lLock

				oQueryManager := QLTQueryManager():New()

				cWhere += " WHERE (QEL_NISERI = '" + Space(GetSx3Cache("QEL_NISERI", "X3_TAMANHO")) + "') "
				cWhere += " AND (QEL_NTFISC <> '" + Space(GetSx3Cache("QEL_NTFISC", "X3_TAMANHO")) + "') "
				cWhere += " AND (D_E_L_E_T_ = ' ') "

				cIniQuery  += " SELECT R_E_C_N_O_ RECNOQEL, QEL_NTFISC, QEL_SERINF, QEL_ITEMNF "
				cQuery     += " FROM " + RetSQLName("QEL") + cWhere

				cIniUpdate += " UPDATE " + RetSqlName("QEL")
				cIniUpdate += " SET QEL_NISERI = " + oQueryManager:acertaConcatenacaoComConcat("", "QEL_NTFISC+QEL_SERINF+QEL_ITEMNF")

				//Valida existÍncia de dados para atualizaÁ„o
				//Registros com QEL_NISERI vazio e QEL_NTFISC preenchido
				cQuery  := oQueryManager:changeQuery(cIniQuery + cQuery)
				cAlias  := oQueryManager:executeQuery(cQuery)
				If !(cAlias)->(Eof())

					//Atualiza QEL_NISERI com a concatenaÁ„o dos campos QEL_NTFISC, QEL_SERINF e QEL_ITEMNF
					cUpdate := oQueryManager:changeQuery(cIniUpdate + cWhere)
					nStatus := TcSQLExec(cUpdate)

				EndIf

				//Garante liberaÁ„o do lock mesmo em caso de erro
				FreeObj(oQueryManager)
				If !Empty(cAlias)
					(cAlias)->(DbCloseArea())
				EndIf

				UnLockByName("QIEXFUN_UQELNICONC_A", .T., .F.)

				//LanÁa exceÁ„o apÛs liberaÁ„o do lock para n„o deix·-lo preso
				If nStatus <> Nil .And. nStatus <> 0
					UserException(TcSqlError())
				EndIf
			EndIf

		EndIf

		QEL->(DbCloseArea())

	EndIf

Return


/*/{Protheus.doc} UQERNICONC
BAKA para AtualizaÁ„o do campo QER_NISERI vazio com a concatenaÁ„o de QER_NTFISC, QER_SERINF e QER_ITEMNF
@author brunno.costa
@since 19/03/2026
@version 1.0
@param 01 - cEmpAux   , caracter, cÛdigo da empresa
@param 02 - cFilAux   , caracter, cÛdigo da filial
@param 03 - cSiglaModu, caracter, sigla do mÛdulo
@param 04 - lRBE      , lÛgico  , se È RBE ou n„o
/*/
Function UQERNICONC(cEmpAux, cFilAux, cSiglaModu, lRBE)

	Local cAlias        := ""
	Local cIniQuery     := ""
	Local cIniUpdate    := ""
	Local cQuery        := ""
	Local cUpdate       := ""
	Local cWhere        := ""
	Local lAmbiente     := .T.
	Local lLock         := Nil
	Local nStatus       := Nil
	Local oQueryManager := Nil

	Default lRBE := .F.

	If !lRBE
		RPCSetType(3)
		lAmbiente := RpcSetEnv(cEmpAux, cFilAux,,,cSiglaModu)
		EndIf

	If lAmbiente .And. FindFunction("QLTQueryManager")

		DbSelectArea("QER")

		If    QER->(FieldPos('QER_NISERI')) > 0 ; //Confirma existÍncia do campo na SX3
		.And. QER->(FieldPos('QER_NTFISC')) > 0 ; //Confirma existÍncia do campo na SX3
		.And. QER->(FieldPos('QER_SERINF')) > 0 ; //Confirma existÍncia do campo na SX3
		.And. QER->(FieldPos('QER_ITEMNF')) > 0 ; //Confirma existÍncia do campo na SX3

			//ProteÁ„o de execuÁ„o simult‚nea conforme instruÁ„o de Nilton Rodrigues
			lLock := LockByName("QIEXFUN_UQERNICONC_A", .T., .F.)

			If lLock

				oQueryManager := QLTQueryManager():New()

				cWhere += " WHERE (QER_NISERI = '" + Space(GetSx3Cache("QER_NISERI", "X3_TAMANHO")) + "') "
				cWhere += " AND (QER_NTFISC <> '" + Space(GetSx3Cache("QER_NTFISC", "X3_TAMANHO")) + "') "
				cWhere += " AND (D_E_L_E_T_ = ' ') "

				cIniQuery  += " SELECT R_E_C_N_O_ RECNOQER, QER_NTFISC, QER_SERINF, QER_ITEMNF "
				cQuery     += " FROM " + RetSQLName("QER") + cWhere

				cIniUpdate += " UPDATE " + RetSqlName("QER")
				cIniUpdate += " SET QER_NISERI = " + oQueryManager:acertaConcatenacaoComConcat("", "QER_NTFISC+QER_SERINF+QER_ITEMNF")

				//Valida existÍncia de dados para atualizaÁ„o
				//Registros com QER_NISERI vazio e QER_NTFISC preenchido
				cQuery  := oQueryManager:changeQuery(cIniQuery + cQuery)
				cAlias  := oQueryManager:executeQuery(cQuery)
				If !(cAlias)->(Eof())

					//Atualiza QER_NISERI com a concatenaÁ„o dos campos QER_NTFISC, QER_SERINF e QER_ITEMNF
					cUpdate := oQueryManager:changeQuery(cIniUpdate + cWhere)
					nStatus := TcSQLExec(cUpdate)

				EndIf

				//Garante liberaÁ„o do lock mesmo em caso de erro
				FreeObj(oQueryManager)
				If !Empty(cAlias)
					(cAlias)->(DbCloseArea())
				EndIf

				UnLockByName("QIEXFUN_UQERNICONC_A", .T., .F.)

				//LanÁa exceÁ„o apÛs liberaÁ„o do lock para n„o deix·-lo preso
				If nStatus <> Nil .And. nStatus <> 0
					UserException(TcSqlError())
				EndIf
			EndIf

		EndIf

		QER->(DbCloseArea())

	EndIf

Return

/*{Protheus.doc} RBE_QIE
FunÁ„o de compatibilizaÁ„o antes da execuÁ„o de Base do UPDDISTR.
@type Function
@author brunno.costa
@param  cVersion, Character, Vers„o do Protheus
@param  cMode, Character, Modo de execuÁ„o. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart, Character, Release de partida  Ex: 002
@param  cRelFinish, Character, Release del chegada Ex: 005
@param  cLocaliz, Character, LocalizaÁ„o (paÌs). Ex: BRA
@since 25/04/2025
*/
Function RBE_QIE(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

	Local lRBE := .T.

	If cMode == '1'
		Conout("[RBE_QIE] Versao: " + cVersion + " | " + "Modo: " + cMode + " | " + "Release Inicial:" + cRelStart + " | " + "Release Final: " + cRelFinish + " | " + "Pais : " + cLocaliz)
		Conout("[RBE_QIE] Inicio: " + Time())

		UQELNISERI(Nil, Nil, Nil, lRBE)
		UQERNISERI(Nil, Nil, Nil, lRBE)
		UQELNICONC(Nil, Nil, Nil, lRBE)
		UQERNICONC(Nil, Nil, Nil, lRBE)

		Conout("[RBE_QIE] Final : " + Time())
		EndIf

Return NIL

/*/{Protheus.doc} QIEValInst
FunÁ„o de validaÁ„o do modo de ediÁ„o dos campos QE7_TIPO e QE8_TIPO
@type  Function
@author brunno.costa
@since 30/04/2025
/*/
Function QIEValInst()

	Local lRet 		:= .T.

	If !GetMv("MV_QINTQMT") == "S"
		lRet := .F.
	Endif
	
Return lRet


