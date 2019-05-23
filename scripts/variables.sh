#!/bin/bash
#set -eou pipefail

BASE=jdk8s3
LOCATION=eastus
SUB='ca-jessde-demo-test'
CLUSTER_NAME=jdk8s3
NODECOUNT=3

function base() 
{
    local  base=$BASE
    echo "$base"
}

function rg()
{
    local rg=$(base)
    echo "$rg"

}
function location() 
{
    local  location=$LOCATION
    echo "$location"
}
function subscription() 
{
    local  subscription=$SUB
    echo "$subscription"
}
function rgfunc()
{
    local rgfunc=$(rg)-func
    echo "$rgfunc" 
}

function clustername()
{
    local clustername=$CLUSTER_NAME
    echo "$clustername"
}
function nodecount()
{
    local nodecount=$NODECOUNT
    echo "$nodecount"
}
