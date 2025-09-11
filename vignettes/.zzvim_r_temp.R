p_boxplot <- lplot(stats_demo, efficacy ~ visit | treatment,
                   cluster_var = "subject_id", baseline_value = 0,
                   summary_statistic = "boxplot",
                   theme = "nature",
                   title = "Boxplot Summary",
                   xlab = "Week", ylab = "Efficacy Score")
