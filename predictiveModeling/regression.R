############################################################
##  Automobile Imports-85 – Linear / Ridge / Lasso        ##
############################################################

# ---- 1. libraries ----------------------------------------
suppressPackageStartupMessages({
  library(dplyr)
  library(caret)
  library(glmnet)
  library(ggplot2)
})

# ---- 2. load raw -----------------------------------------
cols <- c("symboling","normalized_losses","make","fuel_type","aspiration",
          "num_of_doors","body_style","drive_wheels","engine_location","wheel_base",
          "length","width","height","curb_weight","engine_type","num_of_cylinders",
          "engine_size","fuel_system","bore","stroke","compression_ratio",
          "horsepower","peak_rpm","city_mpg","highway_mpg","price")

raw <- read.csv("automobile/imports-85.data",
                header = FALSE, na.strings = "?", col.names = cols,
                stringsAsFactors = FALSE)

num_vars <- c("normalized_losses","engine_size","horsepower",
              "wheel_base","length","width","height",
              "curb_weight","city_mpg","highway_mpg","price")
raw[num_vars] <- lapply(raw[num_vars], as.numeric)

raw <- raw %>% filter(!is.na(price))   # must keep target

# ---- 3. IMPUTE missing numeric values -------------------
raw[num_vars] <- lapply(raw[num_vars], function(v){
  v[is.na(v)] <- median(v, na.rm = TRUE)
  v
})

# ---- 4. one-hot encode factors ---------------------------
dum <- dummyVars(price ~ ., data = raw, fullRank = TRUE)
X   <- as.data.frame(predict(dum, newdata = raw))

## if a dummy column still has NA (rare), turn to 0
X[is.na(X)] <- 0

dat <- bind_cols(X, price = raw$price)

# ---- 5. split -------------------------------------------
set.seed(123)
idx      <- createDataPartition(dat$price, p = 0.7, list = FALSE)
train_df <- dat[idx, ]
test_df  <- dat[-idx, ]

# ---- 6. multiple-linear model ----------------------------
lm_fit   <- lm(price ~ ., data = train_df)
pred_lm  <- predict(lm_fit, test_df)

rmse_lm  <- RMSE(pred_lm, test_df$price)
mae_lm   <- MAE (pred_lm, test_df$price)
r2_lm    <- R2  (pred_lm, test_df$price)

cat("\nLinear model (test set):\n",
    sprintf("  RMSE = %.2f\n  MAE  = %.2f\n  R²   = %.3f\n",
            rmse_lm, mae_lm, r2_lm))

# ---- 7. diagnostics (unchanged) --------------------------
png("qq_plot.png", 600, 600)
qqnorm(residuals(lm_fit)); qqline(residuals(lm_fit)); title("QQ-Plot")
dev.off()

png("residuals_vs_fitted.png", 700, 500)
plot(fitted(lm_fit), residuals(lm_fit),
     xlab = "Fitted", ylab = "Residuals",
     main = "Residuals vs Fitted"); abline(h = 0, col = "red", lty = 2)
dev.off()

png("scale_location.png", 700, 500)
plot(fitted(lm_fit), sqrt(abs(residuals(lm_fit))),
     ylab = "√|Residuals|", xlab = "Fitted",
     main = "Scale-Location Plot")
dev.off()

# ---- 8. Ridge & Lasso  (glmnet) --------------------------
x  <- as.matrix(train_df[ , setdiff(names(train_df), "price")])
y  <- train_df$price
xt <- as.matrix(test_df [ , setdiff(names(test_df ), "price")])

set.seed(123)
cv_ridge <- cv.glmnet(x, y, alpha = 0, nfolds = 10)
ridge_pred <- predict(cv_ridge, xt, s = "lambda.min")
cat("\nRidge (λ.min)  test-RMSE =", RMSE(ridge_pred, test_df$price),
    " R² =", R2(ridge_pred, test_df$price), "\n")

set.seed(123)
cv_lasso <- cv.glmnet(x, y, alpha = 1, nfolds = 10)
lasso_pred <- predict(cv_lasso, xt, s = "lambda.min")
cat("Lasso (λ.min)  test-RMSE =", RMSE(lasso_pred, test_df$price),
    " R² =", R2(lasso_pred, test_df$price), "\n")

cat("\nDiagnostic plots saved:\n  • qq_plot.png\n  • residuals_vs_fitted.png\n  • scale_location.png\n")
############################################################
