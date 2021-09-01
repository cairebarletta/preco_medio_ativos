#carregando as bibliotecas necessarias
library(readxl)
library(openxlsx)
library(dplyr)

#lendo o arquivo excel
dados <- read_excel("operacoes.xlsx")

#funcao criada para calcular o preco medio
preco_medio <- function(acao){
  ticker <- dados %>%
    filter(ativo == acao)
  
  #criando a coluna de saldo das quantidades
  saldo <- NULL
  
  for (i in 1:length(ticker$tipo)) {
    if(ticker$tipo[i] == "C") {
      if(i == 1){
        saldo[i] <- ticker$qtd[i]
      }
      else{
        saldo[i] <- saldo[i-1] + ticker$qtd[i]
      }
    }
    if(ticker$tipo[i] == "V") {
      saldo[i] <- saldo[i-1] - ticker$qtd[i]
    }
  }
  
  ticker <- cbind(ticker, saldo)
  
  #criando a coluna de custo total
  custo_total <- NULL
  
  for (i in 1:length(ticker$tipo)) {
    if(ticker$tipo[i] == "C") {
      if(i == 1){
        custo_total[i] <- ticker$valor_total[i]
      }
      else{
        custo_total[i] <- custo_total[i-1] + ticker$valor_total[i]
      }
    }
    if(ticker$tipo[i] == "V") {
      custo_total[i] <- custo_total[i-1]
    }
  }
  
  ticker <- cbind(ticker, custo_total)
  
  #criando a coluna de preco medio de compra
  pm_compra <- NULL
  
  for (i in 1:length(ticker$tipo)){
    if(ticker$tipo[i] == "C"){
      if(i == 1){
        pm_compra[i] <- ticker$preco[i]
      }
      else{
        pm_compra[i] <- (pm_compra[i-1] * saldo[i-1] + ticker$valor_total[i]) / saldo[i]
      }
    }
    if(ticker$tipo[i] == "V"){
      pm_compra[i] <- pm_compra[i-1]
    }
  }
  
  ticker <- cbind(ticker, pm_compra)
  
  #criando a coluna de resultado das vendas (quando houve)
  resultado <- NULL
  
  for (i in 1:length(ticker$tipo)){
    if(ticker$tipo[i] == "C"){
      resultado[i] <- 0
    }
    else{
      resultado[i] <- ticker$preco[i] * ticker$qtd[i] - pm_compra[i] * ticker$qtd[i]
    }
  }
  
  ticker <- cbind(ticker, resultado)
  
  return(tail(ticker$pm_compra, 1))
}

#preco medio atual de cada ativo
ativos <- unique(dados$ativo)

pm_atual <- NULL

for (i in 1:length(ativos)){
  pm_atual[i] <- preco_medio(as.character(ativos[i]))
}

valores <- cbind(ativos, round(pm_atual, 2)) %>%
  as.data.frame() %>%
  mutate(PM = as.numeric(V2)) %>%
  select(c(ativos, PM))

#header em negrito
header <- createStyle(textDecoration = "bold",
                  wrapText = FALSE)

#formatacao dos numeros
form1 <- createStyle(numFmt = "0.00")

#criando a planilha
plan <- createWorkbook()
addWorksheet(plan, "precos_medios")

#escrevendo os dados na planilha
writeData(plan, sheet = 1, valores,
          startCol = 1,
          startRow = 1,
          headerStyle = header)

#adicionando a formatacao dos numeros
addStyle(plan, sheet = 1, style = form1,
         rows = 2:(nrow(valores) + 1),
         cols = 2)

#salvando a planilha
saveWorkbook(plan, file = "output.xlsx", overwrite = T)