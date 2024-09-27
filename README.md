# AB TEST: 3 ROUNDS VS 1 ROUND
This project aims to decide which version is better for 1v1, PvP drag race game. Core gameplay loop is race, upgrade the car and race again. Game doesn't include in-app purchases. 
AB test covers 8 days period over 2 groups around 3800 people in total. 

## Dataset 
The dataset consists of user interaction events collected from Firebase Analytics, which logs various events in following schema. 
```yaml
events:
  - event_name: STRING
  - event_timestamp: TIMESTAMP
  - event_params: RECORD
      - key: STRING
      - value: RECORD
          - string_value: STRING (optional)
          - int_value: INTEGER (optional)
          - float_value: FLOAT (optional)
          - double_value: DOUBLE (optional)
          - timestamp_value: TIMESTAMP (optional)
  - user_properties: RECORD (optional)
      - key: STRING
      - value: RECORD
          - string_value: STRING (optional)
          - int_value: INTEGER (optional)
  - user_id: STRING
  - platform: STRING
  - app_version: STRING
  - device: STRING
```

## Metrics
To measure the effectiveness of each game feature, the following key metrics were used:

- Competitiveness: Measured by the winning rate of the users which is ratio of games won to total games played.
- Engagement: Measured by total games played by each user.
- Retention: Defined by the number of active days over a 8-day period.
- Revenue: Generated from in-game ad impressions.

## Methodology
- Data Cleaning: The dataset was preprocessed to remove outliers and ensure data consistency.
- Descriptive Statistics: Summary statistics for both groups, including mean, median, and standard deviation of key metrics.
- Hypothesis Testing:
  - Mann-Whitney U Test: Used to compare winning rates, as the distributions were skewed.
  - Chi-Square Test: Applied to retention data to compare user activity across groups.
  - T-Test: Used for comparing engagement (total games played) between the groups.

## Results
- Winning Rate: Group0 had a higher winning rate (83%) compared to Group1 (77%) with a statistically significant difference (p-value < 0.01).
- Engagement: Group1 also showed higher engagement with an average of 33 games played, compared to 24.6 in Group0 (p-value < 0.01).
- Retention: Retention rates were slightly better in Group0, but no difference in most active users,(4-5 or more days active users).
- Revenue: Ad revenue is signigicantly higher in Group1 when we only include the users watch at least 1 ad.
- Conclusion: Group1 demonstrates better performance across competetitiveness (lower winning rates with higher std), engagement, and revenue. The feature tested in Group1 is recommended for future development.
