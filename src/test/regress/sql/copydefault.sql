--
-- COPY DEFAULT
-- this file is responsible for testing DEFAULT option of COPY FROM
--

create temp table copy_default (
	id integer primary key,
	text_value text not null default 'test',
	ts_value timestamp without time zone not null default '2022-07-05'
);

-- if DEFAULT is not specified, then it will behave as a regular COPY FROM
-- to maintain backward compatibility
copy copy_default from stdin;
1	value	'2022-07-04'
2	\D	'2022-07-05'
\.

select id, text_value, ts_value from copy_default;

truncate copy_default;

copy copy_default from stdin with (format csv);
1,value,2022-07-04
2,\D,2022-07-05
\.

select id, text_value, ts_value from copy_default;

truncate copy_default;

-- DEFAULT cannot be used in binary mode
copy copy_default from stdin with (format binary, default '\D');

-- DEFAULT cannot be new line nor carriage return
copy copy_default from stdin with (default E'\n');
copy copy_default from stdin with (default E'\r');

-- DELIMITER cannot appear in DEFAULT spec
copy copy_default from stdin with (delimiter ';', default 'test;test');

-- CSV quote cannot appear in DEFAULT spec
copy copy_default from stdin with (format csv, quote '"', default 'test"test');

-- NULL and DEFAULT spec must be different
copy copy_default from stdin with (default '\N');

-- cannot use DEFAULT marker in column that has no DEFAULT value
copy copy_default from stdin with (default '\D');
\D	value	'2022-07-04'
2	\D	'2022-07-05'
\.

copy copy_default from stdin with (format csv, default '\D');
\D,value,2022-07-04
2,\D,2022-07-05
\.

-- how it handles escaping and quoting
copy copy_default from stdin with (default '\D');
1	\D	'2022-07-04'
2	\\D	'2022-07-04'
3	"\D"	'2022-07-04'
\.

select id, text_value, ts_value from copy_default;

truncate copy_default;

copy copy_default from stdin with (format csv, default '\D');
1,\D,2022-07-04
2,\\D,2022-07-04
3,"\D",2022-07-04
\.

select id, text_value, ts_value from copy_default;

truncate copy_default;

-- successful usage of DEFAULT option in COPY
copy copy_default from stdin with (default '\D');
1	value	'2022-07-04'
2	\D	'2022-07-03'
3	\D	\D
\.

select id, text_value, ts_value from copy_default;

truncate copy_default;

copy copy_default from stdin with (format csv, default '\D');
1,value,2022-07-04
2,\D,2022-07-03
3,\D,\D
\.

select id, text_value, ts_value from copy_default;

truncate copy_default;
