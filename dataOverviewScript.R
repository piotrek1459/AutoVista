# Load necessary libraries
library(dplyr)
library(ggplot2)

# Read the dataset (adjust the file path if needed)
data <- read.csv("automobile/imports-85.data", header = FALSE, na.strings = "?")

# Assign column names based on the UCI Automobile (Imports-85) dataset description
colnames(data) <- c("symboling", "normalized_losses", "make", "fuel_type", "aspiration",
                    "num_of_doors", "body_style", "drive_wheels", "engine_location", "wheel_base",
                    "length", "width", "height", "curb_weight", "engine_type", "num_of_cylinders",
                    "engine_size", "fuel_system", "bore", "stroke", "compression_ratio",
                    "horsepower", "peak_rpm", "city_mpg", "highway_mpg", "price")

# Convert key attributes to numeric
data$normalized_losses <- as.numeric(data$normalized_losses)
data$engine_size <- as.numeric(data$engine_size)
data$horsepower <- as.numeric(data$horsepower)
data$city_mpg <- as.numeric(data$city_mpg)
data$highway_mpg <- as.numeric(data$highway_mpg)
data$price <- as.numeric(data$price)

# Create a derived metric: Fuel Efficiency (average of city and highway MPG)
data <- data %>% mutate(fuel_efficiency = (city_mpg + highway_mpg) / 2)

#----------------------------------------
# Aggregated Statistics
#----------------------------------------

# Price Statistics
price_stats <- data %>% summarise(
  mean_price = mean(price, na.rm = TRUE),
  median_price = median(price, na.rm = TRUE),
  var_price = var(price, na.rm = TRUE),
  sd_price = sd(price, na.rm = TRUE)
)
print("Price Statistics:")
print(price_stats)

# Engine Size Statistics
engine_size_stats <- data %>% summarise(
  mean_engine_size = mean(engine_size, na.rm = TRUE),
  median_engine_size = median(engine_size, na.rm = TRUE),
  var_engine_size = var(engine_size, na.rm = TRUE),
  sd_engine_size = sd(engine_size, na.rm = TRUE)
)
print("Engine Size Statistics:")
print(engine_size_stats)

# Horsepower Statistics
hp_stats <- data %>% summarise(
  mean_hp = mean(horsepower, na.rm = TRUE),
  median_hp = median(horsepower, na.rm = TRUE),
  var_hp = var(horsepower, na.rm = TRUE),
  sd_hp = sd(horsepower, na.rm = TRUE)
)
print("Horsepower Statistics:")
print(hp_stats)

# Normalized Losses Statistics
norm_loss_stats <- data %>% summarise(
  mean_norm_loss = mean(normalized_losses, na.rm = TRUE),
  median_norm_loss = median(normalized_losses, na.rm = TRUE),
  var_norm_loss = var(normalized_losses, na.rm = TRUE),
  sd_norm_loss = sd(normalized_losses, na.rm = TRUE)
)
print("Normalized Losses Statistics:")
print(norm_loss_stats)

# City MPG Statistics
city_mpg_stats <- data %>% summarise(
  mean_city_mpg = mean(city_mpg, na.rm = TRUE),
  median_city_mpg = median(city_mpg, na.rm = TRUE),
  var_city_mpg = var(city_mpg, na.rm = TRUE),
  sd_city_mpg = sd(city_mpg, na.rm = TRUE)
)
print("City MPG Statistics:")
print(city_mpg_stats)

# Highway MPG Statistics
highway_mpg_stats <- data %>% summarise(
  mean_highway_mpg = mean(highway_mpg, na.rm = TRUE),
  median_highway_mpg = median(highway_mpg, na.rm = TRUE),
  var_highway_mpg = var(highway_mpg, na.rm = TRUE),
  sd_highway_mpg = sd(highway_mpg, na.rm = TRUE)
)
print("Highway MPG Statistics:")
print(highway_mpg_stats)

# Fuel Efficiency Statistics
fuel_eff_stats <- data %>% summarise(
  mean_fuel_eff = mean(fuel_efficiency, na.rm = TRUE),
  median_fuel_eff = median(fuel_efficiency, na.rm = TRUE),
  var_fuel_eff = var(fuel_efficiency, na.rm = TRUE),
  sd_fuel_eff = sd(fuel_efficiency, na.rm = TRUE)
)
print("Fuel Efficiency Statistics:")
print(fuel_eff_stats)

# Symboling: Frequency distribution and statistics
symboling_freq <- table(data$symboling)
print("Symboling Frequency Distribution:")
print(symboling_freq)
symboling_stats <- data %>% summarise(
  mean_symboling = mean(symboling, na.rm = TRUE),
  median_symboling = median(symboling, na.rm = TRUE),
  var_symboling = var(symboling, na.rm = TRUE),
  sd_symboling = sd(symboling, na.rm = TRUE)
)
print("Symboling Statistics:")
print(symboling_stats)

#----------------------------------------
# Visualization and Saving Each Plot
#----------------------------------------

# Price: Histogram and Boxplot
p1 <- ggplot(data, aes(x = price)) +
  geom_histogram(binwidth = 2000, fill = "blue", color = "black", na.rm = TRUE) +
  ggtitle("Price Distribution") +
  xlab("Price") +
  ylab("Frequency")
ggsave("price_histogram.png", plot = p1, width = 8, height = 6, dpi = 300)

