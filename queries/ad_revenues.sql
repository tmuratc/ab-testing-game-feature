with group_info as ( 
  select distinct e.user_id, p.value.string_value as abtest_group  
  from `spektra-games-case-study.case_study_dataset.events` e, unnest(event_params) p 
  where e.event_name = "abtest_start" and p.key = "abtest_group" 
),
one_or_more_race_users as ( 
  select distinct user_id
  from `spektra-games-case-study.case_study_dataset.events`
  where event_name = "race_complete"
), 
ad_impressions as (
  select e.event_timestamp, e.user_id,
        p.value.string_value as ad_format, 
        p2.value.double_value as revenue, 
        from `spektra-games-case-study.case_study_dataset.events` e, 
  unnest(event_params) p, 
  unnest(event_params) p2,
  unnest(event_params) p3
  where event_name = "ad_impression" and 
        p.key = "ad_format" and 
        p2.key = "value" and 
        p3.key = "currency" 
), 
final_results as (
  select g.user_id, 
        concat("g", max(g.abtest_group)) as abtest_group, 
        sum(ifnull(i.revenue,0)) as revenue
  from group_info g
  left join ad_impressions i on g.user_id = i.user_id
  where g.user_id in (select * from one_or_more_race_users)
  group by 1     
)
select * from final_results