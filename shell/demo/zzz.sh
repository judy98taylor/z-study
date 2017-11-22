#!/bin/bash
save=$1
function t {
    # git pull --tags > /dev/null 2>&1
    # git pull

    #mkdir ttt
    cd /Users/luckyzd/www/activity-mi-com
		$1=${pwd}
		echo ${save}
    #open .
}
t
