#!/usr/bin/env bash

program="$0"
program_name="${0##*/}"

#Find the original program we're wrapping
OPATH="$PATH"
while [ "$program" == "$0" ]; do
    PATH="${PATH#*:}"
    program="$(which $program_name 2> /dev/null)"
done
PATH=$OPATH

#Generate coverage raw data
if [ -n "$ACS_COVERAGE" ]; then
    if [ -z "program" ]; then
        echo "Program '$program_name' not found. It was called with parameters: '$@'"
        exit 1
    fi

    #Define Python site-packages according to ACSROOT/INTLIST/INTROOT
    if [ -n "$ACSROOT" ]; then
        SPATH="$ACSROOT/${PYTHON_SITE_PACKAGES}"
    fi
    if [ -n "$INTLIST" ]; then
        for int in ${INTLIST//:/ }; do
            SPATH="$int/${PYTHON_SITE_PACKAGES},$SPATH"
        done
    fi
    if [ -n "$INTROOT" ]; then
        SPATH="$INTROOT/${PYTHON_SITE_PACKAGES},$SPATH"
    fi

    #Find .coveragerc on ACS installation areas
    RCFILE=$(searchFile config/.coveragerc)
    [[ ! "$RCFILE" == "#error#" ]] && RCFILE="--rcfile $RCFILE/config/.coveragerc" || RCFILE=

    #Run appropriate wrapped coverage command
    if [ "$program_name" == "nose2" ]; then
        coverage run $RCFILE --source $SPATH -p -m $program_name "$@"
    elif [ "$program_name" == "python" ]; then
        if [ "$1" == "-V" ]; then
            "$program" "$@"
        else
            if [ "$1" == "-c" ]; then
                script=/tmp/coverage_cmd.$RANDOM.py
                echo "$2" > $script
                shift 2
                set -- $script "$@"
            fi
            coverage run $RCFILE --source $SPATH -p "$@"
        fi
    elif [ "$program_name" == "java" ]; then
        if [ -n "$ACS_JCOV_SAVER_JAR" -a -f "$ACS_JCOV_SAVER_JAR" ]; then
            newparams=()
            unset cparg
            unset cpargfound
            for param; do
                if [ -n "$cparg" ]; then
                    newparams+=("$ACS_JCOV_SAVER_JAR:$param")
                    cpargfound=true
                    unset cparg
                    continue
                fi
                [[ $param == '-cp' || $param == '-classpath' ]] && cparg=true
                newparams+=("$param")
            done
            if [ -z "$cpargfound" -a -z "$CLASSPATH" ]; then
                newparams=("-cp" "$ACS_JCOV_SAVER_JAR" "${newparams[@]}")
            elif [ -z "$cpargfound" ]; then
                export CLASSPATH="$ACS_JCOV_SAVER_JAR:$CLASSPATH"
            fi
            set -- "${newparams[@]}"
            "$program" "$@"
        elif [ -n "$ACS_JCOV_JAR" -a -f "$ACS_JCOV_JAR" ]; then
            "$program" -javaagent:$ACS_JCOV_JAR=grabber "$@"
        else
            "$program" "$@"
        fi
    else
        echo "Unhandled program '$program_name' called with parameters: '$@'"
        "$program" "$@"
    fi
else
    "$program_name" "$@"
fi
