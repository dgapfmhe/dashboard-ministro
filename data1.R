

##################################################################################################
# GESTION DE DATOS PARA DASHBOARD ENERGETICO
#################################################################################################
# MINISTERIO DE HACIENDA
# DIRECCION GENERAL DE ANALISIS Y POLITICA FISCAL (DGAPF)
# Realizado por: Jose Antonio Vargas
# Ultima actualizacion: 1/28/2025
################################################################################################


#----------- Entorno de trabajo y paquetes necesarios---------
################################################################################################

rm(list = ls())# emilina objetos existentes en el entorno de R
#setwd("C:/Users/USER/Desktop/MH") # fija carpeta de trabajo
setwd("M:/Direccion Estadisticas Fiscales/Dashboard DGAPF/Dashboard Monitor Energetico/gestion_data") # fija carpeta de trabajo
options(scipen = 999)
#library(tidyverse) #diversos paquetes: especialmente para el manejo de datos y visualización
library(tidyr) 
library(dplyr)
library(readxl) #para leer archivos excel
library(rvest) #para realizar el web scraping
library(rjson) #para leer documentos .js
library(boot)
library(lubridate) # para trabajar con fechas 
library(RODBC) # para consultas SQL SERVER
library(openxlsx)
library(RCurl)

#------------- Gestión de datos ------------------
###############################################################################################
  
  
 fechaCorte <- paste(if(month(Sys.Date())<=2) year(Sys.Date())-1 else year(Sys.Date()),"-", switch (month(Sys.Date()),
                                                                                                     
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                   
                                                                                                     "11",
                                                                                                     "12",
                                                                                                     "01",
                                                                                                     "02",
                                                                                                     "03",
                                                                                                     "04",
                                                                                                     "05",
                                                                                                     "06",
                                                                                                     "07",
                                                                                                     "08",
                                                                                                     "09",
                                                                                                    "10"
                                                                                                     
  ),"-", "01", sep = "")
#fechaCorte <- "2023-03-01"
  

  anio <- if(month(Sys.Date())<=2) year(Sys.Date())-1 else year(Sys.Date())
  
 
##------ Indicadores energaticos: Departamento de estad?sticas------------
##################################################################################################

# Identificando url del ultimo Informe de desempe?o publicado en la web del MEM
  
  urlID <- "https://mem.gob.do/category/sector-electrico/informe-de-desempeno/"
  download.file(urlID, destfile = "scrapedpage.html", quiet=TRUE)
  pagID <- read_html("scrapedpage.html")
  
  ###  Extrayendo links de la p?gina
  links <- html_nodes(pagID,"div a")
  
  ### Extrayendo valores necesarios para crear data frame
  dominio_valor = links %>% html_attr('href')
  nombre_valor = links %>% html_text()
  
  ### Construyento data frame
  link_dfID <- tibble(
    dominio = dominio_valor,
    nombre = nombre_valor
  )
  
  url <- paste0(link_dfID$dominio[which(grepl("Anexo", link_dfID$nombre))][1])

  
# Descargando archivo

#  as.Date(35981, origin = "1899-12-30")
#  as.Date(43831, origin = "1899-12-30")
  
download.file(url, destfile = "sector_elec.xlsx", mode = "wb")


# Cargando archivo y seleccionando periodo de actualizaci?n de datos: desde ene 2020 hasta el ultimo mes con datos, 
#para el los resultados financieros se actualiza el a?o en curso

dist_elec <- read.xlsx("sector_elec.xlsx", 
                       sheet = "EDE's",startRow = 5)
dist_elec <- cbind(dist_elec[,1], dist_elec[,which(as.numeric(dist_elec[1,])==43831):ncol(dist_elec)])
dist_elec <- dist_elec[,-(which(dist_elec[1,]==2009)):-ncol(dist_elec)]

gen_elec <- read.xlsx("sector_elec.xlsx", 
                      sheet = "Variables Relevantes",startRow = 6)
gen_elec <- cbind(gen_elec[,2], gen_elec[,which(as.numeric(gen_elec[1,])==43831):ncol(gen_elec)])
gen_elec <- gen_elec[,-(which(gen_elec[1,]==2009)):-ncol(gen_elec)]

