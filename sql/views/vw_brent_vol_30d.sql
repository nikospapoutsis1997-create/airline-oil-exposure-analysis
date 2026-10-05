create or alter view vw_brent_vol_30d as
	select
		[date],
		daily_return,
		stdev(daily_return) over(order by [date]
		rows between 29 preceding and current row) as vol_30d
	from vw_brent_daily_returns