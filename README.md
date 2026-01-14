# Preprocessing and Segmentation

The Preprocessing and Segmentation component focuses on transforming raw EEG recordings into structured, analysis ready datasets. It includes dataset specific segmentation scripts and reusable preprocessing functions.

**Segmentation: NATO Alphabet Imagined Speech Experiment**

This subsection contains a dedicated file for segmenting EEG recordings from the NATO alphabet imagined speech experiment. The script:

•	Parses recorded LSL markers corresponding to individual NATO alphabet prompts.

•	Extracts time locked EEG epochs associated with imagined speech intervals.

•	Organizes segmented trials into a structured format suitable for machine learning and statistical analysis.

The segmentation logic is parameterized, allowing adjustments to epoch lengths, baseline periods, and class definitions.

**Segmentation: English–Greek Imagined Speech Dataset**

A separate segmentation file is provided for the English–Greek imagined speech dataset. This script accounts for dataset specific characteristics, including:

•	Language dependent prompt labeling.

•	Potential differences in trial structure or timing.

•	Harmonized output formatting to ensure compatibility with shared preprocessing and analysis pipelines.

By maintaining separate segmentation scripts, the repository preserves clarity while supporting heterogeneous experimental designs.

Preprocessing Functions

The repository includes a collection of reusable preprocessing functions applied consistently across datasets. These functions address common EEG signal conditioning requirements, including:

•	Artifact Subspace Reconstruction (ASR): Automated detection and attenuation of high variance artifacts, improving signal quality while preserving neural information.

•	FORCe based preprocessing: Advanced signal conditioning methods aimed at enhancing robustness and consistency across sessions and subjects.

Additional standard preprocessing steps (e.g., filtering, re referencing, normalization) are implemented in a modular fashion, allowing users to enable, disable, or customize each step as needed.
