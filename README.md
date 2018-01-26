# jean_baptiste

Matlab Script (2016b). Computer Science university project.

Analyses sounds using the Fourier Transform. The sound sample might be recorded with a sound interface, uploaded from an audio file or chosen from a small selection (.wav files found in the repository). Firstly, it calculates and plots the frequency spectrum (frequencies vs. relative intensities) from the sound sample. Secondly, it breaks the sound sample into partitions and applies the Fourier Transform to each of them. The script plots this data into a frequencies vs. time vs. relative intensities. This might be the most useful feature as it brings a visual representation on how the partials (harmonics) evolute thorough time. The purpose of this program was to be used in a laboratory to identify possible variations in the pattern depending on the attack mode. Finally, it allows the user to rebuild the sound sample using applying some functions to the data obtained, i.e. applying certain function to the data obtained from the Fourier transform and then use the inverse Fourier Transform to reconstruct the sound.

All sounds used were downloaded from freesounds.org under the Creative Commons License.

Contents:
- fourier.m: Matlab script (comments in Spanish)
- frecHz.mat, nota.mat:  correspondences between frequencies and musical notes, used by the .m script
- .wav files: sound samples 
- informe.pdf: project report handled (Spanish)

Latest version: April 2017
