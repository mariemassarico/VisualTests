# Establish a project directory and navigate to it.
mkdir $1
cd $1
# Initialize git and .gitignore
git init
touch .gitignore
echo "cypress.env.json\ncypress/downloads/\nnode_modules/" > .gitignore
# Initialize NPM
npm init -y
# Install Cypress (if a version is specified, it will be installed; otherwise, the latest version will be installed).
if [ "$2" ]; then
  npm i cypress@"$2" -D
else
  npm i cypress -D
fi
# Open Cypress for create your directories
npx cypress open
