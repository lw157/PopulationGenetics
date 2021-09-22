## plot qq with CI using ggplot2 styple
## adapted from Kamil Slowikowski's gg_qqplot

qqplot <- function(pval, ci = 0.95) {
  N <- length(pval)
  dat <- data.frame(obs = -log10(sort(pval)),
                   exp = -log10(ppoints(N)),
                   clow  = -log10(qbeta(p = (1 - ci) / 2, shape1 = 1:N, shape2 = N:1)),
                   cupp   = -log10(qbeta(p = (1 + ci) / 2, shape1 = 1:N, shape2 = N:1))  )
  xlabels <- expression(paste("Expected ( -log"[10], plain(P), " )"))
  ylabels <- expression(paste("Observed (-log"[10], plain(P), " )" ))
  p = ggplot(dat) +
    geom_point(aes(exp, obs), shape = 20, size = 3) +
    geom_abline(intercept = 0, slope = 1,color = "red", linetype="dashed") +
    geom_ribbon(aes(x = exp, ymin = clow, ymax = cupp), fill = "lightblue", alpha=0.4) +
    xlab(xlabels) +
    ylab(ylabels)
  return(p)
}



inflation_adj <- function(PVALUE = NULL){
  
  chisq<-qchisq((1 - PVALUE), 1)
  lambda <- median(chisq)/qchisq(0.5,1)
  chi_adj <-  chisq /lambda
  padj<-pchisq(chi_adj, df=1,lower.tail=FALSE)
  
  return(list(p_raw = PVALUE, lambda = lambda, padj = padj ))
 }

'# example
'# 
'# p = data.table::fread("gwas.txt")
'# p_adj = inflation_adj(PVALUE = p$PVALUE)
'# qqplot(pval = padj$p_raw,ci = 0.95) ## qqplot for raw p values
'# qqplot(pval = padj$p_adj, ci=0.95) # qq plot for adjusted p value
