#!/usr/bin/env bash

set -euf -o pipefail

TAG=${1:-}

if ! command -v git-cliff &>/dev/null; then
	echo "git-cliff is not installed. Run 'cargo install git-cliff' to install it"
fi

if [ -z "${TAG}" ]; then
	echo "Please provide a tag."
	echo "Usage: ./release.sh v[X.Y.Z]"
	exit
fi

echo "Preparing ${TAG}..."
# update the changelog
git-cliff --config cliff.toml --tag "${TAG}" >CHANGELOG.md
git add -A &&
	git -c user.name="Kristoffer Winther Balling" \
		-c user.email="balling_cc@k.wbnet.dk" \
		-c user.signingkey="830658948EB172F0!" \
		commit -m "chore(release): prepare for ${TAG}"
git show
# generate a changelog for the tag message
export GIT_CLIFF_TEMPLATE="\
	{% for group, commits in commits | group_by(attribute=\"group\") %}
	{{ group | upper_first }}\
	{% for commit in commits %}
		- {% if commit.breaking %}(breaking) {% endif %}{{ commit.message | upper_first }} ({{ commit.id | truncate(length=7, end=\"\") }})\
	{% endfor %}
	{% endfor %}"
changelog=$(git-cliff --config cliff_tag.toml --unreleased --strip all)
# create a signed tag
git -c user.name="Kristoffer Winther Balling" \
	-c user.email="balling_cc@k.wbnet.dk" \
	-c user.signingkey="830658948EB172F0!" \
	tag -s -a "${TAG}" -m "Release ${TAG}" -m "$changelog"
git tag -v "${TAG}"
echo "Done!"
echo "Now push the commit (git push) and the tag (git push --tags)."
