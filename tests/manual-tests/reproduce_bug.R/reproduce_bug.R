library(zzlongplot)
# Load the package in development mode (no reinstall needed for code changes)
devtools::load_all()
# Now you can debug
df = read.csv("df.csv")
measure = "mmse"
group = "arm"
  fm1 <- as.formula(paste0(measure, " ~ month |", group))
fg1 = lplot(df, form = fm1, xlab = "visit", ylab = measure, title = measure,
    cluster_var="rid", baseline_value=0,
    plot_type = "obs", error_type = "band"
  )

