# Load Libraries

library(tidyverse)

# Load CSV Data
users <- read_csv("C:/Users/HP/OneDrive/Desktop/Juspay_projects/Funnel_Anomaly/Data/users.csv")
sessions <- read_csv("C:/Users/HP/OneDrive/Desktop/Juspay_projects/Funnel_Anomaly/Data/sessions.csv")
transactions <- read_csv("C:/Users/HP/OneDrive/Desktop/Juspay_projects/Funnel_Anomaly/Data/transactions.csv")

# Merge Data for Analysis
full_data <- transactions %>%
  left_join(sessions, by = "session_id") %>%
  left_join(users, by = "user_id")

# 1. Funnel Plot: Visitors → Transactions → Success
visitors <- n_distinct(sessions$user_id)
transactions_count <- n_distinct(transactions$session_id)
successful_txns <- n_distinct(filter(transactions, status == "success")$session_id)

funnel_data <- data.frame(
  Stage = c("Visitors", "Transactions", "Success"),
  Count = c(visitors, transactions_count, successful_txns)
)

funnel_plot <- ggplot(funnel_data, aes(x = Stage, y = Count, fill = Stage)) +
  geom_bar(stat = "identity", width = 0.6) +
  ggtitle("Funnel: Visitors → Transactions → Success") +
  theme_minimal()

ggsave("C:/Users/HP/OneDrive/Desktop/Juspay_projects/Funnel_Anomaly/output/funnel_plot.jpg", plot = funnel_plot, width = 6, height = 4)


# 2. Failure Rate by Location (Bar Heatmap)
failure_by_location <- full_data %>%
  group_by(location) %>%
  summarise(failure_rate = sum(status == "failed") / n())

failure_plot <- ggplot(failure_by_location, aes(x = location, y = failure_rate, fill = failure_rate)) +
  geom_col() +
  ggtitle("Failure Rate by City") +
  ylab("Failure Rate") +
  theme_minimal()

ggsave("C:/Users/HP/OneDrive/Desktop/Juspay_projects/Funnel_Anomaly/output/failure_heatmap.jpg", plot = failure_plot, width = 6, height = 4)


# 3. Success Amount by Location
success_amount <- full_data %>%
  filter(status == "success") %>%
  group_by(location) %>%
  summarise(total_amount = sum(amount))

success_plot <- ggplot(success_amount, aes(x = location, y = total_amount, fill = location)) +
  geom_col() +
  ggtitle("Total Success Amount by Location") +
  ylab("Success ₹ Amount") +
  theme_minimal()

ggsave("C:/Users/HP/OneDrive/Desktop/Juspay_projects/Funnel_Anomaly/output/success_by_location.jpg", plot = success_plot, width = 6, height = 4)


# 4. (Optional) Success Trend Over Time
transactions$timestamp <- as.Date(transactions$timestamp)

trend_plot <- ggplot(filter(transactions, status == "success"), aes(x = timestamp)) +
  geom_histogram(binwidth = 1, fill = "steelblue") +
  ggtitle("Successful Transactions Over Time") +
  theme_minimal()

ggsave("C:/Users/HP/OneDrive/Desktop/Juspay_projects/Funnel_Anomaly/output/success_trend.jpg", plot = trend_plot, width = 6, height = 4)
