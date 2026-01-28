setup:
	cp -n .env.example .env || true
	sed -i "s/^WWWUSER=.*/WWWUSER=$$(id -u)/" .env
	sed -i "s/^WWWGROUP=.*/WWWGROUP=$$(id -g)/" .env
