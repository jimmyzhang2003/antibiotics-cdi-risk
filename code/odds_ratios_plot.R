#### odds_ratios_plot.R ####
#### Jimmy Zhang @ 5/20/2022 ####

#set working directory
bdir = "~/Desktop/DSI_Scholars/CDI_Marketscan"
setwd(bdir)

#load packages
install.packages("ggplot2")
install.packages("randomcoloR")
install.packages('svglite')
library(ggplot2)
library(randomcoloR)
library(svglite)

#make data frame with hard coded odds ratios and 95% CIs (taken from logistic regression output)
odds_ratios_df = data.frame(index = c(1:10),
                            antibiotic = c("Clindamycin", "Cefdinir", "Cefuroxime",
                                           "Fluoroquinolones", "Nitrofurantoin",
                                           "Cephalexin", "Amoxicillin", "Penicillin VK", 
                                           "Clarithromycin", "Azithromycin"),
                            effect = c(3.702, 2.876, 2.307, 2.019, 1.386, 1.207,
                                       1.192, 0.793, 0.781, 0.684),
                            lower = c(3.310, 2.473, 1.957, 1.817, 1.198, 1.072,
                                      1.071, 0.661, 0.614, 0.609),
                            upper = c(4.140, 3.344, 2.720, 2.243, 1.604, 1.360,
                                      1.326, 0.951, 0.995, 0.768))

#make forest plot
colors = randomColor(count = 10, luminosity = "dark")
g = ggplot(data = odds_ratios_df,
           aes(y=index, x=effect, xmin=lower, xmax=upper)) +
  geom_point(shape=18, size=5, color = colors) +
  geom_errorbarh(height=0.3, color = colors) +
  scale_y_continuous(name="Antibiotic", 
                   breaks=1:nrow(odds_ratios_df), 
                   labels=odds_ratios_df$antibiotic,
                   trans="reverse") +
  xlab("Adjusted Relative Risk of C. difficile Infection (Reference = Doxycycline)") +
  labs(title = "Relative Risk of C. difficile Infection Across Antibiotic Classes") +
  geom_vline(xintercept=1, color='red', linetype='dashed', cex=1, alpha=0.5) +
  theme_bw(base_size=20) +
  theme(plot.title=element_text(hjust=0.5))

ggsave(filename="results/odds_ratios_plot_color.svg",
       plot=g,
       width = 15,
       height = 12,
       dpi=300)

#without colors
g2 = ggplot(data = odds_ratios_df,
           aes(y=index, x=effect, xmin=lower, xmax=upper)) +
  geom_point(shape=18, size=5) +
  geom_errorbarh(height=0.3) +
  scale_y_continuous(name="Antibiotic", 
                     breaks=1:nrow(odds_ratios_df), 
                     labels=odds_ratios_df$antibiotic,
                     trans="reverse") +
  xlab("Adjusted Relative Risk of C. difficile Infection (Reference = Doxycycline)") +
  labs(title = "Relative Risk of C. difficile Infection Across Antibiotic Classes") +
  geom_vline(xintercept=1, color='red', linetype='dashed', cex=1, alpha=0.5) +
  theme_bw(base_size=20) +
  theme(plot.title=element_text(hjust=0.5))

ggsave(filename="results/odds_ratios_plot_no_color.svg",
       plot=g2,
       width = 15,
       height = 12,
       dpi=300)