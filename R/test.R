aa = read.csv("test.csv")
# library(zzlongplot)
source("claude_zzlongplot.R")
p1 = lplot(aa, score ~ week | arm, cluster_var="rid", baseline_value="bl", plot_type = "both", ylab = "PSPRS score",
  ylab2 = "PSPRS change score", title = "PSPRS", title2 = "",
  caption = "error bars are plus/minus one standard error",
  caption2 = "Date from PASSPORT trial. Dam et al. Nat Med. 2021"
)
