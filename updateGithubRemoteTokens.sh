#!/bin/bash

# this is a script I can use to replace lots of personal access tokens at once. When they expire it's a pain;
# this makes it slightly less of a pain.
#
# Example, if I run "git remote -v" for this shellScripts repo I see something like:
# [tfeiler@ICF shellScripts]$ git remote -v
# origin  https://FakeTomUserName:abc_fakeaccess@github.com/FakeTomUserName/shellScripts.git (fetch)
# origin  https://FakeTomUserName:abc_fakeaccess@github.com/FakeTomUserName/shellScripts.git (push)
# 
# "FakeTomUserName:abc_fakeaccess" is the token - if I'm moving away from that, put that into OLD_TOKEN and my new one into NEW_TOKEN.
#
# (ICF repos typically don't have that username bit for whatever reason, but my personal ones do)
#
# TODO - add instrux on how to make a new token?

echo "this was last run July 28, 2025 - recompute candidate_paths, update OLD/REPLACEMENT_TOKEN before running again, spotcheck a few using DRY_RUN==1, etc.!"
exit 1

# ICF Corporate Github repos
# OLD_TOKEN="REDACTED"
# REPLACEMENT_TOKEN="REDACTED"

# ICF Corporate Github repos owned by tom
# OLD_TOKEN="REDACTED"
# REPLACEMENT_TOKEN="REDACTED"

# DookTibs personal account
# OLD_TOKEN="REDACTED"
# REPLACEMENT_TOKEN="REDACTED"

# tfeiler-icf token -- used for things like EPA HAWC repo
# OLD_TOKEN="REDACTED"
# REPLACEMENT_TOKEN="REDACTED"

# set to 1 to just preview what would happen...
DRY_RUN=1


echo "CHECKING DIRS FOR REPOS THAT USE TOKEN '$OLD_TOKEN'..."
echo "REPLACE ORIGIN WITH new token '$REPLACEMENT_TOKEN'..."
echo "----------------------------------------------------------------"

cd /Users/38593/development/

# to get fresh version of this list, run cmd like:
# "cd ~/development/ && find . -path ./archives -prune -o -name '.git' -print"
#
candidate_paths=(
	"./file_renamer/.git"
	"./configurations/.git"
	"./shellScripts/.git"
	"./trim-builder/.git"
	"./hawc_tagging/.git"
	"./hawc_tagging_preparer/.git"
	"./tools/Neovim-from-scratch/.git"
	"./tools/sack/.git"
	"./tools/show-struct/.git"
	"./lfc/unsynced/azure-samples-python-management/.git"
	"./lfc/.git"
	"./nhtsa/nhtsa-aq/.git"
	"./debuggerVimBridge/.git"
	"./TO117_TASK6_genAiStudyEval/.git"
	"./litemcee/litmc-online/.git"
	"./dorothy/.git"
	"./hawc_visual_postprocessing/.git"
	"./cebs/.git"
	"./cebs/docx/.git"
	"./stitcher/.git"
	"./epa-jira-automation/.git"
	"./diceware/.git"
	"./json_pruner/.git"
	"./distiller_utils/.git"
	"./llr/llrsim/.git"
	"./llr/pyscaffold/.git"
	"./docterOnline/.git"
	"./expoagg-pipeline/.git"
	"./asreview_experiments/asreview/.git"
	"./cphea-doc-production/.git"
	"./TO117_TASK5_dashboard/.git"
	"./pyshiny_components/temp/pdfjs-viewer/.git"
	"./pyshiny_components/temp/pdfjs_from_git/.git"
	"./pyshiny_components/.git"
	"./langqs-cdk/.git"
	"./genai/CW-long-csv-chatbot/.git"
	"./genai/qanda/.git"
	"./genai/azure_pdf_to_text/.git"
	"./langqs/unsynced/streamlit_helloworld/ip-info-checker/.git"
	"./langqs/.git"
	"./icf_dragon/unsynced/archived/awsUtils/viz/aws-map/.git"
	"./icf_dragon/unsynced/archived/awsUtils/viz/graphviz-aws/.git"
	"./icf_dragon/unsynced/archived/20210728_usageReportJustInCase/lambda/awslambda-psycopg2/.git"
	"./icf_dragon/.git"
	"./langqs_frontend/.git"
	"./hawc_project/hawc2025/.git"
	"./hawc_project/AWS_GENAI_DEMO/aws_poc_deliverables_from_bucket/tomtemp/.git"
	"./hawc_project/AWS_GENAI_DEMO/aws_poc_deliverables_from_bucket/epa-study-review/.git"
	"./hawc_project/epiv2_workarea/PCP_CROSSWALKING/.git"
	"./hawc_project/_hawc_from_old_laptop/.git"
	"./hawc_project/_hawc_2024_stopped_working_but_might_have_interesting_branches/.git"
	"./hawc_project/hawc-deploy-demo/.git"
	"./picnic/.git"
)

x=0
for cp in "${candidate_paths[@]}"
do
	repo_data=`cat $cp/config | grep "url.*=.*https://${OLD_TOKEN}@github.com" | sed 's-.*@github.com\(.*\)-\1-'`

	if [[ $repo_data != "" ]]; then
		# sanity check; is that for "origin"?
		git -C $cp/.. remote -v | grep -q "origin.*https://${OLD_TOKEN}@github.com${repo_data} (fetch)"

		if [[ $? -eq 0 ]]; then
			echo "$cp uses the token to access '$repo_data'; update!"

			if [[ $DRY_RUN -eq 1 ]]; then
				echo "NOT RUNNING: 'git -C $cp/.. remote set-url origin https://${REPLACEMENT_TOKEN}@github.com${repo_data}'"
			else
				git -C $cp/.. remote set-url origin https://${REPLACEMENT_TOKEN}@github.com${repo_data}

				if [[ $? -eq 0 ]]; then
					echo "     successfully updated!"
				else
					echo "     unknown error - check this one!"
				fi
			fi

		else
			echo "(skipping $cp - failed sanity check)"
		fi
	else
		echo "(skipping $cp - doesn't use token)"
	fi


	x=$(($x+1))

	if [ $x -gt 500 ];
	then
		echo "BREAKING EARLY"
		break
	fi
done

echo "done!"

