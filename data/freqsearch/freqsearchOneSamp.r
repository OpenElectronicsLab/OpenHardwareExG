setwd("/home/ace/src/eeg-mouse/src")

#read in the data
#coding <- read.csv("coding.csv");
#creative <- read.csv("creativewriting.csv");
#eat <- read.csv("eat-drink.csv");
#eyesclosed <- read.csv("eyesClosed.csv");
#facebug <- read.csv("facebug.csv");
#looking <- read.csv("lookingAtPics.csv");
spreadsheet <- read.csv("spreadsheet.csv");
#stare <- read.csv("stareAtWall.csv");
#surfing1 <- read.csv("surfing1.csv");
#surfing2 <- read.csv("surfing2.csv");
#talking <- read.csv("talking.csv");

#number of rows
#nrow(coding)
#coding 77557
#creative 77329
#eat 32655
#eyesclosed 33305
#facebug 110411
#looking 76244
#spreadsheet 78475
#stare 44954
#surfing1 76473
#surfing2 77264
#talking 28326

#select rows 1-1000
#cod <- coding[1:1000,]

#codingF <- list()
#creativeF <- list()
#eatF <- list()
#eyesclosedF <- list()
#facebugF <- list()
#lookingF <- list()
spreadsheetF <- list()
#stareF <- list()
#surfing1F <- list()
#surfing2F <- list()
#talkingF <- list()

#N = 1000

splitter <- function(source,target){
index=1
n=N
 while(n < nrow(source)){
 temp <- source[(n-999):n,]
 target[[index]] <- temp
 n <- n+999
 index = index+1
 }
target
}

#codingF <- splitter(coding,codingF)
#creativeF <- splitter(creative,creativeF)
#eatF <- splitter(eat,eatF)
#eyesclosedF <- splitter(eyesclosed,eyesclosedF)
#facebugF <- splitter(facebug,facebugF)
#lookingF <- splitter(looking,lookingF)
spreadsheetF <- splitter(spreadsheet,spreadsheetF)
#stareF <- splitter(stare,stareF)
#surfing1F <- splitter(surfing1,surfing1F)
#surfing2F <- splitter(surfing2,surfing2F)
#talkingF <- splitter(talking,talkingF)

#for testing
#minisplit <- function(source,target){
#index=1
#n=10
# while(n < 50){
# temp <- source[(n-9):n,]
# target[[index]] <- list(temp)
# n <- n+9
# index = index+1
# }
#target
#}

    # sample rate (samples per second)
    rate <- 250
    # possible/valid fft frequencies
    f <- (0:(N - 1)) / N * rate; #N is set above

fflist <- function(sourcelist,targetlist){
    #take each item in the list
    for(i in seq(along=sourcelist)){
      fftresult = fft(sourcelist[[i]][,8])
      targetlist = cbind(targetlist, fftresult)
    }
targetlist
}

fftResults <- c()

#fftResults = fflist(codingF, fftResults)
#fftResults = fflist(creativeF, fftResults)
#fftResults = fflist(eatF, fftResults)
#fftResults = fflist(eyesclosedF, fftResults)
#fftResults = fflist(facebugF, fftResults)
#fftResults = fflist(lookingF, fftResults)
fftResults = fflist(spreadsheetF, fftResults)
#fftResults = fflist(stareF, fftResults)
#fftResults = fflist(surfing1F, fftResults)
#fftResults = fflist(surfing2F, fftResults)
#fftResults = fflist(talkingF, fftResults)

# another way to do for loops
# for (i in 1:10) { print(i); }

absFftResults = abs(fftResults)
means = apply(absFftResults, 1, mean)
sds = apply(absFftResults, 1, sd)
cvs = sds/means

#for each subsample, get the density of results at each fft result
#transpose it to get it in the same rows/columns as the original
densities = t(apply(absFftResults, 1, function (x) { density(x, from=0, to=0.020)$y }))

#install rgl if you don't have it
library(rgl)

rgl.open()
rgl.surface(1:1000, 1:512*2, densities/10, col="steelblue")
rgl.bbox()
