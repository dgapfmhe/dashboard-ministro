##################################################################################################
# GESTI?N DE DATOS PARA PRON?STICOS MACROECON?MICOS
#################################################################################################
# Ministerio de Hacienda
# Direcci?n General de Estudios Fiscales 
# Analista encargado: Jose Antonio Vargas
#----------- Entorno de trabajo y paquetes necesarios---------
################################################################################################

rm(list = ls())# emilina objetos existentes en el entorno de R
path <-   "C:/Users/jlhc6/OneDrive/Escritorio/jose tarea/MH/datadgapf"
excelPath <- paste0(path, "/dataDGAPF_gg.xlsx")
dataPath <- paste0(path, "/datos")
setwd(dataPath)
Sys.setlocale("LC_TIME", "Spanish")

options(scipen = 999)
library(fredr)
library(tidyverse) #diversos paquetes: especialmente para el manejo de datos y visualizaci?n
library(stringr)
library(readr)
library(quantmod)
library(readxl)
library(tidyr)
library(openxlsx) #para leer archivos excel
library(rvest) #para realizar el web scraping
library(rjson) #para leer documentos .js
#library(boot)
#library(repr)
library(lubridate)
#library(tabulizer)
library(RODBC)
library(openxlsx)
library(RCurl)
library(httr) # conectar al API SB
library(jsonlite) # convertir un objeto JSON a objeto R
library(xts)
library(conflicted)
conflicts_prefer(dplyr::select, dplyr::filter, xts::last, base::sum)

#------------- Archivos a ser actualizados ------------------
###############################################################################################

cd <- Sys.Date()
cyear <- year(cd)
cmonth <- month(cd)
cday <- day(cd)
indicador_dia <- read_excel(excelPath,sheet = "data_diaria",  skip = 2)
indicadores <-  read_excel(excelPath,sheet = "data_mensual",  skip = 2)
data_eo <-  read_excel(excelPath, sheet = "data_eo", skip = 2)
indicadores_trim <- read_excel(excelPath, sheet = "data_trimestral", skip = 2)
data_BoP <-  read_excel(excelPath, sheet = "data_bop", skip = 2)
data_pii <-  read_excel(excelPath, sheet = "data_pii", skip = 2)
data_deuda <-  read_excel(excelPath, sheet = "data_deuda", skip = 2)
data_monetario <-  read_excel(excelPath, sheet = "data_monetario", skip = 2)
data_pm <-  read_excel(excelPath, sheet = "panorama_monetario", skip = 2)
proy_m <- read_excel(excelPath,sheet = "proyecciones_ext_mensuales",  skip = 2)
proy_t <- read_excel(excelPath,sheet = "proyecciones_ext_trimestrales",  skip = 2)

##----------Periodo de referencia-----
# periodo <- read_excel("maestras.xlsx", sheet = "Periodo")
# excel <- read_excel("maestras.xlsx", sheet = "Excel")
# col <-  read_excel("maestras.xlsx", sheet = "Excel")
meses <- c("Enero","Febrero",  "Marzo",  "Abril", "Mayo",  "Junio",  "Julio",  "Agosto",  "Septiembre", "Octubre","Noviembre","Diciembre")
fechaCorte <- paste(if(month(Sys.Date())==1)  year(Sys.Date())-1 else year(Sys.Date()),"-", switch (month(Sys.Date()),                                                                      "12",
                                                                                "01",
                                                                                "02",
                                                                                "03",
                                                                                "04",
                                                                                "05",
                                                                                "06",
                                                                                "07",
                                                                                "08",
                                                                                "09",
                                                                                "10",
                                                                                "11"
  ),"-", "01", sep = "")
  
  fechaCorteUD <- paste(substr(fechaCorte,1,8), days_in_month(fechaCorte), sep = "")
  fechaCorteL <- paste(fechaCorte, "UTC")
  anio <- if(month(Sys.Date())==1) year(Sys.Date())-1 else year(Sys.Date())
  
  mesCorte <- switch (month(Sys.Date()),
                      "diciembre",
                      "enero",
                      "febrero",
                      "marzo",
                      "abril",
                      "mayo",
                      "junio",
                      "julio",
                      "agosto",
                      "septiembre",
                      "octubre",
                      "noviembre")
  
  mesCorte2 <- switch (month(Sys.Date()),
                       "Diciembre",
                       "Enero",
                       "Febrero",
                       "Marzo",
                       "Abril",
                       "Mayo",
                       "Junio",
                       "Julio",
                       "Agosto",
                       "Septiembre",
                       "Octubre",
                       "Noviembre")
  
  nMes <- month(fechaCorte) 

anio1 <- year(Sys.Date())

if(nMes==1 & day(fechaCorteUD)<18) {
  Q <-"Q3"
  anioQ = anio1-1
}else if(nMes==1 & day(fechaCorteUD)>=18) {
  Q <-"Q4"
  anioQ = anio1-1
} else if(between(nMes,2,3)) {
  Q <-"Q4"
  anioQ = anio1-1
} else if(nMes==4 & day(fechaCorteUD)<18) {
  Q <-"Q4"
  anioQ = anio1-1
} else if(nMes==4 & day(fechaCorteUD)>=18) {
  Q <-"Q1"
  anioQ = anio1
} else if(between(nMes,5,6)) {
  Q <-"Q1"
  anioQ = anio1 
}  else if(nMes==7 & day(fechaCorteUD)< 18) {
  Q <-"Q1"
  anioQ = anio1
}  else if(nMes==7 & day(fechaCorteUD) >=18) {
  Q <-"Q2"
  anioQ = anio1
}  else if(between(nMes,8,9)) {
  Q <-"Q2"
  anioQ = anio1
} else if(nMes==10 & day(fechaCorteUD) < 18) {
  Q <-"Q2"
  anioQ = anio1
}  else if(nMes==10 & day(fechaCorteUD) >= 18) {
  Q <-"Q3"
  anioQ = anio1
} else if(nMes==11) {
  Q <-"Q3"
  anioQ = anio1
} else if(nMes==12) {
  Q <-"Q3"
  anioQ = anio1-1
}

##------ Variables diarias---------------#########################################################

start <- "2022-02-01"
dash_YD <- substr(indicador_dia$Date, 1,10)

download.file("https://cdn.bancentral.gov.do/documents/estadisticas/mercado-cambiario/documents/TASA_DOLAR_REFERENCIA_MC.xlsx?v=1737945788371?v=1737945788373", 
              destfile = "tasas_ref.xlsx",  mode="wb")
tcn <- read_excel("tasas_ref.xlsx",skip=2)
tasas_de_merc <- read_excel("M:/Direccion Politica y Estudios Fiscales/Estudios Fiscales/SIPROMFI/data/datos/tasas de mercado.xlsx")
t_act_rd <- read_excel("M:/Direccion Politica y Estudios Fiscales/Estudios Fiscales/SIPROMFI/data/datos/tasas de mercado.xlsx",sheet = 1)
t_pas_rd <- read_excel("M:/Direccion Politica y Estudios Fiscales/Estudios Fiscales/SIPROMFI/data/datos/tasas de mercado.xlsx",sheet = 2)
t_act_us <- read_excel("M:/Direccion Politica y Estudios Fiscales/Estudios Fiscales/SIPROMFI/data/datos/tasas de mercado.xlsx",sheet = 3)
t_pas_us <- read_excel("M:/Direccion Politica y Estudios Fiscales/Estudios Fiscales/SIPROMFI/data/datos/tasas de mercado.xlsx",sheet = 4)

fecha_pos <- which(year(indicador_dia$Date )==year(fechaCorte) & month(indicador_dia$Date )==month(Sys.Date()) & day(indicador_dia$Prd)==day(Sys.Date()))
mesA <- c("Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic")
fecha_pos <- which(year(indicador_dia$Date) == year(Sys.Date()) &
                     month(indicador_dia$Date) == month(Sys.Date()) &
                     day(indicador_dia$Date) == day(Sys.Date()))

meses_abrev <- c(
  Ene = 1, Feb = 2, Mar = 3, Abr = 4,
  May = 5, Jun = 6, Jul = 7, Ago = 8,
  Sep = 9, Oct = 10, Nov = 11, Dic = 12
)

tcn$Fecha <- as.Date(
  paste(
    tcn$Año,
    meses_abrev[tcn$Mes],
    tcn$Día,
    sep = "-"
  )
)

# EMBI

url <- "https://cdn.bancentral.gov.do/documents/entorno-internacional/documents/Serie_Historica_Spread_del_EMBI.xlsx?v=1634571720614"
download.file(url, destfile = "embi.xlsx", mode = "wb")
embi <- read_excel("embi.xlsx", skip = 1)
embi_filtrado <- embi %>%
  filter(Fecha >= as.Date("2022-01-01")) %>%
  select(Fecha, embi_valor = `REP DOM`)
indices <- match(as.Date(indicador_dia$Date), as.Date(embi_filtrado$Fecha))
indicador_dia$embi <- embi_filtrado$embi_valor[indices]

# tcn compra dolar
tcn_2022 <- tcn %>%
  filter(Fecha >= as.Date("2022-01-01")) %>%
  select(Fecha, Compra)

indicador_dia <- indicador_dia %>%
  left_join(
    tcn_2022,
    by = c("Date" = "Fecha")
  ) %>%
  mutate(
    tcn_compra = ifelse(
      Date >= as.Date("2022-01-01") & !is.na(Compra),
      Compra,
      tcn_compra
    )
  ) %>%
  select(-Compra)

# Actualizar tcn_venta dolar

tcnv_2022_v <- tcn %>%
  filter(Fecha >= as.Date("2022-01-01")) %>%
  select(Fecha, Venta)

indicador_dia <- indicador_dia %>%
  left_join(
    tcnv_2022_v,
    by = c("Date" = "Fecha")
  ) %>%
  mutate(
    tcn_venta = ifelse(
      Date >= as.Date("2022-01-01") & !is.na(Venta),
      Venta,
      tcn_venta
    )
  ) %>%
  select(-Venta)

# Actualizar tcn_venta euro
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/mercado-cambiario/documents/TASAS_CONVERTIBLES_OTRAS_MONEDAS.xlsx?v=1777566722976"
download.file(url, destfile = "tcn_eur.xlsx", mode = "wb")
tcn_eur <- read_excel("tcn_eur.xlsx", skip = 2)

tcn_eur$Fecha <- as.Date(paste(tcn_eur$Año,meses_abrev[tcn_eur$Mes],tcn_eur$Día,sep = "-"))

euro <- as.data.frame(tcn_eur$Fecha,tcn_eur$"EURO")
idx_destino <- match(tcn_eur$Fecha, dash_YD)
indicador_dia$tcn_venta_eur[idx_destino[!is.na(idx_destino)]] <- euro[!is.na(idx_destino)]

# tcn spread
indicador_dia$tcn_venta  <- as.numeric(indicador_dia$tcn_venta)
indicador_dia$tcn_compra <- as.numeric(indicador_dia$tcn_compra)
indicador_dia$tcn_usa_spread <- indicador_dia$tcn_venta - indicador_dia$tcn_compra

# yf tickers

getSymbols("CL=F", from = start, to = cd)
Oil <- as.data.frame(`CL=F`)  
Oil$Fecha <- row.names(Oil)
Oil_YD <- substr(Oil$Fecha, 1, 10)
getSymbols("GC=F", from = start, to = cd)
Gold <- as.data.frame(`GC=F`) 
Gold$Fecha <- row.names(Gold)
Gold_YD <- substr(Gold$Fecha, 1, 10)
getSymbols("NG=F", from = start, to = cd)
NG <- as.data.frame(`NG=F`)
NG$Fecha = row.names(NG)
NG_YD <- substr(NG$Fecha, 1, 10)
getSymbols("MTF=F", from = start, to = cd)
Coal <- as.data.frame(`MTF=F`)
Coal$Fecha = row.names(Coal)
Coal_YD <- substr(Coal$Fecha, 1, 10)
getSymbols("^GSPC", from = start, to = cd)
sp500 <- as.data.frame(`GSPC`)
sp500$Fecha = row.names(sp500)
sp500_YD <- substr(sp500$Fecha, 1, 10)
getSymbols("DGS10", src = "FRED", from = start, to = cd)
dgs10 <- as.data.frame(`DGS10`)
dgs10$Fecha = row.names(dgs10)
dgs10_YD <- substr(dgs10$Fecha, 1, 10)
getSymbols("^VIX", from = start, to = cd)
vix <- as.data.frame(`VIX`)  
vix$Fecha <- row.names(vix)
vix_YD <- substr(vix$Fecha, 1, 10)
getSymbols("^DJI", from = start, to = cd)
bolsa_DowJones <- as.data.frame(`DJI`)  
bolsa_DowJones$Fecha <- row.names(bolsa_DowJones)
bolsa_DowJones_YD <- substr(bolsa_DowJones$Fecha, 1, 10)
bolsa_DowJones

idx14 <- match(dash_YD, Oil_YD)
idx15 <- match(dash_YD, Gold_YD)
idx16 <- match(dash_YD, NG_YD)
idx17 <- match(dash_YD, Coal_YD)
idx18 <- match(dash_YD, sp500_YD)
idx19 <- match(dash_YD, dgs10_YD)
idx20 <- match(dash_YD, vix_YD)
idx21 <- match(dash_YD, bolsa_DowJones_YD)

