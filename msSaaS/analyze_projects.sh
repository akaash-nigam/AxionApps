#!/bin/bash
echo "Project,Size,HasPackageJSON,HasDockerfile,HasClientServer,HasGit,Status"
for dir in msSaaS_*/; do
    name=$(basename "$dir")
    size=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
    
    has_pkg="No"
    has_docker="No"
    has_stack="No"
    has_git="No"
    status="Empty"
    
    [ -f "$dir/package.json" ] && has_pkg="Yes"
    [ -f "$dir/Dockerfile" ] && has_docker="Yes"
    [ -d "$dir/client" ] && [ -d "$dir/server" ] && has_stack="Yes"
    [ -d "$dir/.git" ] && has_git="Yes"
    
    if [ "$has_pkg" = "Yes" ] && [ "$has_stack" = "Yes" ]; then
        status="FullStack"
    elif [ "$has_pkg" = "Yes" ]; then
        status="HasCode"
    elif [ -f "$dir/README.md" ]; then
        status="DocsOnly"
    fi
    
    echo "$name,$size,$has_pkg,$has_docker,$has_stack,$has_git,$status"
done
