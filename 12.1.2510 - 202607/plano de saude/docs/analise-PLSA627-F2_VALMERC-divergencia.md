# Análise: divergência F2_VALMERC × somatório SD2 — PLSA627

**Data:** 27/05/2026  
**Contexto:** NF Doc `001630`, Série `UNI`, Filial `M SP 01`  
**Solicitação:** identificar por que `MaFisRet(, "NF_VALMERC")` retorna valor menor que a soma dos itens SD2 durante execução da PLSA627.

---

## 1. Resumo do problema reportado

| Item SD2 | Valor |
|----------|------:|
| Item 01 | R$ 78,06 |
| Item 02 | R$ 50,00 |
| Item 03 | R$ 220,00 |
| **Total esperado** | **R$ 348,06** |

| Campo SF2 | Valor gravado |
|-----------|--------------:|
| `F2_VALMERC` | R$ 270,00 |

**Diferença:** R$ 78,06 — exatamente o valor do **item 01**.

Observação numérica relevante: `270,00 = 50,00 + 220,00` (itens 02 e 03). O item 01 **não compõe** o total fiscal do cabeçalho no momento da gravação do SF2.

---

## 2. Conclusão executiva

A divergência **não está em chamadas diretas ao motor fiscal dentro do PLSA627.PRW** (este fonte não invoca `MaFisIni`, `MaFisAdd`, `MaFisAlt` etc.). A NF é gerada pela cadeia:

```
PLSA627 ? PLGERREC (PLSA510.PRW) ? PLSTOSE1 (plstose1.prw) ? MaNfs2Nfs ? MaNfs2Nfs2 (mata461.prx)
```

O valor gravado em `F2_VALMERC` vem de:

```advpl
SF2->F2_VALMERC := MaFisRet(, "NF_VALMERC") - MaFisRet(, "NF_DESCONTO")
```

(`MaAvalSF2` — `mata461.prx`, linha ~11032)

A causa raiz **mais provável** está no **reprocessamento fiscal pós-gravação dos itens SD2** dentro de `MaNfs2Nfs2`, especificamente no par:

```advpl
If MaFisRet(nY, "IT_TES") == SD2->D2_TES
    MaFisAlt("IT_TES", "", nY)
EndIf
MaFisAlt("IT_TES", SD2->D2_TES, nY)
```

(`mata461.prx`, linhas ~10551–10554)

Seguido, quando CFGTRIB está ativo:

```advpl
If lTrbGen .And. !lNoFiscal
    MaFisRecal("IT_NORECAL", nY)
EndIf
```

(`mata461.prx`, linhas ~10563–10565)

Esse padrão pode **subtrair o item 01 de `NF_VALMERC`** via `MaFisSomaIt(nItem, .F.)` e **não repor** o valor após o recálculo com TES vazia, deixando `NF_VALMERC = 270,00`.

---

## 3. Como `NF_VALMERC` é calculado no motor fiscal

### 3.1 Agregação incremental (fluxo normal)

Quando um item é finalizado com `MaFisEndLoad(nItem, 2)`, o motor chama `MaFisSomaIt(nItem)`, que delega para `xFisSomaIt` em `IMPXFIS.prw`:

```advpl
aNfCab[NF_VALMERC] += aNfItem[nX][IT_VALMERC] - aNfItem[nX][IT_VNAGREG]
```

(`IMPXFIS.prw`, linha ~11132)

### 3.2 Alteração via `MaFisAlt`

Em `MaFisAlt` (`matxfis.prx`, linhas ~2905–2969), para campos de item (`IT_*`):

1. **`MaFisSomaIt(nItem, .F.)`** — subtrai o item do cabeçalho (`NF_VALMERC` diminui)
2. Altera o campo no `aNfItem`
3. **`MaFisRecal(cCampo, nItem)`** — recalcula tributos/valores conforme o campo alterado
4. **`MaFisSomaIt(nItem)`** — re-soma o item no cabeçalho

Se, após o passo 3, `IT_VALMERC` do item ficar **zerado** (comum ao limpar `IT_TES` para `""` e disparar `MaFisRecal("IT_TES")`), o passo 4 **re-soma zero** e `NF_VALMERC` **permanece reduzido**.

### 3.3 Rebuild parcial do cabeçalho

Em recálculos que acionam `MaFisImpIV` (`matxfis.prx`, linhas ~11686–11695), o cabeçalho é zerado e re-somado com a condição:

```advpl
If nItem <> nX .Or. lDespesas .Or. ...
```

Ou seja, durante o recálculo de um item, **o próprio item pode ficar temporariamente excluído** da soma do cabeçalho. Se `IT_VALMERC` estiver zerado nesse momento, o total fica incompleto.