indicador_dia$p_petroleo <- Oil$`CL=F.Close`[idx14]
indicador_dia$carb_aus <- Coal$`MTF=F.Close`[idx17]
indicador_dia$p_oro <- Gold$`GC=F.Close`[idx15]
indicador_dia$p_gas_nat <- NG$`NG=F.Close`[idx16]
indicador_dia$sp500 <- sp500$`GSPC.Close`[idx18]
indicador_dia$DGS10 <- dgs10$`DGS10`[idx19]
indicador_dia$vix <- vix$`VIX.Close`[idx20]
indicador_dia$bolsa_DowJones <- bolsa_DowJones$DJI.Close[idx21]

# vix_y DJIA mensual
getSymbols("^VIX", from = 1990, to = cd)
dash_mth <- substr(indicadores$Codigo, 1,10)

VIX_mensual <- to.monthly(VIX, indexAt = "firstof", OHLC = FALSE)

VIX <- as.data.frame(VIX_mensual)
VIX$Fecha <- row.names(VIX)

pos_ene_90 <- which(indicadores$Codigo=="1990M1")
VIX <- data.frame(periodo = indicadores$Codigo[pos_ene_90:(pos_ene_90+nrow(VIX)-1)], VIX)
idxb3 <- match(dash_mth, VIX$periodo)

indicadores$vix <- VIX$VIX.Close[idxb3]

pos_ene_92 <- which(indicadores$Codigo=="1992M1")
getSymbols("^DJI", from = 1992, to = cd)
dash_mth <- substr(indicadores$Codigo, 1,10)

DJI_mensual <- to.monthly(DJI, indexAt = "firstof", OHLC = FALSE)

bolsa_DowJones <- as.data.frame(DJI_mensual)
bolsa_DowJones$Fecha <- row.names(bolsa_DowJones)

bolsa_DowJones <- data.frame(periodo = indicadores$Codigo[pos_ene_92:(pos_ene_92+nrow(bolsa_DowJones)-1)], bolsa_DowJones)
idxb2 <- match(dash_mth, bolsa_DowJones$periodo)



indicadores$bolsa_DowJones <- bolsa_DowJones$DJI.Close[idxb2]

dias <- c(1:31)

#TAPRD26 
TAPRD26 <- read_excel("tdia_2026.xlsx", skip =9,sheet = "ACTRD$") %>% 
  select(1,8) %>%
  drop_na()
TAPRD26=TAPRD26 %>% 
  rename("Dia"=names(TAPRD26[1]),
         "TAP"=names(TAPRD26[2]))
TAPRD26 <- TAPRD26 %>% 
  mutate("Mes"=TAPRD26$Dia) 
TAPRD26$Mes <- ifelse(TAPRD26$Mes%in%dias,NA,TAPRD26$Mes)
TAPRD26 <- TAPRD26 %>% 
  fill(Mes,.direction = "down") %>% 
  relocate(Mes,Dia) %>% 
  mutate(
    Mes = str_remove_all(Mes, "//*|2/"), 
    Mes = str_trim(Mes))

TAPRD26$Dia <- ifelse(TAPRD26$Dia%in%meses,NA,TAPRD26$Dia)
TAPRD26$Dia <- ifelse(grepl("\\*", TAPRD26$Dia), NA, TAPRD26$Dia)
TAPRD26 <- TAPRD26 %>% 
  drop_na(Dia)

TAPRD26 <- TAPRD26 %>%
  mutate(Fecha_Texto = paste(Dia, Mes, "2026", sep = "-")) %>%
  mutate(Date = dmy(Fecha_Texto)) %>% 
  select(5,1:3)

indicador_dia <- indicador_dia %>%
  left_join(TAPRD26 %>% select(Date, TAP_temp = TAP), by = "Date") %>%
  mutate(across(14, ~ coalesce(., TAP_temp))) %>% 
  select(-TAP_temp)

# TPPRD26
TPPRD26 <- read_excel("tdia_2026.xlsx", skip = 9,sheet = "PASRD$")%>% 
  select(1,10) %>%
  drop_na()
TPPRD26 <- TPPRD26 %>% 
  rename("Dia"=names(TPPRD26[1]),
         "TPP"=names(TPPRD26[2]))
TPPRD26 <- TPPRD26 %>% 
  mutate("Mes"=TPPRD26$Dia) 
TPPRD26$Mes <- ifelse(TPPRD26$Mes%in%dias,NA,TPPRD26$Mes)
TPPRD26 <- TPPRD26 %>% 
  fill(Mes,.direction = "down") %>% 
  relocate(Mes,Dia) %>% 
  mutate(
    Mes = str_remove_all(Mes, "//*|2/"), 
    Mes = str_trim(Mes))

TPPRD26$Dia <- ifelse(TPPRD26$Dia%in%meses,NA,TPPRD26$Dia) 
TPPRD26$Dia <- ifelse(grepl("\\*", TPPRD26$Dia), NA, TPPRD26$Dia)

TPPRD26 <- TPPRD26 %>% 
  drop_na(Dia)

TPPRD26 <- TPPRD26 %>%
  mutate(Fecha_Texto = paste(Dia, Mes, "2026", sep = "-")) %>%
  mutate(Date = dmy(Fecha_Texto)) %>% 
  select(5,1:3)

indicador_dia <- indicador_dia %>%
  left_join(TPPRD26 %>% select(Date, TPP_temp = TPP), by = "Date") %>%
  mutate(across(16, ~ coalesce(., TPP_temp))) %>% # Actualiza la col 17 si está vacía
  select(-TPP_temp)

# TAPUS26

TAPUS26 <- read_excel("tdia_2026.xlsx", skip = 9,sheet = "ACTUS$")%>% 
  select(1,8) %>%
  drop_na()
TAPUS26 <- TAPUS26 %>% 
  rename("Dia"=names(TAPUS26[1]),
         "TAP"=names(TAPUS26[2]))
TAPUS26 <- TAPUS26 %>% 
  mutate("Mes"=TAPUS26$Dia) 
TAPUS26$Mes <- ifelse(TAPUS26$Mes%in%dias,NA,TAPUS26$Mes)
TAPUS26 <- TAPUS26 %>% 
  fill(Mes,.direction = "down") %>% 
  relocate(Mes,Dia) %>% 
  mutate(
    Mes = str_remove_all(Mes, "//*|2/"), 
    Mes = str_trim(Mes))

TAPUS26$Dia <- ifelse(TAPUS26$Dia%in%meses,NA,TAPUS26$Dia) 
TAPUS26$Dia <- ifelse(grepl("\\*", TAPUS26$Dia), NA, TAPUS26$Dia)

TAPUS26 <- TAPUS26 %>% 
  drop_na(Dia)

TAPUS26 <- TAPUS26 %>%
  mutate(Fecha_Texto = paste(Dia, Mes, "2026", sep = "-")) %>%
  mutate(Date = dmy(Fecha_Texto)) %>% 
  select(5,1:3)

indicador_dia <- indicador_dia %>%
  left_join(TAPUS26 %>% select(Date, TAP_temp = TAP), by = "Date") %>%
  mutate(across(15, ~ coalesce(., TAP_temp))) %>% # Actualiza la col 17 si está vacía
  select(-TAP_temp)

# TPPUS26

TPPUS26 <- read_excel("tdia_2026.xlsx", skip = 9,sheet = "PASUS$") %>% 
  select(1,10) %>%
  drop_na()
TPPUS26 <- TPPUS26 %>% 
  rename("Dia"=names(TPPUS26[1]),
         "TPP"=names(TPPUS26[2]))
TPPUS26 <- TPPUS26 %>% 
  mutate("Mes"=TPPUS26$Dia) 
TPPUS26$Mes <- ifelse(TPPUS26$Mes%in%dias,NA,TPPUS26$Mes)
TPPUS26 <- TPPUS26 %>% 
  fill(Mes,.direction = "down") %>% 
  relocate(Mes,Dia) %>% 
  mutate(
    Mes = str_remove_all(Mes, "//*|2/"), 
    Mes = str_trim(Mes))

TPPUS26$Dia <- ifelse(TPPUS26$Dia%in%meses,NA,TPPUS26$Dia) 
TPPUS26$Dia <- ifelse(grepl("\\*", TPPUS26$Dia), NA, TPPUS26$Dia)
TPPUS26 <- TPPUS26 %>% 
  drop_na(Dia)

TPPUS26 <- TPPUS26 %>%
  mutate(Fecha_Texto = paste(Dia, Mes, "2026", sep = "-")) %>%
  mutate(Date = dmy(Fecha_Texto)) %>% 
  select(5,1:3)

indicador_dia <- indicador_dia %>%
  left_join(TPPUS26 %>% select(Date, TPP_temp = TPP), by = "Date") %>%
  mutate(across(17, ~ coalesce(., TPP_temp))) %>% 
  select(-TPP_temp)

##------ Datos Banco Central de la Rep?lica Dominicana---------------###################

# Posiciones a ser actualizadas
posFecCor <- which(ym(indicadores$Codigo)==fechaCorte)
posEne <- which(ym(indicadores$Codigo)== paste0(year(fechaCorte),"-01-01"))
fecEne <- paste0(year(fechaCorte),"-01-01")
posPA <- posEne:posFecCor
pos_enero <- which(year(ym(indicadores$Codigo))==anio & month(ym(indicadores$Codigo))==1)
### IMAE 

#### Descargando y leyendo archivo IMAE

url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-real/documents/imae_2018.xlsx?v=1759177462005"
download.file(url, destfile = "imae.xlsx", mode = "wb")
imae <- read_excel("imae.xlsx", skip = 7)
pib_real <- imae[imae$...2 %in% meses, ]$Interanual...4
imae <- imae[imae$...2 %in% meses, ]$...3

pos_ene_07 <- which(indicadores$Codigo=="2007M1")
indicadores$IMAE[pos_ene_07:(pos_ene_07+length(imae)-1)] <- imae
indicadores$pib_real[pos_ene_07:(pos_ene_07+length(pib_real)-1)] <- pib_real


### Descargando y leyendo archivo IPC
url <-"https://cdn.bancentral.gov.do/documents/estadisticas/precios/documents/ipc_base_2019-2020.xls?v=1632881513714"
download.file(url, destfile = "IPC.xls", mod = "wb")
ipc <- read_excel("IPC.xls", skip = 5)
ipc <- ipc[ipc$...2 %in% meses, ]$`12 meses...6`
indicadores$inf_rd[1:length(ipc)] <- ipc

#### IPC subyacente
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/precios/documents/ipc_subyacente_base_2019-2020.xlsx?v=1635263919988"
download.file(url, destfile = "inf_sub.xlsx", mod="wb")
inf_sub <- read_excel("inf_sub.xlsx",skip = 4)
inf_sub <- inf_sub[inf_sub$...2 %in% meses, ]$Interanual
pos_ene_00 <- which(indicadores$Codigo=="2000M1")
indicadores$inf_sub[pos_ene_00:(pos_ene_00 + length(inf_sub) - 1)] <- inf_sub

#### IPC transable/no transable
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/precios/documents/ipc_tnt_base_2019-2020.xls?v=1635263919988"
download.file(url, destfile = "IPCTNt.xls", mod="wb")
inf_trans <- read_excel("IPCTNt.xls", skip = 4)
inf_trans <- inf_trans[inf_trans$...2 %in% meses, ]$General
pos_feb_99 <- which(indicadores$Codigo=="1999M2")
indicadores$inf_trans[pos_feb_99:(pos_feb_99 + length(inf_trans) - 1)] <- inf_trans

inf_no_trans <- read_excel("IPCTNt.xls", skip = 4)
inf_no_trans <- inf_no_trans[inf_no_trans$...2 %in% meses, ]$`No Transables`
pos_feb_99 <- which(indicadores$Codigo=="1999M2")
indicadores$inf_no_trans[pos_feb_99:(pos_feb_99 + length(inf_no_trans) - 1)] <- inf_no_trans


#### IPC por articulos
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/precios/documents/ipc_articulos_base_2019-2020.xlsx?v=1635262341853"
download.file(url, destfile = "IPCArt.xlsx", mod="wb")


#### IPC por bienes y servicios diversos
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/precios/documents/ipc_grupos_base_2019-2020.xls?v=1776776092815"
download.file(url, destfile = "IPCbysd.xls", mod="wb")
pos_ene_99 <- which(indicadores$Codigo=="1999M1")
bysd <- read_excel("IPCbysd.xls", skip = 4)

