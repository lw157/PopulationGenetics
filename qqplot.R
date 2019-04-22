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
