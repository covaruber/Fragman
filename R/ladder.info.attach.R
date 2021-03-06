ladder.info.attach <- function(stored, ladder, 
                               channel.ladder=NULL, method="iter2", 
                               ladd.init.thresh=NULL, env = parent.frame(), 
                               prog=TRUE, draw=TRUE, attempt=10){
  all.names <- names(stored)
  
  ## make sure you did not read channels with missing info
  good <- apply(stored[[1]],2, function(x){length(which(is.na(x)))/length(x)})
  keep <- which(good ==0)
  stored <- lapply(stored, function(x){x[,keep]})
  ##
  
  dev=50; warn= FALSE
  if(is.null(channel.ladder)){
    channel.ladder <- dim(stored[[1]])[2]
  }else{channel.ladder <- channel.ladder}
  layout(matrix(1:3,nrow=3, ncol=1))
  #####################
  ### this part extracts all the models for each single plant in my plants
  list.ladders <- lapply(stored, function(x){y <- x[,channel.ladder]; return(y)})
  # extract ladder channels for all plants
  #to.add <- names(stored)
  #for(f in 1:length(list.ladders)){
  #  attributes(list.ladders[[f]])$name <- to.add[f]
  #}
  ##
  for(t in 1:length(list.ladders)){
    attributes(list.ladders[[t]]) <- list(mycomm=names(list.ladders)[t])
  }
  
  if(prog==TRUE){
    res <- lapply_pb(list.ladders, find.ladder, init.thresh=ladd.init.thresh, ladder=ladder, dev=dev, warn=warn, method=method, draw=draw, attempt=attempt)
  }
  if(prog==FALSE){
    res <- lapply(list.ladders, find.ladder, ladder=ladder, dev=dev, warn=warn,  method=method,init.thresh=ladd.init.thresh, draw=draw, attempt=attempt)
  }
  env$list.data.covarrubias <- res
  
  cat("\nSizing process complete. Information has been stored in the environment for posterior functions.\nFor example to be used by the overview2() or score.markers() functions.")
  
  correlations <- unlist(lapply(res, function(x){x$corr}))
  if(length(which(correlations < .92)) >0){
    cat(paste("\nWe did not find a good ladder in",length(which(correlations < .92)),"sample(s). \nIf you wish to correct it you can try one of the following:\n"))
    cat("\na) The value of ladd.init.thresh might be too low, making noisy peaks too be abundant \n     Solution-- make sure your initial value 'init.thresh' is not below 200 RFUs\nb) You can continue your analysis without worrying for those samples or removing. Identify them as:\n     corro <- unlist(lapply(list.data.covarrubias, function(x){x$corr}))\n     (bad <- which(corro < .9999))\nc) MOST IMPORTANT! you can correct manually the bad samples using the 'ladder.corrector()' function providing the names of the bad samples (below), your ladder, and the information from the 'storing.inds' function, type ?ladder.corrector\n\nNames of the bad sample(s):\n")
    # a) The first peaks of your ladder are in a very noisy area \n     Solution-- try discarding some initial values of your ladder, start one by one \n
    #print(all.names[which(correlations < .92)])
   # if(length(which(correlations < .92)) > (length(correlations)*.05)){
    #  ww <- which(correlations < .92)[1]
    #  prov <- stored[[ww]][,dim(stored[[ww]])[2]]
    #  mind <- big.peaks.col(prov, ladd.init.thresh)
    #  layout(matrix(1,1,1))
    #  plot(prov, type="l", ylim=c(0,4000))
    #  abline(v=mind$pos, lty=3, col="red")
      #legend("topright", legend=paste(length(mind$pos),"peaks found,",length(ladder),"ladder peaks expected"), bty="n")
    #  legend("center", legend=c(paste(ladder[1:round(length(ladder)/2)],"",sep="", collapse = "  ")),bty="n", cex=.7)
    #  legend("topleft", legend="?",bty="n", cex=2)
    #  cat(paste("We will show you a plot of the ladder channel of one bad sample, you provided a ladder with",length(ladder), "expected peaks and there's",length(mind$pos), "peaks in the channel, make sure that 1st peak of your ladder is not in an area with too much noise \nSolution-- Consider discarding some initial values of your ladder \n "))
      
    #}
  }
  ######################
  layout(matrix(1,1,1))
  
  bads <- all.names[which(correlations < .92)]
  if(length(bads)>0){
    return(bads) 
  }
}



##################################################################################################
#Startup function
#this function is executed once the library is loaded
.onAttach = function(library, pkg)
{
  Rv = R.Version()
  if(!exists("getRversion", baseenv()) || (getRversion() < "2.1"))
    stop("This package requires R 2.1 or later")
  assign(".Fragman.home", file.path(library, pkg),
         pos=match("package:Fragman", search()))
  Fragman.version = "1.0.9 (2018-02-01)"
  assign(".Fragman.version", Fragman.version, pos=match("package:Fragman", search()))
  if(interactive())
  {
    packageStartupMessage(paste("## ============================================================= ## "),appendLF=TRUE)
    packageStartupMessage(paste("## ============================================================= ## "),appendLF=TRUE)
    packageStartupMessage(paste("# Fragman: An R package for Fragment Analysis ", Fragman.version, ". ",sep=""),appendLF=TRUE)
    packageStartupMessage("# Author: Covarrubias-Pazaran et al. (2016)",appendLF=TRUE)
    packageStartupMessage("# Published: BMC Genetics 17(62):1-8",appendLF=TRUE)
    packageStartupMessage("# Supported and partially funded by:", appendLF=TRUE)
    packageStartupMessage("#    + Council of Science and Technology (CONACYT)", appendLF=TRUE)
    packageStartupMessage("#    + US Department of Agriculture (USDA-ARS)", appendLF=TRUE)
    packageStartupMessage("# Type 'help(Fragman)' for summary information",appendLF=TRUE)
    packageStartupMessage("# Type 'citation(Fragman)' to know how to cite this package",appendLF=TRUE)
    packageStartupMessage("# Update Fragman from time to time using 'install.packages('Fragman')'",appendLF=TRUE)
    packageStartupMessage(paste("## ============================================================= ## "),appendLF=TRUE)
    packageStartupMessage(paste("## ============================================================= ## "),appendLF=TRUE)
  }
  invisible()
}

