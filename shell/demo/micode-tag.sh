#!/bin/bash
function mitag {
    git pull --tags > /dev/null 2>&1
    local branch=$(git branch | sed -n '/\* /s///p')
    if [[ $branch =~ ^testing ]]; then
        local new_tag=$(echo ${branch}-$(date +'%Y%m%d')-$(git tag -l "${branch}-$(date +'%Y%m%d')-*" | wc -l | xargs printf '%02d'))
        echo ${new_tag}
        git tag ${new_tag}
        git push origin $new_tag > /dev/null 2>&1
    elif [[ $branch =~ ^RELEASE ]]; then
        local new_tag=$(echo ${branch}-$(date +'%Y%m%d')-$(git tag -l "${branch}-$(date +'%Y%m%d')-*" | wc -l | xargs printf '%02d'))
        echo ${new_tag}
        git tag ${new_tag}
        git push origin $new_tag > /dev/null 2>&1
    else
        exit 1
    fi

}
mitag