---

## 4. Desk test — mecanismo provável no item 01

| Passo | Ação | `IT_VALMERC` (item 01) | `NF_VALMERC` |
|------:|------|------------------------|-------------:|
| 1 | Após inclusão dos 3 itens (`MaFisEndLoad`) | 78,06 | **348,06** |
| 2 | `MaFisAlt("IT_TES", "", 1)` — TES já igual à SD2 | 78,06 ? **0** | 348,06 ? 78,06 = **270,06** |
| 3 | `MaFisSomaIt(1)` após recalc com TES vazia | 0 | **270,06** (soma 0) |
| 4 | `MaFisAlt("IT_TES", D2_TES, 1)` — repõe TES | 0 ou não restaurado | **270,06** |
| 5 | Itens 02 e 03 passam pelo mesmo ciclo | valores preservados | **270,00** (arredondamento) |

**Interpretação:** o item 01 perde participação em `NF_VALMERC`; os demais itens mantêm seus valores. O resultado bate com o cenário reportado.

---

## 5. PLSA627 vs MATA461 — diferenças relevantes

| Aspecto | PLSA627 / PLSTOSE1 | MATA461 (faturamento padrão) |
|---------|-------------------|------------------------------|
| **Chamada ao motor** | Indireta via `MaNfs2Nfs` | Direta: `MaFisIni` ? `MaFisIniLoad` ? `MaFisLoad`/`MaFisTes` ? `MaFisRecal` ? `MaFisEndLoad` |
| **Montagem SD2** | `PLAGLUSD2` monta matriz com `D2_TOTAL`/`D2_PRCVEN`/`D2_TES` a partir de `aVlrCob` | Itens originados do pedido (SC6/SC9) com carga explícita de valores |
| **Valor do item no motor** | Carregado via `MaFisLoad` + `aRelImp` (`MaFisRelImp("MT100")`) a partir dos campos SD2 | `MaFisLoad("IT_VALMERC", SC6->C6_VALOR, nItem)` antes do recalc |
| **TES no motor** | Vem de `aVlrCob[38]` ? `D2_TES`; motor recebe via `aRelImp` | `MaFisTes(SC6->C6_TES, ...)` **antes** do recálculo completo |
| **Hook fiscal SD2** | `bFiscalSD2 := NIL` em `PLSTOSE1` | Pode ter PEs; fluxo padrão usa o mesmo trecho `MaNfs2Nfs2` |
| **Hook fiscal SF2** | Apenas `MaFisAlt("NF_NATUREZA", ..., lRecal := .F.)` | Natureza + demais campos conforme pedido |
| **Pré-carga F2_VALMERC** | `aSF2[F2_VALMERC] := nValor` (valor do título) em `PLSTOSE1` ~294 | Calculado integralmente pelo motor |
| **Gravação final SF2** | `MaAvalSF2` ? `MaFisRet(, "NF_VALMERC")` | Idem |

**Por que MATA461 “funciona” na comparação:** no fluxo nativo de pedido ? NF, o motor fiscal é alimentado **item a item durante o faturamento**, com `IT_VALMERC` e TES definidos **antes** do recálculo. O PLS monta a SD2 externamente e delega ao `MaNfs2Nfs`, que **reprocessa todos os itens** após a gravação com o padrão destrutivo de `MaFisAlt("IT_TES", "", nY)` quando TES motor = TES SD2.

> **Importante:** o trecho `MaNfs2Nfs2` (~10551+) é **código padrão TOTVS** em `mata461.prx`, compartilhado por PLS e faturamento. A diferença de comportamento tende a estar na **forma como os itens chegam ao motor** (valores, TES, CFGTRIB, ordem de processamento), não em um bug exclusivo do fonte PLSA627.

---

## 6. Hipóteses ordenadas por probabilidade

### 6.1 (Alta) Duplo `MaFisAlt("IT_TES")` zera `IT_VALMERC` do item 01

- **Onde:** `mata461.prx` ~10551–10554  
- **Sintoma:** `NF_VALMERC` = soma dos itens **exceto** o item 01  
- **Validação:** breakpoint após `MaFisAlt("IT_TES", "", 1)` — verificar se `MaFisRet(1, "IT_VALMERC")` vai a **0**

### 6.2 (Média) CFGTRIB + `MaFisRecal("IT_NORECAL")` altera `IT_VALMERC` do item 01

- **Onde:** `mata461.prx` ~10563–10565; `matxfis.prx` ~3347–3349  
- **Mecanismo:** `IT_NORECAL := "S"` e fluxo `xFisTrbGen` recalculam tributos genéricos; regra CFGTRIB pode projetar `IT_VALMERC` diferente de `D2_TOTAL`  
- **Validação:** comparar `MaFisRet(1, "IT_VALMERC")` vs `SD2->D2_TOTAL` após `MaFisRecal("IT_NORECAL", 1)`; simular item 01 no FISA176