p2 <- ggplot(data, aes(y = price)) +
  geom_boxplot(fill = "orange", na.rm = TRUE) +
  ggtitle("Price Boxplot") +
  ylab("Price")
ggsave("price_boxplot.png", plot = p2, width = 8, height = 6, dpi = 300)

# Engine Size: Histogram and Boxplot
p3 <- ggplot(data, aes(x = engine_size)) +
  geom_histogram(binwidth = 10, fill = "green", color = "black", na.rm = TRUE) +
  ggtitle("Engine Size Distribution") +
  xlab("Engine Size (cc)") +
  ylab("Frequency")
ggsave("engine_size_histogram.png", plot = p3, width = 8, height = 6, dpi = 300)

p4 <- ggplot(data, aes(y = engine_size)) +
  geom_boxplot(fill = "purple", na.rm = TRUE) +
  ggtitle("Engine Size Boxplot") +
  ylab("Engine Size (cc)")
ggsave("engine_size_boxplot.png", plot = p4, width = 8, height = 6, dpi = 300)

# Horsepower: Histogram and Boxplot
p5 <- ggplot(data, aes(x = horsepower)) +
  geom_histogram(binwidth = 10, fill = "red", color = "black", na.rm = TRUE) +
  ggtitle("Horsepower Distribution") +
  xlab("Horsepower") +
  ylab("Frequency")
ggsave("horsepower_histogram.png", plot = p5, width = 8, height = 6, dpi = 300)

p6 <- ggplot(data, aes(y = horsepower)) +
  geom_boxplot(fill = "cyan", na.rm = TRUE) +
  ggtitle("Horsepower Boxplot") +
  ylab("Horsepower")
ggsave("horsepower_boxplot.png", plot = p6, width = 8, height = 6, dpi = 300)

# Normalized Losses: Histogram and Boxplot
p7 <- ggplot(data, aes(x = normalized_losses)) +
  geom_histogram(binwidth = 10, fill = "gray", color = "black", na.rm = TRUE) +
  ggtitle("Normalized Losses Distribution") +
  xlab("Normalized Losses") +
  ylab("Frequency")
ggsave("normalized_losses_histogram.png", plot = p7, width = 8, height = 6, dpi = 300)

p8 <- ggplot(data, aes(y = normalized_losses)) +
  geom_boxplot(fill = "magenta", na.rm = TRUE) +
  ggtitle("Normalized Losses Boxplot") +
  ylab("Normalized Losses")
ggsave("normalized_losses_boxplot.png", plot = p8, width = 8, height = 6, dpi = 300)

# City MPG: Histogram and Boxplot
p9 <- ggplot(data, aes(x = city_mpg)) +
  geom_histogram(binwidth = 2, fill = "darkgreen", color = "black", na.rm = TRUE) +
  ggtitle("City MPG Distribution") +
  xlab("City MPG") +
  ylab("Frequency")
ggsave("city_mpg_histogram.png", plot = p9, width = 8, height = 6, dpi = 300)

p10 <- ggplot(data, aes(y = city_mpg)) +
  geom_boxplot(fill = "lightblue", na.rm = TRUE) +
  ggtitle("City MPG Boxplot") +
  ylab("City MPG")
ggsave("city_mpg_boxplot.png", plot = p10, width = 8, height = 6, dpi = 300)

# Highway MPG: Histogram and Boxplot
p11 <- ggplot(data, aes(x = highway_mpg)) +
  geom_histogram(binwidth = 2, fill = "darkred", color = "black", na.rm = TRUE) +
  ggtitle("Highway MPG Distribution") +
  xlab("Highway MPG") +
  ylab("Frequency")
ggsave("highway_mpg_histogram.png", plot = p11, width = 8, height = 6, dpi = 300)

p12 <- ggplot(data, aes(y = highway_mpg)) +
  geom_boxplot(fill = "lightgreen", na.rm = TRUE) +
  ggtitle("Highway MPG Boxplot") +
  ylab("Highway MPG")
ggsave("highway_mpg_boxplot.png", plot = p12, width = 8, height = 6, dpi = 300)

# Fuel Efficiency: Histogram and Boxplot
p13 <- ggplot(data, aes(x = fuel_efficiency)) +
  geom_histogram(binwidth = 1, fill = "gold", color = "black", na.rm = TRUE) +
  ggtitle("Fuel Efficiency Distribution") +
  xlab("Fuel Efficiency (avg of city & highway MPG)") +
  ylab("Frequency")
ggsave("fuel_efficiency_histogram.png", plot = p13, width = 8, height = 6, dpi = 300)

p14 <- ggplot(data, aes(y = fuel_efficiency)) +
  geom_boxplot(fill = "salmon", na.rm = TRUE) +
  ggtitle("Fuel Efficiency Boxplot") +
  ylab("Fuel Efficiency")
ggsave("fuel_efficiency_boxplot.png", plot = p14, width = 8, height = 6, dpi = 300)

# Symboling: Bar Plot
p15 <- ggplot(data, aes(x = factor(symboling))) +
  geom_bar(fill = "steelblue", na.rm = TRUE) +
  ggtitle("Symboling Frequency Distribution") +
  xlab("Symboling") +
  ylab("Count")
ggsave("symboling_frequency.png", plot = p15, width = 8, height = 6, dpi = 300)