inf_BySD <- bysd[bysd$...1 %in% meses, ]$...24
indicadores$inf_BySD[pos_ene_99:(pos_ene_99 + length(inf_BySD) - 1)] <- inf_BySD
inf_RyH <- bysd[bysd$...1 %in% meses, ]$...22
indicadores$inf_RyH[pos_ene_99:(pos_ene_99 + length(inf_RyH) - 1)] <- inf_RyH
inf_edu <- bysd[bysd$...1 %in% meses, ]$...20
indicadores$inf_edu[pos_ene_99:(pos_ene_99 + length(inf_edu) - 1)] <- inf_edu
inf_Ryc <- bysd[bysd$...1 %in% meses, ]$...18
indicadores$inf_Ryc[pos_ene_99:(pos_ene_99 + length(inf_Ryc) - 1)] <- inf_Ryc
inf_com <- bysd[bysd$...1 %in% meses, ]$...16
indicadores$inf_com[pos_ene_99:(pos_ene_99 + length(inf_com) - 1)] <- inf_com
inf_transport <- bysd[bysd$...1 %in% meses, ]$...14
indicadores$inf_transport[pos_ene_99:(pos_ene_99 + length(inf_transport) - 1)] <- inf_transport
inf_sal <- bysd[bysd$...1 %in% meses, ]$...12
indicadores$inf_sal[pos_ene_99:(pos_ene_99 + length(inf_sal) - 1)] <- inf_sal
inf_mue <- bysd[bysd$...1 %in% meses, ]$...10
indicadores$inf_mue[pos_ene_99:(pos_ene_99 + length(inf_mue) - 1)] <- inf_mue
inf_viv <- bysd[bysd$...1 %in% meses, ]$...8
indicadores$inf_viv[pos_ene_99:(pos_ene_99 + length(inf_viv) - 1)] <- inf_viv
inf_vestir <- bysd[bysd$...1 %in% meses, ]$'y Calzado'
indicadores$inf_vestir[pos_ene_99:(pos_ene_99 + length(inf_vestir) - 1)] <- inf_vestir
inf_BAyT <- bysd[bysd$...1 %in% meses, ]$'y Tabaco'
indicadores$inf_BAyT[pos_ene_99:(pos_ene_99 + length(inf_BAyT) - 1)] <- inf_BAyT
inf_AyBNA <- bysd[bysd$...1 %in% meses, ]$...2
indicadores$inf_AyBNA[pos_ene_99:(pos_ene_99 + length(inf_AyBNA) - 1)] <- inf_AyBNA

view(indicadores)

### ICI
url <-"https://cdn.bancentral.gov.do/documents/politica-monetaria/expectativas-macroeconomicas/documents/Historico-EOE-(Mensual).xlsx?v=1633704618191"
download.file(url, destfile = "expE.xlsx", mod = "wb")
expE <- read_excel("expE.xlsx", skip = 5)
indicadores$ICI[(pos_ene_07-6):((pos_ene_07-7)+nrow(expE))] <- unlist(expE[,12])

### Tipo de Cambio entidades financiera
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/mercado-cambiario/documents/TASA_ENTIDADES_FINANCIERAS.xls?v=1652187771673"
download.file(url, destfile = "tc.xls", mode = "wb")
excel_sheets("tc.xls")
tc <- read_excel("tc.xls", sheet = "Mensual", skip = 2)
tcTrim <- read_excel("tc.xls", sheet = "Trimestral", skip = 2)

pos_ene_92 <- which(indicadores$Codigo=="1992M1")
indicadores$tcn_compra[pos_ene_92:(pos_ene_92+nrow(tc)-1)] <- tc$Compra
indicadores$tcn_venta[pos_ene_92:(pos_ene_92+nrow(tc)-1)] <- tc$Venta
indicadores$tcr_rd <- (indicadores$tcn_venta/1.358727436*indicadores$ipc_eeuu/218.076*100)/indicadores$ipc
#se divide el ipc de 2020 con el coeficiente de enlace para convertir al ipc de 2010. 
# Luego se divide entre el promedio del cpi de 2010 al cpi para convertirlo a su Prd base 
indicadores$tcn_usa_spread <- indicadores$tcn_venta-indicadores$tcn_compra

# Actualizar tcn_venta euro
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/mercado-cambiario/documents/TASAS_CONVERTIBLES_OTRAS_MONEDAS.xlsx?v=1777566722976"
download.file(url, destfile = "tcn_eur.xlsx", mode = "wb")
tcn_eur <- read_excel("tcn_eur.xlsx", skip = 2,sheet = "Mensual")
euro <- tcn_eur$"EURO"

pos_ene_04 <- which(indicadores$Codigo=="2004M1")
indicadores$tcn_eur[pos_ene_04:(pos_ene_04+nrow(tcn_eur)-1)] <- euro

### Valor importaciones petrolera y derivados
#### Estableciendo fecha para el excel

#### Fecha de inicio enero 2010
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-externo/documents/Importaciones_Crudo_6.xls?v=1633706202582"
download.file(url, 
              destfile = "impPetreloD.xls", 
              mode = "wb")
impPetreloD <- read_excel("impPetreloD.xls", skip = 5)

impPetreloD <- na.omit(impPetreloD)
impPetreloD <- impPetreloD[unlist(impPetreloD[, 1]) %in% meses, ]
pos_ene_10 <- which(indicadores$Codigo=="2010M1")
indicadores$imp_pd_va[pos_ene_10:(pos_ene_10+nrow(impPetreloD)-1)] <- unlist(impPetreloD[, ncol(impPetreloD)])
indicadores$m_pqoil_rd[pos_ene_10:(pos_ene_10+nrow(impPetreloD)-1)] <- as.numeric(unlist(impPetreloD[, ncol(impPetreloD)-2]))/1000000

### Remesas familiares
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-externo/documents/Remesas_6.xlsx?v=1633710689799"
download.file(url, 
              destfile = "remFam.xlsx", 
              mode = "wb")

remFam <- read_excel("remFam.xlsx", skip = 5)
remFam <- remFam[1:12, ]
remFam <- gather(remFam, key = "anio", value = "valor", -1)
remFam <- na.omit(remFam)
indicadores$rem_fam[pos_ene_10:(pos_ene_10+nrow(remFam)-1)] <- remFam$valor/1000000

### Llegadas de turistas
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-turismo/documents/lleg_total.xls?v=1633708226777"
download.file(url, 
              destfile = "llagadaTur.xls", 
              mode = "wb")
llegadaTur <- read_excel("llagadaTur.xls", skip = 7)

llegadaTur <- llegadaTur[!is.na(llegadaTur[, 2]), ]
llegadaTur <- llegadaTur[unlist(llegadaTur[, 1]) %in% meses, ]
llegadaTur <- window(ts(llegadaTur, start = c(1978, 1), frequency = 12), start = c(1984,1))
indicadores$se_cc_numtur[1:nrow(llegadaTur)] <- unlist(llegadaTur[, 2])

### Base monetaria
#### Fecha de inicio dicimebre 2001
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/base_monetaria.xlsx?v=1679415689613"
download.file(url, 
              destfile = "baseMon.xlsx", 
              mode = "wb")

baseMon <- read_excel("baseMon.xlsx", skip = 11)
baseMon <- na.omit(baseMon)
bm <- as.numeric(unlist(baseMon[, 6]))
pos_dic_01 <- which(indicadores$Codigo=="2001M12")
indicadores$bmr_rd[pos_dic_01:(pos_dic_01+length(bm)-1)] <- bm

### Medio circulante (M1)
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/agregados_monetarios.xlsx?v=1679417565251"
download.file(url, destfile = "Agregados.xlsx", mode = "wb")
agregados <- read_excel("Agregados.xlsx", skip = 10)
agregados <- na.omit(agregados[, 1:12])
indicadores$M1[pos_dic_01:(pos_dic_01+nrow(agregados)-1)] <- unlist(agregados[, 5])
indicadores$M2[pos_dic_01:(pos_dic_01+nrow(agregados)-1)] <- unlist(agregados[, 8])
indicadores$M3[pos_dic_01:(pos_dic_01+nrow(agregados)-1)] <- unlist(agregados[, 12])

### Credito Sectorial 

#### Fecha de inicio enero 1996
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/serie_prestamos_por_destino_armonizados.xlsx?v=1633718726308"
download.file(url, destfile = "creditoSectorial.xlsx", mode = "wb")
creditoSectorial <- read_excel("creditoSectorial.xlsx", skip = 7)

cs <- t(creditoSectorial[,-1])
cn <- unlist(creditoSectorial[,1])
cs <- window(ts(cs, start = 1996, frequency = 12), start = c(1996, 1), end = c(anio, nMes))
pos_ene_96 <- which(indicadores$Codigo=="1996M1")
indicadores$pvcred_nc_rd[pos_ene_96:(pos_ene_96+nrow(cs)-1)] <- cs[, which(cn=="SECTOR PRIVADO M/N")][,1]
indicadores$prest_tot[pos_ene_96:(pos_ene_96+nrow(cs)-1)] <- cs[, which(cn=="SECTOR PRIVADO (CONSOLIDADO)")][,1]
indicadores$prest_agr[pos_ene_96:(pos_ene_96+nrow(cs)-1)] <- cs[, which(cn=="AGRICULTURA, SILVICULTURA Y PESCA (4)")][,1]
indicadores$prest_ind[pos_ene_96:(pos_ene_96+nrow(cs)-1)] <- cs[, which(cn=="INDUSTRIAS MANUFACTURERAS")][,3]
indicadores$prest_con[pos_ene_96:(pos_ene_96+nrow(cs)-1)] <- cs[, which(cn=="CONSTRUCCIÓN")][,3]
indicadores$prest_com[pos_ene_96:(pos_ene_96+nrow(cs)-1)] <- cs[, which(cn=="COMERCIO AL POR MAYOR Y AL POR MENOR")][, 3]
indicadores$prest_viv[pos_ene_96:(pos_ene_96+nrow(cs)-1)] <- cs[, which(cn=="ADQUISICIÓN DE VIVIENDAS")][, 3]
indicadores$prest_cons[pos_ene_96:(pos_ene_96+nrow(cs)-1)] <- cs[, which(cn=="PRÉSTAMOS DE CONSUMO")[3]]
indicadores$prest_tar[pos_ene_96:(pos_ene_96+nrow(cs)-1)] <- cs[, which(cn=="TARJETAS DE CRÉDITO")[3]]

### Credito al Sector P?blico y Pivado

url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/serie_indicadores_osd.xlsx?v=1633718726308"
download.file(url, destfile = "credito.xlsx", mode = "wb")
credito <- read_excel("credito.xlsx", skip = 3)
credito <- t(credito)
credito <- as.numeric(credito[-1, which(credito[1,]=="SECTOR PÚBLICO")][, 1])
indicadores$pbcred_nc_rd[pos_ene_96:(pos_ene_96+length(credito)-1)] <- credito

### Indicadores Armonizados BCRD

#### Fecha de inicio enero 1996
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/serie_indicadores_bcrd.xlsx?v=1634568400821"
download.file(url, destfile = "IndAmoBCRD.xlsx", mode = "wb")
IndAmoBCRD <- read_excel("IndAmoBCRD.xlsx", skip = 4)
indicadores$sm_bcrd_vc[pos_ene_96:(pos_ene_96+ncol(IndAmoBCRD)-2)] <- unlist(IndAmoBCRD[which(IndAmoBCRD[,1]=="VALORES EN CIRCULACION (6)"), ])[-1]

### Encaje Bancario 

#### Fecha de inicio enero 2001

url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/encaje_bancario.xlsx?v=1679417565251"
download.file(url, destfile = "encaje.xlsx", mode = "wb")

encaje <- read_excel("encaje.xlsx", skip = 11)
encaje <- na.omit(encaje)
indicadores$encajemn_d_q[pos_dic_01:(pos_dic_01+nrow(encaje)-1)] <- unlist(encaje[, ncol(encaje)-8])
indicadores$encajeme_d_q[pos_dic_01:(pos_dic_01+nrow(encaje)-1)] <- unlist(encaje[, ncol(encaje)-1])

### Operaciones Compra Total de D?lares Estadounidenses

url <- "https://cdn.bancentral.gov.do/documents/estadisticas/mercado-cambiario/documents/Operaciones_us.xls?v=1633717713695"
download.file(url, 
              destfile = "compraDolar.xls", 
              mode = "wb")

compraDolar <- read_excel("compraDolar.xls", skip = 12)
compraDolar <- na.omit(compraDolar)
pos_ene_04 <- which(indicadores$Codigo=="2004M1")
indicadores$compra_fx_tot[pos_ene_04:(pos_ene_04+nrow(compraDolar)-1)] <- unlist(compraDolar[, ncol(compraDolar)-3])

### Inter?s
# Se debe descargar los Excel y colocarlo en la carpe 

##### Tasas activas
meses <- c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
           "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre","*Febrero 2/")

url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/tbm_activad.xlsx?v=1673968852556?v=1673968852558"
download.file(url, 
              destfile = "tbm_activad.xlsx", 
              mode = "wb")

TiActiva <- read_excel("tbm_activad.xlsx", skip = 5)
TiActiva <- na.omit(TiActiva)
#colnames(TiActiva)
TiActiva <- separate(TiActiva,col = "...1", into = c("mes", "anio"), sep = "(?= 2025)|(?=2026)|(?= 2024)|(?= 2023)|(?= 2022)|(?= 2021)|(?= 2020)|(?= 2019)")
TiActiva <- TiActiva[TiActiva$mes %in% meses, ]

# Tasa activa
urlPI <- "https://www.bancentral.gov.do/"
download.file(urlPI, destfile = "scrapedpage.html", quiet=TRUE)
pagBC <- read_html("scrapedpage.html")

###  Extrayendo tablas de pagina 
tablas <- html_nodes(pagBC ,"table")
tasas_interes <- data.frame(html_table(tablas)[[5]])

