#!/bin/sh
set -eu

# Function: write_file()

write_file() {
    echo "${FIRST_LINE}"                                                      > ${OUTFILE}
    echo "// Created by make-go-github-file.yaml on $(date)"                >> ${OUTFILE}
    echo "package ${INPUT_PACKAGE}"                                          >> ${OUTFILE}
    echo ""                                                                  >> ${OUTFILE}
    echo "var githubDate            string = \"${RELEASE_DATE}\""            >> ${OUTFILE}
    echo "var githubIteration       string = \"${RELEASE_ITERATION}\""       >> ${OUTFILE}
    echo "var githubRef             string = \"refs/tags/${NEXT_VERSION}\""  >> ${OUTFILE}
    echo "var githubRefName         string = \"${NEXT_VERSION}\""            >> ${OUTFILE}
    echo "var githubRepository      string = \"${GITHUB_REPOSITORY}\""       >> ${OUTFILE}
    echo "var githubRepositoryName  string = \"${RELEASE_REPOSITORY_NAME}\"" >> ${OUTFILE}
    echo "var githubVersion         string = \"${NEXT_VERSION}\""            >> ${OUTFILE}
    echo ""                                                                  >> ${OUTFILE}
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

# Input parameters.

INPUT_FILENAME=$1
INPUT_PACKAGE=$2

echo "  Input parameters: $@"
echo "Requested filename: ${INPUT_FILENAME}"
echo "Requested  package: ${INPUT_PACKAGE}"

# Apply hotfix for 'fatal: unsafe repository' error.

git config --global --add safe.directory "${GITHUB_WORKSPACE}"

# Required git configuration.

git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"

# Change directory to git repository.

cd "${GITHUB_WORKSPACE}" || exit

# Synthesize variables.

RELEASE_REPOSITORY_NAME=$(basename ${GITHUB_REPOSITORY})
RELEASE_ITERATION="0"
RELEASE_DATE=$(date +%Y-%m-%d)
OUTFILE="${GITHUB_WORKSPACE}/${INPUT_FILENAME}"

# Calculate next semantic version.

VERSION="${GITHUB_REF_NAME}"
VERSION="${VERSION#[vV]}"
VERSION_MAJOR="${VERSION%%\.*}"
VERSION_MINOR="${VERSION#*.}"
VERSION_MINOR="${VERSION_MINOR%.*}"
VERSION_PATCH="${VERSION##*.}"
NEXT_VERSION_PATCH=$((1+${VERSION_PATCH}))

echo "Version: ${VERSION}"
echo "Version      [major]: ${VERSION_MAJOR}"
echo "Version      [minor]: ${VERSION_MINOR}"
echo "Version      [patch]: ${VERSION_PATCH}"
echo "Version [next-patch]: ${NEXT_VERSION_PATCH}"

NEXT_VERSION="${VERSION_MAJOR}.${VERSION_MINOR}.${NEXT_VERSION_PATCH}"
NEXT_BRANCH_NAME="make-go-github-file.yaml/${NEXT_VERSION}"

# Check if file is already up-to-date.

FIRST_LINE="// ${NEXT_VERSION}"

if [ -f ${OUTFILE} ]; then
    EXISTING_FIRST_LINE=$(head -n 1 ${OUTFILE})
    if [ "${FIRST_LINE}" = "${EXISTING_FIRST_LINE}" ]; then
        echo "${OUTFILE} is up to date. No changes needed."
        exit 0
    fi
fi

#------------------------------------------------------------------------------
# Make a Pull Request for main branch.
#------------------------------------------------------------------------------

# Make a new branch.

echo ">>>>>>>> git checkout -b \"${NEXT_BRANCH_NAME}\""
git checkout -b "${NEXT_BRANCH_NAME}"
git status

# Write the file into the branch.

write_file

# Inspect the file.

echo ""
echo "Contents of ${OUTFILE}:"
echo ""
cat ${OUTFILE}

# Commit the file to the branch and push branch to origin.

echo ">>>>>>>> git add ${OUTFILE}"
git add ${OUTFILE}
git status

echo ">>>>>>>> git commit -m \"make-go-github-file.yaml updated ${INPUT_FILENAME} for versioned release: ${NEXT_VERSION}\""
git commit -m "make-go-github-file.yaml updated ${INPUT_FILENAME} for versioned release: ${NEXT_VERSION}"
git status

echo ">>>>>>>> git push --set-upstream origin \"${NEXT_BRANCH_NAME}\""
git push --set-upstream origin "${NEXT_BRANCH_NAME}"
git status

# Create a Pull Request for the branch.

echo ">>>>>>>> gh pr create --head \"${NEXT_BRANCH_NAME}\" --title \"make-go-github-file.yaml updated ${INPUT_FILENAME} for versioned release: ${NEXT_VERSION}\"  --body \"make-go-github-file.yaml updated ${INPUT_FILENAME} for versioned release: ${NEXT_VERSION}\""
gh pr create \
    --head "${NEXT_BRANCH_NAME}" \
    --title "make-go-github-file.yaml: ${INPUT_FILENAME}@${NEXT_VERSION}" \
    --body "make-go-github-file.yaml updated ${INPUT_FILENAME} for versioned release: ${NEXT_VERSION}"

echo ">>>>>>>> Done"

