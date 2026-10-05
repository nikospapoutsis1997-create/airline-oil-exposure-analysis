create or alter view vw_brent_daily_returns as
	with prev_close_price as (
		select
			[date],
			[close],
			lag([close], 1) over(order by [date]) as prev_close
		from dim_brent
		)
		select
			[date],
			[close],
			prev_close,
			(([close] - prev_close) / prev_close) as daily_return
		from prev_close_price