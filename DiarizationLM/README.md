# DiarizationLM

## Overview

Here we open source some functions and tools used in the [DiarizationLM paper](https://arxiv.org/abs/2401.03506).

<img src="resources/DiarizationLM_Bard_demo.gif" alt="demo" width="512"/>

## Disclaimer

**This is NOT an official Google product.**

## Instructions

### Data format

We assume all internal data are stored in JSON files. An example is `testdata/example_data.json`. The field `"utterances"` stores a list of utterances, and in each utterance we have these string fields:

| Field | Description |
| ----- | ----------- |
| `"utterance_id"` | This stores the utterance ID.|
| `"hyp_text"` | This stores the sequence of hypothesis words, but joined but spaces.|
| `"hyp_spk"` | This stores the sequence of hypothesis speakers, but joined but spaces.|
| `"hyp_diarized_text"` | This is the text representation of the hypothesis words and speakers. It can be used for debugging and to build the prompts to LLM.|
| `"ref_*"` | Similar to the `"hyp_*"` fields, but these are ground truth reference, rather than hypothesis.|

### Conversion between representations

In the paper, we mentioned two representations:

1. The word sequence and speaker sequence representation.
2. The pure text representation.

We provide the functions in `utils.py` to convert between these two representations:

* `create_diarized_text()` converts the word and speaker sequences to the pure text representation.
* `extract_text_and_spk()` converts the pure text reprensentation to the word and speaker sequences.

### Transcript-preserving speaker transfer (TPST)

TPST is a critical data processing algorithm used in multiple places in our paper.

A Python implementation is available in `utils.py`, defined as:

```Python
def transcript_preserving_speaker_transfer(
    src_text: str, src_spk: str, tgt_text: str, tgt_spk: str
) -> str
```

### Training data preparation

We provide a Python script `train_data_prep.py` that can be used for preparing the dataset for finetuning LLMs (i.e. the prompt builder module described in the paper). This tool will do these for you:

1. Segment the prompts and completions based on the input and output length limit.
2. Optionally apply prefix and suffix to prompts and completions.
3. Store prompt-completion pairs in different file formats.

The segmentation length, prefix, and suffix are passed in as flags to `train_data_prep.py`. In Python code, they are configured as `PromptOptions` defined in `utils.py`.

We support 3 different output file formats:

| Format | Description |
| ------ | ----------- |
| `tfrecord` | The [TFRecord format](https://www.tensorflow.org/tutorials/load_data/tfrecord) can be used by various machine learning libraries.|
| `csv` | This format can be used by [OpenAI API](https://platform.openai.com/docs/api-reference/) for finetuning GPT models. OpenAI will usually convert these csv files to jsonl files.|
| `json` | This format is more human readable and can be used for debugging. It's also useful for finetuning PaLM models via the [Google Cloud API](https://cloud.google.com/vertex-ai/docs/generative-ai/models/tune-text-models-supervised#text).|

Example command:

```bash
python3 train_data_prep.py \
--input="testdata/example_data.json" \
--output="/tmp/example_data.csv" \
--output_type=csv \
--emit_input_length=1000 \
--emit_target_length=1000 \
--prompt_suffix=" --> " \
--completion_suffix=" [eod]" \
--input_feature_key="prompt" \
--output_feature_key="completion"
```

### Completion parser

During inference, the prompts are send to the LLM, and the LLM will generate the completions. We provide a `postprocess_completions.py` script that serves as the completion parser module as described in the paper. It will:

1. Truncate the completion suffix, and any text generated after this suffix.
2. Concatenate the completions of all segments from the same utterance.
3. Transfer the speakers to the original hypothesis ASR transcript.

## Citation

Our paper is cited as:

```
@article{wang2024diarizationlm,
  title={{DiarizationLM: Speaker Diarization Post-Processing with Large Language Models}},
  author={Quan Wang and Yiling Huang and Guanlong Zhao and Evan Clark and Wei Xia and Hank Liao},
  journal={arXiv preprint arXiv:2401.03506},
  year={2024}
}
```
