# GitHub Notes

**The Procedure:**

- Hop on the master branch
- Type 'git branch'
- If master is not green then type 'git checkout master'
- Type 'git pull' to grab all of the latest changes
- Type 'git fetch' to grab all of the latest branches
- Copy the folder into a development folder
- Do all your work in that development folder
- When you are done with your work go back to the terminal and master branch and type 'git pull'
- Hop on to your own branch by typing 'git checkout -b YourBranchName'
- Paste your development folder into the folder associated with your branch
- Type 'git status' to see your changes (they should be red)
- Type 'git add -A' to add all of the tracked and untracked files and folders
- Type 'git status' to make sure all the files are green
- Type 'git commit -m "What you did in past tense"
- Type 'git push' to push your local repository to GitHub
- If you run into an error that says you do not have a set origin, copy the recommended code it gives you and type 'git push' again
- Type 'git pull origin master' to pull master through your branch
- Go on GitHub and switch to your branch on the website
- Check the differences between your branch and master
- If it looks right open a pull request
- Let the group know you opened a pull request and if they say it looks good confirm the pull request
- Repeat step 1

**If there are merge conflicts at any point push your branch up and message the group**