### 6.3 (Média) Rebuild `lRefazNFCab` exclui item corrente

- **Onde:** `matxfis.prx` ~11686–11695  
- **Validação:** breakpoint em `MaFisImpIV` — se `NF_VALMERC = 270` após processar item 01 com `lRefazNFCab = .T.`

### 6.4 (Baixa) Pré-carga `F2_VALMERC` via `nValor` do título

- **Onde:** `plstose1.prw` ~294–295  
- **Nota:** valor é sobrescrito por `MaAvalSF2`, mas pode interagir com `MaFisLoad` via `aRelImp` no primeiro item  
- **Validação:** inspecionar `MaFisRet(, "NF_VALMERC")` logo após `MaFisIni` e após cada `MaFisEndLoad`

### 6.5 (Baixa) Item 01 marcado como `IT_DELETED` no motor

- **Validação:** `aNfItem[1][IT_DELETED]`, `Len(aNfItem)` vs quantidade de registros SD2

### 6.6 (Baixa) Entry Points PLS (`PL627AGL`, `PLSITEMO`)

- **Onde:** `plstose1.prw` ~352–354, ~932+  
- **Validação:** verificar se item 01 recebe TES/produto/campos diferentes dos demais

---

## 7. Checklist de debug para o analista

### A. Confirmar dados gravados (NF 001630)

```sql
-- Itens SD2
SELECT D2_ITEM, D2_COD, D2_TES, D2_TOTAL, D2_VALMERC, D2_DESCON, D2_PRCVEN, D2_QUANT
  FROM SD2010
 WHERE D2_FILIAL = '<filial>'
   AND D2_DOC    = '001630'
   AND D2_SERIE  = 'UNI'
   AND D_E_L_E_T_ = ' '
 ORDER BY D2_ITEM

-- Cabeçalho SF2
SELECT F2_VALMERC, F2_VALBRUT, F2_DESCONT, F2_VALFAT
  FROM SF2010
 WHERE F2_FILIAL = '<filial>'
   AND F2_DOC    = '001630'
   AND F2_SERIE  = 'UNI'
   AND D_E_L_E_T_ = ' '
```

### B. Breakpoints em `MaNfs2Nfs2` (`mata461.prx`)

| # | Linha (aprox.) | Inspecionar |
|---|----------------|-------------|
| 1 | ~10431 | Após `MaFisEndLoad` do 3º item: `MaFisRet(, "NF_VALMERC")` ? esperado **348,06** |
| 2 | ~10551 | Antes do clear de TES item 1: `MaFisRet(1, "IT_VALMERC")`, `MaFisRet(1, "IT_TES")`, `SD2->D2_TES` |
| 3 | ~10552 | Após `MaFisAlt("IT_TES", "", 1)`: `MaFisRet(1, "IT_VALMERC")` — **se 0, hipótese 6.1 confirmada** |
| 4 | ~10554 | Após `MaFisAlt("IT_TES", SD2->D2_TES, 1)`: `MaFisRet(1, "IT_VALMERC")` e `MaFisRet(, "NF_VALMERC")` |
| 5 | ~10564 | Após `MaFisRecal("IT_NORECAL", 1)`: repetir inspeção item 1 |
| 6 | ~11032 | Antes de `MaAvalSF2`: `MaFisRet(, "NF_VALMERC")` ? se **270**, motor já divergiu antes da gravação SF2 |

### C. Loop de inspeção por item (após reprocessamento)

```advpl
Local n
For n := 1 To 3
    ConOut("Item " + cValToChar(n) + ;
           " IT_VALMERC=" + cValToChar(MaFisRet(n, "IT_VALMERC")) + ;
           " IT_TES=" + MaFisRet(n, "IT_TES") + ;
           " IT_NORECAL=" + MaFisRet(n, "IT_NORECAL"))
Next n
// Usar FWLogMsg em produção — ConOut apenas para debug local
```

### D. CFGTRIB

- Verificar `SuperGetMV("MV_USATRIB")` / `NF_CHKTRIBLEG` / `NF_TEMF2B`
- Comparar `IT_VALMERC` vs `D2_TOTAL` **item a item** após `MaFisRecal("IT_NORECAL")`
- Simulador FISA176 para item 01 isolado

### E. Teste de isolamento (homologação)

Comentar **temporariamente** apenas o clear de TES:

