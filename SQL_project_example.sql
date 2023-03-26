#
select utm_source,
		utm_campaign,
		http_referer,
        count(website_session_id) AS session
from website_sessions
where created_at < '2012-04-12'
group by 1,2,3;

#
select 
	count(distinct website_sessions.website_session_id) AS sessions,
    count(distinct orders.order_id) AS orders,
    count(distinct orders.order_id) /count(distinct website_sessions.website_session_id) AS Covert_rate
from website_sessions 
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-04-14'
	And utm_source = 'gsearch'
    And utm_campaign = 'nonbrand';
    
#
select
	YEAR(created_at) AS YR,
    WEEK(created_at) AS WK,
    MIN(Date(created_at)) AS week_started_at,
    count(website_sessions.website_session_id) AS session
from website_sessions
where website_sessions.created_at < '2012-05-11'
	And utm_source = 'gsearch'
    And utm_campaign = 'nonbrand'
group by 1,2;

#
select
	 website_sessions.device_type,
    count(distinct website_sessions.website_session_id) AS sessions,
    count(distinct orders.order_id) AS orders,
	count(distinct orders.order_id) / count(distinct website_sessions.website_session_id) AS session_to_order_conv_rate
from website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-05-11'
	And utm_source = 'gsearch'
    And utm_campaign = 'nonbrand'
group by 1;

#
select
	MIN(DATE(website_sessions.created_at)) AS weeek_start_date,
    COUNT(CASE WHEN website_sessions.device_type = 'desktop' THEN device_type ELSE NULL END) AS dtop_sessions,
	COUNT(CASE WHEN website_sessions.device_type = 'mobile' THEN device_type ELSE NULL END) AS mob_sessions
from website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at BETWEEN '2012-04-15' and '2012-06-10'
	And utm_source = 'gsearch'
    And utm_campaign = 'nonbrand'
group by YEAR(website_sessions.created_at),
		WEEK(website_sessions.created_at);

#
select
	pageview_url,
    COUNT(Distinct website_pageview_id) AS sessions
from website_pageviews
where created_at < '2012-06-09'
group by 1
order by 2 desc;

# finding top website page
# Step1: find the first pageview for each session
# Stpep2: find the url the customer saw on that first pageview
create temporary table first_pageview2
select 
	website_session_id,
    MIN(website_pageview_id) AS min_pageview_session
from website_pageviews
where created_at < '2012-06-12'
group by 1;

select*
from first_pageview2;

select
	website_pageviews.pageview_url AS Landing_page,
    COUNT(Distinct first_pageview2.website_session_id) AS sessions_hitting_this_landing_page
from first_pageview2 
	Left join website_pageviews
    on first_pageview2.min_pageview_session = website_pageviews.website_pageview_id
group by 1
order by 2 desc;


create temporary table first_pageviews_demo2
select 
	website_pageviews.website_session_id,
	MIN(website_pageviews.website_pageview_id) AS  min_pageview_id
from website_pageviews 
where created_at < '2012-06-14' 
Group by 1;

select*from first_pageviews_demo2;

Create temporary table session_w_landingpage
select
	first_pageviews_demo2.website_session_id,
	website_pageviews.pageview_url AS landing_page
from first_pageviews_demo2
	Left join website_pageviews
    on website_pageviews.website_session_id = first_pageviews_demo2.min_pageview_id
where website_pageviews.pageview_url = '/home';
       
select*from session_w_landingpage;

create temporary table bounce_w_session
select 
	session_w_landingpage.website_session_id,
    session_w_landingpage.landing_page AS landing_page,
    COUNT(website_pageviews.website_session_id) AS count_of_pages_viewed
    
from session_w_landingpage
	Left join website_pageviews
	on session_w_landingpage.website_session_id = website_pageviews.website_session_id

Group by 1,2

Having COUNT(website_pageviews.website_session_id) =1 ;

select*from bounce_w_session;

select 
	COUNT(Distinct session_w_landingpage.website_session_id) AS sessions,
    COUNT(Distinct bounce_w_session.website_session_id) AS bounced_sessions,
    COUNT(Distinct bounce_w_session.website_session_id) /COUNT(Distinct session_w_landingpage.website_session_id) AS bounce_rate
from session_w_landingpage
	Left join bounce_w_session
    on session_w_landingpage.website_session_id = bounce_w_session.website_session_id;
    
#

