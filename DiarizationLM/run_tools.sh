#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# Get project path.
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd ${PROJECT_PATH}

python3 train_data_prep.py \
--input=testdata/example_data.json \
--output=/tmp/example_data.tfrecord \
--output_type=tfrecord

python3 postprocess_completions.py \
--input=testdata/example_completion_with_bad_completion.json \
--output=/tmp/example_postprocessed.json

popd
