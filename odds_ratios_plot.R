#### odds_ratios_plot.R ####
#### Jimmy Zhang @ 7/20/2022 ####

#set working directory
bdir = "~/Desktop/DSI_Scholars/CDI_Marketscan"
setwd(bdir)

#load packages
install.packages("ggplot2")
install.packages('svglite')
library(ggplot2)
library(svglite)

#make data frame with hard coded odds ratios and 95% CIs (taken from logistic regression output)
odds_ratios_df = data.frame(index = c(1:10),
                            antibiotic = c("Clindamycin", "Cefdinir", "Cefuroxime",
                                           "Fluoroquinolones", "Amoxicillin", "Cephalexin",
                                           "Nitrofurantoin", "Clarithromycin", 
                                           "Penicillin VK", "Azithromycin"),
                            effect = c(8.81, 5.86, 4.57, 4.05, 2.29, 1.97, 
                                       1.92, 1.31, 1.21, 0.77),
                            lower = c(7.76, 5.03, 3.87, 3.58, 2.02, 1.71, 
                                      1.63, 1.03, 1.00, 0.67),
                            upper = c(10.00, 6.83, 5.39, 4.59, 2.60, 2.25, 
                                      2.26, 1.66, 1.47, 0.88),
                            colors = c("gold", "goldenrod", "hotpink", "darkgreen", "darkslategray", 
                                       "darkblue", "aquamarine", "dodgerblue", "magenta",
                                       "maroon")
)

#make forest plot
g = ggplot(data = odds_ratios_df,
           aes(y=index, x=effect, xmin=lower, xmax=upper)) +
  geom_point(shape=18, size=14, color = odds_ratios_df$colors) +
  geom_errorbarh(height=0.7, color = odds_ratios_df$colors) +
  scale_x_continuous(trans="log10") +
  scale_y_continuous(name="Antibiotic", 
                   breaks=1:nrow(odds_ratios_df), 
                   labels=odds_ratios_df$antibiotic,
                   trans="reverse") +
  xlab("Odds Ratios of C. difficile Infection (Reference = Doxycycline)") +
  labs(title = "Adjusted Odds Ratios of C. difficile Infection Across Antibiotics") +
  geom_vline(xintercept=1, color='red', linetype='dashed', cex=1, alpha=0.5) +
  theme_bw(base_size=26) +
  theme(plot.title=element_text(hjust=0.5))

ggsave(filename="figures/odds_ratios_plot_color.svg",
       plot=g,
       width = 15,
       height = 12,
       dpi=300)