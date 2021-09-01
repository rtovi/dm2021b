#limpio la memoria
rm(list=ls())   #remove all objects
gc()            #garbage collection

#Arbol elemental con libreria  rpart
require("data.table")
require("rpart")

setwd("M:\\")  #Establezco el Working Directory

#cargo los datos de 202001 que es donde voy a ENTRENAR el modelo
dtrain  <- fread("./datasetsOri/paquete_premium_202011.csv")


modeloA   <- rpart("clase_ternaria ~ .", 
                   data= dtrain, 
                   xval= 0, 
                   cp= -1, 
                   maxdepth= 5 )


#calculo la ganancia del arbol   A en los datos donde entrene
tabla_arbolA  <- as.data.table( modeloA$frame )
tabla_arbolA[ , ganancia :=   -1250*yval2.V2  + 48750*yval2.V3 - 1250*yval2.V4 ]
#sumo los nodos que son hojas y tienen ganancia positiva en los datos donde entrene
tabla_arbolA[ var=="<leaf>" & ganancia>0,  sum( ganancia ) ]



#aplico el modeloA  a los datos de 202101
dapply  <- fread("./datasetsOri/paquete_premium_202101.csv")

prediccionA  <- predict( modeloA, dapply , type = "prob")

dapply[ , prob_baja2 := prediccionA[, "BAJA+2"] ]
dapply[ , Predicted := as.numeric(prob_baja2 > 0.025) ]

entregaA  <- dapply[   , list( numero_de_cliente, Predicted)  ]

fwrite( entregaA, file="./kaggle/MiPrimerModelo_01.csv", sep="," )

#ahora debo subir la prediccion a Kaggle y ver como me fue
