## plot qq with CI using ggplot2 styple
## adapted from Kamil Slowikowski's gg_qqplot, but with the "fast" features to thin the SNPs. This is very useful when there are millions of SNPs

qqplot <- function(pval, fast = FALSE, ci = 0.95) {
  N <- length(pval)
  xpvs = sort(pval)
  ypvs = sort(ppoints(N))
  
  keep = seq_along(ypvs)
  if (fast == TRUE){ 
    if (length(ypvs) > 1000) {
        xlv = as.integer((xpvs - xpvs[1])/diff(range(xpvs)) * 2000)
        ylv = as.integer((ypvs - ypvs[1])/diff(range(ypvs)) * 2000)
        keep = c(TRUE, (diff(xlv) != 0) | (diff(ylv) != 0) )
      } 
  }
  
  dat <- data.frame(obs = -log10(xpvs[keep]),
                   exp = -log10(ypvs[keep]),
                   clow  = -log10(qbeta(p = (1 - ci) / 2, shape1 = 1:N, shape2 = N:1))[keep],
                   cupp   = -log10(qbeta(p = (1 + ci) / 2, shape1 = 1:N, shape2 = N:1))[keep]
                   )
  xlabels <- expression(paste("Expected ( -log"[10], plain(P), " )"))
  ylabels <- expression(paste("Observed (-log"[10], plain(P), " )" ))
  
  p = ggplot(dat) +
    geom_point(aes(exp, obs), shape = 20, size = 3) +
    geom_abline(intercept = 0, slope = 1,color = "red", linetype="dashed") +
    xlab(xlabels) +
    ylab(ylabels)
  
  if(ci){
    p <- p +
      geom_ribbon(aes(x = exp, ymin = clow, ymax = cupp), fill = "lightblue", alpha=0.4)
  } 
  
  return(p)
}

lambda_adjust <- function(PVALUE = NULL){
  ## calculate the inflation - lambda and correct the raw p values
  
  PVALUE = PVALUE[!(is.infinite(PVALUE) | is.na(PVALUE))]
  
  chisq<-qchisq((1 - PVALUE), 1)
  lambda <- median(chisq)/qchisq(0.5,1)
  
  chi_adj <-  chisq /lambda
  padj <- pchisq(chi_adj, df=1,lower.tail=FALSE)
  
  return(list(p_raw = PVALUE, lambda = lambda, padj = padj ))
 }

'# example
'# 
'# p = data.table::fread("gwas.txt")
'# p_adj = lambda_adjust(PVALUE = p$PVALUE)
'# qqplot(pval = p_adj$p_raw, fast=T, ci = 0.95) ## qqplot for raw p values
'# qqplot(pval = p_adj$p_adj, fast = T, ci = 0.95) # qq plot for adjusted p value
'# 
'# add lambda value to plots
'# p = qqplot(p_adj$p_raw,fast = F, ci = 0.95)
'# myp <- myp +
'#     annotate('text', x=1,y= 10, label= bquote(lambda ~ "=" ~ .(round(p_adj$lambda,4)) ), cex=6)
