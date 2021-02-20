# DON'T TOUCH THE IF SENTENCE. Validating the number of parameters. You have to edit nothing

if [ $# -lt 2 ]; then
   echo Invalid number of parameters
   exit 1
fi

# Run a command on the left to check that the folder .git exists
# 
#rev-parse --is-inside-work-treeworking tree, meaning the location where the repository has been checked out 
#rev-parse --git-dir working directory where git status command is run
 
 git rev-parse --is-inside-work-tree &> /dev/null

# DON'T TOUCH THE IF SENTENCE. Validating that we are in a git folder

if [ $? -gt 0 ]; then
   echo Your current folder does not contain a Git repository
   exit 2
fi

# Run a command between `` to get the URL of your remote GitHub repository

url=`git config --get remote.origin.url`


# DON'T TOUCH THE IF SENTENCE. Validating that your repository is synchronized with GitHub

if [ -z "$url" ]; then
   echo No remote URL from GitHub
   exit 3
fi

# Variables to store the arguments

main=$1
new_branch=$2

# Run a command on the left to check out your main/master branch
# Switch to main branch

git checkout main &> /dev/null

# DON'T TOUCH THE IF SENTENCE. Validating the main or master exists

if [ $? -gt 0 ]; then
   echo Your main/master branch does not exist
   exit 4
fi

# Checking if the branc already exits
# If true will exit (necessary because if the script is run again will delete
# all main content and creates the folder named $2
# If not exists, will creates the ne nuew branch named $2 based on main

if [ `git branch --list $2` ]; then
   echo Branch name $2 already exists.
   exit 5
else 
	git checkout -b $2

fi

#Removing tracked files from the branch (Git index). Additionally, can be used 
#to remove files from both the staging index and the working directory.
#removing files copied from main

git rm -rf *

#Variable to create the folder and file
FILE=./$2/testfile.text

#Create de foleder and file

mkdir -p "$(dirname "$FILE")" && touch "$FILE"

#mkdir $2
#cd $2
#touch $2/testfile.txt

#Adding a change in the working directory to the staging area.
#It can also speciefied hich update to include update in the next commit
# * all changes

git add *

#Saving changes to the local repository
#-m "message "
 
git commit -m "New  branch  called $2"

#Host github.com 
#HostName github.com 
#User rblaper 
#IdentityFile ~/.ssh/id_ed25519.pub

# Pushing changes
# origin is usually used only where there are multiple remote repository and 
# it is needed to specify which remote repository should be used 

git push origin $2

#For testing purpose
#git checkout $1
