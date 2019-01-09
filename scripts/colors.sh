#!/usr/bin/env bash

# CLI color functions
function red()
{
    printf "\e[31m"
}

function bold()
{
    printf "\e[1m"
}

function green()
{
    printf "\e[32m"
}

function yellow()
{
    printf "\e[33m"
}

function blue()
{
    printf "\e[34m"
}

function grey()
{
    printf "\e[37m"
}

function regular()
{
    printf "\e[m"
}
