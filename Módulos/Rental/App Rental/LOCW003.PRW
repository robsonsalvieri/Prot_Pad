#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GetEmp      ³ Autor ³ Rafael P.Goncalves ³ Data ³05.04.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Responsavel por retornar todas empresas e filiais          ³±±
±±³Descricao ³ 		DESCONTINUADO  		                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*
WSRESTFUL GetEmp DESCRIPTION "Web Service REST para retornar empresas cadastradas."
	
	WSMETHOD GET DESCRIPTION "<h2>Metodo para retornar empresas cadastradas.</h2><br><br>Enviar no corpo em formato JSON.</strong> " WsSyntax "/GetEmp"
    
END WSRESTFUL

WsMethod Get WsService GetEmp
Local   _aCab       := {}
Local   _aLinha     := {}
Local   _aEmp       := FwLoadSm0()
Local   lPost       := .t.
Local   _lRet       := .f.
Local   _cJson      := ""
Local   _cMotivo    := ""
Local   cTrabName   := ""
Local 	nX			:= 1

Private cEmp        := _aEmp[1,1]
Private cFil        := _aEmp[1,2]
Private cModulo     := "FIN"

    /*---------------------------------------------*
    | Leitura e desserializacao do JSon.          |
    *---------------------------------------------*/

/*
    ::SetContentType("application/json")

    Begin Sequence

        RPCClearEnv() //Limpa o ambiente
        RPCSetType(3) //Não consome licença

        If RpcSetEnv(cEmp,cFil,,,"FIN",GetEnvServer(),{""})
            
            aAdd(_aCab,"M0_CODIGO"	)
            aAdd(_aCab,"M0_CODFIL"	)
            aAdd(_aCab,"M0_NOME"	)
            aAdd(_aCab,"M0_NOMECOM"	)
            aAdd(_aCab,"M0_FILIAL"	)
            aAdd(_aCab,"M0_CGC"		)
            aAdd(_aCab,"M0_LEIAUTE"	)
            
            cTrabName := Criatrab(Nil,.F.)

                For nX := 1 to Len(_aEmp)
                    aAdd(_aLinha,{_aEmp[nX,1]        , _aEmp[nX,2],;
                                Alltrim(_aEmp[nX,6]) , Alltrim(_aEmp[nX,7]),;
                                Alltrim(_aEmp[nX,17]), Alltrim(_aEmp[nX,18]),;
                                Alltrim(_aEmp[nX,13])+Alltrim(_aEmp[nX,14])+Alltrim(_aEmp[nX,15])})
                Next nX

            _cJson  := GetEmpArrJson(_aCab,_aLinha)	// Cabecalho, Linha
            
            _lRet := .t.
            
            DelClassIntf()	// Exclui todas classes de interface da thread

            RESET ENVIRONMENT

        EndIf
    End Sequence

    If _lRet
        ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"OK",'+_cJson+'}')))
    EndIf

Return lPost
*/
Function GetEmpArrJson()

Alert("Hello World")

Return ()
