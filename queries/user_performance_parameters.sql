with g0_complete_events as (
      select date(timestamp_micros(e.event_timestamp)) as event_day, e.user_id, e.event_name, 
            p.value.int_value as round_num,  
            p1.value.int_value as round_result, 
            p2.value.int_value as nth_race, 
            p3.value.int_value as race_result
      from `spektra-games-case-study.case_study_dataset.events` e, 
      unnest(event_params) p, 
      unnest(event_params) p1, 
      unnest(event_params) p2, 
      unnest(event_params) p3 
      where event_name = "race_complete" and 
            p.key = "round" and 
            p1.key = "round_result" and 
            p2.key = "nth_race" and 
            p3.key = "race_result" and 
            p.value.int_value = 0
),
g0_total_performances as (
      select user_id, 
       count(round_num) as total_round_played, 
       (max(nth_race) - min(nth_race)) + 1 as total_game_played, 
       sum(race_result) as total_game_win,  
      count(distinct event_day) as active_days, 
      case when min(nth_race) = 0 then 1 else 0 end as new_user
      from g0_complete_events
      group by 1 
), 
g0_final_results as (
      select *, "g0" as test_group 
      from g0_total_performances 
), 
g1_complete_events as (
      select date(timestamp_micros(e.event_timestamp)) as event_day, e.user_id, e.event_name, 
            p.value.int_value as round_num,  
            p1.value.int_value as round_result, 
            p2.value.int_value as nth_race, 
            p3.value.int_value as race_result
      from `spektra-games-case-study.case_study_dataset.events` e, 
      unnest(event_params) p, 
      unnest(event_params) p1, 
      unnest(event_params) p2, 
      unnest(event_params) p3 
      where event_name = "race_complete" and 
            p.key = "round" and 
            p1.key = "round_result" and 
            p2.key = "nth_race" and 
            p3.key = "race_result" and 
            p.value.int_value != 0
),
g1_total_performances as (
      select user_id, 
       sum(round_num) as total_round_played, 
       (max(nth_race) - min(nth_race)) + 1 as total_game_played, 
       sum(race_result) as total_game_win, 
       count(distinct event_day) as active_days,
       case when min(nth_race) = 0 then 1 else 0 end as new_user
      from g1_complete_events
      group by 1 
),  
g1_final_results as (
      select *, "g1" as test_group, 
      from g1_total_performances 
), 
union_results as (
      select g0.*
      from g0_final_results g0
      union distinct 
      select g1.*
      from g1_final_results  g1
), 
ranked_results as ( 
      select *,
      total_game_win/total_game_played as win_rate,
      sum(total_game_win) over (partition by test_group) / sum(total_game_played) over (partition by test_group) as group_win_rate,  
      dense_rank() over (order by total_game_played) as rank_total_game, 
      dense_rank() over (order by total_round_played) as rank_total_round, 
      from union_results ) 
--select * from ranked_results limit 100

select test_group, 
      count(distinct user_id) as sample_size, 
      avg(total_game_played) as avg_total_game,  
      approx_quantiles(total_game_played, 100)[offset(50)] as mdn_total_game,
      stddev(total_game_played) as std_total_game, 
      sum(rank_total_game) as sum_ranks_total_game,  
      avg(total_round_played) as avg_total_round,  
      approx_quantiles(total_round_played, 100)[offset(50)] as mdn_total_round,
      stddev(total_round_played) as std_total_round,
      sum(rank_total_round) as sum_ranks_total_round,
      sum(total_game_win)/sum(total_game_played) as avg_weighted_win_rate,
      sqrt(sum(power(win_rate - group_win_rate, 2)*total_game_played)/sum(total_game_played)) as std_weighted_win_rate,
      sum(new_user) as new_users, 
      sum(case when active_days>=2 then 1 else 0 end) as active_2days_users,
      sum(case when active_days>=3 then 1 else 0 end) as active_3days_users, 
      sum(case when active_days>=4 then 1 else 0 end) as active_4days_users,
      sum(case when active_days>=5 then 1 else 0 end) as active_5days_users
from ranked_results
group by test_group
