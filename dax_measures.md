# DAX Measures Documentation

## Total Revenue
```dax
Total Revenue = SUM(Fact_OrderItems[price])
```
Sum of all product prices sold (excluding freight).

## Total Freight
```dax
Total Freight = SUM(Fact_OrderItems[freight_value])
```
Sum of all shipping costs.

## Total Orders
```dax
Total Orders = DISTINCTCOUNT(Fact_OrderItems[order_id])
```
Count of unique orders (not line items).

## Average Order Value
```dax
Average Order Value = DIVIDE([Total Revenue], [Total Orders])
```
Average revenue per order.

## On-Time Delivery %
```dax
On-Time Delivery % = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT('dwh Dim_Order'[order_id]),
        'dwh Dim_Order'[order_delivered_customer_date] <= 'dwh Dim_Order'[order_estimated_delivery_date]
    ),
    CALCULATE(
        DISTINCTCOUNT('dwh Dim_Order'[order_id]),
        NOT ISBLANK('dwh Dim_Order'[order_delivered_customer_date])
    )
)
```
Percentage of delivered orders that arrived on or before the estimated date.

## Total Payment Value
```dax
Total Payment Value = SUM(Fact_Payments[payment_value])
```
Total amount paid across all payment methods (cross-check against Total Revenue + Total Freight).

## Average Review Score
```dax
Average Review Score = AVERAGE(Fact_Reviews[review_score])
```
Baseline average customer rating (1-5 scale).

## Average Delivery Delay (Days)
```dax
Average Delivery Delay (Days) = 
AVERAGEX(
    FILTER(
        Dim_Order,
        NOT ISBLANK(Dim_Order[order_delivered_customer_date])
    ),
    DATEDIFF(
        Dim_Order[order_estimated_delivery_date],
        Dim_Order[order_delivered_customer_date],
        DAY
    )
)
```
Average difference (in days) between estimated and actual delivery date. Negative = delivered early.

## Customer Order Count
```dax
Customer Order Count = DISTINCTCOUNT(Dim_Order[order_id])
```
Number of orders per customer (used for RFM Frequency).

## Revenue per Customer
```dax
Revenue per Customer = [Total Revenue]
```
Contextual alias of Total Revenue when sliced by customer.

## Max Order Date
```dax
Max Order Date = MAX(Dim_Order[order_purchase_timestamp])
```
Reference point (latest date in the dataset) used to calculate Recency.

## Customer Last Purchase Date
```dax
Customer Last Purchase Date = 
CALCULATE(
    MAX(Dim_Order[order_purchase_timestamp]),
    ALLEXCEPT(Dim_Order, Dim_Customer[customer_id])
)
```
Last purchase date per customer, ignoring any other filters applied on the report page.

## Recency (Days)
```dax
Recency (Days) = DATEDIFF([Customer Last Purchase Date], [Max Order Date], DAY)
```
Days since the customer's last purchase, relative to the latest date in the dataset.

## RFM Segment
```dax
RFM Segment = 
VAR R_Score = IF([Recency (Days)] <= 90, 3, IF([Recency (Days)] <= 180, 2, 1))
VAR F_Score = IF([Customer Order Count] >= 3, 3, IF([Customer Order Count] >= 2, 2, 1))
VAR M_Score = IF([Total Revenue] >= 500, 3, IF([Total Revenue] >= 150, 2, 1))
VAR TotalScore = R_Score + F_Score + M_Score
RETURN
    SWITCH(
        TRUE(),
        TotalScore >= 8, "Champion",
        TotalScore >= 6, "Loyal Customers",
        TotalScore >= 4, "At Risk",
        "Lost"
    )
```
Classifies each customer into a segment based on Recency, Frequency (Customer Order Count), and Monetary (Total Revenue) scores — a simplified RFM model.