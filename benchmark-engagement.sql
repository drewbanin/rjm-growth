WITH events AS (
	SELECT * from atomic.events WHERE page_url ILIKE '%/resources/reports/the-state-of-data-science%'
),
users AS (
	SELECT distinct domain_userid from events
),
page_pings AS (
	SELECT * from events where events.event = 'page_ping'
),
max_y_pos AS (
	SELECT domain_userid, max(pp_yoffset_max) max_y from page_pings group by 1
),
time_on_site AS (
	-- jitter points on plot
	SELECT domain_userid, (count(*) * 10) + random() * 10 - 5 time_on_site from page_pings group by 1
),
signups AS (
	SELECT distinct domain_userid FROM events WHERE event = 'unstruct' AND unstruct_event LIKE '%submit_form%'
)
SELECT users.domain_userid, max_y_pos.max_y, time_on_site.time_on_site,
		CASE WHEN signups.domain_userid IS NULL THEN 0 ELSE 1 END as signed_up
	FROM users
	LEFT OUTER JOIN max_y_pos ON max_y_pos.domain_userid = users.domain_userid
	LEFT OUTER JOIN time_on_site ON time_on_site.domain_userid = users.domain_userid
	LEFT OUTER JOIN signups ON signups.domain_userid = users.domain_userid
