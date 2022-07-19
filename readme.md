# Allowance Smart Contract

Um contrato inteligente (Smart Contract) com funcionalidades de permissão de valor para alguma carteira crypto por um estimado período de tempo, bloqueando o acesso à esse valor após o prazo acabar. É possível atribuir mesada/subsídio especificando o valor e o tempo de permissão para a carteira, revogar a permissão e sacar os valores de volta do contrato.

O contrato foi feito em **Solidity**, destinado para blockchains como Ethereum, Polygon, ou qualquer outra que possua integração com a linguagem Solidity.

----

## Sumário das funções do contrato:

1. ### Funções de leitura de valores:
   
   1. #### [getTotalBalance](#gettotalbalance) (obterSaldoTotal)
   2. #### [getMyBalance](#getmybalance) (obterMeuSaldo)
   3. #### [getAllMyAllowanceBalances](#getallmyallowancebalances) (obterTodosOsMeusSaldosDeSubsídio)
   4. #### [getMyReservedBalanceFrom](#getmyreservedbalancefrom) (obterMeuSaldoReservadoDe)
   5. #### [getMyAllowanceFrom](#getmyallowancefrom) (obterMeuSubsídioDe)

2. ### Funções de subsídio:
   
   - #### Atribuir subsídio/mesada:
     1. #### [giveAllowance](#giveallowance) (atribuirSubsídio)
     2. #### [depositAndGiveAllowance](#depositandgiveallowance) (depositarEAtribuirSubsídio)
     3. #### [transferAndGiveAllowance](#transferandgiveallowance) (transferirEAtribuirSubsídio)
   - #### Revogar subsídio/mesada:
     1. #### [revokeAllowanceOf](#revokeallowanceof) (revogarSubsídioDe)
     2. #### [redeemFreeValueFromTheBalanceOf](#redeemfreevaluefromthebalanceof) (resgatarValorDisponívelDoSaldoDe)

3. ### Funções de saque:
   
   1. #### [withdrawFromMyBalance](#withdrawfrommybalance) (sacarDoMeuSaldo)
   2. #### [withdrawFromAllowance](#withdrawfromallowance) (sacarDeSubsídio)

---

## Funções de leitura de valores:

1. ### getTotalBalance (obterSaldoTotal)
   
   Obtém o saldo total do contrato, todo o valor que está depositado nele.

2. ### getMyBalance (obterMeuSaldo)
   
   Obtém o saldo da carteira que executa a função, o valor disponível que esta carteira possui depositada no contrato (um valor que é atribuído como subsídio/mesada à uma carteira não mais faz parte do saldo da carteira que atribuiu).

3. ### getAllMyAllowanceBalances (obterTodosOsMeusSaldosDeSubsídio)
   
    Obtém todo o saldo proveniente de subsídios/mesadas, a soma de todos os subsídios/mesadas atribuídas à carteira que executa a função.

4. ### getMyReservedBalanceFrom (obterMeuSaldoReservadoDe)
   
	Obtém da carteira passada como parâmetro o saldo de dinheiro reservado desta para a carteira que executa a função. 
    (Ex: a carteira A tem reservado 5 Ethers para a carteira B, mas dá um subsídio de apenas 1 Ether para a carteira B. Quando esta função for chamada pela carteira B retornará o valor de 5 Ether pois esse é o saldo que está reservado da carteira A para ela, mesmo que somente 1 Ether esteja disponível no subsídio.)

5. ### getMyAllowanceFrom (obterMeuSubsídioDe)

    Obtém os dados do subsídio/mesada recebido pela carteira que deve ser passada como parâmetro. Os dados são:
   
   - Índice (número identificador do subsídio)
   - Horário (quando o subsídio foi feito, em formato timestamp)
   - Duração (tempo de permissão do subsídio)
   - Tempo restante (quanto tempo resta até acabar a duração do subsídio)
   - Tempo atual do block (em formato timestamp)
   - Valor (valor permitido para sacar deste subsídio)

## Funções de subsídio:

- ### Atribuir subsídio/mesada:
  
  1. ### giveAllowance (atribuirSubsídio)
  2. ### depositAndGiveAllowance (depositarEAtribuirSubsídio)
  3. ### transferAndGiveAllowance (transferirEAtribuirSubsídio)

- ### Revogar subsídio/mesada:
  
  1. ### revokeAllowanceOf (revogarSubsídioDe)
  
  2. ### redeemFreeValueFromTheBalanceOf (resgatarValorDisponívelDoSaldoDe)

## Funções de saque:

1. ### withdrawFromMyBalance (sacarDoMeuSaldo)

2. ### withdrawFromAllowance (sacarDeSubsídio)
