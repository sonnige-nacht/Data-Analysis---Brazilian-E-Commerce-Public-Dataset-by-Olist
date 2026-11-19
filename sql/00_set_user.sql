-- 1. Create a new user (Role with login capability and password)
CREATE ROLE iman WITH LOGIN PASSWORD '1234';

-- 2. Set 'iman' as the official owner of the 'olist_db' database
ALTER DATABASE olist_db OWNER TO iman;

-- 3. Set 'iman' as the official owner of the 'olist_dw' database
ALTER DATABASE olist_dw OWNER TO iman;