res_fin <- read.xlsx("sector_elec.xlsx", 
                      sheet = "Anexo Res Financieros",
                      cols =  2:14,
                      rows = 14:305)


if(substr(file.info("sector_elec.xlsx")$mtime, 1, 10)==Sys.Date()) {
  
  indicadores <- read_excel("M:/Direccion Estadisticas Fiscales/Dashboard DGAPF/Dashboard Monitor Energetico/indicadores_energeticos.xlsx", col_types = c("numeric","date", rep("numeric", 60)))
 
#as.numeric(as.Date("2022-12-01"))  
#as.Date(44896-25568)
}

  #---------------------------Actualizando indicadores-----------------------
  ################################################################################
  cn <- gen_elec[, 1]
  gen_elec <- gen_elec[, -1]
  int_a <- 1:ncol(gen_elec)
  print(cn)
  
  # Generación 
  indicadores$`Total Generación`[int_a] <- as.numeric(gen_elec[which(cn=="Total Generación"), ])
  indicadores$`Carbón Mineral (Generación de Energía por tipo de combustible)`[int_a] <- as.numeric(gen_elec[which(cn=="Total Generación")+1, ])
  indicadores$`Gas Natural (Generación de Energía por tipo de combustible)`[int_a] <- as.numeric(gen_elec[which(cn=="Total Generación")+2, ])
  indicadores$`Fuel Oil No. 2 (Generación de Energía por tipo de combustible)`[int_a] <- as.numeric(gen_elec[which(cn=="Total Generación")+3, ])
  indicadores$`Fuel Oil No. 6 (Generación de Energía por tipo de combustible)`[int_a] <- as.numeric(gen_elec[which(cn=="Total Generación")+4, ])
  indicadores$`Fuel Oil No. 2 y No. 6 (Generación de Energía por tipo de combustible)`[int_a] <- as.numeric(gen_elec[which(cn=="Total Generación")+5, ])
  indicadores$`Hidráulica (Generación de Energía por tipo de combustible)`[int_a] <- as.numeric(gen_elec[which(cn=="Total Generación")+6, ])
  indicadores$`Eòlica (Generación de Energía por tipo de combustible)`[int_a] <- as.numeric(gen_elec[which(cn=="Total Generación")+7, ])
  indicadores$`Solar Fotovoltaica (Generación de Energía por tipo de combustible)`[int_a] <- as.numeric(gen_elec[which(cn=="Total Generación")+8, ])
  indicadores$`Biomasa (Generación de Energía por tipo de combustible)`[int_a] <- as.numeric(gen_elec[which(cn=="Total Generación")+9, ])
  
  # Costos 
  indicadores$`Costos Marginal de Energía (USCents$/KWh)`[int_a]  <- as.numeric(gen_elec[which(cn=="Costos Marginal de Energía (cUSD$/KWh)"), ])
  indicadores$`Costos Marginal de Potencia  (US$/kW-Mes)`[int_a]  <- as.numeric(gen_elec[which(cn=="Costos Marginal de Potencia  (cUSD/kW-Mes)"), ])
  indicadores$`Peaje de Transmisión (USCents$/KWh)`[int_a]  <- as.numeric(gen_elec[which(cn=="Peaje de Transmisión (cUSD/KWh)"), ])
  indicadores$`Derecho de Conexión Unitario (US$/kW-mes)`[int_a]  <- as.numeric(gen_elec[which(cn=="Derecho de Conexión Unitario (USD/kW-mes)"), ])
  
  # Precios 
  indicadores$`Fuel Oil # 2 (Precios Combustibles)`[int_a]  <- as.numeric(gen_elec[which(cn=="Fuel Oil # 2 (US$/MMBTU)"), ])
  indicadores$`Fuel Oil # 6 (Precios Combustibles)`[int_a]  <- as.numeric(gen_elec[which(cn=="Fuel Oil # 6 (US$/MMBTU)"), ])
  indicadores$`Gas Natural (Precios Combustibles)`[int_a]  <- as.numeric(gen_elec[which(cn=="Gas Natural (US$/MMBTU)"), ])
  indicadores$`Gas Natural Conversion (Precios Combustibles)`[int_a]  <- as.numeric(gen_elec[which(cn=="Gas Natural Conversion (US$/MMBTU)"), ])
  indicadores$`Carbón Mineral (Precios Combustibles)`[int_a]  <- as.numeric(gen_elec[which(cn=="Carbón Mineral (US$/MMBTU)"), ])
  indicadores$`Tasa de Cambio  (RD$/US$)`[int_a]  <- as.numeric(gen_elec[which(cn=="Tasa de Cambio  (DOP/USD)"), ])
  
  cn <- dist_elec[, 1]
  dist_elec <- dist_elec[, -1]
  int_a <- 1:ncol(dist_elec)
  
  indicadores$`Precio Medio de Venta de Energía (USCents/kWh)`[int_a] <- as.numeric(dist_elec[which(cn=="Precio Medio de Venta de Energía (cUSD/kWh)"), ])
  indicadores$`Edenorte Precio Medio de Venta de Energía (USCents/kWh)`[int_a] <- as.numeric(dist_elec[which(cn=="Precio Medio de Venta de Energía (cUSD/kWh)")+1, ])
  indicadores$`Edesur Precio Medio de Venta de Energía (USCents/kWh)`[int_a] <- as.numeric(dist_elec[which(cn=="Precio Medio de Venta de Energía (cUSD/kWh)")+2, ])
  indicadores$`Edeeste Precio Medio de Venta de Energía (USCents/kWh)`[int_a] <- as.numeric(dist_elec[which(cn=="Precio Medio de Venta de Energía (cUSD/kWh)")+3, ])
  
  indicadores$`Precio Medio de Compra de Energía SPOT (USCents/kWh)`[int_a] <- as.numeric(dist_elec[which(cn=="Precio Medio de Compra de Energía SPOT (cUSD/kWh)"), ])
  indicadores$`Edenorte Precio Medio de Compra de Energía SPOT (USCents/kWh)`[int_a] <- as.numeric(dist_elec[which(cn=="Precio Medio de Compra de Energía SPOT (cUSD/kWh)")+1, ])
  indicadores$`Edesur Precio Medio de Compra de Energía SPOT (USCents/kWh)`[int_a] <- as.numeric(dist_elec[which(cn=="Precio Medio de Compra de Energía SPOT (cUSD/kWh)")+2, ])
  indicadores$`Edeeste Precio Medio de Compra de Energía SPOT (USCents/kWh)`[int_a] <- as.numeric(dist_elec[which(cn=="Precio Medio de Compra de Energía SPOT (cUSD/kWh)")+3, ])
  
  indicadores$`Precio Medio de Compra de Energía CONTRATOS (USCents/kWh)`[int_a] <- as.numeric(dist_elec[which(cn=="Precio Medio de Compra de Energía CONTRATOS (cUSD/kWh)"), ])
  indicadores$`Edenorte Precio Medio de Compra de Energía CONTRATOS (USCents/kWh)`[int_a] <- as.numeric(dist_elec[which(cn=="Precio Medio de Compra de Energía CONTRATOS (cUSD/kWh)")+1, ])
  indicadores$`Edesur Precio Medio de Compra de Energía CONTRATOS (USCents/kWh)`[int_a] <- as.numeric(dist_elec[which(cn=="Precio Medio de Compra de Energía CONTRATOS (cUSD/kWh)")+2, ])
  indicadores$`Edeeste Precio Medio de Compra de Energía CONTRATOS (USCents/kWh)`[int_a] <- as.numeric(dist_elec[which(cn=="Precio Medio de Compra de Energía CONTRATOS (cUSD/kWh)")+3, ])
  
  # Distribuci?n 
  
  
  indicadores$`CRI (%)`[int_a] <- dist_elec[which(cn=="CRI (%)"), ]
  indicadores$`Edenorte CRI (%)`[int_a] <- dist_elec[which(cn=="CRI (%)")+1, ]
  indicadores$`Edesur CRI (%)`[int_a] <- dist_elec[which(cn=="CRI (%)")+2, ]
  indicadores$`Edeeste CRI (%)`[int_a] <- dist_elec[which(cn=="CRI (%)")+3, ]
  
  indicadores$`Energía Facturada (GWh)`[int_a] <- dist_elec[which(cn=="Energía Facturada (GWh)"), ]
  indicadores$`Edenorte Energía Facturada (GWh)`[int_a] <- dist_elec[which(cn=="Energía Facturada (GWh)")+1, ]
  indicadores$`EdesurEnergía Facturada (GWh)`[int_a] <- dist_elec[which(cn=="Energía Facturada (GWh)")+2, ]
  indicadores$`Edeeste Energía Facturada (GWh)`[int_a] <- dist_elec[which(cn=="Energía Facturada (GWh)")+3, ]
  
  indicadores$Perdida[int_a] <- as.numeric(dist_elec[which(cn=="Pérdidas (%)"), ])
  indicadores$Perdida_Edenorte[int_a] <- as.numeric(dist_elec[which(cn=="Pérdidas (%)")+1, ])
  indicadores$Perdida_Edesur[int_a] <- as.numeric(dist_elec[which(cn=="Pérdidas (%)")+2, ])
  indicadores$Perdida_Edeeste[int_a] <- as.numeric(dist_elec[which(cn=="Pérdidas (%)")+3, ])
  
  indicadores$Cobranzas[int_a] <- as.numeric(dist_elec[which(cn=="Cobranzas (%)"), ])
  indicadores$Cobranzas_Edenorte[int_a] <- as.numeric(dist_elec[which(cn=="Cobranzas (%)")+1, ])
  indicadores$Cobranzas_Edesur[int_a] <- as.numeric(dist_elec[which(cn=="Cobranzas (%)")+2, ])
  indicadores$Cobranzas_Edeeste[int_a] <- as.numeric(dist_elec[which(cn=="Cobranzas (%)")+3, ])
  
  # Anexo Resultados financieros
  
  anio_res_f <- colnames(read.xlsx("sector_elec.xlsx", 
                          sheet = "Anexo Res Financieros",
                          #cols =  2:14,
                          rows = 14))[2]
  
  t <- substr(anio_res_f, nchar(anio_res_f)-3, nchar(anio_res_f))
  i_pos <- which(indicadores$Periodo==t)[1]
  
  cn <- res_fin[, 1]
  res_fin <- res_fin[, -1]
  int_a <- i_pos:(i_pos+1)
  
  
  indicadores$Def_op[int_a] <- as.numeric(res_fin[which(cn=="4. Balance Operacional (1-2)")[1], ])
  indicadores$Def_op_Edenorte[int_a] <- as.numeric(res_fin[which(cn=="4. Balance Operacional (1-2)")[2], ])
  indicadores$Def_op_Edesur[int_a] <- as.numeric(res_fin[which(cn=="4. Balance Operacional (1-2)")[3], ])
  indicadores$Def_op_Edeeste[int_a] <- as.numeric(res_fin[which(cn=="4. Balance Operacional (1-2)")[4], ])
  
  indicadores$Def_capex[int_a] <- as.numeric(res_fin[which(cn=="6. Balance con Inversiones (4-5)")[1], ])
  indicadores$Def_capex_Edenorte[int_a] <- as.numeric(res_fin[which(cn=="6. Balance con Inversiones (4-5)")[2], ])
  indicadores$Def_capex_Edesur[int_a] <- as.numeric(res_fin[which(cn=="6. Balance con Inversiones (4-5)")[3], ])
  indicadores$Def_capex_Edeeste[int_a] <- as.numeric(res_fin[which(cn=="6. Balance con Inversiones (4-5)")[4], ])
  
  indicadores$Def_fin[int_a] <- as.numeric(res_fin[which(cn=="8.  Balance luego de Financiamiento (7+8)")[1], ])
  indicadores$Def_fin_Edenorte[int_a] <- as.numeric(res_fin[which(cn=="8.  Balance luego de Financiamiento (7+8)")[2], ])
  indicadores$Def_fin_Edesur[int_a] <- as.numeric(res_fin[which(cn=="8.  Balance luego de Financiamiento (7+8)")[3], ])
  indicadores$Def_fin_Edeeste[int_a] <- as.numeric(res_fin[which(cn=="8.  Balance luego de Financiamiento (7+8)")[4], ])
  
  indicadores <- as.data.frame(indicadores)

  
  xlsx::write.xlsx(indicadores, file = "M:/Direccion Estadisticas Fiscales/Dashboard DGAPF/Dashboard Monitor Energetico/indicadores_energeticos.xlsx", 
                   row.names = FALSE,
                   showNA = FALSE,)
  
  