#####Tasas pasivas
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/tbm_pasivad.xlsx?v=1673968852556?v=1673968852558"
download.file(url,destfile = "tbm_pasividad.xlsx", mode = "wb")

TiPasiva  <- read_excel("tbm_pasividad.xlsx", skip = 5)
indicadores$tip_prom_pond[posFecCor] <- as.numeric(substr(tasas_interes[3, 2], 1,4))
indicadores$tia_prom_pond_rd[posFecCor] <- as.numeric(substr(tasas_interes[2, 2], 1,4))

pos_ene_19 <- which(indicadores$Codigo=="2019M1")
indicadores$tia_90[pos_ene_19:(pos_ene_19+nrow(TiActiva)-1)] <- unlist(TiActiva$`0 a 90 días`)
indicadores$tia_5yr[pos_ene_19:(pos_ene_19+nrow(TiActiva)-1)] <- unlist(TiActiva$`2 a 5 años`)

##### Volatilidad tasas de interes pasivas

url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/volatilidades.xls?v=1777561765753"
download.file(url,destfile = "vol_pasividad.xls", mode = "wb")

tasPasiv <- read_excel("vol_pasividad.xls", skip = 12)
patron <- paste(mesA, collapse = "|")

VolPasiv <- tasPasiv[grepl(patron, tasPasiv$Mes), ]$'Volatilidad * 2.33' %>% tail(-24)
sdPasiv <- tasPasiv[grepl(patron, tasPasiv$Mes), ]$'Variación Típica'%>% tail(-24)

pos_ene_06 <- which(indicadores$Codigo=="2006M1")
indicadores$vol_tip[pos_ene_06:(pos_ene_06+length(VolPasiv)-1)] <- VolPasiv
indicadores$sd_tip[pos_ene_06:(pos_ene_06+length(sdPasiv)-1)] <- sdPasiv

#### Interbancaria 
meses <- c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
           "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre","*Febrero 2/",
           "Enero*2/","Febrero*2/","Marzo*2/","Abril*2/","Mayo*2/","Junio*2/","Julio*2/", 
           "Agosto*2/", "Septiembre*2/", "Octubre*2/", "Noviembre*2/", "Diciembre*2/")

url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/operaciones_interb.xls?v=1679417565251"
download.file(url, destfile = "TIIntB.xls", mode = "wb")
TIIntB <- read_excel("TIIntB.xls", skip = 202)
TIIntB <- TIIntB %>% drop_na()
TIIntB  <- TIIntB[TIIntB$`2012` %in% meses,]
TIIntB  <- ts(TIIntB, start = 2012, frequency = 12)
pos_ene_12 <- which(indicadores$Codigo=="2012M1")
indicadores$tib_rd[pos_ene_12:(pos_ene_12+nrow(TIIntB)-1)] <- unlist(TIIntB[,3])

#### Tasa de politica monetaria
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/Serie_TPM.xlsx?v=1635532077197"
download.file(url, destfile = "tpm.xlsx", mode = "wb")
tpm <- read_excel("tpm.xlsx")

indicadores$tpm[posFecCor] <- as.numeric(tpm[which(tpm[,1]==anio)+(nMes-1) ,3])
indicadores$DEPOS[posFecCor] <- as.numeric(tpm[which(tpm[,1]==anio)+(nMes-1) ,4])
indicadores$REPOS[posFecCor] <- as.numeric(tpm[which(tpm[,1]==anio)+(nMes-1) ,5])

### EMBI
url <- "https://cdn.bancentral.gov.do/documents/entorno-internacional/documents/Serie_Historica_Spread_del_EMBI.xlsx?v=1634571720614"
download.file(url, destfile = "embi.xlsx", mode = "wb")
embi <- read_excel("embi.xlsx", skip = 1)
indicadores$embi_rd[posFecCor] <- embi$`REP DOM`[length(unlist(embi[substr(embi$Fecha,1,12) >= "2007-10-29" & substr(embi$Fecha,1,12) <= fechaCorteUD ,1]))]

# Reservas Internacionales Neta
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-externo/documents/reservas_internacionales.xlsx?v=1635276484780"
download.file(url, destfile = "RIN.xlsx", mode = "wb")
rin <- read_excel("RIN.xlsx", skip = 5)
indicadores$rin[posFecCor] <- as.numeric(unlist(rin[, ncol(rin)])[1:nMes+2])

# Banlanza de Pagos 
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-externo/documents/bpagos__trim_6.xls?v=1698524576390"
download.file(url, destfile = "balPag.xls", mode = "wb")
balPag <- read_excel("balPag.xls")
cn <- unlist(balPag[,1])
balPag <- t(balPag[,-1])
balPag <- balPag[, c(-1:-5,-7:-8,-10)]
colnames(balPag) <- cn[c(-1:-5,-7:-8,-10)]
balPag <- data.frame(balPag)

data_BoP$x_ncnl[1:nrow(balPag)] <- as.numeric(balPag[,7])
data_BoP$x_zf[1:nrow(balPag)] <- as.numeric(balPag[,8])
data_BoP$m_ncnl[1:nrow(balPag)] <- as.numeric(balPag[,10])
data_BoP$m_zf[1:nrow(balPag)] <- as.numeric(balPag[,11])
data_BoP$viajes[1:nrow(balPag)] <- as.numeric(balPag[,15])
data_BoP$serv_mifpt[1:nrow(balPag)] <- as.numeric(balPag[,16])
data_BoP$otros_serv_cred[1:nrow(balPag)] <- as.numeric(balPag[,17])
data_BoP$fletes[1:nrow(balPag)] <- as.numeric(balPag[,19])
data_BoP$otros_serv_deb[1:nrow(balPag)] <- as.numeric(balPag[,20])
data_BoP$remu_empl[1:nrow(balPag)] <- as.numeric(balPag[,23])
data_BoP$ied[1:nrow(balPag)] <- as.numeric(balPag[,27])
data_BoP$idc[1:nrow(balPag)] <- as.numeric(balPag[,30])
data_BoP$otra_i[1:nrow(balPag)] <- as.numeric(balPag[,33])
data_BoP$adr[1:nrow(balPag)] <- as.numeric(balPag[,36])
data_BoP$rem_fam_cred[1:nrow(balPag)] <- as.numeric(balPag[,42])
data_BoP$otras_transf_cred[1:nrow(balPag)] <- as.numeric(balPag[,43])
data_BoP$rem_fam_deb[1:nrow(balPag)] <- as.numeric(balPag[,45])
data_BoP$otras_transf_deb[1:nrow(balPag)] <- as.numeric(balPag[,46])
data_BoP$cuenta_cap[1:nrow(balPag)] <- as.numeric(balPag[,48])
data_BoP$id[1:nrow(balPag)] <- as.numeric(balPag[,53])
data_BoP$inv_cart[1:nrow(balPag)] <- as.numeric(balPag[,54])
data_BoP$dpp_mlp[1:nrow(balPag)] <- as.numeric(balPag[,55])
data_BoP$dpp_cp[1:nrow(balPag)] <- as.numeric(balPag[,56])
data_BoP$myd[1:nrow(balPag)] <- as.numeric(balPag[,57])
data_BoP$otros_cf[1:nrow(balPag)] <- as.numeric(balPag[,58])
data_BoP$saldo[1:nrow(balPag)] <- as.numeric(balPag[,60])
data_BoP$eyo[1:nrow(balPag)] <- as.numeric(balPag[,62])
data_BoP$adr_financ[1:nrow(balPag)] <- as.numeric(balPag[,65])
data_BoP$u_cpfmi[1:nrow(balPag)] <- as.numeric(balPag[,66])
data_BoP$transf_financ[1:nrow(balPag)] <- as.numeric(balPag[,67])
data_BoP$otra_inv_pas[1:nrow(balPag)] <- as.numeric(balPag[,68])

# POsicion de inversion internacional
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-externo/documents/piitrim_6.xlsx?v=1698524576391"
download.file(url, destfile = "pii.xlsx", mode = "wb")
pii <- read_excel("pii.xlsx", sheet = last(excel_sheets("pii.xlsx")))
pii <- t(pii)
cn <- pii[1,]
t <- substr(last(excel_sheets("pii.xlsx")), 16, 19)
f_pos <- which(data_pii$Prd==t)[1]
pii <- pii[which(pii[, 5]=="Saldo al final del período"), ]

#activos
data_pii$a_pc_ide[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 12]
data_pii$a_pc_eid[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 13]
data_pii$a_pc_eee[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 14]
data_pii$a_inst_ide[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 17]
data_pii$a_inst_eid[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 18]
data_pii$a_inst_eee[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 19]
data_pii$a_bc_pcf[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 24]
data_pii$a_sd_pcf[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 25]
data_pii$a_gg_pcf[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 26]
data_pii$a_osf_pcf[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 28]
data_pii$a_snfhsfl_pcf[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 29]
data_pii$a_bc_td[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 32]
data_pii$a_sd_td[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 33]
data_pii$a_gg_td[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 34]
data_pii$a_osf_td[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 36]
data_pii$a_snfhsfl_td[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 37]
data_pii$a_dfoc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 39]
data_pii$a_opc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 43]
data_pii$a_bc_md[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 46]
data_pii$a_sd_md[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 47]
data_pii$a_gg_md[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 48]
data_pii$a_osf_md[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 50]
data_pii$a_snfhsfl_md[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 51]
data_pii$a_bc_pms[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 54]
data_pii$a_sd_pms[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 55]
data_pii$a_gg_pms[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 56]
data_pii$a_osf_pms[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 58]
data_pii$a_snfhsfl_pms[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 59]
data_pii$a_segpen[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 61]
data_pii$a_bc_cac[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 64]
data_pii$a_sd_cac[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 65]
data_pii$a_gg_cac[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 66]
data_pii$a_osf_cac[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 68]
data_pii$a_snfhsfl_cac[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 69]
data_pii$a_bc_ocpc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 72]
data_pii$a_sd_ocpc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 73]
data_pii$a_gg_ocpc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 74]
data_pii$a_osf_ocpc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 76]
data_pii$a_snfhsfl_ocpc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 77]
data_pii$a_lingoro[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 82]
data_pii$a_coro_nasg[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 83]
data_pii$a_dereg[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 85]
data_pii$a_pres_fmi[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 87]
data_pii$a_deraam[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 91]
data_pii$a_deraoe[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 92]
data_pii$a_td_tv[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 94]
data_pii$a_pcf_tv[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 95]
data_pii$a_drvfin[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 96]
data_pii$a_oda[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 97]

#pasivos
data_pii$p_pc_ide[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 104]
data_pii$p_pc_eid[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 105]
data_pii$p_pc_eee[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 106]
data_pii$p_inst_ide[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 109]
data_pii$p_inst_eid[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 110]
data_pii$p_inst_eee[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 111]
data_pii$p_bc_pcf[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 116]
data_pii$p_sd_pcf[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 117]
data_pii$p_gg_pcf[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 118]
data_pii$p_osf_pcf[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 120]
data_pii$p_snfhsfl_pcf[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 121]
data_pii$p_bc_td[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 124]
data_pii$p_sd_td[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 125]
data_pii$p_gg_td[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 126]
data_pii$p_osf_td[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 128]
data_pii$p_snfhsfl_td[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 129]
data_pii$p_dfoc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 131]
data_pii$p_opc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 135]
data_pii$p_bc_md[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 138]
data_pii$p_sd_md[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 139]
data_pii$p_gg_md[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 140]
data_pii$p_osf_md[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 142]
data_pii$p_snfhsfl_md[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 143]
data_pii$p_bc_pms[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 146]
data_pii$p_sd_pms[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 147]
data_pii$p_gg_pms[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 148]
data_pii$p_osf_pms[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 150]
data_pii$p_snfhsfl_pms[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 151]
data_pii$p_segpen[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 152]
data_pii$p_bc_cac[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 155]
data_pii$p_sd_cac[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 156]
data_pii$p_gg_cac[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 157]
data_pii$p_osf_cac[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 159]
data_pii$p_snfhsfl_cac[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 160]
data_pii$p_bc_ocpc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 163]
data_pii$p_sd_ocpc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 164]
data_pii$p_gg_ocpc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 165]
data_pii$p_osf_ocpc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 167]
data_pii$p_snfhsfl_ocpc[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 168]
data_pii$p_dereg[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 170]
data_pii$p_pii[f_pos:(nrow(pii)+f_pos-1)] <- pii[, 172]

# Panorama monetario Banco Central 
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/panorama_pbc.xlsx?v=1715274249671"
download.file(url, destfile = "pm_bc.xlsx", mode = "wb")
pm_bc <- read_excel("pm_bc.xlsx", skip = 11)
pm_bc <- pm_bc[-1, -1:-2]
pm_bc[, 1] <- as.numeric(unlist(pm_bc[, 1]))
pm_bc <- aggregate(ts(pm_bc, start = 2002, frequency = 12), FUN = 'last', nfrequency = 4)

