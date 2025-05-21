############################################################
##  Automobile Imports-85 – Regression Tree for Price     ##
############################################################

# ---- 1. libraries ----------------------------------------
suppressPackageStartupMessages({
  library(dplyr)
  library(caret)
  library(rpart)
  library(rpart.plot)
  library(ggplot2)
})

# ---- 2. read & clean raw data ----------------------------
cols <- c("symboling","normalized_losses","make","fuel_type","aspiration",
          "num_of_doors","body_style","drive_wheels","engine_location","wheel_base",
          "length","width","height","curb_weight","engine_type","num_of_cylinders",
          "engine_size","fuel_system","bore","stroke","compression_ratio",
          "horsepower","peak_rpm","city_mpg","highway_mpg","price")

raw <- read.csv("automobile/imports-85.data",
                header = FALSE, na.strings = "?", col.names = cols,
                stringsAsFactors = FALSE)

# numeric conversions
num_vars <- c("normalized_losses","engine_size","horsepower",
              "wheel_base","length","width","height","curb_weight",
              "city_mpg","highway_mpg","bore","stroke",
              "compression_ratio","peak_rpm","price")
raw[num_vars] <- lapply(raw[num_vars], as.numeric)

raw <- raw %>% filter(!is.na(price))          # need target value

# ---- 3. one-hot encode all factors -----------------------
dummyObj <- dummyVars(price ~ ., data = raw, fullRank = TRUE)
X        <- as.data.frame(predict(dummyObj, newdata = raw))

##  make every column name syntactically valid  <<<<<<<<<<<<<<
names(X) <- make.names(names(X), unique = TRUE)

dat <- bind_cols(X, price = raw$price)

# ---- 4. train / test split -------------------------------
set.seed(123)
tr_idx   <- createDataPartition(dat$price, p = 0.70, list = FALSE)
train_df <- dat[tr_idx, ]
test_df  <- dat[-tr_idx, ]

# ---- 5. rpart + caret settings ---------------------------
r_ctrl <- rpart.control(cp = 0, maxdepth = 30,
                        minsplit = 20, xval = 10)

cv_ctrl <- trainControl(method = "cv", number = 10)

set.seed(123)
tree_mod <- train(
  x          = train_df[ , setdiff(names(train_df), "price")],
  y          = train_df$price,
  method     = "rpart",
  trControl  = cv_ctrl,
  tuneLength = 10,
  metric     = "RMSE",
  control    = r_ctrl,
  na.action  = na.rpart           # surrogate splits for any numeric NA
)

cat("\nBest cp from 10-fold CV:\n")
print(tree_mod$bestTune)

final_tree <- tree_mod$finalModel

# ---- 6. test-set performance -----------------------------
pred  <- predict(final_tree, test_df)
rmse  <- RMSE(pred, test_df$price)
rsq   <- R2(pred,  test_df$price)
cat(sprintf("\nTest-set RMSE = %.2f   |   R² = %.3f\n", rmse, rsq))

# ---- 7. visualisations -----------------------------------

## 7a. tree diagram
png("reg_tree_price.png", width = 900, height = 600, res = 120)
rpart.plot(final_tree,
           type = 2, extra = 101, tweak = 1.2, under = TRUE,
           fallen.leaves = TRUE, main = "Regression Tree for Price")
dev.off()

## 7b. variable-importance bar plot
vip <- varImp(tree_mod)$importance
vip$Feature <- rownames(vip)

vip_plot <- ggplot(vip,
                   aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Variable Importance (CART – Price)",
       x = "", y = "Importance")

ggsave("var_importance_price.png", vip_plot,
       width = 6, height = 4, dpi = 300)

## 7c. predicted vs actual scatter
scatter <- ggplot(test_df, aes(x = price, y = pred)) +
  geom_point(alpha = 0.6, colour = "#1b9e77") +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(title = "Predicted vs Actual Price (Test Set)",
       x = "Actual Price", y = "Predicted Price") +
  theme_minimal()

ggsave("pred_vs_actual_price.png", scatter,
       width = 5, height = 5, dpi = 300)

cat("\nPlots saved:\n",
    "  • reg_tree_price.png\n",
    "  • var_importance_price.png\n",
    "  • pred_vs_actual_price.png\n", sep = "")
############################################################