select 
min(created_at) AS first_created_at,
min(website_pageview_id) AS first_pageview_id
    from website_pageviews
    where pageview_url = '/lander-1';
    
create temporary table first_test_pageviews
select 
	website_pageviews.website_session_id,
	MIN(website_pageviews.website_pageview_id) AS  min_pageview_id
from website_pageviews 
	inner join website_sessions
    on website_sessions.website_session_id = website_pageviews.website_session_id 
	AND website_sessions.created_at < '2012-07-29' 
	AND website_pageviews.website_pageview_id>23504
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
Group by 1;

select*from first_test_pageviews;

Create temporary table nonbrand_session_w_landingpage
select
	first_test_pageviews.website_session_id,
	website_pageviews.pageview_url AS landing_page
from first_test_pageviews
	Left join website_pageviews
    on first_test_pageviews.min_pageview_id = website_pageviews.website_session_id
where website_pageviews.pageview_url IN ('/lander-1','/home') ;
       
select*from nonbrand_session_w_landingpage;

create temporary table nonbrand_test_bounced_session
select 
	nonbrand_session_w_landingpage.website_session_id,
    nonbrand_session_w_landingpage.landing_page AS landing_page,
    COUNT(website_pageviews.website_session_id) AS count_of_pages_viewed
    
from nonbrand_session_w_landingpage
	Left join website_pageviews
	on nonbrand_session_w_landingpage.website_session_id = website_pageviews.website_session_id

Group by 1,2

Having COUNT(website_pageviews.website_session_id) =1;

select*from nonbrand_test_bounced_session;

select 
	nonbrand_session_w_landingpage.landing_page,
    COUNT(Distinct nonbrand_session_w_landingpage.website_session_id) AS sessions,
    COUNT(Distinct nonbrand_test_bounced_session.website_session_id) AS bounced_sessions,
    COUNT(Distinct nonbrand_test_bounced_session.website_session_id) /COUNT(Distinct nonbrand_session_w_landingpage.website_session_id) AS bounce_rate
from nonbrand_session_w_landingpage
	Left join nonbrand_test_bounced_session
    on nonbrand_session_w_landingpage.website_session_id = nonbrand_test_bounced_session.website_session_id
Group by 1;

drop temporary table sessions_w_min_pv_id_and_view_count;
drop temporary table sessions_w_counts_lander_and_created_at;

