aa = read.csv("test.csv")
# library(zzlongplot)
source("zzlongplot.R")
p1 = lplot(aa, score ~ week | arm, ytype = "obs", ylab = "PSPRS score",
  ylab2 = "PSPRS change score", title = "PSPRS", title2 = "",
  caption = "error bars are plus/minus one standard error",
  caption2 = "Date from PASSPORT trial. Dam et al. Nat Med. 2021"
)
