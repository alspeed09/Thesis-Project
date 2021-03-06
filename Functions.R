#FUNCIONES EMPLEADAS EN EL PROCESAMIENTO DE DATOS.

#/////////////////////////////////////////////////
#Cbind para data frames ff.
cbind.ffdf2 <- function(d1, d2){
    D1names <- colnames(d1)
    D2names <- colnames(d2)
    mergeCall <- do.call("ffdf", c(physical(d1), physical(d2)))
    colnames(mergeCall) <- c(D1names, D2names)
    mergeCall
}

#/////////////////////////////////////////////////
#Plot de geolocalizacion de la raw data en archivos PNG
MapaRawData<-function(df,file,title,lonIni=-66.715,latIni=13.115,zoom=6,size=2,color="red"){
    png(file=file)
    map<-get_map(location= c(lon=lonIni,lat=latIni),zoom=zoom,maptype="terrain") 
    plotMapa<-ggmap(map) +
        geom_point(data=df,aes(x=lon,y=lat),col=color,show.legend=FALSE,size=size) +
        labs(title=title)	
    plot(plotMapa)
    dev.off()
}

#/////////////////////////////////////////////////
#Transformacion a formato decimal para geolocalizacion.
geo2dec<-function(c){
    z<-sapply(strsplit(c, "[o.\']"),as.character)
    dec<- as.numeric(z[1, ]) + as.numeric(z[2, ])/60 + as.numeric(z[3, ])/3600
    if (z[4, ]=="N"||z[4, ]=="E") {
        dec 
    }else{
        -dec
    } 
}

#/////////////////////////////////////////////////
#Formateo de las filas de los archivos txt descargados de la NOAA
formato<-function(fila,Tab){
    vect<-strsplit(as.character(fila)[1],split="")[[1]]
    if(Tab==TRUE){
        vect<-gsub("\t"," ",vect)
    }
    s<-which(vect==" ")
    pos<-rep(0,length(s))
    for(i in 1:(length(s)-1)){
        if(s[i]+1!=s[i+1]){
            pos[i]<-1
        }
    }
    pos[length(s)]<-1
    if(any(pos==0)){
        fila<-stringr::str_trim(paste0(vect[-s[pos==0]],collapse=""))
    }else{
        fila<-stringr::str_trim(paste0(vect,collapse=""))
    }
    return(strsplit(fila,split=" ")[[1]])
}

#/////////////////////////////////////////////////
#Importe y formateo de los archivos txt descargados de la NOAA
importar<-function(file,Tab=FALSE){
    data <- read.csv(paste0("~/Thesis Project AB/Data/Raw Data/",file),
                     na.strings=c(""),stringsAsFactors=F)
    k<-t(apply(data[-1,],1,formato,Tab))
    data[2:nrow(data),]<-k
    return(data)
}

#/////////////////////////////////////////////////
#Construccion del dataframe con los datos de geolocalizacion
dfGeo<-function(lista){
    lat<-c(lista[[1]][1],lista[[2]][1],lista[[3]][1])
    lon<-c(lista[[1]][2],lista[[2]][2],lista[[3]][2])
    lat<-geo2dec(lat)
    lon<-geo2dec(lon)
    return(data.frame(lat=lat,lon=lon))
}

#/////////////////////////////////////////////////
#Data frames con columnas de caracteres as.factor
df.as.factor<-function(df){
    pos<-which(unname(sapply(df,class))=="character")
    if(length(pos)!=0){
        for (i in 1:length(pos)){
            df[,pos[i]]<-as.factor(df[,pos[i]])
        }
    }
    return(df)
}

#/////////////////////////////////////////////////
#Merge ffdf all=TRUE
merge.ffdf.all<-function(x,y,by=intersect(names(x),names(y)),by.x=by,by.y=by){
    #Hacemos merges ff's por parte.
    aux1<-merge.ffdf(x,y,by.x,by.y,all.x=TRUE)
    aux2<-merge.ffdf(y,x,by.x,by.y,all.x=TRUE)
    #Transformamos en data frames estandar y eliminamos filas repetidas
    aux2<-aux2[,names(aux1)]
    aux1<-aux1[,names(aux1)]
    aux2<-aux2[!(aux2$clave %in% aux1$clave),]
    #Transformamos en data frames ff nuevamente y hacemos 'rbind'.
    aux1<-as.ffdf(aux1)
    #Check
    if(nrow(aux2) != 0){
        aux2 <- as.ffdf(aux2)
        df3 <- ffdfappend(aux1,aux2)
    }else{
        df3 <- aux1
    }
    #Exportamos
    return(df3)
}

