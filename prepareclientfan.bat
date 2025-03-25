@echo off

REM Check if the version argument is provided
if "%1" == "" (
    echo Usage: %0 ^<version_number^> [upstream_branch]
    echo Example: %0 1.2.3 main
    echo Example: %0 1.2.3 develop
    exit /b 1
)

set VERSION=%1
set JQ_PATH=d:\workspace\gitea\jq-win64.exe
set PACKAGE_JSON=package.json
set PACKAGE_NEW_JSON=package-new.json
set UPSTREAM_BRANCH=master
if "%2" NEQ "" set UPSTREAM_BRANCH=%2 REM Allow override from command line.
set BRANCHES=obelisk fanedition

echo Current Version: %VERSION%
echo Upstream Branch: %UPSTREAM_BRANCH%
echo.

REM 0.  Go to master and remove uncommitted changes
echo 0.  Going to master branch and removing uncommitted changes...
git checkout master
git reset --hard
if errorlevel 1 goto error


REM 1. Go to master branch, pull changes from server
echo 1. Going to master branch and pulling changes...
git checkout master
git pull origin master
if errorlevel 1 goto error

REM 2. Pull also from origin and upstream
echo 2. Pulling from origin and upstream...
git pull origin
git pull upstream %UPSTREAM_BRANCH%
if errorlevel 1 goto error

REM 3. List of branches - removed
REM 4. Go over each branch and pull from origin
echo 4. Pulling from origin for each branch: %BRANCHES%...
for %%B in (%BRANCHES%) do (
    echo    Checking out and pulling branch %%B
    git stash --quiet
    git checkout %%B
    git pull origin %%B
    if errorlevel 1 goto error
    git stash pop
    if errorlevel 1 (
        echo    Conflict after stash pop on branch %%B.  Manual resolution required.
        pause
        git add .
        git commit -m "Merged changes after stash pop on %%B"
        if errorlevel 1 goto error
    )
)

REM 5. Create new branch with the provided argument
echo 5. Creating new branch %VERSION%...
git checkout -b %VERSION%
if errorlevel 1 goto error

REM 6. Go to master
echo 6. Going to master branch...
git checkout master
if errorlevel 1 goto error

REM 7. Create new branch (likely for release)
echo 7. Creating new branch release-%VERSION%...
git checkout -b release-%VERSION%
if errorlevel 1 goto error

REM 8. Merge with all branches in the list
echo 8. Merging branches %BRANCHES% into release-%VERSION%...
for %%B in (%BRANCHES%) do (
    echo    Merging branch %%B
    git merge %%B --no-ff
    if errorlevel 1 (
        echo    Merge conflict detected. Pausing for manual resolution.
        pause
        git add .
        echo    Attempting merge again after pause...
        git merge %%B --no-ff
        if errorlevel 1 goto error
    )
)

REM 9. Update package.json
echo 9. Updating package.json...
if not exist "%JQ_PATH%" (
    echo Error: jq not found at %JQ_PATH%
    echo Please make sure jq is installed and the path is correct.
    exit /b 1
)
REM Use a temporary file to handle potential issues with direct redirection.
%JQ_PATH% ".version = \"%VERSION%\"" "%PACKAGE_JSON%" > "%PACKAGE_NEW_JSON%.tmp"
if errorlevel 1 goto error

REM Replace the original file with the new one.  This handles file permissions better.
move /y "%PACKAGE_NEW_JSON%.tmp" "%PACKAGE_JSON%" >nul 2>&1
if errorlevel 1 goto error

echo Done!

goto end

:error
echo An error occurred.  Exiting.
exit /b 1

:end
exit /b 0