data_pm$ae_ronr_bc[45:(nrow(pm_bc)+44)] <- pm_bc[, 1]
data_pm$ae_onr_bc[45:(nrow(pm_bc)+44)] <- pm_bc[, 2]
data_pm$p_cp_nr[45:(nrow(pm_bc)+44)] <- pm_bc[, 3]
data_pm$p_lp_nr[45:(nrow(pm_bc)+44)] <- pm_bc[, 4]
data_pm$rin[45:(nrow(pm_bc)+44)] <- pm_bc[, 5]
data_pm$ai_gc_bc[45:(nrow(pm_bc)+44)] <- pm_bc[, 7]
data_pm$ai_snf_bc[45:(nrow(pm_bc)+44)] <- pm_bc[, 8]
data_pm$ai_osd_bc[45:(nrow(pm_bc)+44)] <- pm_bc[, 9]
data_pm$ai_os_bc[45:(nrow(pm_bc)+44)] <- pm_bc[, 10]
data_pm$ai_op_bc[45:(nrow(pm_bc)+44)] <- pm_bc[, 11]
data_pm$bm_circ[45:(nrow(pm_bc)+44)] <- pm_bc[, 14]
data_pm$dvp[45:(nrow(pm_bc)+44)] <- pm_bc[, 15]
data_pm$tc[45:(nrow(pm_bc)+44)] <- pm_bc[, 16]

# Panorama monetario Banco Central 
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/panorama_posd.xlsx?v=1715274249671"
download.file(url, destfile = "pm_osd.xlsx", mode = "wb")
pm_osd <- read_excel("pm_osd.xlsx", skip = 11)
pm_osd <- pm_osd[-1, -1:-2]
pm_osd[, 1] <- as.numeric(unlist(pm_osd[, 1]))
pm_osd <- aggregate(ts(pm_osd, start = 2002, frequency = 12), FUN = 'last', nfrequency = 4)

data_pm$ae_nr_osd[45:(nrow(pm_osd)+44)] <- pm_osd[, 1]
data_pm$p_nr_osd[45:(nrow(pm_osd)+44)] <- pm_osd[, 2]
data_pm$ai_gc_osd[45:(nrow(pm_osd)+44)] <- pm_osd[, 4]
data_pm$ai_gel_osd[45:(nrow(pm_osd)+44)] <- pm_osd[, 5]
data_pm$ai_snf_osd[45:(nrow(pm_osd)+44)] <- pm_osd[, 6]
data_pm$ai_bcbm_osd[45:(nrow(pm_osd)+44)] <- pm_osd[, 7]
data_pm$ai_bcd_osd[45:(nrow(pm_osd)+44)] <- pm_osd[,8]
data_pm$ai_bcv_osd[45:(nrow(pm_osd)+44)] <- pm_osd[, 9]
data_pm$ai_osf_osd[45:(nrow(pm_osd)+44)] <- pm_osd[, 10]
data_pm$ai_osnf_osd[45:(nrow(pm_osd)+44)] <- pm_osd[, 11]
data_pm$ai_hsfl_osd[45:(nrow(pm_osd)+44)] <- pm_osd[, 12]
data_pm$ai_op_osd[45:(nrow(pm_osd)+44)] <- pm_osd[, 13]
data_pm$p_dsa_dt_osd[45:(nrow(pm_osd)+44)] <- pm_osd[, 16]
data_pm$p_dsa_odv_osd[45:(nrow(pm_osd)+44)] <- pm_osd[, 17]


# Credito al sector publico del Banco Central 
url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-monetario-y-financiero/documents/credito_nofinanciero_bc.xlsx?v=1715284416593"
download.file(url, destfile = "cr_spnf_bc.xlsx", mode = "wb")
cr_spnf_bc <- read_excel("cr_spnf_bc.xlsx", skip = 11)
cr_spnf_bc <- cr_spnf_bc[-1, -1:-2]
cr_spnf_bc[, 1] <- as.numeric(unlist(cr_spnf_bc[, 1]))
cr_spnf_bc <- aggregate(ts(cr_spnf_bc, start = 2002, frequency = 12), FUN = 'last', nfrequency = 4)