#/////////////////////////////////////////////////
#Funcion que indica cuales filas del data frame son solo NA's.
fullNA<-function(df){
    d<-apply(df,1,function(i){sum(is.na(i))})
    pos<-which(d==ncol(df))
    if(length(pos)==0){
        stop("No implementar esta funcion. El data frame no tiene filas de NA's")
    }else{
        return(pos)   
    }
}

#/////////////////////////////////////////////////
#Formateando tablas de Cariaco
CariacoFormat<-function(data,vect,p1=":",p2=":",p3=":",complete=TRUE
                        ,v1=21,p=11,x2=TRUE,r1=1:3,r2=1:3,r3=1:3){
    data[,v1][p]<-"Lattitude"
    data[,v1][data$x1=="Cast 1"]<-df1$lat[1]
    data[,v1][data$x1=="Cast 2"]<-df1$lat[2]
    data[,v1][data$x1=="Cast 3"]<-df1$lat[3]
    data[,(v1+1)][p]<-"Longitude"
    data[,(v1+1)][data$x1=="Cast 1"]<-df1$lon[1]
    data[,(v1+1)][data$x1=="Cast 2"]<-df1$lon[2]
    data[,(v1+1)][data$x1=="Cast 3"]<-df1$lon[3] 
    if(x2==TRUE){
        if(complete==TRUE){
            a<-paste(strsplit(data$x2[vect[1]],split=" ")[[1]][r1]
                     ,collapse="")
            a<-sub(p1,"",a)
            data$x2[vect[1]]<-a
            b<-paste(strsplit(data$x2[vect[2]],split=" ")[[1]][r2]
                     ,collapse="")
            b<-sub(p2,"",b)
            data$x2[vect[2]]<-b
            c<-paste(strsplit(data$x2[vect[3]],split=" ")[[1]][r3]
                     ,collapse="")
            c<-sub(p3,"",c)
            data$x2[vect[3]]<-c
        }
        data$x1[data$x1=="Cast 1"]<-data$x2[vect[1]]
        data$x1[data$x1=="Cast 2"]<-data$x2[vect[2]]
        data$x1[data$x1=="Cast 3"]<-data$x2[vect[3]]
    }else{
        if(complete==TRUE){
            a<-paste(strsplit(data$x1[vect[1]],split=" ")[[1]][r1]
                     ,collapse="")
            a<-sub(p1,"",a)
            data$x1[vect[1]]<-a
            b<-paste(strsplit(data$x1[vect[2]],split=" ")[[1]][r2]
                     ,collapse="")
            b<-sub(p2,"",b)
            data$x1[vect[2]]<-b
            c<-paste(strsplit(data$x1[vect[3]],split=" ")[[1]][r3]
                     ,collapse="")
            c<-sub(p3,"",c)
            data$x1[vect[3]]<-c
        }
        data$x1[data$x1=="Cast 1"]<-data$x1[vect[1]]
        data$x1[data$x1=="Cast 2"]<-data$x1[vect[2]]
        data$x1[data$x1=="Cast 3"]<-data$x1[vect[3]]
    }
    return(data)
}

#/////////////////////////////////////////////////
#formateando tablas para futura union con rbind
formatUnion<-function(df1,df2){   
    faltantes<-names(df1)[!(names(df1) %in% names(df2))]
    nroColNA<-length(faltantes)
    if(nroColNA!=0){
        dataNA<-as.data.frame(
            matrix(rep(NA,times=(nroColNA*nrow(df2))),nrow(df2),nroColNA))
        names(dataNA)<-faltantes
        df2<-cbind(df2,dataNA)
    }
    faltantes<-names(df2)[!(names(df2) %in% names(df1))]
    nroColNA<-length(faltantes)
    if(nroColNA!=0){
        dataNA<-as.data.frame(
            matrix(rep(NA,times=(nroColNA*nrow(df1))),nrow(df1),nroColNA))
        names(dataNA)<-faltantes
        df1<-cbind(df1,dataNA)
    }
    df2<-df2[,names(df1)]
    return(list(df1,df2))
}

