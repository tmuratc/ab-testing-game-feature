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
car_level_ups as (
  select e.event_timestamp, e.user_id, 1 as car_level_up 
        from `spektra-games-case-study.case_study_dataset.events` e
  where event_name = "car_level_up"
), 
final_results as (
  select g.user_id, 
        max(g.abtest_group) as abtest_group, 
        sum(ifnull(c.car_level_up, 0)) as car_level_up
  from group_info g
  left join car_level_ups c on g.user_id = c.user_id
  where g.user_id in (select * from one_or_more_race_users)
  group by 1
)
select * from final_results order by car_level_up 