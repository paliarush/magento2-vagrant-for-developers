#!/usr/bin/env bash

# CLI color functions
function red()
{
    tput setaf 1
}

function bold()
{
    tput bold
}

function green()
{
    tput setaf 2
}

function yellow()
{
    tput setaf 3
}

function yellow_background()
{
    tput setab 3
}

function blue()
{
    tput setaf 4
}

function magenta()
{
    tput setaf 5
}

function cyan()
{
    tput setaf 6
}

function grey()
{
    tput setaf 7
}

function grey_background()
{
    tput setab 7
}

function regular()
{
    tput sgr0
}