data_pm$a_vda_gc[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[, 1]
data_pm$a_vda_gel[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[, 2]
data_pm$a_vda_snf[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[, 3]
data_pm$a_prm_gc[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[, 4]
data_pm$a_prm_gel[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[, 5]
data_pm$a_prm_snf[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[, 6]
data_pm$a_o[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[,7]
data_pm$p_dto_gc[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[, 9]
data_pm$p_dto_gel[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[, 10]
data_pm$p_dto_snf[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[, 11]
data_pm$p_vto_gc[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[, 12]
data_pm$p_vto_gel[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[, 13]
data_pm$p_vto_snf[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[, 14]
data_pm$p_o[45:(nrow(cr_spnf_bc)+44)] <- cr_spnf_bc[, 15]

# Indicadores Monetarios y FInancieros del Banco Central  

ind_mf_bc <- t(IndAmoBCRD)
cn <- ind_mf_bc[1,  ]
ind_mf_bc <- ind_mf_bc[-1,  ]
colnames(ind_mf_bc) <- cn
ind_mf_bc <- aggregate(window(ts(ind_mf_bc, start = 1996, frequency = 12), start = 2000), FUN = 'last', nfrequency = 4)

data_monetario$a_in_b[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 3]
data_monetario$rib[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 4]
data_monetario$rin[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 5]
data_monetario$a_fgc[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 8]
data_monetario$a_fsp[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 10]
data_monetario$cred_osd[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 11]
data_monetario$val_circ[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 13]
data_monetario$desc_vem[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 15]
data_monetario$deprem_cp[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 17]
data_monetario$bm_em_bmr[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 21]
data_monetario$el_sc_osd_bmr[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 23]
data_monetario$valbc_pososd_bmr[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 24]
data_monetario$bmr[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 26]
data_monetario$el_sc_osd_bma[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 27]
data_monetario$deprem_cp_me[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 28]
data_monetario$ovn[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 29]
data_monetario$deprem_cp_me[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 30]
data_monetario$od_osd_bc[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 31]
data_monetario$valcp_embc_osd[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 32]
data_monetario$bm_pp[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 35]
data_monetario$dt_mn[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 36]
data_monetario$m1[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 38]
data_monetario$od_mn[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 39]
data_monetario$valda_mn_emosd[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 40]
data_monetario$valda_mn_embc[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 41]
data_monetario$m2[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 43]
data_monetario$od_me[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 44]
data_monetario$valda_me[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 45]
data_monetario$k2_1[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 49]
data_monetario$k2_2[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 50]
data_monetario$k2_3[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 51]
data_monetario$tc[37:(nrow(ind_mf_bc)+36)] <- ind_mf_bc[, 53]

# PIB DESDE EL GASTO

url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-real/documents/pib_gasto_retro_2018.xlsx"
download.file(url, destfile = "pibGastobase2018.xlsx", mode = "wb")
file.access("////sefsadfs1//UPF//Direccion Politica y Estudios Fiscales//Estudios Fiscales//ModelosDGAPF//SIPROMACP//Gestion_data", 2)

pibGasto1 <- t(read_excel("pibGastobase2018.xlsx", sheet = "PIB$_Trim", skip = 5))
cn <- pibGasto1[1, ]
pibGasto <- ts(pibGasto1[-1,-c(1,2)], start = 1991, frequency = 4) #Muestra la hoja de PIB$_Trim del sector real 

pibGastok1 <- t(read_excel("pibGastobase2018.xlsx", sheet = "PIBK_Trim", skip = 5))#Muestra la hoja de PIBK_Trim del sector real 
pibGastok <- ts(pibGastok1[-1,-c(1,2,6,8)], start = 1991, frequency = 4)

url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-real/documents/pib_deflactor_2018.xlsx"
download.file(url, destfile = "defl_pib.xlsx", mode = "wb")
defl_pib  <- read_excel("defl_pib.xlsx", sheet = "PIB_Trimestral_deflactor", skip = 6)
defl_pib  <- defl_pib[unlist(defl_pib[,1]) %in% c("I", "II", "III", "IV"), ]
defl_pib_clean <- defl_pib %>%
  filter(.[[1]] %in% c("I", "II", "III", "IV")) %>%
  mutate(
    t = row_number() - 1,
    Prd = 2018 + t %/% 4,
    Tri = c("Q1", "Q2", "Q3", "Q4")[t %% 4 + 1]
  ) %>%
  dplyr::select(Prd, Tri, defl_pib = `Deflactor del PIB`)

#---------Actualizando data-----------------------lm

indicadores_trim <- indicadores_trim %>%
  rows_update(
    defl_pib_clean,
    by = c("Prd", "Tri")
  )

# Componentes del gasto a nivel nominal
indicadores_trim$ct_nom[1:nrow(pibGasto)] <- pibGasto[,1]
indicadores_trim$cpr_nom[1:nrow(pibGasto)] <- pibGasto[, 2]
indicadores_trim$cpu_nom[1:nrow(pibGasto)] <- pibGasto[,3]
indicadores_trim$fbkt[1:nrow(pibGasto)] <- pibGasto[,4]
indicadores_trim$fbkf_nom[1:nrow(pibGasto)] <- pibGasto[,5]
indicadores_trim$ve[1:nrow(pibGasto)] <- pibGasto[,6]
indicadores_trim$exp_nom[1:nrow(pibGasto)] <- pibGasto[,7]
indicadores_trim$imp_nom[1:nrow(pibGasto)] <- pibGasto[,8]
indicadores_trim$pib_nom[1:nrow(pibGasto)] <- pibGasto[,9]

# Componentes del gasto a nivel real
indicadores_trim$ct_real[1:nrow(pibGasto)] <- pibGastok[,1]
indicadores_trim$cpr_real[1:nrow(pibGasto)] <- pibGastok[,2]
indicadores_trim$cpu_real[1:nrow(pibGasto)] <- pibGastok[,3]
indicadores_trim$fbkf_real[1:nrow(pibGasto)] <- pibGastok[,4]
indicadores_trim$exp_real[1:nrow(pibGasto)] <- pibGastok[,5]
indicadores_trim$imp_real[1:nrow(pibGasto)] <- pibGastok[,6]
indicadores_trim$pib_real[1:nrow(pibGasto)] <- pibGastok[,7]

# Incidencia de los componentes del gasto en el PIB

indicadores_trim$inc_con[1:nrow(pibGasto)] <- pibGastok[,27]
indicadores_trim$inc_fbkf[1:nrow(pibGasto)] <- pibGastok[,31]
indicadores_trim$inc_exp[1:nrow(pibGasto)] <- pibGastok[,33]
indicadores_trim$inc_imp[1:nrow(pibGasto)] <- pibGastok[,34]

# Ponderación de los componentes del gasto en el PIB
indicadores_trim$pond_cpr[1:nrow(pibGasto)] <-  pibGasto[,16]
indicadores_trim$pond_cpu[1:nrow(pibGasto)] <-  pibGasto[,17]
indicadores_trim$pond_fbkf[1:nrow(pibGasto)] <- pibGasto[,18]
indicadores_trim$pond_exp[1:nrow(pibGasto)] <-  pibGasto[,21]
indicadores_trim$pond_imp[1:nrow(pibGasto)] <-  pibGasto[,22]

# PIB DESDE EL ORIGEN

url <- "https://cdn.bancentral.gov.do/documents/estadisticas/sector-real/documents/pib_origen_retro_2018.xlsx?v=1772124150730"
download.file(url, destfile = "pibOrigenbase2018.xlsx", mode = "wb")
file.access("////sefsadfs1//UPF//Direccion Politica y Estudios Fiscales//Estudios Fiscales//ModelosDGAPF//SIPROMACP//Gestion_data", 2)

pibOrigen1 <- t(read_excel("pibOrigenbase2018.xlsx", sheet = "PIB$_Trim", skip = 5))
cn <- pibOrigen1[1, ]
pibOrigen <- ts(pibOrigen1[-1,-c(1,2)], start = 1991, frequency = 4) #Muestra la hoja de PIB$_Trim del sector real 

pibOrigenk1 <- t(read_excel("pibOrigenbase2018.xlsx", sheet = "PIBK_Trim", skip = 5))#Muestra la hoja de PIBK_Trim del sector real 
pibOrigenk <- ts(pibOrigenk1[-1,-c(1,2)], start = 1991, frequency = 4)

#---------Actualizando data-----------------------lm

# Incidencia de los componentes sectoriales en el PIB

indicadores_trim$inc_agr[1:nrow(pibOrigenk)] <- pibOrigenk[,53]
indicadores_trim$inc_ind[1:nrow(pibOrigenk)] <- pibOrigenk[, 54]
indicadores_trim$inc_ser[1:nrow(pibOrigenk)] <- pibOrigenk[,59]

# Componentes sectoriales a nivel real

indicadores_trim$agro_real[1:nrow(pibOrigenk)] <- pibOrigenk[,1]
indicadores_trim$minas_real[1:nrow(pibOrigenk)] <- pibOrigenk[, 3]
indicadores_trim$manzf_real[1:nrow(pibOrigenk)] <- pibOrigenk[,5]
indicadores_trim$cons_real[1:nrow(pibOrigenk)] <- pibOrigenk[,6]
indicadores_trim$serv_real[1:nrow(pibOrigenk)] <- pibOrigenk[,7]
indicadores_trim$com_real[1:nrow(pibOrigenk)] <- pibOrigenk[,9]
indicadores_trim$HByR_real[1:nrow(pibOrigenk)] <- pibOrigenk[,10]
indicadores_trim$trans_real[1:nrow(pibOrigenk)] <- pibOrigenk[,11]
indicadores_trim$intfin_real[1:nrow(pibOrigenk)] <- pibOrigenk[,13]
indicadores_trim$viv_real[1:nrow(pibOrigenk)] <- pibOrigenk[,14]
indicadores_trim$otros_real[1:nrow(pibOrigenk)] <- pibOrigenk[,17]
indicadores_trim$adminpub_real[1:nrow(pibOrigenk)] <- pibOrigenk[,18]

#Mercado de trabajo 

url <- "https://cdn.bancentral.gov.do/documents/estadisticas/mercado-de-trabajo/documents/3_1_Deciles_Rama.xlsx?v=1714230323755"
download.file(url, destfile = "trabajo.xlsx", mode = "wb")
trabajo <- read_excel("trabajo.xlsx", skip = 7)
trabajo[,2] <- as.numeric(trabajo$`Ocupados Perceptores`)

ocup <- 1+bimets::DELTAP(ts(na.omit(trabajo[trabajo[,1] == "Total", 2]), start = c(2014, 3), frequency = 4))/100
for (i in seq_along(ocup)) {
  indicadores_trim$l_enftc_empalmado[95+i] <- indicadores_trim$l_enftc_empalmado[95+i-1]*ocup[i]
}

ingLab <- 1+bimets::DELTAP(ts(na.omit(trabajo[trabajo[,1] == "Ingresos por Hora", 2]), start = c(2014, 3), frequency = 4))/100
for (i in seq_along(ingLab)) {
  indicadores_trim$wnom_enftc_empalmado[95+i] <- indicadores_trim$wnom_enftc_empalmado[95+i-1]*ingLab[i]
}

hrsTrb <- 1+bimets::DELTAP(ts(na.omit(trabajo[trabajo[,1] == "Horas Trabajadas", 2]), start = c(2014, 3), frequency = 4))/100
for (i in seq_along(hrsTrb)) {
  indicadores_trim$hrs_enftc_empalmado[95+i] <- indicadores_trim$hrs_enftc_empalmado[95+i-1]*hrsTrb[i]
}

##----------- Data Hacienda: Estado de Operaciones-------------
######################################################################################################

# Estado de Operaciones del portal del Ministerio de Hacienda
  
  # Identificando url del ultimo Informe de desempe?o publicado en la web del MEM
  
urlEF <- "https://www.hacienda.gob.do/estadisticas-fiscales/"
download.file(urlEF, destfile = "scrapedpage.html", quiet=TRUE)
pagEF <- read_html("scrapedpage.html")

###  Extrayendo links de la p?gina
links <- html_nodes(pagEF,"div a")

### Extrayendo valores necesarios para crear data frame
dominio_valor = links %>% html_attr('href')
nombre_valor = links %>% html_text()

### Construyento data frame
link_dfEF <- tibble(
  dominio = dominio_valor,
  nombre = nombre_valor
)

url <- link_dfEF$dominio[which(link_dfEF$nombre=="Gobierno central presupuestario estado de operaciones mensual RD$ y US$")]

url <- "https://www.hacienda.gob.do/wp-content/uploads/2025/07/Gobierno-central-presupuestario-estado-de-operaciones-mensual-RD-y-US-8.xlsx"
download.file(url, destfile = "eo.xlsx", mode = "wb")
#eo <- read_excel("M:/Direccion Estadisticas Fiscales/1. Estado de Operaciones ADM Central/Estado de Operaciones Mensual/EO DGAPF  2023.xlsx", sheet = "ESTADO DE OPERACIONES")
eo <- read_excel("eo.xlsx", sheet = 1,skip = 12)
eo <- t(eo[1:111,])
cn <- eo[2, ]
eo <- eo[-1:-2, ]
colnames(eo) <- cn 
eo <- ts(eo, start = 2000, frequency = 12)
pos_ene_00 <- which(indicadores$Codigo=="2000M1")
eo <- data.frame(periodo = indicadores$Codigo[pos_ene_00:(pos_ene_00+nrow(eo)-1)], eo)
# View(eo)

# Ingresos
data_eo$isr_pf[data_eo$Codigo %in% eo$periodo] <- as.numeric(eo$Pagaderos.por.personas.físicas[eo$periodo %in% data_eo$Codigo])
data_eo$isr_se[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Pagaderos.por.sociedades.y.otras.empresas[eo$periodo %in% data_eo$Codigo])
data_eo$isp[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Impuestos.sobre.la.propiedad[eo$periodo %in% data_eo$Codigo])
data_eo$iva[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Impuestos.sobre.el.valor.agregado..ITBIS.[eo$periodo %in% data_eo$Codigo])
data_eo$ist_fc[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Impuestos.sobre.transacciones.financieras.y.de.capital[eo$periodo %in% data_eo$Codigo])
data_eo$i_sel[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Impuestos.selectivos[eo$periodo %in% data_eo$Codigo])
data_eo$isse[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Impuestos.sobre.servicios.específicos[eo$periodo %in% data_eo$Codigo])
data_eo$isb[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Impuestos.sobre.el.uso.de.bienes.y.sobre.el.permiso.para.usar.bienes.o.realizar.actividades[eo$periodo %in% data_eo$Codigo])
data_eo$isct[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Impuestos.sobre.el.comercio.y.las.transacciones.internacionales[eo$periodo %in% data_eo$Codigo])
data_eo$otros_imp[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Otros.impuestos[eo$periodo %in% data_eo$Codigo])
data_eo$cs_ing[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Contribuciones.sociales[eo$periodo %in% data_eo$Codigo])
data_eo$don[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Donaciones[eo$periodo %in% data_eo$Codigo])
data_eo$otros_ing[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Otros.ingresos[eo$periodo %in% data_eo$Codigo])

indicadores$ing_trib[indicadores$Codigo%in% eo$periodo] <- as.numeric(eo$Impuestos[eo$periodo %in% indicadores$Codigo])
indicadores$gk[indicadores$Codigo%in% eo$periodo] <- as.numeric(eo$Partida.informativa..Gasto.de.Capital..MEFP.1986..4.[eo$periodo %in% indicadores$Codigo])

#Gastos 
data_eo$ss[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Sueldos.y.salarios[eo$periodo %in% data_eo$Codigo])
data_eo$cs_gasto[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Contribuciones.sociales.1[eo$periodo %in% data_eo$Codigo])
data_eo$u_bys[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Uso.de.bienes.y.servicios[eo$periodo %in% data_eo$Codigo])
data_eo$inter_nr[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$A.no.residentes[eo$periodo %in% data_eo$Codigo])
data_eo$inter_r[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$A.residentes[eo$periodo %in% data_eo$Codigo])
data_eo$subs_sp[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$A.sociedades.públicas[eo$periodo %in% data_eo$Codigo])
data_eo$subs_ep[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$A.empresas.privadas[eo$periodo %in% data_eo$Codigo])
data_eo$don_ge[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$A.gobiernos.extranjeros[eo$periodo %in% data_eo$Codigo])
data_eo$don_ogint[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$A.organismos.internacionales[eo$periodo %in% data_eo$Codigo])
data_eo$don_gg_corr[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Corrientes[eo$periodo %in% data_eo$Codigo])
data_eo$don_gg_cap[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$De.capital[eo$periodo %in% data_eo$Codigo])
data_eo$prest_soc[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Prestaciones.sociales[eo$periodo %in% data_eo$Codigo])
data_eo$transf_corr_ncop[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Transferencias.corrientes.no.clasificadas.en.otra.partida[eo$periodo %in% data_eo$Codigo])
data_eo$transf_cap_ncop[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Transferencias.de.capital.no.clasificadas.en.otra.partida[eo$periodo %in% data_eo$Codigo])
data_eo$act_f[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Activos.fijos[eo$periodo %in% data_eo$Codigo])
data_eo$obj_val[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Objetos.de.valor[eo$periodo %in% data_eo$Codigo])
data_eo$act_np[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Activos.no.producidos[eo$periodo %in% data_eo$Codigo])
data_eo$din_ld[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Dinero.legal.y.depósitos[eo$periodo %in% data_eo$Codigo])
data_eo$part_cap_di[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Participaciones.de.capital.y.en.fondos.de.inversión[eo$periodo %in% data_eo$Codigo])
data_eo$otras_cpc[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Otras.cuentas.por.cobrar[eo$periodo %in% data_eo$Codigo])
data_eo$emis_ai[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Emisiones[eo$periodo %in% data_eo$Codigo])
data_eo$amort_ai[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Amortizaciones[eo$periodo %in% data_eo$Codigo])
data_eo$resto_ai[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Resto.6.[eo$periodo %in% data_eo$Codigo])
data_eo$loan_sb_ai[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Con.el.sector.bancario[eo$periodo %in% data_eo$Codigo])
data_eo$loan_snb_ai[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Con.el.sector.no.bancario[eo$periodo %in% data_eo$Codigo])
data_eo$otros_pas_ai[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Otros.pasivos.1[eo$periodo %in% data_eo$Codigo])
data_eo$emis_ae[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Emisiones.1[eo$periodo %in% data_eo$Codigo])
data_eo$otros_pas_ai[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Otros.pasivos.1[eo$periodo %in% data_eo$Codigo])
data_eo$amort_ae[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Amortizaciones.1[eo$periodo %in% data_eo$Codigo])
data_eo$resto_ae[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Resto.6..1[eo$periodo %in% data_eo$Codigo])
data_eo$desemb_loan_ae[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Desembolsos[eo$periodo %in% data_eo$Codigo])
data_eo$amort_loan_ae[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Amortizaciones.2[eo$periodo %in% data_eo$Codigo])
data_eo$resto_loan_ae[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Resto.6..2[eo$periodo %in% data_eo$Codigo])
data_eo$din_ld_rspnf[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Dinero.legal.y.depósitos.1[eo$periodo %in% data_eo$Codigo])
data_eo$tdd_rspnf[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Titulos.de.deuda[eo$periodo %in% data_eo$Codigo])
data_eo$cpc_rspnf[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Cuentas.por.cobrar[eo$periodo %in% data_eo$Codigo])
data_eo$de_rspnf[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Deudores.externos.1[eo$periodo %in% data_eo$Codigo])
data_eo$pas_tdd_ai[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Titulos.de.deuda.1[eo$periodo %in% data_eo$Codigo])
data_eo$loan_rspnf[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Préstamos.2[eo$periodo %in% data_eo$Codigo])
data_eo$otros_pas_rspnf[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Otros.pasivos.1[eo$periodo %in% data_eo$Codigo])
data_eo$ae_rspnf[data_eo$Codigo%in% eo$periodo] <- as.numeric(eo$Acreedores.externos.1[eo$periodo %in% data_eo$Codigo])


##------ Datos Credito Publico -------
####################################################################################################

url <- "https://www.creditopublico.gob.do/Content/estadisticas/consolidada/trimestral/04Deuda%20P%C3%BAblica%20Consolidada%20por%20Sector%20Institucional%20Trimestral.xlsx"
download.file(url, destfile = "deudapc.xlsx", mode = "wb")
deudapc <- read_excel("deudapc.xlsx")
cn <- unlist(deudapc[,1])
deudapc <- t(deudapc[,-1])
deudapc <- deudapc[, c(-1:-3,-9,-15,-19,-24:-41)]
deudapc <- data.frame(deudapc)

data_deuda$dpc_ext[89:(nrow(deudapc)+88)] <- as.numeric(deudapc[,4])
data_deuda$dpc_int[89:(nrow(deudapc)+88)] <- as.numeric(deudapc[,5])
data_deuda$d_ext_spnf_gc[89:(nrow(deudapc)+88)] <- as.numeric(deudapc[,8])
data_deuda$d_int_spnf_gc[89:(nrow(deudapc)+88)] <- as.numeric(deudapc[,9])
data_deuda$d_ext_spnf_r[89:(nrow(deudapc)+88)] <- as.numeric(deudapc[,12])
data_deuda$d_int_spnf_r[89:(nrow(deudapc)+88)] <- as.numeric(deudapc[,13])
data_deuda$d_ext_spf[89:(nrow(deudapc)+88)] <- as.numeric(deudapc[,16])
data_deuda$d_int_spf[89:(nrow(deudapc)+88)] <- as.numeric(deudapc[,17])

##------ Datos SIB ---------------- 
####################################################################################################
# # 
#library(ggplot2) # generar gr?ficos

apiKey <- Sys.getenv("1eed1e3530244c0abfa7a6b2145abacb")

# colocamos el url, end points y par?metros de consulta seg?n las especificaciones
# de la p?gina web del API de la SB https://desarrollador.sb.gob.do/
# library(httr)
# base_url = "https://apis.sb.gob.do/estadisticas"
# end_point = "/v2/indicadores/financieros"
# print(base_url)
# print(end_point)
# print(apiKey)
# print(fechaCorte)
# result <- GET(paste0(base_url,end_point),
#               add_headers("Ocp-Apim-Subscription-Key"= apiKey),
#               query = list(
#                 periodoInicial = "2019-01",
#                 periodoFinal = substr(fechaCorte, 1, 7),
#                 tipoEntidad= "TODOS"
#               ),
#               encode = "json")
# #print(class(result))
# #print(status_code(result))
# result <- httr::content(result, as = "text", encoding = "UTF-8") # retorna un objeto en formato JSON
# result <- fromJSON(result) # convierte un objeto JSON a objeto R
# #View(result)
# #IndFin <- as.data.frame(result$data) # convierte objETO R a Data frame
# IndFin <- as.data.frame(result) # convierte objETO R a Data frame
# #oTRA FORMA DE HACERLO
# 
# # View(IndFin)
# pos_ene_19 <- which(indicadores$Codigo=="2019M1")
# if(any(IndFin[,"periodo"] == substr(fechaCorte, 1, 7))){
# 
#    indicadores$calact_rd[pos_ene_19:posFecCor] <- as.numeric(unlist(IndFin[IndFin[,"indicador"]=="Cobertura de Cartera de Crédito Vencida", "valor"]))
#    indicadores$liq_rd[pos_ene_19:posFecCor] <- as.numeric(unlist(IndFin[IndFin[,"indicador"]=="Disponibilidades / Total de Captaciones", "valor"]))
#    }

##------ Datos DGII: Se tomar? del Excel enviado por DGII----------
####################################################################################################

#opItbis <- read_excel("M:/Direccion Politica y Estudios Fiscales/Estudios Fiscales/SIPROMFI/data/datos/Operaciones Totales ITBIS 2026 - MH.xlsx", sheet = 1,skip = 14)

if(file.exists(paste("Operaciones Totales ITBIS ", anio,".xlsx", sep = ""))){
  
  opItbis <- read_excel(paste("Operaciones Totales ITBIS ", anio,".xlsx", sep = ""), skip = 14)
  
  cn <- unlist(opItbis[, 1])
  opItbis <- opItbis[which(colnames(opItbis)=="Enero"):which(colnames(opItbis)==ifelse(any(colnames(opItbis)==mesCorte2), mesCorte2, meses[nMes -1]))]


  } else if(file.exists(paste("Operaciones Totales ITBIS ", anio-1,".xlsx", sep = ""))){
  
  opItbis <- read_excel(paste("Operaciones Totales ITBIS ", anio-1,".xlsx", sep = ""), skip = 14)
  
  cn <- unlist(opItbis[, 1])
  opItbis <- opItbis[which(colnames(opItbis)=="Enero"):which(colnames(opItbis)==ifelse(any(colnames(opItbis)==mesCorte2), mesCorte2, meses[nMes -1]))]
  
}


if(exists("opItbis")){
  
  if(last(colnames(opItbis))==mesCorte2){
    
    indicadores$ventas_dgii_rd[(posFecCor-nMes+1):posFecCor] <- 
      unlist(opItbis[cn=="Total",])/1000000
    indicadores$ventas_const[(posFecCor-nMes+1):posFecCor] <- 
      unlist(opItbis[cn=="Construcción",])/1000000
    indicadores$ventas_mineria[(posFecCor-nMes+1):posFecCor] <- 
      unlist(opItbis[cn=="Explotación de Minas y Canteras",])/1000000
    indicadores$ventas_manuf[(posFecCor-nMes+1):posFecCor] <- 
      unlist(opItbis[cn=="Manufactura",])/1000000
    indicadores$ventas_comercio[(posFecCor-nMes+1):posFecCor] <- 
      unlist(opItbis[cn=="Comercio",])/1000000
    indicadores$ventas_hoteles[(posFecCor-nMes+1):posFecCor] <- 
      unlist(opItbis[cn=="Hoteles, Bares y Restaurantes",])/1000000
    indicadores$ventas_transp[(posFecCor-nMes+1):posFecCor] <- 
      unlist(opItbis[cn=="Transporte y Almacenamiento",])/1000000
    indicadores$ventas_otros <- indicadores$ventas_dgii_rd-(indicadores$ventas_const+
                                                              indicadores$ventas_mineria+
                                                              indicadores$ventas_manuf+
                                                              indicadores$ventas_comercio+
                                                              indicadores$ventas_hoteles+
                                                              indicadores$ventas_transp) 
  }
  
}

# Recaudo por impuesto semanal

recaudo_raw <- read_excel(paste0(dataPath, "/Recaudo por impuestos semanal 2015 - 2026.xlsx"),
                          sheet = "Resultados", skip = 11)
recaudo_raw <- recaudo_raw %>% select(-contains("Semana"))

extraer_impuesto <- function(raw, fila_inicio) {
  as.numeric(as.matrix(raw[fila_inicio + 1:12, 2:13])) / 1e6
}

pos_ene_15 <- which(indicadores$Codigo == "2015M1")
n_periodos <- length(extraer_impuesto(recaudo_raw, fila_inicio = 1))  

recaudo <- data.frame(
  periodo      = indicadores$Codigo[pos_ene_15:(pos_ene_15 + n_periodos - 1)],
  Hidro_av     = extraer_impuesto(recaudo_raw, fila_inicio = 1),
  Hidro_esp    = extraer_impuesto(recaudo_raw, fila_inicio = 14),
  itbis_ret_ca = extraer_impuesto(recaudo_raw, fila_inicio = 27),
  imp_cheq     = extraer_impuesto(recaudo_raw, fila_inicio = 40)
)

idx <- match(recaudo$periodo, indicadores$Codigo)
indicadores$Hidro_av[idx]     <- recaudo$Hidro_av
indicadores$Hidro_esp[idx]    <- recaudo$Hidro_esp
indicadores$itbis_ret_ca[idx] <- recaudo$itbis_ret_ca
indicadores$imp_cheq[idx]     <- recaudo$imp_cheq

##------ Datos SIPEN----------------
####################################################################################################

### Explorando el archivo HTML

urlPI <- "https://www.sipen.gob.do/estadisticas/estadistica-previsional/estadisticas-previsionales"
download.file(urlPI, destfile = "scrapedpage.html", quiet=TRUE)
pagSIPEN <- read_html("scrapedpage.html")

###  Extrayendo links de la p?gina
links <- html_nodes(pagSIPEN,"div a")

### Extrayendo valores necesarios para crear data frame
dominio_valor = links %>% html_attr('href')
nombre_valor = links %>% html_text()

### Construyento data frame salarios
link_dfSIPEN <- tibble(
  dominio = dominio_valor,
  nombre = nombre_valor
)

url <- link_dfSIPEN$dominio[which(link_dfSIPEN$nombre=="Salario")]
url <- url[which(grepl("xlsx", url))]
url <- "https://www.sipen.gob.do/descarga/estadisticas-previsionales_2026_03_1773431460.xlsx"
download.file(url, destfile = "Salario.xlsx", mode = "wb")
salario <- read_excel("Salario.xlsx",sheet = "PROMEDIOS", col_types = c("date", "numeric"), skip = 3)
pos_jul_03<- which(indicadores$Codigo=="2003M7")
salario <- na.omit(salario)
indicadores$salario[pos_jul_03:posFecCor] <- unlist(salario$Salario)

### Construyento data frame cotizantes
link_dfSIPEN <- tibble(
  dominio = dominio_valor,
  nombre = nombre_valor
)

url <- link_dfSIPEN$dominio[which(link_dfSIPEN$nombre=="Cotizantes")]
url <- url[which(grepl("xlsx", url))]
url <- "https://www.sipen.gob.do/descarga/estadisticas-previsionales_2026_03_1773430757.xlsx"

download.file(url, destfile = "Cotizantes.xlsx", mode = "wb")
cotizantes <- read_excel("Cotizantes.xlsx", col_types = c("date", "numeric"), skip = 3)
pos_sep_03<- which(indicadores$Codigo=="2003M9")
cotizantes <- na.omit(cotizantes)
indicadores$cot_tss[pos_sep_03:posFecCor] <- unlist(cotizantes$COTIZANTES)

##------ Datos DGA -----------------
####################################################################################################

#Importaciones DGA
#Creando conecci?n a SQL SERVER
sqlConn <- odbcDriverConnect('driver={SQL Server};server=172.16.2.91;database=DGA_PLT;uid=usrplt;pwd=ultrakoala65')

# Consulta exportaciones del mes
exp <- sqlQuery(sqlConn, paste("SELECT SUBSTRING(CONVERT(varchar(10), fecha_declaracion, 120), 1, 7) AS mes, SUM(valor_fob) valor
         FROM [DGA_PLT].[dbo].[DGA_EXPORTACIONES]
         WHERE  REGIMEN_CODIGO IN (2,11,16, 20)", 
                               " GROUP BY  SUBSTRING(CONVERT(varchar(10), fecha_declaracion, 120), 1, 7)",
                               sep=""))

exp <- arrange(exp, mes)

indicadores$export[pos_enero:posFecCor] <- exp$valor/1000000

imp <- sqlQuery(sqlConn, paste("SELECT SUBSTRING(CAST(f_declara AS CHAR),1,3) AS mes, SUM([v_fob]) AS valor
         FROM [DGA_PLT].[dbo].[dga_importaciones]
         WHERE  SUBSTRING(CAST(f_declara AS CHAR),1,3) IN ('Jan',
                                                                'Feb',
                                                                'Mar',
                                                                'Apr',
                                                                'May',
                                                                'Jun',
                                                               'Jul',
                                                                'Aug',
                                                                'Sep',
                                                                'Oct',
                                                                'Nov',
                                                                'Dec')",
                               "AND REGIMEN IN (1,2,7,10,11)", "GROUP BY SUBSTRING(CAST(f_declara AS CHAR),1,3)", sep=" "))

meses_en_s <- c('Jan',  'Feb',  'Mar',  'Apr', 'May',  'Jun', 'Jul', 'Aug', 'Sep', 'Oct',  'Nov', 'Dec')
imp[imp$mes %in% meses_en_s, ]
imp <- imp %>% arrange(factor(mes, levels = meses_en_s))
indicadores$import[pos_enero:posFecCor] <- imp$valor/1000000

#Cerrando conecci?n con SQL SERVER
odbcClose(sqlConn)
#sqlConn <- odbcDriverConnect('driver={SQL Server};server=172.16.70.15,2019;database=repodb;uid=consulta_dgapf;pwd=consulta_dgapf')
#gastos <- sqlQuery(sqlConn, "SELECT * FROM [repodb].[dgapf].[vw_Resumen_Gastos]")

# creando libro Excel
#resul <- createWorkbook()

# Agregando hoja y guardando resultado en Excel 

#addWorksheet(resul, "data")
#writeData(resul, "data", data)
#saveWorkbook(resul,"data_persona_fisica.xlsx", overwrite = TRUE)

#---------EIA----------------------- 
###########################################################################
url <- "https://www.eia.gov/outlooks/steo/xls/STEO_m.xlsx"
download.file(url, destfile = "pronEia.xlsx", mode = "wb")
pronUsa <- read_excel("pronEia.xlsx", sheet = "9atab")
pronUsaN <- pronUsa[, 1]
pronUsa <- t(pronUsa[, -1:-2])
colnames(pronUsa) <- pronUsaN$`Table of Contents`
pronUsa <- ts(pronUsa, start = c(pronUsa[1, 2]), frequency = 12)

pronWti <- read_excel("pronEia.xlsx", sheet = "2tab")

pronWtiN <- pronWti[, 1]
pronWti <- t(pronWti[, -1:-2])
colnames(pronWti) <- pronWtiN$`Table of Contents`
pronWti <- ts(pronWti, start = c(pronWti[1, 2]), frequency = 12)

pron_mensuales <- cbind(pronUsa, pronWti)

##------ Datos Federal Reserve Economic Data (FRED)----------
####################################################################################################

### Indice de producci?n industrial USA
fredr_set_key("e85d1335733028f45126dc22e579cadc")

ipiUSA <- fredr(
  series_id = "INDPRO",
  observation_start = as.Date("1984-01-01"),
  frequency = "m"
)

indicadores$indpro_usa[1:nrow(ipiUSA)] <- ipiUSA$value
ffp <- which(is.na(indicadores$indpro_usa))[1]
ffp1 <- which(ym(indicadores$Codigo[ffp])== as.Date(time(pronUsa)))
proy_m$indpro_usa_f[ffp:(ffp+11)] <- pronUsa[ffp1:(ffp1+11), "ZOTOIUS"]

# Epu_usa

epu_eeuu <- fredr(
  series_id = "USEPUINDXM",
  observation_start = as.Date("1985-01-01"),
  frequency = "m"
)

indicadores$epu_eeuu[1:nrow(epu_eeuu)] <- epu_eeuu$value
ffp <- which(is.na(indicadores$epu_eeuu))[1]
ffp1 <- which(ym(indicadores$Codigo[ffp])== as.Date(time(pronUsa)))
# proy_m$epu_eeuu_f[ffp:(ffp+11)] <- pronUsa[ffp1:(ffp1+11), "ZOMNIUS"]

pos_ene_85 <- which(indicadores$Codigo=="1985M1")
epu_eeuu <- data.frame(periodo = indicadores$Codigo[pos_ene_85:(pos_ene_85+nrow(epu_eeuu)-1)], epu_eeuu)
idxa <- match(indicadores$Codigo,epu_eeuu$periodo)
indicadores$epu_eeuu <- epu_eeuu$value[idxa]

# Epu_glob
epu_global <- fredr(
  series_id = "GEPUCURRENT",
  observation_start = as.Date("1997-01-01"),
  frequency = "m"
)

pos_ene_97 <- which(indicadores$Codigo=="1997M1")
epu_global <- data.frame(periodo = indicadores$Codigo[pos_ene_97:(pos_ene_97+nrow(epu_global)-1)], epu_global)
idxa2 <- match(indicadores$Codigo,epu_global$periodo)

indicadores$epu_global <- epu_global$value[idxa2]

# ipimanusa
ipiManUSA <- fredr(
  series_id = "IPMAN",
  observation_start = as.Date("1984-01-01"),
  frequency = "m"
)

indicadores$indproMan_usa[1:nrow(ipiManUSA)] <- ipiManUSA$value
ffp <- which(is.na(indicadores$indproMan_usa))[1]
ffp1 <- which(ym(indicadores$Codigo[ffp])== as.Date(time(pronUsa)))
proy_m$indproMan_usa_f[ffp:(ffp+11)] <- pronUsa[ffp1:(ffp1+11), "ZOMNIUS"]

### IPC 
ipcUSA <- fredr(
  series_id = "CPIAUCSL",
  observation_start = as.Date("1984-01-01"),
  frequency = "m"
)

indicadores$ipc_eeuu[1:nrow(ipcUSA)] <- ipcUSA$value
ffp <- which(is.na(indicadores$ipc_eeuu))[1]
pronUsa_ipc <- bimets::DELTAP(ts(as.numeric(pronUsa[, "CICPIUS"]), start = start(pronUsa), frequency = frequency(pronUsa)), 12)/100
ffp1 <- which(ym(indicadores$Codigo[ffp])== as.Date(time(pronUsa_ipc)))

proy_m$ipc_eeuu_f[ffp:(ffp+11)] <- indicadores$ipc_eeuu[(ffp-12):(ffp-1)]*(1+(pronUsa_ipc [ffp1:(ffp1+11)]))

fedFunds <- fredr(
  series_id = "FEDFUNDS",
  observation_start = as.Date("1984-01-01"),
  #observation_end = as.Date("2022-01-01"),
  frequency = "m"
)
indicadores$ti_fond_fed[1:nrow(fedFunds)] <- fedFunds$value


#----------------PIB USA

PIBUSA <- fredr(
  series_id = "GDPC1",
  observation_start = as.Date("1991-01-01"),
  #observation_end = as.Date("2022-01-01"),
  frequency = "q"
)
indicadores_trim$pib_eeuu[1:nrow(PIBUSA)] <- PIBUSA$value

ffp <- which(is.na(indicadores$ur_sa_usa))[1]
ffp1 <- which(ym(indicadores$Codigo[ffp])== as.Date(time(pronUsa)))
proy_m$pib_eeuu_f[ffp:(ffp+11)] <- pronUsa[ffp1:(ffp1+11), "GDPQXUS"]

#---------------Desempleo USA
#"UNRATE"      "UNRATENSA"

desempleoUSANA <- fredr(
  series_id = "UNRATENSA",
  observation_start = as.Date("1984-01-01"),
  frequency = "m"
)

indicadores$ur_usa[1:(nrow(desempleoUSANA))] <- desempleoUSANA$value

desempleoUSA <- fredr(
  series_id = "UNRATE",
  observation_start = as.Date("1984-01-01"),
  frequency = "m"
)

indicadores$ur_sa_usa[1:(nrow(desempleoUSA))] <- desempleoUSA$value

ffp <- which(is.na(indicadores$ur_sa_usa))[1]
ffp1 <- which(ym(indicadores$Codigo[ffp])== as.Date(time(pronUsa)))
proy_m$ur_sa_usa_f[ffp:(ffp+11)] <- pronUsa[ffp1:(ffp1+11), "XRUNR"]

##------ FMI/WEO----------
# install.packages("remotes")
# remotes::install_github("opensdmx/rsdmx")
# 
# library(rsdmx)
# library(AzureAuth)
# 
# client_id <-"446ce2fa-88b1-436c-b8e6-94491ca4f6fb"
# tenant <- "https://imfprdb2c.onmicrosoft.com/"
# authority <-"https://imfprdb2c.b2clogin.com/imfprdb2c.onmicrosoft.com/b2c_1a_signin_aad_simple_user_journey/oauth2/v2.0"
# scope <- "https://imfprdb2c.onmicrosoft.com/4042e178-3e2f-4ff9-ac38-1276c901c13d/iData.Login"
# token <- get_azure_token(resource=scope,
#                          tenant=tenant,
#                          app=client_id,
#                          version=2,
#                          aad_host=authority
#                          )
# 
# token_header <- paste(token$credentials$token_type,token$credentials$access_token)
# 
# headers = c('Authorization' = token_header)
# flowref <- 'IMF.STA,CPI'

# filter <- 'USA...IX.M'
# dataset <- as.data.frame(readSDMX(providerId = 'IMF_DATA',
#                                   resource = 'data',
#                                   flowRef = flowref,
#                                   key = filter,
#                                   headers=headers))

####################################################################################################
##------ Banco Mundial---------------------------------------####################
####################################################################################################
### Comodity

url <- "https://thedocs.worldbank.org/en/doc/74e8be41ceb20fa0da750cda2f6b9e4e-0050012026/related/CMO-Historical-Data-Monthly.xlsx"
download.file(url, destfile = "comodity.xlsx", mode = "wb")
comodity <- read_excel("comodity.xlsx", sheet = "Monthly Prices", skip = 4)
comodity <- comodity[which(comodity[,]=="1984M01"):nrow(comodity), ]
indicadores$p_petroleo[1:nrow(comodity)] <- as.numeric(comodity$`Crude oil, WTI`)
indicadores$p_gas_nat[1:nrow(comodity)] <- as.numeric(comodity$`Natural gas, US`)
indicadores$p_oro[1:nrow(comodity)] <- as.numeric(comodity$Gold)

comodity <- read_excel("comodity.xlsx", sheet = "Monthly Indices", skip = 8)
ayb <- unlist(comodity[which(comodity[,]=="1984M01"):nrow(comodity), 5])
indicadores$ind_p_AyB[1:length(ayb)] <- as.numeric(ayb)

ener <- unlist(comodity[which(comodity[,]=="1984M01"):nrow(comodity), 3])
indicadores$ener_ind[1:length(ener)] <- as.numeric(ener)

nonener <- unlist(comodity[which(comodity[,]=="1984M01"):nrow(comodity), 4])
indicadores$non_ener_ind[1:length(nonener)] <- as.numeric(nonener)

comer <- unlist(comodity[which(comodity[,]=="1984M01"):nrow(comodity), 7])
indicadores$food_ind[1:length(comer)] <- as.numeric(comer)

metale <- unlist(comodity[which(comodity[,]=="1984M01"):nrow(comodity), 15])
indicadores$metals_ind[1:length(metale)] <- as.numeric(metale)

metal_pre <- unlist(comodity[which(comodity[,]=="1984M01"):nrow(comodity), 17])
indicadores$prec_metal_ind[1:length(metal_pre)] <- as.numeric(metal_pre)

ffp <- which(is.na(indicadores$ind_p_AyB))[1]
ffp1 <- which(ym(indicadores$Codigo[ffp])== as.Date(time(pronWti)))

ffp <- which(is.na(indicadores$p_petroleo))[1]
ffp1 <- which(ym(indicadores$Codigo[ffp])== as.Date(time(pronWti)))
proy_m$p_petroleo_f[ffp:(ffp+11)] <- pronWti[ffp1:(ffp1+11), "WTIPUUS"]

ffp <- which(is.na(indicadores$p_gas_nat))[1]
ffp1 <- which(ym(indicadores$Codigo[ffp])== as.Date(time(pronWti)))
proy_m$p_gas_nat_f[ffp:(ffp+11)] <- pronWti[ffp1:(ffp1+11), "NGHHUUS"]

##------ Revisiones----
#####################################################################################################

any(is.na(indicadores[posFecCor,]))
base::sum(is.na(indicadores[posFecCor,]))
is.na(indicadores[posFecCor,])

##------ Guardando resultados------------
##############################

# # Actualizando data DGAPF

# Trimetralizando data mensual 
indicadores[, -1:-4] <- apply(indicadores[, -1:-4], MARGIN = 2, FUN = as.numeric, simplify = TRUE)
indicadores_trim[,-1:-2] <- apply(indicadores_trim[,-1:-2], MARGIN = 2, FUN = as.numeric, simplify = TRUE)
proy_t[,-1:-2] <- apply(proy_t[,-1:-2], MARGIN = 2, FUN = as.numeric, simplify = TRUE)

mens_a_trim <- cbind.zoo(aggregate.ts(ts(indicadores[, c("tib_rd", "tpm","embi_rd","calact_rd","liq_rd", "tia_prom_pond_rd",	
                                                         "tip_prom_pond",	"tia_90",	"tia_5yr", "p_petroleo", "ti_fond_fed", "ipc", "tcn_venta", 
                                                         "ipc_eeuu", "vix", "epu_global", "epu_eeuu", "bolsa_DowJones", "p_oro","DEPOS","REPOS")], 
                                         start = 1984, frequency = 12), 
                                      nfrequency = 4, FUN = "mean"),

aggregate.ts(ts(indicadores[, c("sm_bcrd_vc","M1","rin","M2","M3","meta")], 
                start = 1984, frequency = 12), 
             nfrequency = 4, FUN = "last"),
aggregate.ts(ts(indicadores[, c("imp_pd_va","m_pqoil_rd")], 
                start = 1984, frequency = 12), 
             nfrequency = 4, FUN = "sum")
)

mens_a_trim <- window(mens_a_trim, start = 1991)

data_eo_tri <- aggregate.ts(ts(data_eo[, -1:-4], 
                               start = 2000, frequency = 12), 
                            nfrequency = 4, FUN = "sum")

indicadores_trim[1:nrow(mens_a_trim),colnames(mens_a_trim)] <- mens_a_trim

p_mens_a_trim <- cbind.zoo(aggregate.ts(ts(proy_m[, c("indproMan_usa_f","indpro_usa_f","pib_eeuu_f","ipc_eeuu_f",
                                                      "ur_sa_usa_f","p_gas_nat_f","p_petroleo_f"
)], 
                                         start = 1984, frequency = 12), 
                                      nfrequency = 4, FUN = "mean"))
p_mens_a_trim <- window(p_mens_a_trim, start = 2000)
proy_t[1:nrow(p_mens_a_trim),colnames(p_mens_a_trim)] <- p_mens_a_trim

# Actualizando data DGAPF

setwd(paste0(path, "/data"))
wb <- loadWorkbook("dataDGAPF_gg.xlsx")

indicadores[, -1:-4] <- apply(indicadores[, -1:-4], MARGIN = 2, FUN = as.numeric, simplify = TRUE)
indicador_dia[, -1:-4] <- apply(indicador_dia[, -1:-4], MARGIN = 2, FUN = as.numeric, simplify = TRUE)
data_BoP[,-1:-2] <- apply(data_BoP[,-1:-2], MARGIN = 2, FUN = as.numeric, simplify = TRUE)
data_eo[, -1:-4] <- apply(data_eo[, -1:-4], MARGIN = 2, FUN = as.numeric, simplify = TRUE)
indicadores_trim[,-1:-2] <- apply(indicadores_trim[,-1:-2], MARGIN = 2, FUN = as.numeric, simplify = TRUE)
data_pii[,-1:-2] <- apply(data_pii[,-1:-2], MARGIN = 2, FUN = as.numeric, simplify = TRUE)
data_deuda[,-1:-2] <- apply(data_deuda[,-1:-2], MARGIN = 2, FUN = as.numeric, simplify = TRUE)
data_monetario[,-1:-2] <- apply(data_monetario[,-1:-2], MARGIN = 2, FUN = as.numeric, simplify = TRUE)
data_pm[,-1:-2] <- apply(data_pm[,-1:-2], MARGIN = 2, FUN = as.numeric, simplify = TRUE)
proy_m[, -1:-4] <- apply(proy_m[, -1:-4], MARGIN = 2, FUN = as.numeric, simplify = TRUE)
proy_t[,-1:-2] <- apply(proy_t[,-1:-2], MARGIN = 2, FUN = as.numeric, simplify = TRUE)

writeData(wb, sheet = "data_diaria", indicador_dia, colNames = T, startRow = 3)
writeData(wb, sheet = "data_mensual", indicadores, colNames = T, startRow = 3)
writeData(wb, sheet = "data_trimestral", indicadores_trim, colNames = T, startRow = 3)
writeData(wb, sheet = "data_bop", data_BoP, colNames = T, startRow = 3)
writeData(wb, sheet = "data_eo", data_eo, colNames = T, startRow = 3)
writeData(wb, sheet = "data_eo_tri", data_eo_tri, colNames = T, startRow = 3, startCol = 3)
writeData(wb, sheet = "data_pii", data_pii, colNames = T, startRow = 3)
writeData(wb, sheet = "data_deuda", data_deuda, colNames = T, startRow = 3)
writeData(wb, sheet = "data_monetario", data_monetario, colNames = T, startRow = 3)
writeData(wb, sheet = "panorama_monetario", data_pm, colNames = T, startRow = 3)
writeData(wb, sheet = "proyecciones_ext_mensuales", proy_m, colNames = T, startRow = 3)
writeData(wb, sheet = "proyecciones_ext_trimestrales", proy_t, colNames = T, startRow = 3)

saveWorkbook(wb,"dataDGAPF_gg.xlsx",overwrite = T)




