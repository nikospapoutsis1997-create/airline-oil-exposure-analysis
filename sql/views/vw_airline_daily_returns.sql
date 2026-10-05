create or alter view vw_airline_daily_returns as
	with prev_close_price as (
		select
			[date],
			[name],
			[close],
			lag([close], 1) over(partition by [name] order by [date]) as prev_close
		from fact_airline_prices
		)
		select
			[date],
			[name],
			[close],
			prev_close,
			(([close] - prev_close) / prev_close) as daily_return
		from prev_close_price