#
create temporary table sessions_w_min_pv_id_and_view_count
select 
	website_sessions.website_session_id,
    min(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
    
from website_sessions
	LEft join website_pageviews
    on website_sessions.website_session_id = website_pageviews.website_session_id

where website_sessions.created_at > '2012-06-01'
      AND website_sessions.created_at < '2012-08-31'
      AND website_sessions.utm_source = 'gsearch'
      AND website_sessions.utm_campaign = 'nonbrand'
      
Group by website_sessions.website_session_id;
      

Create temporary table sessions_w_counts_lander_and_created_at
select 
	sessions_w_min_pv_id_and_view_count.website_session_id,
    sessions_w_min_pv_id_and_view_count.first_pageview_id,
    sessions_w_min_pv_id_and_view_count.count_pageviews,
	website_pageviews.pageview_url AS Landing_page,
	website_pageviews.created_at AS session_created_at
    
from sessions_w_min_pv_id_and_view_count
	 Left join website_pageviews
     on sessions_w_min_pv_id_and_view_count.first_pageview_id = website_pageviews.website_session_id;

select
	yearweek(session_created_at) AS yearweek,
    min(date(session_created_at)) AS week_start_date,
    count(Distinct website_session_id) AS total_session,
    COUNT(CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_session,
	COUNT(CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END)*1.0/count(Distinct website_session_id) AS bounced_rate,
	COUNT(CASE WHEN Landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_session,
	COUNT(CASE WHEN Landing_page = 'lander-1' THEN website_session_id ELSE NULL END) AS lander_session
    
from sessions_w_counts_lander_and_created_at
group by 
	yearweek(session_created_at);
    
#building conversion funnel
select 
	 website_sessions.website_session_id,
     website_pageviews.created_At AS pageview_created_at,
     CASE WHEN pageview_url= '/products' THEN 1 ELSE 0 END AS products_page,
     CASE WHEN pageview_url= '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
     CASE WHEN pageview_url= '/cart' THEN 1 ELSE 0 END AS cart_page, 
     CASE WHEN pageview_url= '/shipping' THEN 1 ELSE 0 END AS shipping_page, 
     CASE WHEN pageview_url= '/billing' THEN 1 ELSE 0 END AS billing_page, 
     CASE WHEN pageview_url= '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page 
from website_sessions
	Left join website_pageviews
    on website_sessions.website_session_id = website_pageviews.website_session_id
Where   website_sessions.created_at > '2012-08-05'
	AND website_sessions.created_at < '2012-09-05'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
	#AND website_pageviews.pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
order by 1,2;

drop temporary table session_level_made_it_flags_demo1;

create temporary table session_level_made_it_flags_demo1
select
	 website_session_id,
     MAX(products_page) AS product_made_it,
	 MAX(mrfuzzy_page) AS mrfuzzy_made_it,
	 MAX(cart_page) AS cart_made_it,
     MAX(shipping_page) AS shipping_made_it,
     MAX(billing_page) AS billing_made_it,
     MAX(thankyou_page) AS thankyou_made_it
from(

select 
	 website_sessions.website_session_id,
     website_pageviews.created_At AS pageview_created_at,
     CASE WHEN pageview_url= '/products' THEN 1 ELSE 0 END AS products_page,
     CASE WHEN pageview_url= '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
     CASE WHEN pageview_url= '/cart' THEN 1 ELSE 0 END AS cart_page, 
     CASE WHEN pageview_url= '/shipping' THEN 1 ELSE 0 END AS shipping_page, 
     CASE WHEN pageview_url= '/billing' THEN 1 ELSE 0 END AS billing_page, 
     CASE WHEN pageview_url= '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page 
from website_sessions
	Left join website_pageviews
    on website_sessions.website_session_id = website_pageviews.website_session_id
Where   website_sessions.created_at > '2012-08-05'
	AND website_sessions.created_at < '2012-09-05'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
	#AND website_pageviews.pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
order by 1,2)
AS pageview_level

Group by website_session_id;

select * from session_level_made_it_flags_demo1;

select
	count(distinct website_session_id) AS sessions,
    	count(distinct case when product_made_it=1 THEN website_session_id ELSE NULL END),
		count(distinct case when mrfuzzy_made_it=1 THEN website_session_id ELSE NULL END),
		count(distinct case when cart_made_it=1 THEN website_session_id ELSE NULL END) ,
		count(distinct case when shipping_made_it=1 THEN website_session_id ELSE NULL END),
		count(distinct case when billing_made_it=1 THEN website_session_id ELSE NULL END),
		count(distinct case when thankyou_made_it=1 THEN website_session_id ELSE NULL END) 
from session_level_made_it_flags_demo1;

select
	count(distinct website_session_id) AS sessions,
    	count(distinct case when product_made_it=1 THEN website_session_id ELSE NULL END)
			/count(distinct website_session_id) AS lander_CTR,
		count(distinct case when mrfuzzy_made_it=1 THEN website_session_id ELSE NULL END) 
            /count(distinct case when product_made_it=1 THEN website_session_id ELSE NULL END) AS products_CTR,
		count(distinct case when cart_made_it=1 THEN website_session_id ELSE NULL END) 
			/count(distinct case when mrfuzzy_made_it=1 THEN website_session_id ELSE NULL END)AS cart_CTR ,
		count(distinct case when shipping_made_it=1 THEN website_session_id ELSE NULL END) 
                /count(distinct case when cart_made_it=1 THEN website_session_id ELSE NULL END)AS shipping_CTR,
		count(distinct case when billing_made_it=1 THEN website_session_id ELSE NULL END) 
                /count(distinct case when shipping_made_it=1 THEN website_session_id ELSE NULL END) AS billing_CTR,
		count(distinct case when thankyou_made_it=1 THEN website_session_id ELSE NULL END) 
                /count(distinct case when billing_made_it=1 THEN website_session_id ELSE NULL END) AS thankyou_CTR
from session_level_made_it_flags_demo1;

#analyzing conversion funnel test
select
	MIN(website_pageviews.website_pageview_id) AS first_created_at
from website_pageviews
where pageview_url = '/billing-2'; 

select 
	 website_pageviews.website_session_id,
     website_pageviews.pageview_url AS billing_version,
     orders.order_id
from website_pageviews
	Left join orders
    on website_pageviews.website_session_id = orders.website_session_id
Where website_pageviews.website_pageview_id>= 52550
	AND website_pageviews.created_at < '2012-11-10'
    AND  website_pageviews.pageview_url in ('/billing','/billing-2');


select
	 billing_version,
     count(distinct website_session_id) AS sessions,
     count(distinct order_id) AS orders,
     count(distinct order_id)/ count(distinct website_session_id) AS billing_to_order_rt
     
from(
select 
	 website_pageviews.website_session_id,
     website_pageviews.pageview_url AS billing_version,
     orders.order_id
from website_pageviews
	Left join orders
    on website_pageviews.website_session_id = orders.website_session_id
Where website_pageviews.website_pageview_id>= 52550
	AND website_pageviews.created_at < '2012-11-10'
    AND  website_pageviews.pageview_url in ('/billing','/billing-2'))
AS billing_session_w_orders

Group by 1;


select
	count(distinct website_session_id) AS sessions,
    	count(distinct case when product_made_it=1 THEN website_session_id ELSE NULL END)
			/count(distinct website_session_id) AS lander_CTR,
		count(distinct case when mrfuzzy_made_it=1 THEN website_session_id ELSE NULL END) 
            / count(distinct case when product_made_it=1 THEN website_session_id ELSE NULL END)AS products_CTR,
		count(distinct case when cart_made_it=1 THEN website_session_id ELSE NULL END) 
			/count(distinct case when mrfuzzy_made_it=1 THEN website_session_id ELSE NULL END) 
from session_level_made_it_flags_demo;

#
select
	MIN(Date(created_at)) AS week_start_date,
    COUNT(website_sessions.website_session_id) AS total_sessions,
    COUNT(CASE WHEN website_sessions.utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(CASE WHEN website_sessions.utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_sessions
from website_sessions
where website_sessions.created_at > '2012-08-22'
	  AND website_sessions.created_at < '2012-11-29'
      AND utm_campaign = 'nonbrand'
group by YEARWEEK(created_at);

select 
	 utm_source,
     COUNT(website_sessions.website_session_id) AS total_sessions,
     COUNT(CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
     COUNT(CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END)/ COUNT(website_sessions.website_session_id) AS pct_mobile
from website_sessions
where website_sessions.created_at > '2012-08-22'
	  AND website_sessions.created_at < '2012-11-30'
      AND utm_campaign = 'nonbrand'
Group by 1;

select device_type,
	   utm_source,
       COUNT(website_sessions.website_session_id) AS total_sessions,
       COUNT(distinct orders.order_id) AS orders,
       COUNT(distinct orders.order_id)/COUNT(website_sessions.website_session_id) AS cov_rate
from website_sessions
	Left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at > '2012-08-22'
	  AND website_sessions.created_at < '2012-09-19'
      AND utm_campaign = 'nonbrand'
      Group by 1,2;
      
select 
MIN(Date(created_at)) AS week_start_date,
COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS g_dtop_sessions,
COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS b_dtop_sessions,
COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END)
/COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END)
 AS b_pct_of_g_dtop,

COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END)AS g_mob_sessions,
COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS b_mob_sessions,
COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END)
/COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS b_pct_of_g_mob

from website_sessions
where website_sessions.created_at > '2012-11-04'
	  AND website_sessions.created_at < '2012-12-22'
      AND utm_campaign = 'nonbrand'
Group by YEARWEEK(created_at) ;

#
select  YEAR( website_sessions.created_at) As yr,
		Month( website_sessions.created_at) AS mo,
        count(distinct  website_sessions.website_session_id) AS sessions,
        count(distinct order_id) AS orders
from  website_sessions 
left join orders
	on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2013-01-01'
group by 1,2;

select  YEAR( website_sessions.created_at) As yr,
		week( website_sessions.created_at) AS wk,
        MIN(DATE(website_sessions.created_at)) AS week_start,
        count(distinct  website_sessions.website_session_id) AS sessions,
        count(distinct order_id) AS orders
from  website_sessions 
left join orders
	on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2013-01-01'
group by 1,2;

#
select
	HOUR(website_sessions.created_at),
    weekday(website_sessions.created_at) AS wkd,
    CASE WHEN weekday(website_sessions.created_at) = 0 THEN 'Monday'
		 WHEN weekday(website_sessions.created_at) = 1 THEN 'Tuesday'
		 ELSE 'the_otherday'
    END AS 'mon'
from  website_sessions 
left join orders
	on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at between '2012-09-15'and '2012-11-15';

