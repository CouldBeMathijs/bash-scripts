#!/usr/bin/env bash

birth_install=$(stat -c %W /)
current=$(date +%s)

mode="days"

while getopts "yd" opt; do
    case ${opt} in
        y) mode="detailed" ;;
        d) mode="days" ;;
        *) echo "Usage: $0 [-d] [-y]" >&2; exit 1 ;;
    esac
done

if [ "$mode" = "days" ]; then
    time_progression=$((current - birth_install))
    days_difference=$((time_progression / 86400))
    echo "${days_difference} days"
else
    birth_Y=$((10#$(date -d "@$birth_install" +%Y)))
    birth_M=$((10#$(date -d "@$birth_install" +%m)))
    birth_D=$((10#$(date -d "@$birth_install" +%d)))

    curr_Y=$((10#$(date -d "@$current" +%Y)))
    curr_M=$((10#$(date -d "@$current" +%m)))
    curr_D=$((10#$(date -d "@$current" +%d)))

    years=$((curr_Y - birth_Y))
    months=$((curr_M - birth_M))
    days=$((curr_D - birth_D))

    if [ $days -lt 0 ]; then
        months=$((months - 1))
        days_in_prev_month=$(date -d "${curr_Y}-${curr_M}-01 - 1 day" +%d)
        days=$((days + 10#$days_in_prev_month))
    fi

    if [ $months -lt 0 ]; then
        years=$((years - 1))
        months=$((months + 12))
    fi

    echo "${years} years, ${months} months, ${days} days"
fi
