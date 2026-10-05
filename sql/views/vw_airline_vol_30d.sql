create or alter view vw_airline_vol_30d as
	select
		[date],
		[name],
		daily_return,
		stdev(daily_return) over(partition by [name] order by [date]
		rows between 29 preceding and current row) as vol_30d
	from vw_airline_daily_returns