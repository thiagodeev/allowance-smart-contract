# Allowance Smart Contract

Um contrato inteligente (Smart Contract) com funcionalidades de permissão de valor para alguma carteira crypto por um estimado período de tempo, bloqueando o acesso à esse valor após o prazo acabar. É possível atribuir mesada/subsídio especificando o valor e o tempo de permissão para a carteira, revogar a permissão e sacar os valores de volta do contrato.

O contrato foi feito em **Solidity**, destinado para blockchains como Ethereum, Polygon, ou qualquer outra que possua integração com a linguagem Solidity.

----

## Sumário das funções do contrato:

1. ### Funções de leitura de valores:
   
   1. #### [getTotalBalance](#gettotalbalance) (obterSaldoTotal)
   2. #### [getMyBalance](#getmybalance) (obterMeuSaldo)
   3. #### [getAllMyAllowanceBalances](#getallmyallowancebalances) (obterTodosOsMeusSaldosDeSubsídio)
   4. #### [getMyAllowanceBalanceFrom](#getmyallowancebalancefrom) (obterMeuSaldoDeSubsídioDe)
   5. #### [getMyAllowanceFrom](#getmyallowancefrom) (obterMeuSubsídioDe)

2. ### Funções de subsídio:
   
   1. #### [giveAllowance](#giveallowance) (obterSaldoTotal)

---

## Funções de leitura de valores:

1. ### getTotalBalance

2. ### getMyBalance

3. ### getAllMyAllowanceBalances

4. ### getMyAllowanceBalanceFrom

5. ### getMyAllowanceFrom

6. ### giveAllowance
