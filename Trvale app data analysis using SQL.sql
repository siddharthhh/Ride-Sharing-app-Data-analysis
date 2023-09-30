Select * from Assembly
Select * from Durations
Select * from Payments
Select * from Trip_details
Select * from Trips


--Total Trips happed

Select Count(Distinct tripid) from Trip_details


--Total Drivers

select Count(distinct driverid) as total_driver from Trips


	
--Total Earning

select sum(fare) from Trips



--Total no of completed trips

select COUNT(distinct tripid) from Trip_details
where end_ride =1


--Total searches

select COUNT(distinct tripid) from Trip_details
where searches =1



--Total searches which got estimates

select sum(searches_got_estimate) search from Trip_details



--Total searches for quotas

select sum(searches_for_quotes) search from Trip_details


--Searchs which got quotes
	
select sum(searches_got_quotes) search from Trip_details


--total driver cancelled
select count(driver_not_cancelled) cancel from Trip_details
where driver_not_cancelled=0


--Total otp entered
select sum(otp_entered) otp_entered from Trip_details


--Total end ride
select sum(end_ride) end_rides from Trip_details



--Average distance per trip
select round(AVG(distance),0) as avg_dist from Trips 


--Average fare per trip

select round(AVG(fare),0) as avg_dist from Trips 


--Distance travlled
Select sum(distance) as total_distance from Trips


--Which is the most used payment meathods

	select a.method as payment_method from Payments a
	inner join 
	(Select top 1 faremethod,count(distinct tripid) as total_trips from Trips 
	group by faremethod
	order by  count(distinct tripid) desc) b
	on a.id=b.faremethod


--Highest payment made through which method

select a.method as payment_method from Payments a
inner join 
(select top 1 faremethod,MAX(fare) as highestfare from Trips
Group by faremethod
order by MAX(fare) desc)b
	on a.id=b.faremethod


--or it can also be meant as the total sum of payments from particular meathod

select a.method as payment_method from Payments a
inner join 
(select top 1 faremethod,SUM(fare) as total_sum from Trips
group by faremethod
order by SUM(fare) desc) b
on a.id=b.faremethod



--Which 2 locations has most number of trips

select * from
(select *,dense_rank()over(order by trip desc) as drnk from
(select loc_from,loc_to,count(Distinct tripid) as trip from Trips
group by loc_from,loc_to) b)c
where drnk =1


--Top 5 earning drivers
select b.driverid ,b.rnk from
(select *,DENSE_RANK()over(order by earnings desc) as rnk from
(select driverid,sum(fare) as earnings from Trips
group by driverid)a)b
where rnk<=5


--which duration has more trips
select top 1 duration_id,COUNT(tripid) trips from Trips
group by duration_id
order by trips desc


--which driver,customer pair has the more order

select * from
(select *,DENSE_RANK()over(order by trips desc) rnk from
(select driverid,custid,COUNT(distinct tripid) as trips from Trips
group by driverid,custid) a)b
where rnk =1


--search to estimate percent
select concat(round(sum(searches_got_estimate)/count(*)*100,2),'%') as  str_percen from Trip_details


--estimate to search for quotes percentage
select concat(round(sum(searches_for_quotes)/sum(searches_got_estimate)*100,2),'%') as etsgq_percent from Trip_details



--quote acceptance percentage
select concat(round(sum(searches_got_quotes)/sum(searches_for_quotes)*100,2),'%') as quote_acceptance_percent from Trip_details


--quote to booking percentage
select concat(round(sum(end_ride)/sum(searches_got_quotes)*100,2),'%') as qtb_percent from Trip_details



--booking cancellation percentage
select round((COUNT(*)-SUM(a.trip_not_cancelled))/sum(searches)*100,2) as booking_cancellation_percent from
(select *,Case 
			when customer_not_cancelled=1 and driver_not_cancelled=1 then 1
			when customer_not_cancelled=1 and driver_not_cancelled=0 then 0
			when customer_not_cancelled=0 and driver_not_cancelled=1 then 0
			else 0
		End as trip_not_cancelled
from Trip_details)a




--conversion percentage
select round(sum(end_ride) /COUNT(Searches)*100,2) conversion_rate from Trip_details


--which area got highest trips and in which duration(using CTE)

With NT as
(select * from
(select *,DENSE_RANK()over( partition by duration_id order by trip desc)as rnk from
(select duration_id,loc_from,COUNT(distinct tripid) as trip from Trips
group by duration_id,loc_from)a)b
where rnk = 1)

select c.Assembly,d.duration_id,d.trip,d.rnk from Assembly c 
inner join NT d
on c.ID=d.loc_from


--which area got the highest fares,cancellation,trips
select * from Trips
select * from Trip_details


select * from
(select *,RANK()over(order by fares desc) as rnk from
(select loc_from,sum(fare) as fares from Trips
group by loc_from) a)b
where rnk=1


select * from
(select *,RANK()over(order by cust_cancelled desc) as rnk from
(select loc_from,count(*)-sum(customer_not_cancelled)as cust_cancelled from Trip_details
group by loc_from)a)b
where rnk=1


select * from
(select *,RANK()over(order by driv_cancelled desc) as rnk from
(select loc_from,count(*)-sum(driver_not_cancelled)as driv_cancelled from Trip_details
group by loc_from)a)b
where rnk=1


select c.Assembly,d.trip,d.rnk from Assembly c
inner join 
(select * from
(select *,DENSE_RANK()over(order by trip desc) as rnk from
(select loc_from,COUNT(distinct tripid)as trip from Trips
group by loc_from)a)b
where rnk=1)d
on c.ID=d.loc_from



--which duration got the highest fares and trips

--Highes fares
select * from(
select *,DENSE_RANK()over(order by fares desc) rnk from
(select duration_id,sum(fare)as fares from Trips
group by duration_id)a)b

--Highest trips
select * from(
select *,DENSE_RANK()over(order by trip desc) rnk from
(select duration_id,count(distinct tripid)as trip from Trips
group by duration_id)a)b
where rnk =1
