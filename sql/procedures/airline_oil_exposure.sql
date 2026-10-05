create or alter procedure airline_oil_exposure
	@start_date date,
	@end_date date
as
begin
	with filtered_airline_returns as (
		select
			[date],
			[name],
			daily_return
		from vw_airline_daily_returns
		where [date] between @start_date and @end_date
		),
		filtered_brent_returns as (
			select
				[date],
				daily_return
			from vw_brent_daily_returns
			where [date] between @start_date and @end_date
		),
		airline_mean_returns as (
			select
				[name],
				avg(daily_return) as mean_air_return
			from filtered_airline_returns
			group by [name]
		),
		brent_mean_returns as (
			select
				avg(daily_return) as mean_brent_return
			from filtered_brent_returns
		),
		airline_mean_deviation as (
			select
				far.[name],
				far.[date],
				(far.daily_return - amr.mean_air_return) as mean_air_dev
			from filtered_airline_returns as far
			left join airline_mean_returns as amr on amr.[name] = far.[name]
		),
		brent_mean_deviation as (
			select
				fbr.[date],
				(fbr.daily_return - bmr.mean_brent_return) as mean_brent_dev
				from filtered_brent_returns as fbr
				left join brent_mean_returns as bmr on 1 = 1
		),
		beta_correlation_model as (
			select
				far.[name],
				sum(amd.mean_air_dev * bmd.mean_brent_dev) / sum(square(bmd.mean_brent_dev)) as beta,
				sum(amd.mean_air_dev * bmd.mean_brent_dev) / sqrt(sum(square(amd.mean_air_dev)) * sum(square(bmd.mean_brent_dev))) as correlation,
				case
					when far.[name] in ('ryanair', 'wizzair', 'easyjet') then 'low-cost'
					else 'full-service'
				end
				as business_model
			from filtered_airline_returns as far
			left join airline_mean_deviation as amd on amd.[name] = far.[name] and amd.[date] = far.[date]
			left join brent_mean_deviation as bmd on bmd.[date] = far.[date]
			group by far.[name]
			)
			select
				[name],
				business_model,
				beta,
				correlation,
				square(correlation) as r_squared
			from beta_correlation_model
end;