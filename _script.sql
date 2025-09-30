SELECT
  COUNT(DISTINCT `bright_tv_viewership`.`UserID`) AS Number_of_Subscribers,
  `bright_tv_viewership`.`Channel2`,
  CAST(
    TO_TIMESTAMP(`bright_tv_viewership`.`RecordDate2`, 'yyyy/MM/dd HH:mm') AS DATE
  ) AS Watch_date,
  DAYNAME(TO_TIMESTAMP(`bright_tv_viewership`.`RecordDate2`, 'yyyy/MM/dd HH:mm')) AS Day_name,
  date_format(TO_TIMESTAMP(`bright_tv_viewership`.`RecordDate2`, 'yyyy/MM/dd HH:mm'), 'MMMM') AS Month_name,
  `bright_tv_user_profiles`.`Gender`,
  `bright_tv_user_profiles`.`Race`,
  `bright_tv_user_profiles`.`Province`,
  CASE
    WHEN HOUR(DATEADD(HOUR, 2, `bright_tv_viewership`.`Duration2`)) BETWEEN 5 AND 11 THEN 'Morning 5-11am'
    WHEN HOUR(DATEADD(HOUR, 2, `bright_tv_viewership`.`Duration2`)) BETWEEN 12 AND 16 THEN 'Afternoon 12-4pm'
    WHEN HOUR(DATEADD(HOUR, 2, `bright_tv_viewership`.`Duration2`)) BETWEEN 17 AND 20 THEN 'Evening 5-8pm'
    ELSE 'Night'
  END AS Time_Bucket,
  CASE
    WHEN `bright_tv_user_profiles`.`Age` = 0 THEN 'Infant'
    WHEN `bright_tv_user_profiles`.`Age` BETWEEN 1 AND 12 THEN 'Child 1-12'
    WHEN `bright_tv_user_profiles`.`Age` BETWEEN 13 AND 18 THEN 'Youth 13-18'
    WHEN `bright_tv_user_profiles`.`Age` BETWEEN 19 AND 30 THEN 'Young Adult 19-30'
    WHEN `bright_tv_user_profiles`.`Age` BETWEEN 31 AND 64 THEN 'Adult 31-64'
    ELSE 'ELDER +65'
  END AS Age_buckets,
  -- Total viewing duration in hours and minutes
  LPAD(
    FLOOR(
      SUM(
        HOUR(TO_TIMESTAMP(`bright_tv_viewership`.`Duration2`, 'HH:mm:ss')) * 3600 +
        MINUTE(TO_TIMESTAMP(`bright_tv_viewership`.`Duration2`, 'HH:mm:ss')) * 60 +
        SECOND(TO_TIMESTAMP(`bright_tv_viewership`.`Duration2`, 'HH:mm:ss'))
      ) / 3600
    ),
    2, '0'
  ) || ':' ||
  LPAD(
    FLOOR(
      MOD(
        SUM(
          HOUR(TO_TIMESTAMP(`bright_tv_viewership`.`Duration2`, 'HH:mm:ss')) * 3600 +
          MINUTE(TO_TIMESTAMP(`bright_tv_viewership`.`Duration2`, 'HH:mm:ss')) * 60 +
          SECOND(TO_TIMESTAMP(`bright_tv_viewership`.`Duration2`, 'HH:mm:ss'))
        ),
        3600
      ) / 60
    ),
    2, '0'
  ) AS total_duration_hhmm
FROM
  `workspace`.`default`.`bright_tv_viewership`
    JOIN `workspace`.`default`.`bright_tv_user_profiles`
      ON `bright_tv_viewership`.`UserID` = `bright_tv_user_profiles`.`UserID`
WHERE
  `bright_tv_user_profiles`.`Age` IS NOT NULL
GROUP BY
  `bright_tv_viewership`.`Channel2`,
  CAST(TO_TIMESTAMP(`bright_tv_viewership`.`RecordDate2`, 'yyyy/MM/dd HH:mm') AS DATE),
  DAYNAME(TO_TIMESTAMP(`bright_tv_viewership`.`RecordDate2`, 'yyyy/MM/dd HH:mm')),
  date_format(TO_TIMESTAMP(`bright_tv_viewership`.`RecordDate2`, 'yyyy/MM/dd HH:mm'), 'MMMM'),
  `bright_tv_user_profiles`.`Gender`,
  `bright_tv_user_profiles`.`Race`,
  `bright_tv_user_profiles`.`Province`,
  CASE
    WHEN HOUR(DATEADD(HOUR, 2, `bright_tv_viewership`.`Duration2`)) BETWEEN 5 AND 11 THEN 'Morning 5-11am'
    WHEN HOUR(DATEADD(HOUR, 2, `bright_tv_viewership`.`Duration2`)) BETWEEN 12 AND 16 THEN 'Afternoon 12-4pm'
    WHEN HOUR(DATEADD(HOUR, 2, `bright_tv_viewership`.`Duration2`)) BETWEEN 17 AND 20 THEN 'Evening 5-8pm'
    ELSE 'Night'
  END,
  CASE
    WHEN `bright_tv_user_profiles`.`Age` = 0 THEN 'Infant'
    WHEN `bright_tv_user_profiles`.`Age` BETWEEN 1 AND 12 THEN 'Child 1-12'
    WHEN `bright_tv_user_profiles`.`Age` BETWEEN 13 AND 18 THEN 'Youth 13-18'
    WHEN `bright_tv_user_profiles`.`Age` BETWEEN 19 AND 30 THEN 'Young Adult 19-30'
    WHEN `bright_tv_user_profiles`.`Age` BETWEEN 31 AND 64 THEN 'Adult 31-64'
    ELSE 'ELDER +65'
  END
