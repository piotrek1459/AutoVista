############################################################
##  Automobile Imports-85 : 10 Hypothesis-Tests in R      ##
############################################################

# ---- 1. libraries ----
suppressPackageStartupMessages({
  library(dplyr)
  library(coin)
  library(vcd)
})


# ---- 2. read & prepare data ----
cols <- c("symboling","normalized_losses","make","fuel_type","aspiration",
          "num_of_doors","body_style","drive_wheels","engine_location","wheel_base",
          "length","width","height","curb_weight","engine_type","num_of_cylinders",
          "engine_size","fuel_system","bore","stroke","compression_ratio",
          "horsepower","peak_rpm","city_mpg","highway_mpg","price")

data_path <- "/Users/piotr/Documents/smProject/automobile/imports-85.data"
dat <- read.csv(data_path, header = FALSE, na.strings = "?", col.names = cols)

num_vars <- c("normalized_losses","engine_size","horsepower",
              "city_mpg","highway_mpg","price")
dat[num_vars] <- lapply(dat[num_vars], as.numeric)

# derived metric
dat <- dat %>%
  mutate(fuel_efficiency = rowMeans(select(., city_mpg, highway_mpg), na.rm = TRUE))

# helper to print tidy headers
sep_line <- function(title) {
  cat("\n", paste0(rep("=", 65), collapse = ""), "\n")
  cat(title, "\n")
  cat(paste0(rep("-", 65), collapse = ""), "\n")
}

# ======================================================================
#  TEST 1 – Pearson correlation:  Engine Size  vs  Price
# ======================================================================
sep_line("TEST 1  :  Pearson correlation – Engine Size vs Price")
test1 <- cor.test(dat$engine_size, dat$price, use = "complete.obs")
print(test1)

# ======================================================================
#  TEST 2 – Pearson correlation:  Horsepower  vs  Price
# ======================================================================
sep_line("TEST 2  :  Pearson correlation – Horsepower vs Price")
test2 <- cor.test(dat$horsepower, dat$price, use = "complete.obs")
print(test2)

# ======================================================================
#  TEST 3 – Pearson correlation:  City MPG  vs  Highway MPG
# ======================================================================
sep_line("TEST 3  :  Pearson correlation – City MPG vs Highway MPG")
test3 <- cor.test(dat$city_mpg, dat$highway_mpg, use = "complete.obs")
print(test3)

# ======================================================================
#  TEST 4 – Permutation Spearman:  Fuel Efficiency  vs  Engine Size
# ======================================================================
sep_line("TEST 4  :  Permutation Spearman – Fuel Efficiency vs Engine Size")
set.seed(123)   # reproducible resampling
test4 <- spearman_test(
          fuel_efficiency ~ engine_size,
          data = dat,
          distribution = approximate(nresample = 10000)  # ← new arg name
        )
print(test4)

# ======================================================================
#  TEST 5 – Welch t-test:  Price  by  Fuel Type  (gas vs diesel)
# ======================================================================
sep_line("TEST 5  :  Welch t-test – Price by Fuel Type (gas vs diesel)")
test5 <- t.test(price ~ fuel_type, data = dat)
print(test5)

# ======================================================================
#  TEST 6 – Welch t-test:  Horsepower  by  Aspiration  (turbo vs standard)
# ======================================================================
sep_line("TEST 6  :  Welch t-test – Horsepower by Aspiration (turbo vs standard)")
test6 <- t.test(horsepower ~ aspiration, data = dat)
print(test6)

# ======================================================================
#  TEST 7 – One-way ANOVA:  Normalized Losses across Symboling levels
# ======================================================================
sep_line("TEST 7  :  One-way ANOVA – Normalized Losses by Symboling")
anova7 <- aov(normalized_losses ~ factor(symboling), data = dat)
print(summary(anova7))

# ======================================================================
#  TEST 8 – Chi-square (Monte Carlo):  Fuel Type  vs  Aspiration
# ======================================================================
sep_line("TEST 8  :  Chi-square + Cramér's V – Fuel Type vs Aspiration")
tab8   <- table(dat$fuel_type, dat$aspiration)
set.seed(123)
chisq8 <- chisq.test(tab8, simulate.p.value = TRUE, B = 10000)
print(chisq8)

V8 <- assocstats(tab8)$cramer          # Cramér’s V from vcd
cat("Cramér's V =", round(V8, 3), "\n")

# ======================================================================
#  TEST 9 – Chi-square (Monte Carlo):  Body Style  vs  Drive Wheels
# ======================================================================
sep_line("TEST 9  :  Chi-square (Monte Carlo) – Body Style vs Drive Wheels")
tab9   <- table(dat$body_style, dat$drive_wheels)
set.seed(123)
chisq9 <- chisq.test(tab9, simulate.p.value = TRUE, B = 10000)
print(chisq9)

V9 <- assocstats(tab9)$cramer
cat("Cramér's V =", round(V9, 3), "\n")

# ======================================================================
#  TEST 10 – Kruskal-Wallis:  Price across Symboling categories
# ======================================================================
sep_line("TEST 10 :  Kruskal-Wallis – Price by Symboling (non-parametric)")
kw10 <- kruskal.test(price ~ factor(symboling), data = dat)
print(kw10)