#/////////////////////////////////////////////////
#Formateando NAs
formatNA<-function(v){
    v[v=="n.d."]<-NA
    v[grep("-999",v)]<-NA
    if(class(v)=="numeric"){
        v[round(v,0)==-999]<-NA
    }
    return(v)
}

#/////////////////////////////////////////////////
#Formateando tablas del atlas.
atlasformat<-function(data){
    char<-as.character(data[1,1])
    data[,1]<-as.character(data[,1])
    data[1,1]<-char
    data$Medida<-rep(data[1,1], times=nrow(data))
    data<-data[,c(ncol(data),1:(ncol(data)-1))]
    data[2,2]<-"latitude"
    names(data)[2:ncol(data)]<-sapply(data[2,-1],as.character)
    data<-data[-c(1,2),]
    names(data)<-sapply(names(data),tolower)
    names(data)[4]<-"values at depths (m):0"
    return(data)
}

#/////////////////////////////////////////////////
#Formateando tablas del atlas.
aproxGeoloc<-function(df,lat,lon){
    if(nrow(df)==0){
        stop("El data frame ingresado no tiene filas.")
    }
    if(sum(c("latitude","longitude") %in% names(df)) < 2){
        stop("No se reconoce el data frame de localizacion.")
    }
    aux<-df[(lat-0.5)<=df$latitude & df$latitude<=(lat+0.5) &
            (lon-0.5)<=df$longitude & df$longitude<=(lon+0.5),]
    i<-1
    while(nrow(aux)==0){
        i<-i+0.1
        aux<-df[(lat-i)<=df$latitude & df$latitude<=(lat+i) &
                    (lon-i)<=df$longitude & df$longitude<=(lon+i),]       
    }
    df<-aux
    diff<-unname(apply(df,1,function(x){sqrt((x[1]-lat)^2+(x[2]-lon)^2)}))
    pos<-which.min(diff)
    return(list(latAprox=df$latitude[pos],lonAprox=df$longitude[pos],
                Error=round(diff[pos],4)))
}

#/////////////////////////////////////////////////
#Suprimir warings de ciertas funciones temporalmente.
suppressWarnings <- function(expr) {
    ops <- options(warn = -1)       ## FIXME: temporary hack until R_tryEval
    on.exit(options(ops))           ## calls are removed from methods code
    withCallingHandlers(expr,warning=function(w)invokeRestart("muffleWarning"))
}


#/////////////////////////////////////////////////
#Calculo de distancia entre puntos de geolocalizacion en kilometros.   
#p1=(lat,lon) p2=(lat,lon)
distGL <-function(p1,p2,r=6371){
    lat1 <-abs(p1[1])/180
    lat2 <-abs(p2[1])/180
    lon1 <-abs(p1[2])/180
    lon2 <-abs(p2[2])/180
    u <-c(r*cospi(lat1)*sinpi(lon1),r*cospi(lat1)*cospi(lon1),r*sinpi(lat1))
    v <-c(r*cospi(lat2)*sinpi(lon2),r*cospi(lat2)*cospi(lon2),r*sinpi(lat2))
    value <-as.numeric((u %*% v)/(sqrt(u %*% u)*sqrt(v %*% v)))
    if(abs(value - 1) < 0.00000000001){ #Esto es un Bug letal, un super bug.
        alp <-0
    }else{
        alp <-acos(value)
    }
    d <- r*alp
    return(d)
}   

#/////////////////////////////////////////////////
#Media movil
mm <- function(vect,ventana=10){
    nro <- ventana %/% 2
    for(i in nro:(length(vect) - nro)){
        vect[i] <- mean(vect[(i-(nro-1)):(i+nro)],na.rm = TRUE)
    }
    return(vect)
}
	
#Calculo de la moda de un vector categorico.
moda <- function(vect){
    m <- names(which.max(table(vect)))
    return(m)
}

#Stop quietly function 
stop_quietly <- function(){
    opt <- options(show.error.messages = FALSE)
    on.exit(options(opt))
    stop()
}