```advpl
// If MaFisRet(nY, "IT_TES") == SD2->D2_TES
//     MaFisAlt("IT_TES", "", nY)
// EndIf
MaFisAlt("IT_TES", SD2->D2_TES, nY)
```

Se `F2_VALMERC` passar a **348,06** ? **causa confirmada** (hipótese 6.1).

> Atenção: alteração em `mata461.prx` é código padrão TOTVS. Preferir validação em homologação e, se confirmado, abrir demanda TOTVS ou aplicar correção via Entry Point / patch local documentado.

### F. Verificar montagem PLS antes do motor

- Quantidade de linhas em `aItemOri` antes de `MaNfs2Nfs` (`plstose1.prw` ~360)
- TES de cada item: `aVlrCob[nFor, 38]` ? `D2_TES` (`PLAGLUSD2` ~900)
- Parâmetros de aglutinação: `BQC_AGLUT`, `BA3_AGLUT`, `MV_PLGENCC`
- Se item 01 é crédito/débito (`aVlrCob[nFor, 1]`) — ordenação em ~320 pode afetar sequência

---

## 8. Pontos de atenção específicos do PLS (não do motor padrão)

Embora a causa provável esteja em `MaNfs2Nfs2`, o PLS apresenta particularidades que podem **facilitar** a manifestação do problema:

1. **`bFiscalSD2 := NIL`** — não há oportunidade de corrigir valores por item via hook fiscal antes do `MaFisRecal("IT_NORECAL")`.
2. **Montagem externa da SD2** — `PLAGLUSD2` define `D2_TOTAL := D2_PRCVEN` sem passar pelo recálculo item a item do pedido; o motor depende inteiramente do `aRelImp` + reprocessamento pós-gravação.
3. **Pré-carga `F2_VALMERC := nValor`** — valor do título, não necessariamente igual à soma dos itens após aglutinação.
4. **Ordenação crédito/débito** — `aVlrCob` ordenado por tipo (`plstose1.prw` ~320); item 01 pode ser o primeiro processado no loop de reprocessamento fiscal.

---

## 9. Referências de código

| Arquivo | Função/trecho | Linhas (aprox.) | Papel |
|---------|---------------|-----------------|-------|
| `PLSA627.PRW` | chamada `PLGERREC` | ~9366 | Entrada da geração de título/NF |
| `PLSA510.PRW` | `PLGERREC` ? `PLSTOSE1` | ~1362 | Ponte para geração NF |
| `plstose1.prw` | `PLAGLUSD2` | ~895–900 | Monta `D2_TOTAL`, `D2_TES` |
| `plstose1.prw` | `MaNfs2Nfs` | ~360 | Delega ao faturamento |
| `mata461.prx` | `MaNfs2Nfs2` — load SD2 no motor | ~10426–10431 | `MaFisLoad` + `MaFisEndLoad` |
| `mata461.prx` | `MaNfs2Nfs2` — reprocessamento TES | ~10551–10565 | **Ponto crítico** |
| `mata461.prx` | `MaAvalSF2` | ~11032 | Grava `F2_VALMERC` |
| `matxfis.prx` | `MaFisAlt` | ~2905–2969 | Subtrai/recalcula/re-soma |
| `matxfis.prx` | `MaFisRecal` case `IT_NORECAL` | ~3347–3349 | CFGTRIB sem legado |
| `IMPXFIS.prw` | `xFisSomaIt` | ~11132 | Agregação `NF_VALMERC` |

---

## 10. Próximos passos sugeridos

1. Executar checklist **B** e **C** em homologação com a NF 001630 (ou NF reproduzida).
2. Se confirmada hipótese 6.1, executar teste de isolamento **E**.
3. Se persistir após remover clear de TES, investigar CFGTRIB (checklist **D**) focando item 01.
4. Documentar resultado e decidir entre:
   - correção local (Entry Point em `bFiscalSD2` forçando `MaFisAlt("IT_VALMERC", SD2->D2_TOTAL, nY)` após reprocessamento), ou
   - demanda TOTVS para revisão do trecho `MaNfs2Nfs2` quando `IT_TES` motor já coincide com SD2.

---

## 11. Evidência de validação técnica

Análise validada por inspeção direta dos fontes:

- `mata461.prx`, `matxfis.prx`, `IMPXFIS.prw`, `plstose1.prw`, `PLSA510.PRW`, `PLSA627.PRW`

Consultas ao MCP `advpl-tlpp-mcp-docs` foram tentadas para complementar com documentação oficial; as ferramentas retornaram indisponibilidade no ambiente (`Invalid request parameters`). A conclusão baseia-se nos fontes indexados e no desk test descrito acima.

---

*Documento preparado para apoio ao analista Rafael Oliveira na investigação do cenário PLSA627 / F2_VALMERC.*
