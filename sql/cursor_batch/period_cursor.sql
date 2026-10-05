declare @period_name varchar(50), @start_date date, @end_date date;

declare period_cursor cursor for
	select period_name, start_date, end_date
	from shock_periods;

open period_cursor;
fetch next from period_cursor into @period_name, @start_date, @end_date;

while @@FETCH_STATUS = 0
begin
	drop table if exists #temp_air_exposure;
	create table #temp_air_exposure (
		[name] varchar(50),
		business_model varchar(20),
		beta float,
		correlation float,
		r_squared float
	);

	insert into #temp_air_exposure
	exec airline_oil_exposure @start_date = @start_date, @end_date = @end_date;

	insert into period_summary_airlines (
		period_name,
		[start_date],
		[end_date],
		[name],
		business_model,
		avg_vol_30d,
		beta,
		correlation,
		r_squared
	)
	select
		@period_name,
		@start_date,
		@end_date,
		tae.[name],
		tae.business_model,
		avg(av30.vol_30d),
		tae.beta,
		tae.correlation,
		tae.r_squared
	from #temp_air_exposure as tae
	left join vw_airline_vol_30d as av30 on av30.[name] = tae.[name] and (av30.[date] between @start_date and @end_date)
	group by tae.[name], tae.business_model, tae.beta, tae.correlation, tae.r_squared

	fetch next from period_cursor into @period_name, @start_date, @end_date;
end;

close period_cursor;
deallocate period_cursor;
